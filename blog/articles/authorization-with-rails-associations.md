# Authorization with Rails Associations

Authorize Ruby on Rails requests through the domain model's associations.

Routes:

```ruby
resources :brands, only: [] do
  resources :offers, only: [:new]
end
```

User has many brands.
Brand has many offers.

## Authentication

Users are authenticated using [Clearance],
which provides an `:require_login` `before_filter`
and `current_user` method:

[Clearance]: http://github.com/thoughtbot/clearance

```ruby
class OffersController < ApplicationController
  before_filter :require_login

  def new
    @brand = current_user.brands.find(params[:brand_id])
    @offer = @brand.offers.build
  end
end
```

The user is restricted to interacting with brands to which they have access.

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

`ActiveRecord::RecordNotFound` is raised because
there is no record of the user having an association to this brand.

Rails returns a 404 when `ActiveRecord::RecordNotFound` is raised.

Make the tests pass:

```ruby
class OffersController < ApplicationController
  before_filter :require_login

  def new
    @brand = current_user.brands.find(params[:brand_id])
    @offer = @brand.offers.build
  end
end
```

## Lightweight

This authorization approach requires few lines of code
and no extra dependencies beyond Rails and Clearance.
It removes duplication,
is testable,
and uses normal authentication and RESTful conventions.
