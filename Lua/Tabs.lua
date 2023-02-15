local mixes = {
  [0] = 13, --program will be fed to mixbus 13
  [1] = 9,
  [2] = 10,
  [3] = 11,
  [4] = 12,
  [5] = 13 + self.MATRIX  --auto-adjust custom mix by chosen matrix index
}

local mixButtons
local customMixButton = root:findByName("Mix Select", true).children["Custom"].children["Mix Select Button"]

local currentChannel = 1
local delay = 20
local lastUpdate = 0
local updating = false
local tick = 0

local oscString = ""

function init()
  print("User info:")
  print(self.USERNAME)
  print(string.format("Matrix %02d", self.MATRIX))
  print()

  local userObj = root:findByName("User")
  userObj.values.text = self.USERNAME

  self.tag = string.format("%02d", self.MATRIX)
  
  customMix = root:findByName("Button Grid", true)
  customMix.tag = string.format("%02d", mixes[5])
  
  PullX32()
end

function onValueChanged(key)
  if key == "page" and self.values.page == 1 then
    customMixButton.values.x = 1
    GetCustomMixData()
  end
end

function update()
  if updating then
    tick = getMillis()
    if (tick - lastUpdate) > delay then
      lastUpdate = tick
      if currentChannel < 33 then
        GetCustomMixChannel(currentChannel)
        currentChannel = currentChannel + 1
      else
        -- Stop updating after 1 cycle
        currentChannel = 1
        updating = false
      end
    end
  end
end

function GetCustomMixChannel(channel)
  oscString = string.format("/ch/%02d/mix/%02d/on", channel, mixes[5])
  sendOSC(oscString)
  oscString = string.format("/ch/%02d/config/name", channel)
  sendOSC(oscString)
  oscString = string.format("/ch/%02d/config/color", channel)
  sendOSC(oscString)
end

function GetCustomMixData()
  currentChannel = 1
  updating = true
end

function PullX32()
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
  GetCustomMixData()
  
  print("Done!")
end

function onReceiveNotify(msgType, data)
  if msgType == "Refresh" then
    PullX32()
  end
end