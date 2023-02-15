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