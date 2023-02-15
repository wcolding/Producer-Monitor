local button = self.parent.children[1]
local namePath = string.format("/ch/%s/config/name", self.parent.tag)

function init()
  self.frame.x = button.frame.x
  self.frame.y = button.frame.y
  self.frame.w = button.frame.w
  self.frame.h = button.frame.h
end

function onReceiveOSC(message, connections)
  local path = message[1]
  local arguments = message[2]
  
  if (#arguments == 1) and (arguments[1].tag == 's') then 
    if (path == namePath) then
      self.values.text = arguments[1].value
    end
  end
end