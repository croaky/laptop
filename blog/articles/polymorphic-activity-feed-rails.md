# Polymorphic Activity Feed

You won't find "polymorphic partials" in Rails' API documentation but the
general programming technique of [polymorphism][poly] can be applied to Rails
partials.

[poly]: http://en.wikipedia.org/wiki/Polymorphism_in_object-oriented_programming

## Activity feed example

Imagine you are signed into an application similar to eBay. You can buy or sell
items on the marketplace. In order to buy an item, you need to bid on it. You
see an activity feed that includes bids, comments, and other things that are
relevant to you.

## Models

We'll use a [polymorphic association][assoc]:

[assoc]: http://api.rubyonrails.org/classes/ActiveRecord/Associations/ClassMethods.html#label-Polymorphic+Associations

```ruby
class Activity < ActiveRecord::Base
  belongs_to :subject, polymorphic: true
  belongs_to :user
end
```

When subjects like `Bid`s and `Comment`s are created, we'll create `Activity`
records that both the seller and bidder will see in their activity feeds.

```ruby
class Bid < ActiveRecord::Base
  belongs_to :item
  belongs_to :user

  after_create :create_activities

  def bidder
    user
  end

  def seller
    item.user
  end

  private

  def create_activities
    create_activity_for_bidder
    create_activity_for_seller
  end

  def create_activity_for_bidder
    Activity.create(
      subject: self,
      name: 'bid_offered',
      direction: 'from',
      user: bidder
    )
  end

  def create_activity_for_seller
    Activity.create(
      subject: self,
      name: 'bid_offered',
      direction: 'to',
      user: seller
    )
  end
end
```

In a production app, we'd create those records in a background job. We've
simplified here for example's sake. The further benefit of creating them in the
background can be seen when we create activities for each of the commenters,
which may be a large number for an active marketplace item:

```ruby
class Comment < ActiveRecord::Base
  belongs_to :item
  belongs_to :user

  after_create :create_activities

  def seller
    item.user
  end

  private

  def create_activities
    (commenters_on_item + [seller]).uniq.each do |user|
      Activity.create(
        subject: self,
        name: 'comment_posted',
        direction: 'to',
        user: user
      )
    end
  end

  def commenters_on_item
    Comment.where(item_id: item.id).map(&:user).uniq
  end
end
```

Now that we have a clean set of activities in a database table,
the SQL lookup is [simple]:

[simple]: http://www.infoq.com/presentations/Simple-Made-Easy

```ruby
class User < ActiveRecord::Base
  has_many :activities

  def recent_activities(limit)
    activities.order('created_at DESC').limit(limit)
  end
end
```

This is the core benefit of structuring our data this way. At runtime, we find
the data via a single indexable foreign key, `user_id`:

```ruby
create_table :activities, do |t|
  t.timestamps null: false
  t.integer :subject_id, null: false
  t.string :subject_type, null: false
  t.string :name, null: false
  t.string: direction, null: false
  t.integer: user_id, null: false
end

add_index :activities, :subject_id
add_index :activities, :subject_type
add_index :activities, :user_id
```

## Anti-pattern

We've seen alternative implementations that look something like this:

```ruby
class User < ActiveRecord::Base
  def recent_activities(limit)
    [comments, items.map(&:comments), bids].
      flatten.
      sort_by(&:created_at).
      first(limit)
  end
end
```

There are a couple of problems with that approach:

* the number of ActiveRecord objects loaded into memory is large
* sorting is done in Ruby, which is slower than SQL

## Controller

We make our fast lookup:

```ruby
@activities = current_user.recent_activities(20)
```

## Polymorphic Rails partials

Now, let's show the activity feed in a view:

```haml
%ul
  - @activities.each do |activity|
    %li.activity
      = render "#{activity.name}_#{activity.direction}_current_user",
        subject: activity.subject
```

Here we render partials with polymorphism. Through the single
`"#{activity.name}_#{activity.direction}_current_user"` interface, we're able
to render multiple partials:

* `bid_offered_to_current_user`
* `bid_offered_from_current_user`
* `comment_posted_to_current_user`

When we write upcoming features, we'll be able to render even more partials
representing many other interactions, using the same structure:

* `bid_accepted_from_current_user`
* `bid_rejected_to_current_user`
* etc.

In turn, each partial is small, contains no conditional logic,
and results in copy text that makes sense for the user's context:

> The Old Man offered a bid of $100 for your Red Ryder BB gun with a compass in
> the stock, and this thing which tells time.

We can style each partial differently,
perhaps showing an image of the items being offered
or the avatars of the users who commented.

Nowhere do we do anything like this:

```haml
%ul
  - @activities.each do |activity|
    %li.activity
      - if activity.subject_type == 'Bid' && activity.direction == 'to'
        = render "bid_offered_to_current_user", subject: activity.subject
      - elsif
        = # ...
```

We've replaced an ugly conditional with polymorphism
and used a couple of naming conventions to made it easier
to add subject types without changing the view logic.
