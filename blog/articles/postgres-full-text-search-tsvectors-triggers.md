# Full Text Search with tsvectors and Triggers

Postgres full-text search is awesome
but without tuning, searching large columns can be slow.
Introducing a `tsvector` column to cache [lexemes]
and using a trigger to keep the lexemes up-to-date
can improve the speed of full-text searches.

[lexemes]: http://www.postgresql.org/docs/9.4/static/textsearch-intro.html

This article shows how to accomplish that in Rails.

## Using `pg_search` with Rails

We want our users to search for products.
Let's add the [`pg_search` gem](https://github.com/Casecommons/pg_search)
to our Rails app:

```ruby
gem "pg_search"
```

Then, configure it for our `Product` model:

```ruby
class Product < ActiveRecord::Base
  include PgSearch

  pg_search_scope(
    :search,
    against: %i(
      description
      manufacturer_name
      name
    ),
    using: {
      tsearch: {
        dictionary: "english",
      }
    }
  )
end
```

This example shows configuration for
full-text search of the `products` table's
`description`, `manufacturer`, and `name` columns.
See [Implementing Multi-Table Full Text Search with Postgres in Rails][multi]
for an example of full-text search of multiple tables.

[multi]: https://thoughtbot.com/blog/implementing-multi-table-full-text-search-with-postgres

Our [`pg_search_scope`][scope] is named `:search`,
so we can invoke it with:

[scope]: https://github.com/Casecommons/pg_search#pg_search_scope

```ruby
Product.search("wool")
```

We're explicitly specifying the [`:tsearch`][tsearch] option
(which is the default [Postgres full-text search][default])
in order to use the `english` [dictionary] instead of the default
`simple` dictionary.

[tsearch]: https://github.com/Casecommons/pg_search#tsearch-full-text-search
[default]: http://www.postgresql.org/docs/current/static/textsearch-intro.html
[dictionary]: http://www.postgresql.org/docs/current/static/textsearch-dictionaries.html

## What we get for a SQL query

Wonderful. We have full-text searching set up in minutes.

Now, what does our SQL query look like?

```sql
SELECT products.*
FROM products
INNER JOIN (
  SELECT products.id AS pg_search_id,
  (
    ts_rank(
      (
       to_tsvector('english', coalesce(products.description::text, '')) ||
       to_tsvector('english', coalesce(products.manufacturer_name::text, '')) ||
       to_tsvector('english', coalesce(products.name::text, ''))
      ),
      (
        to_tsquery('english', ''' ' || 'wool' || ' ''')
      ),
      ?
    )
  ) AS rank
  FROM products
  WHERE (
   (
     (
       to_tsvector('english', coalesce(products.description::text, '')) ||
       to_tsvector('english', coalesce(products.manufacturer_name::text, '')) ||
       to_tsvector('english', coalesce(products.name::text, ''))
     ) @@
     (
       to_tsquery('english', ''' ' || 'wool' || ' ''')
     )
   )
  )
) pg_search ON products.id = pg_search.pg_search_id
ORDER BY pg_search.rank DESC
LIMIT 24
OFFSET 0
```

This is all pretty standard SQL plus a few cool functions:
`ts_rank`, `to_tsvector`, and `to_tsquery`.
The `to_tsvector` function in is worth a closer look.
It generates [`tsvector`][tsvector] data types,
which are "a sorted list of distinct lexemes."
Lexemes, in turn, are "words that have been normalized
to make different variants of the same word look alike".

[tsvector]: http://www.postgresql.org/docs/9.4/static/datatype-textsearch.html

For example, given the following product:

```ruby
Product.create(
  description: "Michael Kors",
  name: "Sunglasses",
  manufacturer_name: "Michael Kors"
)
```

The `tsvector` looks like:

```
'kor':2,4,6 'michael':1,3,5 'sunglass':7
```

The resulting lexemes were "normalized to make different variants" by
lowercasing, removing suffixes, etc.
The lexemes were sorted into a list and the numbers represent
the position of the lexeme in the original strings.

For tons of awesome examples and details on these three functions, see
[Postgres full-text search is Good Enough!][good]

[good]: http://blog.lostpropertyhq.com/postgres-full-text-search-is-good-enough/

## Caching `tsvector` lexemes

On a large `products` table,
our searches may be slow.
If so, we have some tuning options.

One option would be to cache the `tsvector`s using a materialized view.
Read [Caching with Postgres materialized views][view] or
[Postgres full-text search is Good Enough!][good] (again)
for more information materialized views with Postgres and Ruby.

[view]: http://www.matchingnotes.com/caching-with-postgres-materialized-views.html

Materialized views may be a good option for your data.
One downside is that the entire view must be refreshed with:

```sql
REFRESH MATERIALIZED VIEW view_name;
```

That may be a good fit in some scenarios,
perhaps run daily as a cron or [Heroku Scheduler] job.
In our case,
we want a cache to be updated
when a `Product` is created or updated.

[Heroku Scheduler]: https://devcenter.heroku.com/articles/scheduler

Let's edit our `pg_search_scope`:

```diff
      using: {
        tsearch: {
+         tsvector_column: "tsv",
        }
      }
```

Since we can't dump a `tsvector` column to `schema.rb`,
we need to switch to the SQL schema format
in our `config/application.rb`:

```ruby
config.active_record.schema_format = :sql
```

Remove the now-unnecessary `db/schema.rb`:

```bash
rm db/schema.rb
```

And generate a migration:

```ruby
class AddTsvectorColumns < ActiveRecord::Migration
  def up
    add_column :products, :tsv, :tsvector
    add_index :products, :tsv, using: "gin"

    execute <<-SQL
      CREATE TRIGGER tsvectorupdate BEFORE INSERT OR UPDATE
      ON products FOR EACH ROW EXECUTE PROCEDURE
      tsvector_update_trigger(
        tsv, 'pg_catalog.english', description, manufacturer_name, name
      );
    SQL

    now = Time.current.to_s(:db)
    update("UPDATE products SET updated_at = '#{now}'")
  end

  def down
    execute <<-SQL
      DROP TRIGGER tsvectorupdate
      ON products
    SQL

    remove_index :products, :tsv
    remove_column :products, :tsv
  end
end
```

This change introduces a `tsv` column of type `tsvector` to search against,
a GIN index on the new column,
a `TRIGGER` on those new columns `BEFORE INSERT OR UPDATE`,
and a backfill `UPDATE` for existing `products`,
to keep the data in sync.

Postgres has a built-in [`tsvector_update_trigger` function][trigger]
to make this easier.

[trigger]: http://www.postgresql.org/docs/9.3/static/textsearch-features.html#TEXTSEARCH-UPDATE-TRIGGERS

The GIN index could alternatively be a GiST index.
See the [GIN vs. GiST tradeoffs][tradeoff].

[tradeoff]: http://www.postgresql.org/docs/9.4/static/textsearch-indexes.html

Here's the resulting query with the new `tsvector`-type column:

```sql
SELECT products.*
FROM products
INNER JOIN (
  SELECT products.id AS pg_search_id,
  (
    ts_rank(
     (products.tsv),
     (to_tsquery('english', ''' ' || 'wool' || ' ''')), 0
    )
  ) AS rank
  FROM products
  WHERE (
    ((products.tsv) @@ (to_tsquery('english', ''' ' || 'wool' || ' ''')))
  )
) pg_search ON products.id = pg_search.pg_search_id
ORDER BY pg_search.rank DESC
LIMIT 24
OFFSET 0
```

We can see that our run-time `to_tsvector` function calls are gone,
and our cached `tsvector` data in the
GIN-indexed `tsv` column are being queried against.

We've now improved the speed of our queries
by introducing a `tsvector` column to cache lexemes.
The trigger will keep the lexemes up-to-date
as `products` are created and updated,
without any daily cron job to run.

Happy searching.
