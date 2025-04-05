-- navbar.lua
-- Navigation bar that appears in all tabs

local navbar = {}

-- Tab data
local tabs = {
    {id = "click_tab", name = "Clicker", active = false},
    {id = "business_tab", name = "Business", active = false}
}

local current_tab = nil

-- Initialize the navbar
function navbar.init(active_tab)
    -- Set active tab
    for _, tab in ipairs(tabs) do
        tab.active = (tab.id == active_tab)
        if tab.active then
            current_tab = tab.id
        end
    end
end

-- Draw the navigation bar
function navbar.draw()
    -- Background
    love.graphics.setColor(0.2, 0.2, 0.2)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), 50)
    
    -- Game title
    love.graphics.setColor(1, 0.8, 0.2)
    love.graphics.print("Capital Climb", 20, 15)
    
    -- Tab buttons
    local button_width = 100
    local start_x = love.graphics.getWidth() - (#tabs * button_width) - 20
    
    for i, tab in ipairs(tabs) do
        local x = start_x + (i-1) * button_width
        
        -- Draw button background (highlight if active)
        if tab.active then
            love.graphics.setColor(0.4, 0.4, 0.4)
        else
            love.graphics.setColor(0.3, 0.3, 0.3)
        end
        
        love.graphics.rectangle("fill", x, 10, button_width - 10, 30)
        
        -- Draw button text
        love.graphics.setColor(1, 1, 1)
        love.graphics.print(tab.name, x + 15, 15)
    end
    
    -- Reset color
    love.graphics.setColor(1, 1, 1)
end

-- Check if a click hit any tab button
function navbar.check_click(x, y)
    if y < 50 then
        local button_width = 100
        local start_x = love.graphics.getWidth() - (#tabs * button_width) - 20
        
        for i, tab in ipairs(tabs) do
            local tab_x = start_x + (i-1) * button_width
            
            if x >= tab_x and x <= tab_x + button_width - 10 and y >= 10 and y <= 40 then
                return tab.id
            end
        end
    end
    
    return nil
end

-- Get the current active tab
function navbar.get_current_tab()
    return current_tab
end

return navbar 