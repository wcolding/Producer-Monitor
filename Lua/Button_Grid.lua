local defaults = nil

function init()
  if defaults == nil then
    local ch = 1
  
    for i = 1, #self.children do
      self.children[i].name = string.format("Ch%02d", ch)
      self.children[i].tag = string.format("%02d", ch)
      self.children[i].children["Text"].values.text = self.children[i].name
      ch = ch + 1
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