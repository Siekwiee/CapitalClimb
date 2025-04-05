-- click_tab.lua
-- Clicker tab where players can click to earn money

local click_tab = {}
local navbar = require("src.ui.navbar")
local shared_data = require("src.core.game.shared_data")

-- Tab variables
local clicks = 0
local money_per_click = 1

function click_tab.init()
    navbar.init("click_tab")
end

function click_tab.update(dt)
    -- Update logic for clicker tab
end

function click_tab.draw()
    -- Draw the navbar
    navbar.draw()
    
    -- Draw the content area (below navbar)
    love.graphics.setColor(0.15, 0.15, 0.15)
    love.graphics.rectangle("fill", 0, 50, love.graphics.getWidth(), love.graphics.getHeight() - 50)
    
    -- Draw clicker game content
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Clicks: " .. clicks, 300, 100)
    love.graphics.print("Money: $" .. shared_data.get_money(), 300, 130)
    love.graphics.print("Money per click: $" .. money_per_click, 300, 160)
    
    -- Draw click button
    love.graphics.setColor(0.3, 0.6, 0.9)
    love.graphics.rectangle("fill", 300, 200, 200, 60)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("CLICK ME", 355, 220)
end

function click_tab.keypressed(key)
    -- Handle keypress for clicker tab
end

function click_tab.mousepressed(x, y, button)
    if button == 1 then
        -- Check navbar clicks
        local tab_id = navbar.check_click(x, y)
        if tab_id then
            -- Signal to change tab
            return tab_id
        end
        
        -- Check click button
        if x >= 300 and x <= 500 and y >= 200 and y <= 260 then
            clicks = clicks + 1
            shared_data.add_money(money_per_click)
        end
    end
    
    return nil
end

return click_tab 