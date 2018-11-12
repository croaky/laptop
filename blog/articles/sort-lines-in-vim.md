# Sort Lines in Vim

You are working in Vim.
You come across this code:

```
gem "clearance", "1.0.0.rc4"
gem "neat"
gem "stripe"
gem "pg"
gem "thin"
gem "rails", "3.2.11"
gem "bourbon"
gem "simple_form"
gem "strong_parameters"
```

You want to sort the list alphabetically.
You select the lines visually:

```
Shift + V
```

You invoke the `sort` function:

```
:sort
```

You rejoice:

```
gem "bourbon"
gem "clearance", "1.0.0.rc4"
gem "neat"
gem "pg"
gem "rails", "3.2.11"
gem "simple_form"
gem "stripe"
gem "strong_parameters"
gem "thin"
```

You dig deeper:

```
:help sort
```
