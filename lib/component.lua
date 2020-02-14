-- A fake-component library --

local component = {}

local computer_component = require("/lib/component_computer")
local gpu_component = require("/lib/component_gpu")
local fs_component = require("/lib/component_filesystem")


local addrPlex = {
  "0",
  "1",
  "2",
  "3",
  "4",
  "5",
  "6",
  "7",
  "8",
  "9",
  "a",
  "b",
  "c",
  "d",
  "e",
  "f"
}

local usedAddrs = {}

local function randomAddress() -- Get a random component address
  local rtn
  repeat
    rtn = ""
    repeat
      rtn = rtn .. addrPlex[math.random(1,15)]
    until #rtn == 32
    rtn = table.concat({rtn:sub(1,8),rtn:sub(9,13),rtn:sub(14,18),rtn:sub(19,23),rtn:sub(24,32)}, "-")
  until not usedAddrs[rtn]
  usedAddrs[rtn] = true
  return rtn
end

local emu_components = {
  {
    "computer",
    randomAddress(),
    1024^2 -- There's no real memory limit
  },
  {
    "screen",
    randomAddress()
  },
  {
    "gpu",
    randomAddress(),
    3 -- The GPU tier
  },
  {
    "eeprom",
    randomAddress(),
    4096, -- Max capacity
    256, -- Max data capacity
    "EEPROM (Lua BIOS)" -- Label
  },
  {
    "filesystem",
    dofile("/lib/root_fs_address.lua"), -- Hax to pull off consistent rootFS addresses
    false,
    "EmuRoot"
  },
  {
    "keyboard",
    randomAddress()
  },
  {
    "internet",
    randomAddress(),
    true, -- HTTP?
    false -- TCP? I don't know if CC:Tweaked supports TCP sockets
  }
}

if not fs.exists("/emudata/" .. emu_components[5][2]) then -- Create our rootfs dir
  fs.makeDir("/emudata/" .. emu_components[5][2])
end

function component.list(ctype)
--  print("Getting component list of type " .. (ctype or "all"))
  local cList = {}
  for i=1, #emu_components, 1 do
    if emu_components[i][1] == ctype or ctype == nil then
--      print("Found component " .. emu_components[i][2])
      table.insert(cList, emu_components[i][2])
    end
  end
  local i = 1
  return function()
    i = i + 1
--    print("Returning " .. (cList[i - 1] or "nil"))
    return cList[i - 1] or nil
  end
end

function component.doc()
  return "This function is not implemented."
end

function component.fields()
  return "This function is not implemented."
end

local function fs_invoke(addr, operation, ...)
--  print("Invoking " .. operation .. " on filesystem " .. addr)
  local opArgs = {...}
  if fs.exists("/emudata/" .. addr) then
    return fs_component[operation](...)
  else
    printError("No such component")
    return false, "No such component"
  end
end

local function gpu_invoke(addr, operation, ...)
  if not gpu_component.getScreen() then
    return false, "No screen bound"
  end
--  print("Executing operation " .. operation .. " on GPU " .. addr)
  return gpu_component[operation](...)
end

local function eeprom_invoke(addr, operation, ...)
--  print("Invoking " .. operation .. " on system EEPROM")
  local opArgs = {...}
  if fs.exists("/emudata/eeprom/") then
    if operation == "setData" then
      local handle = fs.open("/emudata/eeprom/data", "w")
      if string.len(opArgs[1]) <= 256 then
        handle.write(opArgs[1])
      else
        handle.close()
        return false, "Data too large"
      end
      handle.close()
    elseif operation == "getData" then
      local handle = fs.open("/emudata/eeprom/data", "r")
      local data = handle.readAll()
      handle.close()
      return data
    elseif operation == "set" then
      if string.len(opArgs[1]) <= 4096 then
        local handle = fs.open("/emudata/eeprom/bios.lua", "w")
        handle.write(opArgs[1])
        handle.close()
      else
        return false, "BIOS too large"
      end
    elseif operation == "get" then
      local handle = fs.open("/emudata/eeprom/bios.lua", "r")
      local data = handle.readAll()
      handle.close()
      return data
    elseif operation == "getDataSize" then
      return 256
    elseif operation == "getSize" then
      return 4096
    end
  else
    return false, "No such component"
  end
end

local function computer_invoke(addr, operation, ...)
  if computer[operation] then
    print("Invoking operation " .. operation .. " on computer " .. addr)
    return computer[operation](...)
  end
end

function component.invoke(addr, operation, ...)
  local addr, ctype = addr, ""
  if not addr then
    return
  end
  for i=1, #emu_components, 1 do
    if emu_components[i][2] == addr then
      ctype = emu_components[i][1]
      addr = emu_components[i][2]
    end
  end
  if not (ctype and addr) then
    return false, "No such component"
  end
  if ctype == "filesystem" then
    return fs_invoke(addr, operation, ...)
  elseif ctype == "gpu" then
    return gpu_invoke(addr, operation, ...)
  elseif ctype == "computer" then
    return computer_invoke(addr, operation, ...)
  elseif ctype == "eeprom" then
    return eeprom_invoke(addr, operation, ...)
  else
    return false, "Component " .. ctype .. " has not yet been implemented"
  end
end

function component.proxy(address)
  for i=1, #emu_components, 1 do
    if emu_components[i][2] == address then
      if emu_components[i][1] == "filesystem" then
        return fs_component
      elseif emu_components[i][1] == "gpu" then
        return gpu_component
      elseif emu_components[i][1] == "computer" then
        return computer_component
      end
    end
  end
end

return component
