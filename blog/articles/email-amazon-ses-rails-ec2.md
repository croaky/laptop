# Email with Amazon SES from Rails on EC2

[Amazon Simple Email Service][ses] (SES) is a
high availability transactional email service.

[ses]: https://aws.amazon.com/ses/

When sending email from an EC2 instance,
it is [particularly inexpensive][pricing]:

* $0 for the first 62,000 emails sent per month
* $0.10 per 1,000 emails sent thereafter

[pricing]: https://aws.amazon.com/ses/pricing/

It is available in three AWS regions:

* eu-west-1 (Ireland)
* us-east-1 (Northern Virginia)
* us-west-2 (Oregon)

If you have an AWS account,
go to [SES in your AWS console][home].

[home]: https://console.aws.amazon.com/ses/home

## Move out of sandbox mode

By default, SES in each region is in sandbox mode.
Since sandbox mode only allows delivering to
a whitelist of verified email addresses,
it's unusable for a production web application.

To move out of sandbox mode,
go to the "Sending Statistics" page
and click "Request a Sending Limit Increase"
to open a support request.
It may take up to a day or so to be approved.

[sand]: https://docs.aws.amazon.com/ses/latest/DeveloperGuide/request-production-access.html?icmpid=docs_ses_console

Once improved,
the sending limit will increase from 200 emails/day to 50,000 emails/day
and the restriction on delivering only to verified email addresses
will be lifted.

## Verify an email address

Click "Email Addresses".
Click "Verify a New Email Address".
Enter an email such as `support@example.com`.
Click the verification link that is emailed to the address.

This address is now allowed to deliver emails using SES.

## EC2 instance profile credentials

If the Rails app is deployed to EC2,
the `aws-sdk-*` gems will load credentials from the
[EC2 instance's metadata][meta].
The IAM role associated with the EC2 instance will be found.

[meta]: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-instance-metadata.html

## IAM role and policy

Go to [Policies in the IAM console][policies].
Click "Create policy".
Choose "SES".
Expand the "Write" section.
Select "SendEmail" and "SendRawEmail".
Create the policy.

[policies]: https://console.aws.amazon.com/iam/home#/policies

Go to [Roles in the IAM console][roles].
Find the role associated with the EC2 instance.
Attach the policy.

[roles]: https://console.aws.amazon.com/iam/home#/roles

## Configure Rails

Add the official [aws-sdk-rails gem][rails-gem]
to the `Gemfile` in the Rails app:

```ruby
gem 'aws-sdk-rails'
```

It lightly wraps other [aws-sdk-ruby gems][ruby-gems]
such as `aws-sdk-ses` and `aws-sdk-core`.
It provides an `ActionMailer` delivery method.

[rails-gem]: https://github.com/aws/aws-sdk-rails
[ruby-gems]: https://github.com/aws/aws-sdk-ruby

Configure your chosen AWS region in
`config/initializers/simple_email_service.rb`:

```ruby
Aws::Rails.add_action_mailer_delivery_method(:aws_sdk, region: 'us-west-2')
```

Use the delivery method in `config/environments/production.rb`:

```ruby
config.action_mailer.delivery_method = :aws_sdk
```

Once your sending limit has been increased,
you can deploy these changes.

## Catch errors

When delivering emails,
optionally rescue `Aws::SES::Errors::ServiceError` errors:

```ruby
class UsersController < ApplicationController
  def create
    @user = User.new(email: params[:user][:email])

    if @user.save
      begin
        Mailer.email_confirmation(@user).deliver_now
      rescue Aws::SES::Errors::ServiceError => err
        Rails.logger.info(err.message)
        flash.now[:alert] = t('.failure')
        render :new
      end
    else
      flash.now[:alert] = t('.failure')
      render :new
    end
  end
end
```
