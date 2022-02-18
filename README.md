# AlterRuby

This class allows you to easily run Ruby code in parallel by using "||".
<br>
Under MIT license so you can use in commercial projects.
<br>
Designed for use with RPG Maker VX Ace.

Turn this:

```
counter = 3
Thread.new {
  line_of_code()
  counter -= 1
}
Thread.new {
  line_of_code()
  counter -= 1
}
Thread.new {
  line_of_code()
  counter -= 1
}
while counter > 0
  sleep(0.01)
end
```

Into this:

```
AR('line_of_code() || line_of_code() || line_of_code()', binding)
```
