-- click_tab.lua
-- Clicker tab where players can click to earn money

local click_tab = {}
local navbar = require("src.ui.navbar")
local shared_data = require("src.core.game.shared_data")
local button = require("src.ui.modules.button.button")
local visualization = require("src.ui.modules.visualization")
local manager_system = require("src.core.managers.manager_system")
local slot_machine = require("src.tabs.click_tab.slot_machine")
local data_loader = require("src.core.utils.data_loader")

-- Tab variables
local click_button = nil
local upgrade_buttons = {}

-- Initialize the tab
function click_tab.init()
    navbar.init("click_tab")
    
    -- Create main click button
    click_button = button.new(
        love.graphics.getWidth() / 2 - 100, 100, 200, 80, 
        "CLICK ME", 
        "accent"  -- Using the accent style from visualization
    )
    
    click_button:set_on_click(function()
        manager_system.process_click()
    end)
    
    -- Create upgrade buttons
    upgrade_buttons = {}
    local all_upgrades = manager_system.upgrades.get_all_upgrades()
    for i, upgrade in ipairs(all_upgrades) do
        local y_pos = 250 + (i-1) * 80
        local upgrade_button = button.new(
            love.graphics.getWidth() - 170, y_pos, 120, 50,
            "Buy: $" .. upgrade:get_cost(),
            "secondary"  -- Using the secondary style from visualization
        )
        
        upgrade_button:set_on_click(function()
            purchase_upgrade(upgrade.id)
        end)
        
        table.insert(upgrade_buttons, {button = upgrade_button, upgrade = upgrade})
    end
    
    -- Initialize slot machine
    slot_machine.init()
    
    -- Initial alignment of buttons with their panels
    click_tab.update(0)
end

-- Purchase an upgrade
function purchase_upgrade(id)
    local success, cost = manager_system.purchase_upgrade(id, shared_data.get_money())
    
    if success then
        -- Deduct cost
        shared_data.add_money(-cost)
        
        -- Update button text for all upgrades
        local all_upgrades = manager_system.upgrades.get_all_upgrades()
        for i, btn_data in ipairs(upgrade_buttons) do
            btn_data.upgrade = all_upgrades[i]
            btn_data.button.text = "Buy: $" .. btn_data.upgrade:get_cost()
        end
    end
end

-- Update function
function click_tab.update(dt)
    -- Recalculate button positions on window resize
    local window_width = love.graphics.getWidth()
    click_button.x = window_width / 2 - 100
    
    -- Update positions of upgrade buttons
    for i, btn_data in ipairs(upgrade_buttons) do
        local y_pos = 250 + (i-1) * 80
        local panel_height = 70
        local button_height = 50
        
        -- Center the button vertically in the panel
        local centered_y = y_pos - 20 + (panel_height - button_height) / 2
        
        btn_data.button.x = window_width - 170
        btn_data.button.y = centered_y
    end
    
    -- Update button states
    local mx, my = love.mouse.getPosition()
    local mouse_pressed = love.mouse.isDown(1)
    
    click_button:update(dt, mx, my, mouse_pressed)
    
    for _, btn_data in ipairs(upgrade_buttons) do
        -- Update button enabled state based on money
        btn_data.button:set_enabled(
            shared_data.get_money() >= btn_data.upgrade:get_cost() and 
            btn_data.upgrade.level < btn_data.upgrade.max_level
        )
        
        -- Update button state
        btn_data.button:update(dt, mx, my, mouse_pressed)
    end
    
    -- Update slot machine
    slot_machine.update(dt)
end

-- Draw function
function click_tab.draw()
    local window_width = love.graphics.getWidth()
    local window_height = love.graphics.getHeight()
    
    -- Draw the navbar
    navbar.draw()
    
    -- Draw main panel
    visualization.draw_panel(20, 82, window_width - 40, window_height - 102)
    
    -- Draw stats panel (Increased height from 120 to 150)
    visualization.draw_panel(20, 100, 220, 150)
    
    -- Draw clicker game content
    love.graphics.setColor(visualization.colors.text)
    love.graphics.print("Clicks: " .. shared_data.get_clicks(), 40, 110)
    love.graphics.print("Money: $" .. data_loader.format_number_to_two_decimals(shared_data.get_money()), 40, 140)
    love.graphics.print("Money per click: $" .. data_loader.format_number_to_two_decimals(manager_system.income.get_money_per_click()), 40, 170)
    -- Display Tokens (New)
    love.graphics.print("Tokens: T" .. data_loader.format_number_to_two_decimals(shared_data.get_tokens()), 40, 200)
    
    -- Draw main click button
    click_button:draw()
    
    -- Draw upgrades panel
    visualization.draw_panel(window_width - 480, 100, 460, window_height - 120)
    
    -- Draw upgrades section header
    love.graphics.setColor(visualization.colors.text)
    love.graphics.print("UPGRADES", window_width - 460, 120)
    
    -- Draw upgrade buttons and info
    for i, btn_data in ipairs(upgrade_buttons) do
        local upgrade = btn_data.upgrade
        local y_pos = 250 + (i-1) * 80
        
        -- Draw upgrade panel
        visualization.draw_panel(window_width - 460, y_pos - 20, 420, 70)
        
        -- Draw upgrade info
        love.graphics.setColor(visualization.colors.text)
        love.graphics.print(upgrade.name, window_width - 440, y_pos - 10)
        
        -- Calculate max width for text to avoid button overlap
        local max_text_width = 260
        
        love.graphics.setColor(visualization.colors.text_secondary)
        love.graphics.print(upgrade.description, window_width - 440, y_pos + 10)
        love.graphics.print("Level: " .. upgrade.level .. "/" .. upgrade.max_level, window_width - 440, y_pos + 30)
        
        -- Draw upgrade button
        btn_data.button:draw()
    end
    
    -- Draw slot machine
    if slot_machine.draw then  -- Check if draw function exists
        slot_machine.draw()
    end
    
    -- Draw auto-click rate info if applicable
    local auto_click_rate = manager_system.income.get_auto_click_rate()
    if auto_click_rate > 0 then
        visualization.draw_panel(20, window_height - 100, 220, 60)
        love.graphics.setColor(visualization.colors.text)
        love.graphics.print("Auto-clicks: " .. auto_click_rate .. " per second", 40, window_height - 90)
    end
end

-- Key press handler
function click_tab.keypressed(key)
    if key == "space" then
        manager_system.process_click()
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
        
        -- Check slot machine buttons
        if slot_machine.mousepressed(x, y, button_num) then
            return nil
        end
    end
    
    return nil
end

return click_tab 