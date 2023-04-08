--Check lua version
assert(_VERSION == "Lua 5.1", "ERROR: LuaJIT or Lua5.1 required")

--Helper functions
local function read_file(path)
  local f = assert(io.open(path, 'rb'))
  local d = f:read('*a')
  f:close()
  return d
end

--Get/normalize file path and working directory
local file_path = arg[1]:gsub("\\","/"):gsub("/?%s*$", ""):gsub("^%s*", "")
local working_dir = file_path:match("(.*/)")

--Read file
local file_data = read_file(file_path)

--Setup macro env
local postprocess_steps = {}
local macro_env = setmetatable({}, {__index = _G})
macro_env._ENV = macro_env
macro_env._G = macro_env

--Main process function
local function process(data)
  return data:gsub("(|>(.-)<|)", function(code)
    code = code:sub(3, -3)
    if code:sub(1, 1) == "!" then
      code = "return("..code:sub(2, -1)..")"
    elseif code:sub(1, 1) == "-" then
      code = ""
    end
    local fn = setfenv(assert(loadstring(code)), macro_env)
    local result = fn()
    if result == nil then
      return "" 
    else
      return tostring(result)
    end
  end)
end

--Create some built-in functions/tables on macro_env
macro_env.file = function(path)
  return read_file(working_dir..path)
end
macro_env.include = function(path)
  return process(macro_env.file(path))
end
macro_env.postprocess = setmetatable({
  remove_whitespace = function(x) return x:gsub('%s', '') end
}, {
  __call = function(self, step)
    if type(step) == "string" then
      what = self[step] or (function(...) return assert(self[step], step.." doesn't exist")(...) end)
    end
    assert(type(what) == "function", "postprocess argument not a function")
    postprocess_steps[#postprocess_steps + 1] = what
  end
})

--Process the entry point file data
local proc_file = process(file_data)

--Run post-process steps
for _, v in ipairs(postprocess_steps) do
  proc_file = v(proc_file)
end

--Write to stdout
io.write(proc_file)
io.flush()
