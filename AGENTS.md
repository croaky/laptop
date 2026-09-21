# Agents guide

laptop sets up a macOS machine as a development environment. See
`README.md` for the setup steps.

## Writing

Write every word in ASD-STE100 Simplified Technical English (STE):
Markdown docs, code comments, commit messages, and replies in an agent
conversation. One idea per sentence, active voice with the actor named,
one word for one meaning, and nothing that carries nothing.

`$HOME/blog/AGENTS.md` holds the full rule and is the one copy to edit.
A second copy here drifts from it, so this section states the summary
and points there.

Apply it to prose, not to code: an identifier, a command, and a quoted
error message stay as they are.

## Commits

- Prefix with what the change acts on: `laptop:`, `shell:`, `vim:`,
  `git:`, `cli:`, `postgres:`, `term:`, `bin:`.
- Imperative mood, lowercase except proper nouns. Hard-wrap at 72.
- Include _why_, not just _what_. See `git log` for examples.
- Sign your work with a `Co-Authored-By` trailer.

## Changes

This repo has no CI and no review gate. Work on `main`, run whatever
the change touches, and push.
