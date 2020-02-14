-- GPU component --

local gpu = {}

local oc_colors = require("/lib/oc_colors")

function gpu.getScreen()
  return nil
end

function gpu.bind(addr) -- Superficial, doesn't actually do anything
  function gpu.getScreen()
    return addr
  end
end

function gpu.getBackground()
  return oc_colors.convertToOC(term.getBackgroundColor())
end

function gpu.setBackground(color, isPalette)
  if isPalette then
    return term.setTextColor(colors[color])
  else
    return term.setBackgroundColor(oc_colors.convertToCC(color))
  end
end

function gpu.getForeground()
  return oc_colors.convertToOC(term.getTextColor())
end

function gpu.setForeground(color, isPalette)
  if isPalette then
    return term.setTextColor(colors[color])
  else
    return term.setTextColor(oc_colors.convertToCC(color))
  end
end

function gpu.getPaletteColor(index)
  return oc_colors.convertPaletteToOC(term.getPaletteColor(oc_colors.convertPaletteToCC(index)))
end

function gpu.setPaletteColor(index, value)
  return term.setPaletteColor(oc_colors.convertPaletteToCC(index))
end

function gpu.getDepth()
  return 4
end

function gpu.setDepth()
  return false, "Cannot set bit depth"
end

function gpu.maxResolution()
  return term.getSize()
end

function gpu.getResolution()
  return term.getSize()
end

function gpu.setResolution()
  return false, "Cannot change resolution"
end

gpu.getViewport = gpu.getResolution
gpu.setViewport = gpu.setResolution

function gpu.get(x,y)
  return " ", 0xFFFFFF, 0x000000, nil, nil
end

function gpu.set(x,y,text)
  term.setCursorPos(x,y)
  term.write(text)
end

function gpu.copy(x,y,w,h,tx,ty)
  term.scroll(1) -- Unfortunately, I don't think there's a way to properly do this without COMPLETELY emulating the entire display, which I don't want to do.
end

function gpu.fill(x,y,w,h,char)
  local cy = y
  while cy <= y+h do
    term.setCursorPos(x,cy)
    write(char:rep(w))
    cy = cy + 1
  end
end

return gpu
