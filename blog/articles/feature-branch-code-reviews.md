# Feature Branch Code Reviews

Updated February 2017.

Put your face on the [Trello] card in the top of the "Next Up" column
that represents a feature.
Move the card to the "In Progress" column.

[Trello]: https://trello.com

Make a branch to work in:

```
git checkout --branch my-feature-branch
```

Code the feature and commit it to version control:

```
git add --all
git commit --verbose
```

Push the feature to a branch:

```
git push
```

Open a pull request using [Hub]:

[Hub]: https://hub.github.com/

```
hub pr
```

A GitHub hook starts a [CircleCI] build.
A GitHub webhook posts the pull request to the team [Slack] channel.
Move the Trello card to the "Code Review" column.

[CircleCI]: https://circleci.com
[Slack]: https://slack.com

A teammate clicks the link in the Slack channel.
The teammate comments in-line on the code,
[offers feedback, and approves it][pr].

[pr]: https://help.github.com/articles/about-pull-request-reviews/

Make the suggested changes.
Commit the changes:

```
git add --all
git commit --amend
```

Merge into master:

```
git checkout master
git merge my-feature-branch
```

Push to master:

```
git push master
```

CI runs again.
Deploy to staging:

```
./bin/deploy staging
```

This is a project-dependent script wrapping commands.
For a Ruby on Rails app, it might look like this:

```
heroku pg:backups capture --remote staging
git push staging
heroku run rake db:migrate --remote staging
heroku restart --remote staging
```

Move the Trello card to the "Testing on Staging" column.
Write acceptance criteria on the card.
Ask a product owner for acceptance.

## What's to like about feature branch code reviews

Test-Driven Development moves code failure earlier in the development process.
It's better to have a failing test on a development machine than in production.
It also allows the developer to have tighter feedback cycles.

Code reviews right before code goes into master offer similar benefits:

* The whole team learns about new code as it is written.
* Mistakes are caught earlier.
* Coding standards are more likely to be established, discussed, and followed.
* Feedback from this style of code review is far more likely to be applied.
* No one forgets context ("Why did we write this?") since it's fresh in the
  author's mind.

Give it a shot!
