# Agents guide

laptop sets up a macOS machine as a development environment. See
`README.md` for the setup steps.

## Writing

Write every word in ASD-STE100 Simplified Technical English (STE):
Markdown docs, code comments, commit messages, and replies in an agent
conversation. See
<https://en.wikipedia.org/wiki/Simplified_Technical_English>.

STE is a controlled English for technical writing: one meaning per
word, one idea per sentence, and the actor named. It is not a house
style. It exists so a reader who is tired, or reading a second
language, or an agent matching on words, all read the same sentence the
same way.

- One idea per sentence. Keep an instruction to 20 words and a
  description to 25.
- Active voice, present tense, and the actor named: say what acts,
  rather than writing "the key is added".
- One word, one meaning. Keep a term the same everywhere rather than
  varying it for tone.
- Use the simple verb, not a noun made from it: "run the installer",
  not "perform execution of the installer".
- Cut what carries nothing: "simply", "just", "note that", "in order
  to".
- Put a warning or a limit before the step it applies to.

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
