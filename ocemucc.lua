-- An OpenComputers emulator for ComputerCraft --

print("OCEmuCC Running on " .. _VERSION)

local computer = require("lib/computer")
local component = require("lib/component")

computer.tmpAddress = component.randomAddress

term.setCursorBlink(false)

term.redirect(term.native())

-- Let's try setting up the sandbox manually, shall we? Probably horribly buggy. --
local function tcopy(tbl)
  local rtn = {}
  for k,v in pairs(tbl) do
    rtn[k] = v
  end
  return rtn
end

local sbMeta = {
  _VERSION = "Lua 5.1-2",
  assert = assert,
  error = error,
  getmetatable = getmetatable,
  ipairs = ipairs,
  next = next,
  pairs = pairs,
  pcall = pcall,
  rawequal = rawequal,
  rawget = rawget,
  rawset = rawset,
  rawlen = rawlen,
  select = select,
  setmetatable = setmetatable,
  tonumber = tonumber,
  tostring = tostring,
  type = type,
  xpcall = xpcall,
  bit32 = tcopy(bit32),
  coroutine = tcopy(coroutine),
  debug = {
    getinfo = debug.getinfo,
    traceback = debug.traceback
  },
  math = tcopy(math),
  os = {
    clock = function()return os.epoch("utc")end,
    date = function()return os.epoch("utc")end,
    difftime = function(t1, t2)return t2 - t1 end,
    time = os.time
  },
  string = tcopy(string),
  table = tcopy(table),
  checkArg = function(n, have, ...)
    local have = type(have) -- What we have
    local args = {...}
    local function check(want)
      return have == want
    end
    for i=1, #args, 1 do
      local isMatch = check(args[i])
      if isMatch then
        return true
      end
    end
    return false, string.format("Bad argument #%d (expected %s, got %s)", n, table.concat(args, " or "), have)
  end,
  component = component,
  computer = computer,
  unicode = {
    char = function()return nil end,
    charWidth = function()return nil end,
    isWide = function()return nil end,
    len = function(str)return str:len() end,
    lower = function(str)return str:lower() end,
    reverse = function(str)return str:reverse() end,
    sub = function(str,char,char2)return str:sub(char,char2) end,
    upper = function(str)return str:upper() end,
    wlen = function(str)return str:upper() end,
    wtrunc = function(str)return str end
  }
}

sbMeta.load = function(text, name, mode, env)
  if type(text) ~= "string" then
    return nil, "Invalid argument #1 (expected string)"
  end
  if name ~= nil and type(name) ~= "string" then
    return nil, "Invalid argument #2 (expected string)"
  end
  local name = name or "=" .. text
  local mode = mode or "t"
  local env = env or sbMeta
  if env == _G then
    env = sbMeta
  end
  return load(text, name, mode, env)
end

local string_format = string.format
sbMeta.string.format = function(fmt, ...)
  local args = {...}
  for i=1, #args, 1 do
    if type(args[i]) == "table" then
      args[i] = table.concat(args[i], " ")
    end
  end
  return string_format(fmt, table.unpack(args))
end

sbMeta._G = sbMeta

local function log()
  local ns = debug.getinfo(2, "Sn").func
  print(ns)
end

--debug.sethook(log, "f")

local function boot()
  local ok, err = loadfile("/emudata/bios.lua")
  if not ok then
    return error(err)
  end

  setfenv(ok, sbMeta)

  local coro = coroutine.create(ok)

  while true do
    local ok, ret = coroutine.resume(coro, os.pullEvent())
    if not ok then
      error(ret)
      break
    elseif ret == "reboot" then
      term.clear()
      return "reboot"
    elseif ret == "shutdown" then
      term.clear()
      term.setCursorPos(1,1)
      return
    end
    if coroutine.status(coro) == "dead" then
      return
    end
  end
end

while true do
  local status = boot()
  if status ~= "reboot" then
    break
  end
end

debug.sethook()
--os.run({}, "src/machine.lua")
--[[
local ok, err = loadfile("/src/machine.lua")
if not ok then
  return error(err)
end
local coro = coroutine.create(ok)

while coroutine.status(coro) ~= "dead" do
  local ok, ret = coroutine.resume(coro)
  if not ok then
    error(ret)
  end
end
]]
