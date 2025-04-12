-- business_tab.lua
-- Business tab where players can buy businesses to earn passive income

local business_tab = {}
local navbar = require("src.ui.navbar")
local shared_data = require("src.core.game.shared_data")
local button = require("src.ui.modules.button.button")
local visualization = require("src.ui.modules.visualization")
local manager_system = require("src.core.managers.manager_system")

-- Tab variables
local business_buttons = {}
local upgrade_buttons = {}
local level_up_buttons = {}
local selected_business = nil
local scroll_offset_y = 0
local showing_upgrades = false
local showing_milestones = false
local animation_time = 0
local tab_buttons = {}

function business_tab.init()
    navbar.init("business_tab")
    animation_time = 0
    
    -- Create tab buttons first
    tab_buttons = {}
    local tab_width = 120
    local tab_height = 40
    local tab_spacing = 10
    local start_x = 290
    
    -- Business tab button
    local business_button = button.new(
        start_x, 110, tab_width, tab_height,
        "BUSINESSES",
        "text_only"
    )
    business_button:set_on_click(function()
        showing_upgrades = false
        showing_milestones = false
    end)
    table.insert(tab_buttons, {button = business_button, id = "businesses"})
    
    -- Upgrades tab button
    local upgrades_button = button.new(
        start_x + tab_width + tab_spacing, 110, tab_width, tab_height,
        "UPGRADES",
        "text_only"
    )
    upgrades_button:set_on_click(function()
        showing_upgrades = true
        showing_milestones = false
        scroll_offset_y = 0
    end)
    table.insert(tab_buttons, {button = upgrades_button, id = "upgrades"})
    
    -- Milestones tab button
    local milestones_button = button.new(
        start_x + (tab_width + tab_spacing) * 2, 110, tab_width, tab_height,
        "MILESTONES",
        "text_only"
    )
    milestones_button:set_on_click(function()
        showing_upgrades = false
        showing_milestones = true
        scroll_offset_y = 0
    end)
    table.insert(tab_buttons, {button = milestones_button, id = "milestones"})
    
    -- Create business buy buttons
    business_buttons = {}
    level_up_buttons = {}
    upgrade_buttons = {}
    
    local businesses = manager_system.businesses.get_businesses()
    for i, business in ipairs(businesses) do
        local y = 240 + (i-1) * 90
        
        -- Buy button
        local buy_button = button.new(
            love.graphics.getWidth() - 140, y + 20, 100, 40,
            "BUY",
            "secondary"
        )
        
        buy_button:set_on_click(function()
            -- Try to buy business
            manager_system.buy_business(i)
        end)
        
        table.insert(business_buttons, {button = buy_button, business_index = i})
        
        -- Level up button
        local level_button = button.new(
            love.graphics.getWidth() - 400, y + 20, 100, 40,
            "LEVEL UP",
            "primary"
        )
        
        level_button:set_on_click(function()
            -- Try to level up business
            manager_system.businesses.upgrade_business_level(i)
        end)
        
        table.insert(level_up_buttons, {button = level_button, business_index = i})
    end
    
    -- Initialize upgrade buttons
    business_tab.init_upgrade_buttons()
    
    -- Reset scroll position
    scroll_offset_y = 0
    
    -- Default to not showing special panels
    showing_upgrades = false
    showing_milestones = false
    
    -- No selected business by default
    selected_business = nil
end

function business_tab.init_upgrade_buttons()
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
                business_tab.init_upgrade_buttons()
            end
        end)
        
        table.insert(upgrade_buttons, {button = upgrade_button, upgrade = upgrade})
    end
end

function business_tab.update(dt)
    -- Update animation time
    animation_time = animation_time + dt
    
    -- Update button positions on window resize
    local window_width = love.graphics.getWidth()
    
    -- Update tab button positions
    local tab_width = 120
    local tab_spacing = 10
    local start_x = 290
    for i, btn_data in ipairs(tab_buttons) do
        btn_data.button.x = start_x + (i-1) * (tab_width + tab_spacing)
    end
    
    -- Update business buy buttons
    for i, btn_data in ipairs(business_buttons) do
        btn_data.button.x = window_width - 140
    end
    
    -- Update level up buttons
    for i, btn_data in ipairs(level_up_buttons) do
        btn_data.button.x = window_width - 400
    end
    
    -- Update upgrade buttons
    for i, btn_data in ipairs(upgrade_buttons) do
        btn_data.button.x = window_width / 2 + 100
    end
    
    -- Update button states
    local mx, my = love.mouse.getPosition()
    local mouse_pressed = love.mouse.isDown(1)
    
    -- Update tab buttons
    for i, btn_data in ipairs(tab_buttons) do
        -- Set active state for tab buttons
        if (btn_data.id == "businesses" and not showing_upgrades and not showing_milestones) or
           (btn_data.id == "upgrades" and showing_upgrades) or
           (btn_data.id == "milestones" and showing_milestones) then
            -- Make sure style exists before setting it
            if visualization.button_styles.primary then
                btn_data.button.style = visualization.button_styles.primary
            end
        else
            -- Make sure style exists before setting it
            if visualization.button_styles.text_only then
                btn_data.button.style = visualization.button_styles.text_only
            end
        end
        
        btn_data.button:update(dt, mx, my, mouse_pressed)
    end
    
    -- Update business buy buttons
    local businesses = manager_system.businesses.get_businesses()
    for i, btn_data in ipairs(business_buttons) do
        local business = businesses[btn_data.business_index]
        -- Update button enabled state based on money
        local cost = manager_system.businesses.get_business_cost(btn_data.business_index)
        local can_afford = shared_data.get_money() >= cost
        btn_data.button:set_enabled(can_afford)
        -- Update button state
        btn_data.button:update(dt, mx, my, mouse_pressed)
    end
    
    -- Update level up buttons
    for i, btn_data in ipairs(level_up_buttons) do
        local business = businesses[btn_data.business_index]
        -- Only enable if business is owned and player has enough money
        local upgrade_cost = manager_system.businesses.get_business_upgrade_cost(btn_data.business_index)
        local can_afford = business.owned > 0 and shared_data.get_money() >= upgrade_cost
        btn_data.button:set_enabled(can_afford)
        -- Update button state
        btn_data.button:update(dt, mx, my, mouse_pressed)
    end
    
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
        if showing_upgrades then
            btn_data.button:update(dt, mx, my, mouse_pressed)
        end
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
    
    -- Draw global business stats
    love.graphics.setColor(visualization.colors.text)
    love.graphics.print("Money: $" .. shared_data.get_money(), 40, 110)
    love.graphics.print("Passive Income: $" .. manager_system.income.get_passive_income() .. "/sec", 40, 140)
    
    -- Draw tab buttons
    for _, btn_data in ipairs(tab_buttons) do
        btn_data.button:draw()
    end
    
    -- Draw businesses panel
    visualization.draw_panel(20, 190, window_width - 40, window_height - 210)
    
    -- Get global multipliers for info display
    local global_income_multi = manager_system.businesses.get_global_income_multiplier()
    local global_cost_reduction = manager_system.businesses.get_global_cost_reduction()
    
    if showing_upgrades then
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
                love.graphics.print("Cost: $" .. upgrade.cost, window_width - 270, y + 20)
            end
            
            -- Draw buy button
            upgrade_buttons[i].button.y = y + 15
            upgrade_buttons[i].button:draw()
            
            ::continue_upgrades::
        end
    elseif showing_milestones then
        -- Draw milestones tab content
        love.graphics.setColor(visualization.colors.text)
        love.graphics.print("BUSINESS MILESTONES", 40, 200)
        
        -- Get milestones data
        local milestones, completed = manager_system.businesses.get_milestones()
        
        -- Display milestone info
        for i, milestone in ipairs(milestones) do
            local y = 240 + (i-1) * 70 - scroll_offset_y
            
            -- Skip if offscreen
            if y + 60 < 240 or y > window_height - 20 then
                goto continue_milestones
            end
            
            -- Create milestone panel with status color
            if completed[milestone.id] then
                -- Green background pulse animation for completed milestones
                local alpha = 0.1 + math.abs(math.sin(animation_time * 2)) * 0.1
                love.graphics.setColor(0.2, 0.6, 0.2, alpha)
                love.graphics.rectangle("fill", 40, y, window_width - 80, 60)
                visualization.draw_panel(40, y, window_width - 80, 60)
            else
                -- Get progress towards milestone for visual representation
                local progress = 0
                local progress_text = ""
                
                if milestone.type == "business_count" and milestone.business_index > 0 then
                    local businesses = manager_system.businesses.get_businesses()
                    local target_business = businesses[milestone.business_index]
                    if target_business then
                        progress = math.min(1.0, target_business.owned / milestone.target)
                        progress_text = target_business.owned .. "/" .. milestone.target
                    end
                elseif milestone.type == "total_income" then
                    local total_income = manager_system.stats.get_total_income()
                    progress = math.min(1.0, total_income / milestone.target)
                    progress_text = math.floor(total_income) .. "/" .. milestone.target
                elseif milestone.type == "total_businesses" then
                    local total_businesses = 0
                    local businesses = manager_system.businesses.get_businesses()
                    for _, business in ipairs(businesses) do
                        total_businesses = total_businesses + business.owned
                    end
                    progress = math.min(1.0, total_businesses / milestone.target)
                    progress_text = total_businesses .. "/" .. milestone.target
                end
                
                -- Draw progress bar background
                love.graphics.setColor(0.2, 0.2, 0.3, 0.5)
                love.graphics.rectangle("fill", 40, y, window_width - 80, 60)
                
                -- Draw progress bar
                if progress > 0 then
                    local bar_width = (window_width - 80) * progress
                    love.graphics.setColor(0.3, 0.4, 0.6, 0.5)
                    love.graphics.rectangle("fill", 40, y, bar_width, 60)
                end
                
                visualization.draw_panel(40, y, window_width - 80, 60)
            end
            
            -- Milestone info
            love.graphics.setColor(visualization.colors.text)
            love.graphics.print(milestone.name, 60, y + 10)
            love.graphics.setColor(visualization.colors.text_secondary)
            love.graphics.print(milestone.description, 60, y + 30)
            
            -- Status and reward
            if completed[milestone.id] then
                love.graphics.setColor(visualization.colors.success)
                love.graphics.print("COMPLETED", window_width - 300, y + 15)
            else
                love.graphics.setColor(visualization.colors.text)
                love.graphics.print("IN PROGRESS", window_width - 300, y + 15)
            end
            
            -- Reward description
            love.graphics.setColor(visualization.colors.text_secondary)
            local reward_text = "Reward: "
            if milestone.reward.type == "unlock_upgrade" then
                reward_text = reward_text .. "Unlock New Upgrade"
            elseif milestone.reward.type == "money_bonus" then
                reward_text = reward_text .. "$" .. milestone.reward.amount .. " Bonus"
            elseif milestone.reward.type == "global_income_multiplier" then
                reward_text = reward_text .. "+" .. (milestone.reward.value * 100) .. "% Global Income"
            elseif milestone.reward.type == "global_cost_reduction" then
                reward_text = reward_text .. (milestone.reward.value * 100) .. "% Cost Reduction"
            end
            love.graphics.print(reward_text, window_width - 300, y + 35)
            
            ::continue_milestones::
        end
    else
        -- Draw businesses tab content (default view)
        love.graphics.setColor(visualization.colors.text)
        love.graphics.print("BUSINESSES", 40, 200)
        
        -- Display global modifiers if active
        if global_income_multi > 1.0 then
            love.graphics.setColor(0, 0.8, 0, 1)
            love.graphics.print("Global Income Multiplier: +" .. math.floor((global_income_multi - 1.0) * 100) .. "%", window_width - 400, 200)
        end
        
        if global_cost_reduction > 0 then
            love.graphics.setColor(0, 0.8, 0, 1)
            love.graphics.print("Global Cost Reduction: " .. math.floor(global_cost_reduction * 100) .. "%", window_width - 400, 220)
        end
        
        local businesses = manager_system.businesses.get_businesses()
        for i, business in ipairs(businesses) do
            local y = 240 + (i-1) * 90
            
            -- Create business panel with pulsing effect for businesses that can be afforded
            local cost = manager_system.businesses.get_business_cost(i)
            local can_afford = shared_data.get_money() >= cost
            local upgrade_cost = manager_system.businesses.get_business_upgrade_cost(i)
            local can_upgrade = business.owned > 0 and shared_data.get_money() >= upgrade_cost
            
            visualization.draw_panel(40, y, window_width - 80, 80)
            
            -- Add affordability indicator
            if can_afford or (business.owned > 0 and can_upgrade) then
                -- Pulsing effect for affordable businesses
                local alpha = 0.05 + math.abs(math.sin(animation_time * 3)) * 0.1
                love.graphics.setColor(0, 0.8, 0, alpha)
                love.graphics.rectangle("fill", 40, y, 8, 80)
            end
            
            -- Business info
            love.graphics.setColor(visualization.colors.text)
            love.graphics.print(business.name .. " (Level " .. business.level .. ")", 60, y + 10)
            
            -- Cost with reduction if applicable
            local actual_cost = manager_system.businesses.get_business_cost(i)
            if can_afford then
                love.graphics.setColor(0, 0.8, 0, 1) -- Green for affordable
            else
                love.graphics.setColor(visualization.colors.text_secondary)
            end
            
            if global_cost_reduction > 0 then
                love.graphics.print("Cost: $" .. actual_cost .. " (reduced from $" .. business.cost .. ")", 60, y + 30)
            else
                love.graphics.print("Cost: $" .. actual_cost, 60, y + 30)
            end
            
            -- Income with multiplier if applicable
            love.graphics.setColor(visualization.colors.text_secondary)
            local income_text = "Income: $" .. business.income
            if business.multiplier > 1.0 then
                local actual_income = math.floor(business.income * business.multiplier)
                income_text = income_text .. " x" .. string.format("%.2f", business.multiplier) .. " = $" .. actual_income
            end
            love.graphics.print(income_text .. "/sec", 60, y + 50)
            
            -- Ownership info
            love.graphics.setColor(visualization.colors.text)
            love.graphics.print("Owned: " .. business.owned, window_width - 270, y + 10)
            
            -- Level up cost
            if business.owned > 0 then
                if can_upgrade then
                    love.graphics.setColor(0, 0.8, 0, 1) -- Green for affordable
                else
                    love.graphics.setColor(visualization.colors.text_secondary)
                end
                love.graphics.print("Upgrade: $" .. upgrade_cost, window_width - 270, y + 50)
                
                -- Draw level up button
                level_up_buttons[i].button:draw()
            end
            
            -- Draw buy button
            if business_buttons[i] then
                business_buttons[i].button:draw()
            end
        end
    end
end

function business_tab.keypressed(key)
    -- No specific key handling for business tab
end

-- Add wheel moved handler
function business_tab.wheelmoved(x, y)
    if y ~= 0 then
        scroll_offset_y = scroll_offset_y - y * 20
        -- Limit scrolling
        scroll_offset_y = math.max(0, scroll_offset_y)
    end
end

function business_tab.mousepressed(x, y, button_num)
    if button_num == 1 then
        -- Check navbar clicks
        local tab_id = navbar.check_click(x, y)
        if tab_id then
            -- Signal to change tab
            return tab_id
        end
        
        -- Check tab buttons
        for _, btn_data in ipairs(tab_buttons) do
            if btn_data.button:mouse_pressed(x, y, button_num) then
                return nil
            end
        end
        
        -- Check business buy buttons
        if not showing_upgrades and not showing_milestones then
            for _, btn_data in ipairs(business_buttons) do
                if btn_data.button:mouse_pressed(x, y, button_num) then
                    return nil
                end
            end
            
            -- Check level up buttons
            for _, btn_data in ipairs(level_up_buttons) do
                if btn_data.button:mouse_pressed(x, y, button_num) then
                    return nil
                end
            end
        elseif showing_upgrades then
            -- Check upgrade buttons
            for _, btn_data in ipairs(upgrade_buttons) do
                if btn_data.button:mouse_pressed(x, y, button_num) then
                    return nil
                end
            end
        end
    end
    
    return nil
end

return business_tab 