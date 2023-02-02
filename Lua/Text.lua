local minY = 8

function onReceiveOSC(message, connections)
  local path = message[1]
  local arguments = message[2]
  --print(path)
  
  if (#arguments == 1) and (arguments[1].tag == 's') then
    if (arguments[1].value ~= '') then
      SetText(arguments[1].value)
    else
      SetText(string.format("Ch %s", self.parent.tag))
    end
  end
end

function SetText(text)
  local modifiedText = text
  local numLines = 1
  
  -- Replace spaces with newlines
  if (string.find(modifiedText, " ") ~= nil) then 
    modifiedText =  string.gsub(modifiedText, " ", function()
      numLines = numLines + 1
      return "\n"
    end)
  end
  
  -- Vertically center text
  if (numLines == 1) then
    SetFrame(55)
  elseif (numLines == 2) then
    SetFrame(41)
  elseif (numLines == 3) then
    SetFrame(22)
  elseif (numLines == 4) then
    SetFrame(0)
  end
  
  self.values.text = modifiedText
end

function SetFrame(y)
  self.frame.y = y + minY
end