-- stats_manager.lua
-- Tracks player statistics across the game

local stats_manager = {}
local shared_data = require("src.core.game.shared_data")

-- Local variables for stats
local game_time = 0
local total_income_earned = 0
local total_clicks = 0
local total_businesses_purchased = 0

-- Initialize the stats manager
function stats_manager.init()
    -- Reset or initialize stats
    game_time = 0
    
    -- Set initial values from shared data
    total_clicks = shared_data.get_clicks()
end

-- Update function to track time
function stats_manager.update(dt)
    game_time = game_time + dt
end

-- Track a click
function stats_manager.track_click()
    total_clicks = total_clicks + 1
end

-- Track income earned
function stats_manager.track_income(amount)
    total_income_earned = total_income_earned + amount
end

-- Track business purchase
function stats_manager.track_business_purchase()
    total_businesses_purchased = total_businesses_purchased + 1
end

-- Get total play time in seconds
function stats_manager.get_play_time()
    return game_time
end

-- Get formatted play time as string (HH:MM:SS)
function stats_manager.get_formatted_play_time()
    local seconds = math.floor(game_time)
    local minutes = math.floor(seconds / 60)
    local hours = math.floor(minutes / 60)
    
    seconds = seconds % 60
    minutes = minutes % 60
    
    return string.format("%02d:%02d:%02d", hours, minutes, seconds)
end

-- Get total income earned
function stats_manager.get_total_income()
    return total_income_earned
end

-- Get total clicks
function stats_manager.get_total_clicks()
    return total_clicks
end

-- Get total businesses purchased
function stats_manager.get_total_businesses()
    return total_businesses_purchased
end

return stats_manager 