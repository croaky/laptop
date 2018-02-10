# Quiet Backtrace for Test Unit

Rails and agile processes help me avoid distraction
but `Test::Unit` backtraces noisy for my tastes.
Most of this typical backtrace will not help me fix my code:

```
1) Failure:
test: logged in on get to index should only show projects for the user's account. (ProjectsControllerTest)
[/System/Library/Frameworks/Ruby.framework/Versions/1.8/usr/lib/ruby/1.8/test/unit/assertions.rb:48:in `assert_block'
/System/Library/Frameworks/Ruby.framework/Versions/1.8/usr/lib/ruby/1.8/test/unit/assertions.rb:500:in `_wrap_assertion'
/System/Library/Frameworks/Ruby.framework/Versions/1.8/usr/lib/ruby/1.8/test/unit/assertions.rb:46:in `assert_block'
/System/Library/Frameworks/Ruby.framework/Versions/1.8/usr/lib/ruby/1.8/test/unit/assertions.rb:63:in `assert'
/System/Library/Frameworks/Ruby.framework/Versions/1.8/usr/lib/ruby/1.8/test/unit/assertions.rb:495:in `_wrap_assertion'
/System/Library/Frameworks/Ruby.framework/Versions/1.8/usr/lib/ruby/1.8/test/unit/assertions.rb:61:in `assert'
test/functional/projects_controller_test.rb:31:in `__bind_1196527660_342195'
/Users/james/Documents/railsApps/projects/vendor/plugins/shoulda/lib/shoulda/context.rb:98:in `call'
/Users/james/Documents/railsApps/projects/vendor/plugins/shoulda/lib/shoulda/context.rb:98:in `test: logged in on get to index should only show projects for the user's account. '
/System/Library/Frameworks/Ruby.framework/Versions/1.8/usr/lib/ruby/1.8/test/unit/testcase.rb:78:in `__send__'
/System/Library/Frameworks/Ruby.framework/Versions/1.8/usr/lib/ruby/1.8/test/unit/testcase.rb:78:in `run'
/System/Library/Frameworks/Ruby.framework/Versions/1.8/usr/lib/ruby/1.8/test/unit/testsuite.rb:34:in `run'
/System/Library/Frameworks/Ruby.framework/Versions/1.8/usr/lib/ruby/1.8/test/unit/testsuite.rb:33:in `each'
/System/Library/Frameworks/Ruby.framework/Versions/1.8/usr/lib/ruby/1.8/test/unit/testsuite.rb:33:in `run'
/System/Library/Frameworks/Ruby.framework/Versions/1.8/usr/lib/ruby/1.8/test/unit/testsuite.rb:34:in `run'
/System/Library/Frameworks/Ruby.framework/Versions/1.8/usr/lib/ruby/1.8/test/unit/testsuite.rb:33:in `each'
/System/Library/Frameworks/Ruby.framework/Versions/1.8/usr/lib/ruby/1.8/test/unit/testsuite.rb:33:in `run'
/System/Library/Frameworks/Ruby.framework/Versions/1.8/usr/lib/ruby/1.8/test/unit/ui/testrunnermediator.rb:46:in `run_suite'
/System/Library/Frameworks/Ruby.framework/Versions/1.8/usr/lib/ruby/1.8/test/unit/ui/console/testrunner.rb:67:in `start_mediator'
/System/Library/Frameworks/Ruby.framework/Versions/1.8/usr/lib/ruby/1.8/test/unit/ui/console/testrunner.rb:41:in `start'
/System/Library/Frameworks/Ruby.framework/Versions/1.8/usr/lib/ruby/1.8/test/unit/ui/testrunnerutilities.rb:29:in `run'
/System/Library/Frameworks/Ruby.framework/Versions/1.8/usr/lib/ruby/1.8/test/unit/autorunner.rb:216:in `run'
/System/Library/Frameworks/Ruby.framework/Versions/1.8/usr/lib/ruby/1.8/test/unit/autorunner.rb:12:in `run'
/System/Library/Frameworks/Ruby.framework/Versions/1.8/usr/lib/ruby/1.8/test/unit.rb:278
test/functional/projects_controller_test.rb:36]:
one or more projects shown does not belong to the current user's account.
false is not true.
```

So, at the inaugural [Boston.rb] hackfest,
we scratched our itch,
with especially good direction from Joe Ferris.
Afterward, [James Golick] and I polished the code into a gem
which I am pleased to announce... now.

[James Golick]: http://jamesgolick.com/
[Boston.rb]: http://bostonrb.org

## Quiet Backtrace

Install the gem:

```
gem install quietbacktrace
```

Run your Test::Unit tests:

```
1) Failure:
  test: logged in on get to index should only show projects for the user's
    account. (ProjectsControllerTest)
  [test/functional/projects_controller_test.rb:31
  vendor/plugins/shoulda/lib/shoulda/context.rb:98
  vendor/plugins/shoulda/lib/shoulda/context.rb:98
  test/functional/projects_controller_test.rb:36]:
  one or more projects shown does not belong to the current user's account.
  false is not true.
```

Ooh la la!

Those Shoulda-related lines are cluttering an otherwise perfect backtrace.
Luckily, Quiet Backtrace is designed to be extended
by calling two types of blocks that yield one line of the backtrace at a time.

## Silencers and filters

Silencers let you specify conditions that, if true,
will remove the line from the backtrace.

Filters let you use Ruby's [String] methods to modify a line
by slicing, stripping, and chomping away at anything you deem unnecessary.

[String]: http://www.ruby-doc.org/core/classes/String.html

If you want to remove Shoulda-related lines,
create a new silencer and add it the array of `backtrace_silencers`:

```ruby
class Test::Unit::TestCase
  self.new_backtrace_silencer(:shoulda) do |line|
    line.include?("vendor/plugins/shoulda")
  end

  self.backtrace_silencers << :shoulda
end
```

Re-run your tests:

```
1) Failure:
  test: logged in on get to index should only show projects for the user's
    account. (ProjectsControllerTest)
  [test/functional/projects_controller_test.rb:31
  test/functional/projects_controller_test.rb:36]:
  one or more projects shown does not belong to the current user's account.
  false is not true.
```

Exquisitely sparse.
Quiet Backtrace clears distractions from the Test-Driven Development process
like a Buddhist monk keeping their mind clear during meditation.

## Getting Noisy Again

To see the noisy backtrace:

```ruby
class Test::Unit::TestCase
  self.quiet_backtrace = false
end
```

Set `Test::Unit::TestCase.quiet_backtrace` to true or false
at any level in your `Test::Unit` code.
Stick it in your `test_helper.rb` file or
get noisy in an individual file or test.
More flex than a rubber band.

## Using Quiet Backtrace with Rails

After you have installed the gem,
open `rails-app-folder/config/environments/test.rb` and add:

```
require "quietbacktrace"
```

Quiet Backtrace will now work with your tests,
but because this gem is meant to work on any Ruby project with Test::Unit,
it does not turn any Rails-specific silencers or filters on by default,
but there is one of each, ready to be switched on.

Add these lines to your `/test/test_helper.rb` file
to get perfectly clean Rails backtraces:

```ruby
class Test::Unit::TestCase
  self.backtrace_silencers << :rails_vendor
  self.backtrace_filters   << :rails_root
end
```

## Ongoing development

Inspired by this gem,
[DHH] added this functionality into Rails itself as [BacktraceCleaner],
and Quiet Backtrace has therefore been deprecated.

[DHH]: https://github.com/dhh
[BacktraceCleaner]: http://api.rubyonrails.org/classes/ActiveSupport/BacktraceCleaner.html

For more details on the history of this open source effort,
see James Golick's post at [James on Software].

[James on Software]: http://jamesgolick.com/2007/12/1/noisy-backtraces-got-you-down.html
