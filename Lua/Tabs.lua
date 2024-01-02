local mixes = {
  [0] = 13, --program will be fed to mixbus 13
  [1] = 9,  -- Zone 1
  [2] = 10, -- Zone 2
  [3] = 11, -- Zone 3
  [4] = 12, -- Zone 4
  [5] = 13 + self.MATRIX  --auto-adjust custom mix by chosen matrix index
}

local mixSelect = root:findByName("Mix Select", true)
local buttonGrid = root:findByName("Button Grid", true)

local currentChannel = 1
local currentZone = 1
local delay = 20
local cooldown = 1000
local lastUpdate = 0
local lastFullRefresh = 0
local updating = true
local tick = 0

local oscString = ""

function init()
  mixes[5] = 13 + self.MATRIX
  print("User info:")
  print(self.USERNAME)
  print(string.format("Matrix %02d", self.MATRIX))
  print(string.format("Mix %02d", mixes[5]))
  print()

  local userObj = root:findByName("User")
  userObj.values.text = self.USERNAME

  self.tag = string.format("%02d", self.MATRIX)
  
  customMix = mixSelect.children["Custom"]
  customMix.tag = string.format("%02d", mixes[5])
  buttonGrid.tag = string.format("%02d", mixes[5])
  
  --PullX32()
  tick = 0
  updating = true
end

function onValueChanged(key)
  if key == "page" then 
    if self.values.page == 1 then
      self.notify(mixSelect, "Toggle", 6)
      GetCustomMixData()
    else
      self.notify(mixSelect, "Toggle", mixSelect.selected)
    end
  end
end

function update()
  tick = getMillis()

  if updating then
    -- Update either channels or zones
    if (tick - lastUpdate) > delay then
      if self.values.page == 1 then
        UpdateChannels()
      else
        UpdateZones()
      end
    end
  else
    -- On cooldown
    if (tick - lastFullRefresh) > cooldown then
      updating = true;
    end
  end
end

function UpdateChannels()
  lastUpdate = tick
  if currentChannel < (#buttonGrid.children + 1) then
    if buttonGrid.children[currentChannel].visible == true then
      GetCustomMixChannel(currentChannel)
    end
    currentChannel = currentChannel + 1
  else
    lastFullRefresh = tick
    currentChannel = 1
    updating = false
  end
end

function UpdateZones()
  lastUpdate = tick
  if currentZone < 5 then
    GetZone(currentZone)
    currentZone = currentZone + 1
  else
    lastFullRefresh = tick
    currentZone = 1
    updating = false
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

function GetZone(zone)
  oscString = string.format("/bus/%02d/config/name", mixes[zone])
  sendOSC(oscString)
  oscString = string.format("/bus/%02d/config/color", mixes[zone])
  sendOSC(oscString)
end

function GetCustomMixData()
  currentChannel = 1
  updating = true
end

function PullX32() 
  print("Fetching mixbus config...")
  local child
  for i = 1, #mixSelect.children do
    child = mixSelect.children[i]
    child.tag = string.format("%02d", mixes[i-1])
    
    if child.name ~= "PGM" and child.name ~= "Custom" then
      oscString = string.format("/bus/%02d/config/name", mixes[i-1])
      sendOSC(oscString)
      oscString = string.format("/bus/%02d/config/color", mixes[i-1])
      sendOSC(oscString)
    end
  end
  
  print("Fetching custom mix...")
  for i = 1, #buttonGrid.children do
    buttonGrid.children[i].visible = true
  end
  GetCustomMixData()
  
  print("Done!")
end

function onReceiveNotify(msgType, data)
  if msgType == "Refresh" then
    PullX32()
  end
end