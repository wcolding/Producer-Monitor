local matrix = 1
local mixes = {
  [0] = 13, --program will be fed to mixbus 13
  [1] = 9,
  [2] = 10,
  [3] = 11,
  [4] = 12,
  [5] = 13 + matrix  --auto-adjust custom mix by chosen matrix index
}

local mixButtons

function init()
  self.tag = string.format("%02d", matrix)
  
  customMix = root:findByName("Button Grid", true)
  customMix.tag = string.format("%02d", mixes[5])
  
  PullX32()
end

function onValueChanged(key)
  if key == "page" then
    updateTab()
  end
end

function updateTab()
  for i = 1, 32 do
    local oscString = string.format("/ch/%02d/mix/%02d/on", i, mixes[5])
    sendOSC(oscString)
  end
end

function PullX32()
  print("Fetching channel config...")
  local oscString
  for i = 1, 32 do
    oscString = string.format("/ch/%02d/config/name", i)
    sendOSC(oscString)
    oscString = string.format("/ch/%02d/config/color", i)
    sendOSC(oscString)
  end
  
  mixButtons = root:findByName("Mix Select", true)
  
  print("Fetching mixbus config...")
  local child
  for i = 1, #mixButtons.children do
    child = mixButtons.children[i]
    child.tag = string.format("%02d", mixes[i-1])
    
    if child.name ~= "PGM" and child.name ~= "Custom" then
      oscString = string.format("/bus/%02d/config/name", mixes[i-1])
      sendOSC(oscString)
      oscString = string.format("/bus/%02d/config/color", mixes[i-1])
      sendOSC(oscString)
    end
  end
  
  print("Fetching custom mix...")
  updateTab()
  
  print("Done!")
end

function onReceiveNotify(msgType, data)
  if msgType == "Refresh" then
    PullX32()
  end
end