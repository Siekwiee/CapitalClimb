-- business_tab.lua
-- Business tab where players can buy businesses to earn passive income

local business_tab = {}
local navbar = require("src.ui.navbar")
local shared_data = require("src.core.game.shared_data")
local button = require("src.ui.modules.button")
local visualization = require("src.ui.modules.visualization")
local manager_system = require("src.core.managers.manager_system")

-- Tab variables
local business_buttons = {}

function business_tab.init()
    navbar.init("business_tab")
    
    -- Create business buy buttons
    business_buttons = {}
    local businesses = manager_system.businesses.get_businesses()
    for i, business in ipairs(businesses) do
        local y = 240 + (i-1) * 90
        
        local buy_button = button.new(
            love.graphics.getWidth() - 200, y + 20, 120, 40,
            "BUY",
            "secondary"
        )
        
        buy_button:set_on_click(function()
            -- Try to buy business
            manager_system.buy_business(i)
        end)
        
        table.insert(business_buttons, {button = buy_button, business_index = i})
    end
end

function business_tab.update(dt)
    -- Update button positions on window resize
    local window_width = love.graphics.getWidth()
    for i, btn_data in ipairs(business_buttons) do
        btn_data.button.x = window_width - 200
    end
    
    -- Update button states
    local mx, my = love.mouse.getPosition()
    local mouse_pressed = love.mouse.isDown(1)
    
    -- Update business buy buttons
    local businesses = manager_system.businesses.get_businesses()
    for i, btn_data in ipairs(business_buttons) do
        local business = businesses[btn_data.business_index]
        -- Update button enabled state based on money
        btn_data.button:set_enabled(shared_data.get_money() >= business.cost)
        -- Update button state
        btn_data.button:update(dt, mx, my, mouse_pressed)
    end
end

function business_tab.draw()
    local window_width = love.graphics.getWidth()
    local window_height = love.graphics.getHeight()
    
    -- Draw the navbar
    navbar.draw()
    
    -- Draw the content area (below navbar)
    love.graphics.setColor(visualization.colors.background)
    love.graphics.rectangle("fill", 0, 62, window_width, window_height - 62)
    
    -- Draw main panel
    visualization.draw_panel(20, 82, window_width - 40, window_height - 102)
    
    -- Draw stats panel
    visualization.draw_panel(20, 100, 220, 80)
    
    -- Draw business info
    love.graphics.setColor(visualization.colors.text)
    love.graphics.print("Money: $" .. shared_data.get_money(), 40, 110)
    love.graphics.print("Passive Income: $" .. manager_system.income.get_passive_income() .. "/sec", 40, 140)
    
    -- Draw businesses panel
    visualization.draw_panel(20, 190, window_width - 40, window_height - 210)
    
    -- Draw businesses header
    love.graphics.setColor(visualization.colors.text)
    love.graphics.print("BUSINESSES", 40, 200)
    
    local businesses = manager_system.businesses.get_businesses()
    for i, business in ipairs(businesses) do
        local y = 240 + (i-1) * 90
        
        -- Create business panel
        visualization.draw_panel(40, y, window_width - 80, 80)
        
        -- Business info
        love.graphics.setColor(visualization.colors.text)
        love.graphics.print(business.name, 60, y + 10)
        love.graphics.setColor(visualization.colors.text_secondary)
        love.graphics.print("Cost: $" .. business.cost, 60, y + 30)
        love.graphics.print("Income: $" .. business.income .. "/sec", 60, y + 50)
        
        love.graphics.setColor(visualization.colors.text)
        love.graphics.print("Owned: " .. business.owned, window_width - 300, y + 30)
        
        -- Draw buy button
        if business_buttons[i] then
            business_buttons[i].button:draw()
        end
    end
end

function business_tab.keypressed(key)
    -- No specific key handling for business tab
end

function business_tab.mousepressed(x, y, button_num)
    if button_num == 1 then
        -- Check navbar clicks
        local tab_id = navbar.check_click(x, y)
        if tab_id then
            -- Signal to change tab
            return tab_id
        end
        
        -- Check buy buttons
        for _, btn_data in ipairs(business_buttons) do
            if btn_data.button:mouse_pressed(x, y, button_num) then
                return nil
            end
        end
    end
    
    return nil
end

return business_tab 