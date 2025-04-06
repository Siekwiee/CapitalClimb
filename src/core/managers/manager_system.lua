-- manager_system.lua
-- Central manager system that controls all individual managers

local manager_system = {}

-- Import all managers
local income_manager = require("src.core.managers.income_manager")
local upgrade_manager = require("src.core.managers.upgrade_manager")
local business_manager = require("src.core.managers.business_manager")
local stats_manager = require("src.core.managers.stats_manager")

-- Track passive income update timer
local last_update_time = 0
local update_interval = 1  -- 1 second passive income tick

-- Initialize all managers
function manager_system.init()
    -- Initialize managers in correct order
    business_manager.init()
    income_manager.calculate_passive_income()
    upgrade_manager.init()
    stats_manager.init()
    
    -- Set initial timer
    last_update_time = love.timer.getTime()
end

-- Update all managers
function manager_system.update(dt)
    -- Update stats tracking
    stats_manager.update(dt)
    
    -- Update income manager (for auto-clicking)
    income_manager.update(dt)
    
    -- Process passive income on a timer
    local current_time = love.timer.getTime()
    if current_time - last_update_time >= update_interval then
        local income_earned = income_manager.process_passive_income_tick()
        stats_manager.track_income(income_earned)
        last_update_time = current_time
    end
end

-- Process a click
function manager_system.process_click()
    local income_earned = income_manager.process_click()
    stats_manager.track_click()
    stats_manager.track_income(income_earned)
end

-- Buy a business
function manager_system.buy_business(index)
    local success, result = business_manager.buy_business(index)
    if success then
        stats_manager.track_business_purchase()
    end
    return success, result
end

-- Purchase an upgrade
function manager_system.purchase_upgrade(id, money)
    return upgrade_manager.upgrade_item(id, money)
end

-- Expose managers through the manager system
manager_system.income = income_manager
manager_system.upgrades = upgrade_manager
manager_system.businesses = business_manager
manager_system.stats = stats_manager

return manager_system 