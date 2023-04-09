# lpp
tiny (80 SLOC) lua preprocessor thing created for personal use

## usage  
```bash
luajit lpp.lua /path/to/file.lpp.lua > output.txt
```  
both lua 5.1 and luajit are supported
.lpp.lua is currently the suggested file extension for lpp files

## syntax  

wrap your lua code between `|> ... <|`  
returned value gets added to the output  
use these to define your globals and functions

#### inline blocks:  
`|>! ... <|` evaluate a single expression  
basically a shorthand for `|> return (...) <|`    
example: `|>! 5 * 5 <|`

#### comments:  
`|>- ... <|`  
self-explanatory

## includes

```
|>! include "bf_fun.lpp.lua" <|
```

notice how `include(...)` is just a normal lua function!   

```
|>! file "data.txt" <|
```

inserts file without any preprocessing  
(again, this is a normal lua function that can be called from anywhere

# post-processing

```lua
postprocess(...)
```
adds post-process filter to the queue.
runs after the final file is generated

## usage:  
accepts strings and functions.
```
|>! postprocess "remove_whitespace" <|
|>! postprocess(postprocess.remove_whitespace) <|
|>! postprocess(function(data)  ... end) <|
```
strings act as pointers to items in the global `postprocess` table.
they can be defined like so:
```
postprocess.remove_whitespace = function(data)
  return data:gsub('%s', '')
end
```

## built-in post-processing functions:  
  - `remove_whitespace`: removes all whitespace (including line breaks)
  - `convert_crlf`: converts \r\n line endings to \n
  - `remove_empty_lines`: removes all empty lines (lines that don't contain anything)

# emit api

`_(...)`
function can be called multiple times to write to the file multiple times.
can be useful for loops and conditions.
please note that emit api is incompatible with return values!

## example:
```lua
|>
  local text = "hello world"
  for i=1,#text do
    _ (text:sub(i,i):byte())
    _ ", "
  end
<|
```
output: `104, 101, 108, 108, 111, 32, 119, 111, 114, 108, 100, `

# example

```
|>! postprocess "remove_empty_lines" <|

|>
  name = "Bob"
  age = 36
<|

Hello! My name is |>! name <|, and my age is |>! age <|. 
I have "|>! -math.huge <|" friends :(.

Some math operations: (age * 36) / 2 = |>! (age * 36) / 2  <|

|>- I'm a comment! |<


Today's lucky number is... |>! math.random(100) <|

```
#### Output:
```
Hello! My name is Bob, and my age is 36.
I have "-inf" friends :(.
Some math operations: (age * 36) / 2 = 648
Today's lucky number is... 60
```

# security  
none.  

