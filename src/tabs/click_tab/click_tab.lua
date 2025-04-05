-- click_tab.lua
-- Clicker tab where players can click to earn money

local click_tab = {}
local navbar = require("src.ui.navbar")
local shared_data = require("src.core.game.shared_data")
local button = require("src.ui.modules.button")
local upgrades = require("src.tabs.click_tab.upgrades")

-- Tab variables
local money_per_click = 1
local click_button = nil
local upgrade_buttons = {}
local auto_click_timer = 0

-- Initialize the tab
function click_tab.init()
    navbar.init("click_tab")
    
    -- Create main click button
    click_button = button.new(
        300, 150, 200, 80, 
        "CLICK ME", 
        {
            normal = {0.3, 0.6, 0.9, 1.0},
            hover = {0.4, 0.7, 1.0, 1.0},
            pressed = {0.2, 0.5, 0.8, 1.0}
        }
    )
    
    click_button:set_on_click(function()
        perform_click()
    end)
    
    -- Create upgrade buttons
    upgrade_buttons = {}
    for i, upgrade in ipairs(upgrades.items) do
        local y_pos = 250 + (i-1) * 70
        local upgrade_button = button.new(
            500, y_pos, 180, 50,
            "Buy: $" .. upgrade:get_cost(),
            {
                normal = {0.2, 0.7, 0.3, 1.0},
                hover = {0.3, 0.8, 0.4, 1.0},
                pressed = {0.1, 0.6, 0.2, 1.0},
                disabled = {0.5, 0.5, 0.5, 1.0}
            }
        )
        
        upgrade_button:set_on_click(function()
            purchase_upgrade(upgrade.id)
        end)
        
        table.insert(upgrade_buttons, {button = upgrade_button, upgrade = upgrade})
    end
    
    -- Initialize values
    money_per_click = upgrades.calculate_money_per_click()
end

-- Perform a click action
function perform_click()
    shared_data.add_clicks(1)
    
    -- Add money based on current money_per_click
    shared_data.add_money(money_per_click)
    
    -- Check for double click chance
    if upgrades.should_double_click() then
        shared_data.add_money(money_per_click)
    end
end

-- Purchase an upgrade
function purchase_upgrade(id)
    local success, cost = upgrades.upgrade_item(id, shared_data.get_money())
    
    if success then
        -- Deduct cost
        shared_data.add_money(-cost)
        
        -- Update money_per_click
        money_per_click = upgrades.calculate_money_per_click()
        
        -- Update button text
        for _, btn_data in ipairs(upgrade_buttons) do
            if btn_data.upgrade.id == id then
                btn_data.button.text = "Buy: $" .. btn_data.upgrade:get_cost()
            end
        end
    end
end

-- Update function
function click_tab.update(dt)
    -- Update button states
    local mx, my = love.mouse.getPosition()
    local mouse_pressed = love.mouse.isDown(1)
    
    click_button:update(mx, my, mouse_pressed)
    
    for _, btn_data in ipairs(upgrade_buttons) do
        -- Update button enabled state based on money
        btn_data.button:set_enabled(
            shared_data.get_money() >= btn_data.upgrade:get_cost() and 
            btn_data.upgrade.level < btn_data.upgrade.max_level
        )
        
        -- Update button state
        btn_data.button:update(mx, my, mouse_pressed)
    end
    
    -- Auto-click functionality
    local auto_click_rate = upgrades.get_auto_click_rate()
    if auto_click_rate > 0 then
        auto_click_timer = auto_click_timer + dt
        
        -- Time to auto-click?
        if auto_click_timer >= (1 / auto_click_rate) then
            perform_click()
            auto_click_timer = 0
        end
    end
end

-- Draw function
function click_tab.draw()
    -- Draw the navbar
    navbar.draw()
    
    -- Draw the content area (below navbar)
    love.graphics.setColor(0.15, 0.15, 0.15)
    love.graphics.rectangle("fill", 0, 50, love.graphics.getWidth(), love.graphics.getHeight() - 50)
    
    -- Draw clicker game content
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Clicks: " .. shared_data.get_clicks(), 50, 70)
    love.graphics.print("Money: $" .. shared_data.get_money(), 50, 100)
    love.graphics.print("Money per click: $" .. money_per_click, 50, 130)
    
    -- Draw main click button
    click_button:draw()
    
    -- Draw upgrades section
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("UPGRADES", 500, 220)
    
    -- Draw upgrade buttons and info
    for i, btn_data in ipairs(upgrade_buttons) do
        local upgrade = btn_data.upgrade
        local y_pos = 250 + (i-1) * 70
        
        -- Draw upgrade info
        love.graphics.setColor(1, 1, 1)
        love.graphics.print(upgrade.name, 300, y_pos)
        love.graphics.print(upgrade.description, 300, y_pos + 20)
        love.graphics.print("Level: " .. upgrade.level .. "/" .. upgrade.max_level, 300, y_pos + 40)
        
        -- Draw upgrade button
        btn_data.button:draw()
    end
end

-- Key press handler
function click_tab.keypressed(key)
    if key == "space" then
        perform_click()
    end
end

-- Mouse press handler
function click_tab.mousepressed(x, y, button_num)
    if button_num == 1 then
        -- Check navbar clicks
        local tab_id = navbar.check_click(x, y)
        if tab_id then
            -- Signal to change tab
            return tab_id
        end
        
        -- Check click button
        if click_button:mouse_pressed(x, y, button_num) then
            return nil
        end
        
        -- Check upgrade buttons
        for _, btn_data in ipairs(upgrade_buttons) do
            if btn_data.button:mouse_pressed(x, y, button_num) then
                return nil
            end
        end
    end
    
    return nil
end

return click_tab 