local buttonGrid
local updating
local curTime
local lastUpdate
local lastFullRefresh
local delay -- delay between channel packets
local curChannel

function init()
    buttonGrid = root:findByName("Button Grid", true)
    lastUpdate = 0
    lastFullRefresh = 0
    delay = 20
    curChannel = 1
    updating = true
end

function update()
    curTime = getMillis()

    if updating then
        if (curTime - lastUpdate) > delay then
            requestData()
        end
    else
        -- On cooldown
        if (curTime - lastFullRefresh) > self.cooldown then
            updating = true;
        end
    end
end

function requestData()
    lastUpdate = curTime
    if curChannel < (#buttonGrid.children + 1) then
        if self.ignoreHiddenButtons == true then
            if buttonGrid.children[curChannel].visible == true then
                self.notify(buttonGrid.children[curChannel].children["Button"], self.updateType)
            end
        else
            self.notify(buttonGrid.children[curChannel].children["Button"], self.updateType)
        end
        
        curChannel = curChannel + 1
    else
        lastFullRefresh = curTime
        curChannel = 1
        updating = false
    end
end