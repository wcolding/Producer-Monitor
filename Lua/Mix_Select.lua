local selected = 1
local oscString
local db

function init()
  for i = 1, #self.children do
    if i == selected then
      self.children[i].children["Mix Select Button"].values.x = 1
    end
  end
end

function onReceiveNotify(sender, msg)
  selected = msg
  doSelected()
end

function doSelected()
  print("Updating selection")
  for i = 1, #self.children do
    -- Float to Sends dB Mapping
    -- 0.75f = 0.0 dB
    -- 0.00f = -inf dB
    
    db = 0.0
    
    if i == selected then
      db = 0.75
      self.children[i].children["Mix Select Button"].interactive = false
    else
      self.children[i].children["Mix Select Button"].values.x = 0
      self.children[i].children["Mix Select Button"].interactive = true
    end
    
    oscString = string.format("/bus/%02d/mix/%02d/level", self.children[i].tag, self.parent.parent.tag)
    sendOSC(oscString, db)
  end
end