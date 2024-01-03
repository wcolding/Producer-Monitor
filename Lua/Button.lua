local colorPath
local toggledPath

local fillColors = 
{
  [0] = Colors.black,                    -- black (placeholder; we will hide the button if it is set to this)
  [1] = Color.fromHexString('e72d2eff'), -- red
  [2] = Color.fromHexString('18D200FF'), -- green
  [3] = Color.fromHexString('FCFF0BFF'), -- yellow
  [4] = Color.fromHexString('17B1FFFF'), -- blue           --0060ff   17B1FFFF
  [5] = Color.fromHexString('ed27acff'), -- magenta
  [6] = Color.fromHexString('2de0e7ff'), -- cyan
  [7] = Colors.gray                      -- white
}

function init()
  colorPath = string.format("/ch/%s/config/color", self.parent.tag)
  toggledPath = string.format("/ch/%s/mix/%s/on", self.parent.tag, self.parent.parent.tag)
end

function SetColor(i)
  local translated = i 
  if (translated > 7) then
    repeat
      translated = translated - 8
    until (translated < 8)
  end
  
  if (translated < 1) then
    -- Hide this button
    self.parent.visible = false
  else
    -- Change the button color
    self.color = fillColors[translated]
    self.parent.visible = true
  end
end

function onReceiveOSC(message, connections)
  local path = message[1]
  local arguments = message[2]
  
  if (#arguments == 1) and (arguments[1].tag == 'i') then 
    if (path == colorPath) then
      SetColor(arguments[1].value)
    end
    
    if (path == toggledPath) then
      --self.values.x = arguments[1].value
    end
  end
end

function onValueChanged(key)
  if key == "x" and self.values.x == 1 then
    self.notify(self.parent.parent, "Toggle", self.exclusiveGroup)
  end
end