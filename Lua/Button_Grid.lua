local defaults = nil

function init()
  if defaults == nil then
  
    for i = 1, #self.children do
      self.children[i].name = string.format("Ch%02d", i)
      self.children[i].tag = string.format("%02d", i)
    end
    
    defaults = "set"
    print("Set defaults")
  end
end

function updateMix(number)
  for i = 1, #self.children do
    oscString = string.format("/ch/%02d/mix/%02d/on", i, number)
    sendOSC(oscString)
  end
end

function onReceiveNotify(sender, msg)
  updateMix(msg)
end