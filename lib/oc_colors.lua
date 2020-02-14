-- Convert ComputerCraft colors to OpenComputers colors, and vice versa. Badly. --

local oc = {}

local colorPlex = { -- CC colors plexed to OC colors 
  [colors.black]     = 0x000000,
  [colors.blue]      = 0x0000FF,
  [colors.brown]     = 0x996600,
  [colors.cyan]      = 0x00FFCC,
  [colors.gray]      = 0x666666,
  [colors.green]     = 0x00EE00,
  [colors.lightBlue] = 0x33CCFF,
  [colors.lightGray] = 0xAAAAAA,
  [colors.lime]      = 0x66FF33,
  [colors.magenta]   = 0xFF00FF,
  [colors.orange]    = 0xFF6600,
  [colors.pink]      = 0xFF66CC,
  [colors.purple]    = 0x9900CC,
  [colors.red]       = 0xFF0000,
  [colors.yellow]    = 0xFFFF00,
  [colors.white]     = 0xFFFFFF
}

function oc.convertToCC(ocColor) -- TODO: Improve
  if ocColor >= 0x000000 and ocColor <= 0x111111 then
    return colors.black 
  elseif ocColor >= 0x222222 and ocColor <= 0x888888 then
    return colors.gray 
  elseif ocColor >= 0x999999 and ocColor <= 0xCCCCCC then
    return colors.lightGray
  elseif ocColor >= 0xDDDDDD and ocColor <= 0xFFFFFF then
    return colors.white 
  end
end

function oc.convertToOC(ccColor)
  return colorPlex[ccColor]
end

function oc.convertPaletteToCC(ocPalette)
  return colors[ocPalette]
end

function oc.convertPaletteToOC(ccPalette)
  return colorPlex[ccPalette]
end

return oc
