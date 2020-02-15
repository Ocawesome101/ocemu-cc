-- FS component --

local filesystem = {}

local fsAddress = "/emudata/" .. dofile("/lib/root_fs_address.lua") .. "/"

local openHandles = {}

function filesystem.seek()
  return false, "This function is not implemented"
end

function filesystem.spaceUsed() -- Behaves like fs.spaceFree() :P
  return fs.getFreeSpace()
end

function filesystem.isReadOnly()
  return false
end

function filesystem.list(path)
  return fs.list(fsAddress .. "/" .. path)
end

function filesystem.rename(source, dest)
  return fs.move(fsAddress .. "/" .. source, fsAddress .. "/" .. dest)
end

function filesystem.lastModified()
  return 0
end

filesystem.isDir = true -- Tell /etc/init.d/70_filesystem.lua we're on computercraft

function filesystem.makeDirectory(path)
  return fs.makeDir(fsAddress .. "/" .. path)
end

function filesystem.getLabel()
  return os.getComputerLabel()
end

function filesystem.setLabel(label)
  os.setComputerLabel(label)
  return label
end

function filesystem.size(path)
  return fs.getSize(fsAddress .. "/" .. path)
end

function filesystem.spaceTotal()
  return fs.getFreeSpace()
end

function filesystem.isDirectory(path)
  return fs.isDir(fsAddress .. "/" .. path)
end

function filesystem.exists(path)
  return fs.exists(fsAddress .. "/" .. path)
end

function filesystem.open(file, mode)
  if not fs.exists(fsAddress .. "/" .. file) then
    return false, file .. ": file not found"
  end
  local mode = mode or "r"
  local handle = io.open(fsAddress .. "/" .. file, mode)
  openHandles[#openHandles + 1] = handle
  return #openHandles
end

function filesystem.read(handle, amount)
  local amount = amount
  if amount == math.huge then
    amount = 0xFFFF
  end
  if openHandles[handle] then
    local rtnData = openHandles[handle]:read(amount)
    return rtnData
  else
    return nil
  end
end

function filesystem.write(handle, data)
  if openHandles[handle] then
    return openHandles[handle]:write(data)
  end
end

function filesystem.close(handle)
  openHandles[handle]:close()
end

return filesystem
