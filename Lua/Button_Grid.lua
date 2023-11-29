local defaults = nil
local exclusives = {31, 32}

function init()
  if defaults == nil then
  
    curString = ''
    for i = 1, #self.children do
      curChild = self.children[i]
      curChild.name = string.format("Ch%02d", i)
      curChild.tag = string.format("%02d", i)
      curChild.children['Button'].exclusiveGroup = 0
      
      for e = 1, #exclusives do
        if exclusives[e] == i then
          curChild.children['Button'].exclusiveGroup = 1
        end
      end

      curString = string.format("%s  %s  %d", curChild.name, curChild.tag, curChild.children['Button'].exclusiveGroup)
      print(curString)
    end
    
    defaults = "set"
    print("Set defaults")
  end
end

function onReceiveNotify(msgType, exclusiveGroup)
  for i = 1, #self.children do
    curButton = self.children[i].children['Button']
    if curButton.exclusiveGroup ~= exclusiveGroup then
      curButton.values.x = 0
    end
  end
end