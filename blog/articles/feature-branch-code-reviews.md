# Feature Branch Code Reviews

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

Open a pull request.

A GitHub webhook starts a [CI] build.
Another GitHub webhook posts the pull request to a team [Slack] channel.
Move the Trello card to the "Code Review" column.

[CI]: https://www.martinfowler.com/articles/continuousIntegration.html
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

Deploy to staging.

Move the Trello card to the "Testing on Staging" column.
Write acceptance criteria on the card.
Ask a product owner for acceptance.

## Benefits

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
