
lulex
=====

A minimal, simplistic lexer generator written in Lua.

Requires lrexlib-pcre. Installation example for the dependency:

```
luarocks install lrexlib-pcre
```

Usage example:

```lua
local lulex = require("lulex")

rules = {
   { 'foo', function(tk) print("got foo!") end },
   { '[ \\n\\t]+', function(tk) print("got "..tostring(#tk).." whitespace chars!") end },
   { '.', function(tk) print("syntax error!") end },
}

local lexer = lulex.new(rules) 

lexer:run("foo  foo   foo       foo")
```

This outputs:

```
got foo!
got 2 whitespace chars!
got foo!
got 3 whitespace chars!
got foo!
got 7 whitespace chars!
got foo!
```

The `rules` table is an array of rules.
Each rule is an array with two entries: a string representing a regular expression, and a function that receives the matched token.

Enjoy!

License
-------

This is free software. (C) 2014 Hisham Muhammad. MIT License, same as Lua 5.2.

