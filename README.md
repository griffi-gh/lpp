# lpp
tiny lua preprocessor thing for personal use

## usage  
```bash
luajit lpp.lua /path/to/file.lpp.lua > output.txt
```  
both lua 5.1 and luajit are supported

## syntax  

wrap your lua code between `|> ... <|`  
returned value gets added to the output  
`nil` is equal to an empty string  
these blocks are usually used to define globals and functions

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
  - `remove_whitespace`: removes all whitespace

# security  
none.  
  
###### pls don't run untrusted code

