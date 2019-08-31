# Roman Numerals

Write a function to convert from normal numbers to Roman Numerals.

There is no need to be able to convert numbers larger than 3000.
The Romans themselves didn't tend to go any higher.

Roman numerals are written by expressing each digit separately
starting with the left most digit
and skipping any digit with a value of zero.

1990 is MCMXC:

```
1000 = M
 900 = CM
  90 = XC
```

2008 is MMVIII:

```
2000 = MM
   8 = VIII
```

Test:

```
go test -v --bench . --benchmem
```

Source: <http://codingdojo.org/cgi-bin/index.pl?KataRomanNumerals>
