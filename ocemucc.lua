-- An OpenComputers emulator for ComputerCraft --

print("OCEmuCC Running on " .. _VERSION)

local component = require("lib/component")
local computer = require("lib/computer")

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
  load = load,
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
  checkArg = function(n, have, ...) -- Pretty much a straight copy of the one from machine.lua
    local have = type(have)
    local args = {...}
    local function check(want)
      if not want then
        return false
      else
        return have == want or check(table.unpack(args))
      end
    end
    if not check(...) then
      local msg = string.format("bad argument #%d (%s expected, got %s)", n, table.concat({...}, " or "), have)
      error(msg, 3)
    end
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

local function log()
  local ns = debug.getinfo(2, "Sn").func
  print(ns)
end

debug.sethook(log, "f")

local function boot()
  local ok, err = loadfile("/emudata/bios.lua")
  if not ok then
    return error(err)
  end

  setfenv(ok, sbMeta)

  local coro = coroutine.create(ok)

  while true do
    local ok, ret = coroutine.resume(coro, os.pullEvent())
    if ret == "reboot" then
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
