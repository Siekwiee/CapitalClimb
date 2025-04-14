-- business_list_view.lua
-- Handles the display and interaction with the business list

local business_list_view = {}
local button = require("src.ui.modules.button.button")
local visualization = require("src.ui.modules.visualization")
local shared_data = require("src.core.game.shared_data")
local manager_system = require("src.core.managers.manager_system")
local data_loader = require("src.core.utils.data_loader")

-- Local variables
local business_buttons = {}
local level_up_buttons = {}

function business_list_view.init()
    -- Create business buy buttons
    business_buttons = {}
    level_up_buttons = {}
    
    local businesses = manager_system.businesses.get_businesses()
    for i, business in ipairs(businesses) do
        local y = 300 + (i-1) * 90
        
        -- Buy button
        local buy_button = button.new(
            love.graphics.getWidth() - 140, y + 20, 100, 40,
            "BUY",
            "secondary"
        )
        
        buy_button:set_on_click(function()
            -- Try to buy business
            local success = manager_system.buy_business(i)
            
            -- Force recalculation if purchase was successful
            if success then
                manager_system.income.calculate_passive_income()
            end
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
            local success = manager_system.businesses.upgrade_business_level(i)
            
            -- Force recalculation if upgrade was successful
            if success then
                manager_system.income.calculate_passive_income()
            end
        end)
        
        table.insert(level_up_buttons, {button = level_button, business_index = i})
    end
end

function business_list_view.update(dt, animation_time)
    local window_width = love.graphics.getWidth()
    
    -- Force recalculation of passive income and token generation
    manager_system.income.calculate_passive_income()
    
    -- Update business buy buttons
    for i, btn_data in ipairs(business_buttons) do
        btn_data.button.x = window_width - 140
    end
    
    -- Update level up buttons
    for i, btn_data in ipairs(level_up_buttons) do
        btn_data.button.x = window_width - 400
    end
    
    -- Update button states
    local mx, my = love.mouse.getPosition()
    local mouse_pressed = love.mouse.isDown(1)
    
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
end

function business_list_view.draw(animation_time)
    local window_width = love.graphics.getWidth()
    local window_height = love.graphics.getHeight()
    
    -- Get global multipliers for info display
    local global_income_multi = manager_system.businesses.get_global_income_multiplier()
    local global_cost_reduction = manager_system.businesses.get_global_cost_reduction()
    
    -- Draw businesses tab content (default view)
    love.graphics.setColor(visualization.colors.text)
    love.graphics.print("BUSINESSES", 40, 260)
    
    -- Display global modifiers if active
    if global_income_multi > 1.0 then
        love.graphics.setColor(0, 0.8, 0, 1)
        love.graphics.print("Global Income Multiplier: +" .. data_loader.format_number_to_two_decimals((global_income_multi - 1.0) * 100) .. "%", window_width - 400, 260)
    end
    
    if global_cost_reduction > 0 then
        love.graphics.setColor(0, 0.8, 0, 1)
        love.graphics.print("Global Cost Reduction: " .. data_loader.format_number_to_two_decimals(global_cost_reduction * 100) .. "%", window_width - 400, 280)
    end
    
    local businesses = manager_system.businesses.get_businesses()
    for i, business in ipairs(businesses) do
        local y = 300 + (i-1) * 90
        
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
            love.graphics.print("Cost: $" .. data_loader.format_number_to_two_decimals(actual_cost) .. " (reduced from $" .. data_loader.format_number_to_two_decimals(business.cost) .. ")", 60, y + 30)
        else
            love.graphics.print("Cost: $" .. data_loader.format_number_to_two_decimals(actual_cost), 60, y + 30)
        end
        
        -- Income with multiplier if applicable
        love.graphics.setColor(visualization.colors.text_secondary)
        if business.income and business.income > 0 then
            local income_text = "Income: $" .. data_loader.format_number_to_two_decimals(business.income)
            if business.multiplier > 1.0 then
                local actual_income = math.floor(business.income * business.multiplier)
                income_text = income_text .. " x" .. data_loader.format_number_to_two_decimals(business.multiplier) .. " = $" .. data_loader.format_number_to_two_decimals(actual_income)
            end
            love.graphics.print(income_text .. "/sec", 60, y + 50)
        elseif business.token_generation and business.token_generation > 0 then
            -- Display token generation for businesses like Casino
            local token_text = "Tokens: T" .. data_loader.format_number_to_two_decimals(business.token_generation)
            if business.multiplier > 1.0 then
                local actual_tokens = math.floor(business.token_generation * business.multiplier)
                token_text = token_text .. " x" .. data_loader.format_number_to_two_decimals(business.multiplier) .. " = T" .. data_loader.format_number_to_two_decimals(actual_tokens)
            end
            love.graphics.print(token_text .. "/sec", 60, y + 50)
        end
        
        -- Ownership info
        love.graphics.setColor(visualization.colors.text)
        love.graphics.print("Owned: " .. data_loader.format_number_to_two_decimals(business.owned), window_width - 270, y + 10)
        
        -- Level up cost
        if business.owned > 0 then
            if can_upgrade then
                love.graphics.setColor(0, 0.8, 0, 1) -- Green for affordable
            else
                love.graphics.setColor(visualization.colors.text_secondary)
            end
            love.graphics.print("Upgrade: $" .. data_loader.format_number_to_two_decimals(upgrade_cost), window_width - 270, y + 50)
            
            -- Draw level up button
            level_up_buttons[i].button:draw()
        end
        
        -- Draw buy button
        if business_buttons[i] then
            business_buttons[i].button:draw()
        end
    end
end

function business_list_view.mousepressed(x, y, button_num)
    -- Check business buy buttons
    for _, btn_data in ipairs(business_buttons) do
        if btn_data.button:mouse_pressed(x, y, button_num) then
            return true
        end
    end
    
    -- Check level up buttons
    for _, btn_data in ipairs(level_up_buttons) do
        if btn_data.button:mouse_pressed(x, y, button_num) then
            return true
        end
    end
    
    return false
end

return business_list_view 