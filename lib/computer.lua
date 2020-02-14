-- A virtual 'computer' component --

local computer = {}

function computer.freeMemory()
  return 0
end

function computer.realTime()
  return os.epoch("utc")
end

function computer.totalMemory()
  return 2048*1024
end

function computer.beep() -- Can't do this, heh
  return true
end

local sigPlex = { -- Mappings of CC signals to OC signals
  ["key"] = "key_down",
  ["key_up"] = "key_up",
  ["paste"] = "clipboard",
  ["peripheral"] = "component_added",
  ["peripheral_detach"] = "component_removed",
  ["disk"] = "component_added",
  ["disk_eject"] = "component_removed",
  ["mouse_click"] = "touch",
--  ["modem_message"] = "modem_message",
  ["mouse_up"] = "drop",
  ["mouse_scroll"] = "scroll",
  ["term_resize"] = "screen_resized"
}

function computer.pullSignal(timeout)
  print("Pulling signal")
  if timeout == 0 then
    return
  else
    while true do
      local rtn = {os.pullEvent()}
      if sigPlex[rtn[1]] then -- Rearrange events to match OpenComputers
        if rtn[1] == "disk" or rtn[1] == "disk_removed" then
          rtn[3] = "filesystem"
          rtn[2] = nil -- There isn't really an easy way, at least how I've set this up, to emulate this
        elseif rtn[1] == "key" or rtn[1] == "key_up" then
          rtn[3] = string.byte(keys[rtn[2]])
          rtn[4] = keys[rtn[2]]
          rtn[2] = nil
        elseif rtn[1] == "paste" then
          rtn[3] = rtn[2]
          rtn[2] = nil
        elseif rtn[1] == "peripheral" or rtn[1] == "peripheral_detach" then
          rtn[3] = peripheral.getType(side)
          rtn[2] = nil
        elseif rtn[1] == "mouse_click" or rtn[1] == "mouse_up" then
          rtn[5] = rtn[2]
          rtn[2] = nil
        elseif rtn[1] == "mouse_scroll" then
          rtn[5] = rtn[2]
          rtn[2] = nil
        elseif rtn[1] == "term_resize" then
          rtn[2], rtn[3] = term.getSize()
        end
        rtn[1] = sigPlex[rtn[1]] -- This is easy compared to the other ones
        return table.unpack(rtn)
      end
    end
  end
end

function computer.pushSignal(sig, ...)
  os.queueEvent(sig, ...)
end

return computer
