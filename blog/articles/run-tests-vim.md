# Run Tests in Vim

Test driven development thrives on a tight feedback loop
but switching from the editor to the shell
to manually run specs is inefficient.

Tools such as `autotest` and `guard` run specs whenever a file gets saved.
Although an improvement over a manual workflow,
those approaches often run the suite when not needed
and run too many or too few specs.

Enter [vim-rspec],
a lightweight Vim plugin that runs specs directly from within Vim
with the press of a key.

[vim-rspec]: https://github.com/thoughtbot/vim-rspec

It exposes methods such as `RunNearestSpec()`,
`RunCurrentSpecFile()`, and
`RunLastSpec()`,
which can be bound to a key mapping of your choice.
In [thoughtbot/dotfiles][dotfiles],
we bind those methods to `<Leader>s`, `<Leader>t`, and `<Leader>l`.

[dotfiles]: https://github.com/thoughtbot/dotfiles/blob/master/vimrc

Cursor over any line within an RSpec spec like this:

```ruby
describe RecipientInterceptor do
  it 'overrides to/cc/bcc fields' do
    Mail.register_interceptor RecipientInterceptor.new(recipient_string)

    response = deliver_mail

    expect(response.to).to eq [recipient_string]
    expect(response.cc).to eq []
    expect(response.bcc).to eq []
  end
end
```

Type `<Leader>s`:

```
rspec spec/recipient_interceptor_spec.rb:4
.

Finished in 0.03059 seconds
1 example, 0 failures
```

The screen is overtaken by a shell that runs only the focused spec.
Developers using tmux with vim-rspec and tslime
sometimes send the output to a nearby shell
so the code and spec output display on the screen at the same time.

Feeling good that this new spec passes,
run the whole file's specs with `<Leader>t`
to make sure the class's entire functionality is still intact:

```
rspec spec/recipient_interceptor_spec.rb
......

Finished in 0.17752 seconds
6 examples, 0 failures
```

Red, green, refactor.
From within the application's or library's code:

```ruby
def delivering_email(message)
  add_custom_headers message
  add_subject_prefix message
  message.to = @recipients
  message.cc = []
  message.bcc = []
end
```

Run `<Leader>l` without having to switch back to the spec:

```
rspec spec/recipient_interceptor_spec.rb
......

Finished in 0.17752 seconds
6 examples, 0 failures
```

These tight feedback loops make Test-Driven Development easier
by eliminating the switching cost between editor to the shell
when running specs.
