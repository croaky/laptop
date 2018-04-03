# Create Indexes Concurrently

By default,
Postgres' `CREATE INDEX` locks writes (but not reads) to a table.
That can be unacceptable during a production deploy.
On a large table, indexing can take hours.

Postgres has a [`CONCURRENTLY` option for `CREATE INDEX`][con]
that creates the index without preventing concurrent
`INSERT`s, `UPDATE`s, or `DELETE`s on the table.

[con]: http://www.postgresql.org/docs/9.2/static/sql-createindex.html

## ActiveRecord migrations

To make this option easier to use in migrations, ActiveRecord 4 introduced an
[`algorithm: :concurrently` option for `add_index`][rails].

[rails]: https://github.com/rails/rails/commit/2d33796457b139a58539c890624591c97354d334

Here's an example:

```ruby
class AddIndexToAsksActive < ActiveRecord::Migration
  disable_ddl_transaction!

  def change
    add_index :asks, :active, algorithm: :concurrently
  end
end
```

The caveat is that
[concurrent indexes must be created outside a transaction][transact].
By default, ActiveRecord migrations are run inside a transaction.

[transact]: http://www.postgresql.org/docs/9.2/static/sql-createindex.html#SQL-CREATEINDEX-CONCURRENTLY

So, ActiveRecord 4's [`disable_ddl_transaction!`][disable] method
must be used in combination with
`algorithm: :concurrently` migrations.

[disable]: https://github.com/rails/rails/commit/b337390889cb4a9f80ed08daf072a043f0e7ddf3

The `disable_ddl_transaction!` method applies only to that migration file.
Adjacent migrations still run in their own transactions
and roll back automatically if they fail.
Therefore, it's a good idea to isolate concurrent index migrations
to their own migration files.
