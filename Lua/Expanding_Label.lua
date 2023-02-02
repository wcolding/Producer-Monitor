local button = self.parent.children['Mix Select Button']

function init()
  self.frame.x = button.frame.x
  self.frame.y = button.frame.y
  self.frame.w = button.frame.w
  self.frame.h = button.frame.h
  self.values.text = self.parent.name
end