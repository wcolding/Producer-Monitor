local tabs

function init()
  tabs = root:findByName("Tabs", true)
end

function onValueChanged(key)
  if key == "x" and self.values.x == 1 then
    print("Refreshing data")
    self.notify(tabs, "Refresh", nil)
  end
end