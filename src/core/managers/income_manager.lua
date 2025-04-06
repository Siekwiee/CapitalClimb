-- income_manager.lua
-- Manages all income sources for the game (passive, clicks, etc.)

local income_manager = {}
local shared_data = require("src.core.game.shared_data")

-- Local variables
local passive_income = 0
local money_per_click = 1
local click_double_chance = 0
local auto_click_rate = 0
local auto_click_timer = 0

-- Calculate the current passive income from businesses
function income_manager.calculate_passive_income()
    local total = 0
    local businesses = shared_data.get_businesses()
    
    for _, business in ipairs(businesses) do
        total = total + (business.income * business.owned)
    end
    
    passive_income = total
    return passive_income
end

-- Get current passive income
function income_manager.get_passive_income()
    return passive_income
end

-- Process passive income tick - returns the amount earned
function income_manager.process_passive_income_tick()
    shared_data.add_money(passive_income)
    return passive_income
end

-- Process a click (manually or auto)
function income_manager.process_click()
    shared_data.add_clicks(1)
    
    -- Add money based on current money_per_click
    shared_data.add_money(money_per_click)
    
    -- Check for double click chance
    if math.random() < click_double_chance then
        shared_data.add_money(money_per_click)
    end
    
    return money_per_click
end

-- Update function (for auto-clicking)
function income_manager.update(dt)
    -- Auto-click functionality
    if auto_click_rate > 0 then
        auto_click_timer = auto_click_timer + dt
        
        -- Time to auto-click?
        if auto_click_timer >= (1 / auto_click_rate) then
            income_manager.process_click()
            auto_click_timer = 0
        end
    end
end

-- Set the money per click value
function income_manager.set_money_per_click(value)
    money_per_click = value
end

-- Get the money per click value
function income_manager.get_money_per_click()
    return money_per_click
end

-- Set the double click chance
function income_manager.set_double_click_chance(chance)
    click_double_chance = chance
end

-- Get the double click chance
function income_manager.get_double_click_chance()
    return click_double_chance
end

-- Set the auto click rate (clicks per second)
function income_manager.set_auto_click_rate(rate)
    auto_click_rate = rate
end

-- Get the auto click rate
function income_manager.get_auto_click_rate()
    return auto_click_rate
end

return income_manager 