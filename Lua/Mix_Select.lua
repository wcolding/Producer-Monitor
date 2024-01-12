local oscString
local db

function init()
  updateSelection(6)
end

function onReceiveNotify(sender, msg)
  if msg < 6 then 
    self.selected = msg
    updateSelection(self.selected)
  else
    updateSelection(msg)
  end
end

function updateSelection(selected)
  print(string.format("Updating selection: %d", selected))
  for i = 1, #self.children do
    -- Float to Sends dB Mapping
    -- 0.75f = 0.0 dB
    -- 0.00f = -inf dB
    
    db = 0.0
    
    if i == selected then
      db = 0.75
      self.children[i].children["Mix Select Button"].values.x = 1
      self.children[i].children["Mix Select Button"].interactive = false
    else
      self.children[i].children["Mix Select Button"].values.x = 0
      self.children[i].children["Mix Select Button"].interactive = true
    end
    
    oscString = string.format("/bus/%s/mix/%02d/level", self.children[i].tag, self.parent.parent.MATRIX)
    sendOSC(oscString, db)
  end
end