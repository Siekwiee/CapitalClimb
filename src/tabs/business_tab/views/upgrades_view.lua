-- upgrades_view.lua
-- Handles the display and interaction with business upgrades

local upgrades_view = {}
local button = require("src.ui.modules.button.button")
local visualization = require("src.ui.modules.visualization")
local shared_data = require("src.core.game.shared_data")
local manager_system = require("src.core.managers.manager_system")
local data_loader = require("src.core.utils.data_loader")

-- Local variables
local upgrade_buttons = {}

function upgrades_view.init()
    upgrades_view.init_upgrade_buttons()
end

function upgrades_view.init_upgrade_buttons()
    upgrade_buttons = {}
    
    -- Get all business upgrades
    local upgrades = manager_system.businesses.get_business_upgrades()
    
    -- Create buttons for each upgrade
    for i, upgrade in ipairs(upgrades) do
        local y = 240 + (i-1) * 70
        
        local upgrade_button = button.new(
            love.graphics.getWidth() / 2 + 100, y, 180, 40,
            "PURCHASE",
            "accent"
        )
        
        upgrade_button:set_on_click(function()
            -- Try to buy upgrade
            local success = manager_system.businesses.purchase_upgrade(upgrade.id)
            
            -- Refresh buttons after purchase
            if success then
                upgrades_view.init_upgrade_buttons()
            end
        end)
        
        table.insert(upgrade_buttons, {button = upgrade_button, upgrade = upgrade})
    end
end

function upgrades_view.update(dt)
    local window_width = love.graphics.getWidth()
    
    -- Update upgrade buttons
    for i, btn_data in ipairs(upgrade_buttons) do
        btn_data.button.x = window_width / 2 + 100
    end
    
    -- Update button states
    local mx, my = love.mouse.getPosition()
    local mouse_pressed = love.mouse.isDown(1)
    
    -- Update upgrade buttons
    for i, btn_data in ipairs(upgrade_buttons) do
        local upgrade = btn_data.upgrade
        -- Only enable if not purchased, meets requirements, and player has enough money
        local businesses = manager_system.businesses.get_businesses()
        local target_business = nil
        local meets_requirements = true
        
        if upgrade.business_index > 0 then
            target_business = businesses[upgrade.business_index]
            if target_business and target_business.owned < upgrade.required_businesses then
                meets_requirements = false
            end
        end
        
        local can_afford = shared_data.get_money() >= upgrade.cost
        btn_data.button:set_enabled(not upgrade.purchased and meets_requirements and can_afford)
        
        -- Visual feedback for button state
        if upgrade.purchased then
            btn_data.button.text = "PURCHASED"
            if visualization.button_styles.disabled then
                btn_data.button.style = visualization.button_styles.disabled
            end
        elseif not meets_requirements then
            btn_data.button.text = "LOCKED"
            if visualization.button_styles.warning then
                btn_data.button.style = visualization.button_styles.warning
            end
        elseif not can_afford then
            btn_data.button.text = "CAN'T AFFORD"
            if visualization.button_styles.disabled then
                btn_data.button.style = visualization.button_styles.disabled
            end
        else
            btn_data.button.text = "PURCHASE"
            if visualization.button_styles.accent then
                btn_data.button.style = visualization.button_styles.accent
            end
        end
        
        -- Update button state
        btn_data.button:update(dt, mx, my, mouse_pressed)
    end
end

function upgrades_view.draw(scroll_offset_y)
    local window_width = love.graphics.getWidth()
    local window_height = love.graphics.getHeight()
    
    -- Draw upgrades tab content
    love.graphics.setColor(visualization.colors.text)
    love.graphics.print("BUSINESS UPGRADES", 40, 200)
    
    -- Display upgrade info
    local upgrades = manager_system.businesses.get_business_upgrades()
    for i, upgrade in ipairs(upgrades) do
        local y = 240 + (i-1) * 80 - scroll_offset_y
        
        -- Skip if offscreen
        if y + 70 < 240 or y > window_height - 20 then
            goto continue_upgrades
        end
        
        -- Create upgrade panel with appropriate style
        local panel_color = visualization.colors.panel
        
        if upgrade.purchased then
            -- Green tint for purchased upgrades
            love.graphics.setColor(0.2, 0.4, 0.2, 1)
            visualization.draw_panel(40, y, window_width - 80, 70)
        elseif upgrade.business_index > 0 then
            -- Check requirements
            local businesses = manager_system.businesses.get_businesses()
            local target_business = businesses[upgrade.business_index]
            if target_business and target_business.owned < upgrade.required_businesses then
                -- Red tint for locked upgrades
                love.graphics.setColor(0.4, 0.2, 0.2, 1)
                visualization.draw_panel(40, y, window_width - 80, 70)
            else
                -- Normal panel for available upgrades
                visualization.draw_panel(40, y, window_width - 80, 70)
            end
        else
            -- Normal panel for available upgrades
            visualization.draw_panel(40, y, window_width - 80, 70)
        end
        
        -- Upgrade info
        love.graphics.setColor(visualization.colors.text)
        love.graphics.print(upgrade.name, 60, y + 10)
        
        love.graphics.setColor(visualization.colors.text_secondary)
        love.graphics.print(upgrade.description, 60, y + 30)
        
        -- Requirements info
        if upgrade.business_index > 0 and upgrade.required_businesses > 0 then
            local businesses = manager_system.businesses.get_businesses()
            local target_business = businesses[upgrade.business_index]
            if target_business then
                local req_text = "Requires: " .. upgrade.required_businesses .. " " .. target_business.name
                
                -- Color based on whether requirements are met
                if target_business.owned >= upgrade.required_businesses then
                    love.graphics.setColor(0, 0.8, 0, 1) -- Green for met requirements
                else
                    love.graphics.setColor(0.8, 0, 0, 1) -- Red for unmet requirements
                end
                
                love.graphics.print(req_text, 60, y + 50)
            end
        end
        
        -- Status and cost
        if upgrade.purchased then
            love.graphics.setColor(visualization.colors.success)
            love.graphics.print("PURCHASED", window_width - 270, y + 20)
        else
            love.graphics.setColor(visualization.colors.text)
            love.graphics.print("Cost: $" .. data_loader.format_number_to_two_decimals(upgrade.cost), window_width - 270, y + 20)
        end
        
        -- Draw buy button
        upgrade_buttons[i].button.y = y + 15
        upgrade_buttons[i].button:draw()
        
        ::continue_upgrades::
    end
end

function upgrades_view.mousepressed(x, y, button_num)
    -- Check upgrade buttons
    for _, btn_data in ipairs(upgrade_buttons) do
        if btn_data.button:mouse_pressed(x, y, button_num) then
            return true
        end
    end
    
    return false
end

return upgrades_view 