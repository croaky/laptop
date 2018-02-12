# Authorization with Rails Associations

Authorize Ruby on Rails requests through the domain model's associations.

Routes:

```ruby
resources :accounts, only: [:new, :create, :show]

resources :brands, only: [:new, :create, :show] do |brands|
  brands.resources :offers, only: [:new]
end
```

Brands belong to accounts.
Offers belong to brands.
Users belong to accounts.

## Authentication

Users are authenticated using [Clearance].
They have a `account_id` foreign key.

[Clearance]: http://github.com/thoughtbot/clearance

Clearance provides an `:authorize` controller filter and ActiveRecord finders:

```ruby
class BrandsController < ApplicationController
  before_filter :authorize

  def new
    @brand = current_user.account.brands.build
  end

  def create
    @brand = current_user.account.brands.build(params[:brand])
    # ...
  end

  def show
    @brand = current_user.account.brands.find(params[:id])
  end
end
```

With this pattern,
the user is restricted to interacting with brands
to which they have access through their account.

## Test at the controller level

```ruby
it "does not find brands unassociated with user" do
  brand = create(:brand)
  sign_in_as create(:user)

  assert_raises(ActiveRecord::RecordNotFound) do
    get :new, brand_id: brand.to_param
  end
end
```

Rails returns a 404 when `ActiveRecord::RecordNotFound` is raised.
This error will be raised in our access control scheme because
there is no record of the `current_user` having a relationship to this brand.

Make the tests pass:

```ruby
class OffersController < ApplicationController
  before_filter :authorize

  def new
    @brand = current_user.brands.find(params[:brand_id])
    @offer = @brand.offers.build
  end
end
```

`User` belongs to an account,
`Account` has many brands,
and `current_user.brands` is delegated through `current_user.account`:

```ruby
class User < ActiveRecord::Base
  include Clearance::User

  belongs_to :account

  delegate :brands, to: :account
end
```

## Lightweight

This authorization approach requires few lines of code
and no extra gem dependencies beyond Rails and Clearance.
It removes duplication,
is testable,
and uses normal authentication and RESTful conventions.
