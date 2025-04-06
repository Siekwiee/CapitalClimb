-- save_manager.lua
-- Manages saving and loading game data

local save_manager = {}
local json = require("src.core.utils.json")
local shared_data = require("src.core.game.shared_data")
local manager_system = require("src.core.managers.manager_system")

-- Save file path - using an identity folder helps with Windows exe builds
local SAVE_FILE = "save_data.json"
local IDENTITY = "CapitalClimb"  -- Game identity for save directory

-- Debug mode flag (set to true for verbose output)
local DEBUG_MODE = false  -- Debug mode disabled for production

-- Print debug messages
local function debug_print(msg)
    if DEBUG_MODE then
        print("[SaveManager] " .. msg)
    end
end

-- Setup save directory
local function init_save_system()
    -- Set identity for save files - important for Windows exe builds
    love.filesystem.setIdentity(IDENTITY)
    debug_print("Save directory: " .. love.filesystem.getSaveDirectory())
end

-- Save game data to file
function save_manager.save()
    -- Make sure save system is initialized
    init_save_system()
    
    -- Get upgrades from manager
    local all_upgrades = manager_system.upgrades.get_all_upgrades()
    local upgrades_data = {}
    
    -- Create upgrade data for saving
    for _, upgrade in ipairs(all_upgrades) do
        upgrades_data[upgrade.id] = upgrade.level
    end
    
    -- Get stats from stats manager
    local stats_data = {
        play_time = manager_system.stats.get_play_time(),
        total_income = manager_system.stats.get_total_income(),
        total_clicks = manager_system.stats.get_total_clicks(),
        total_businesses = manager_system.stats.get_total_businesses()
    }
    
    local data = {
        -- Core data
        money = shared_data.get_money(),
        
        -- Click tab data
        clicks = shared_data.get_clicks(),
        upgrades = upgrades_data,
        
        -- Business tab data
        businesses = shared_data.get_businesses(),
        
        -- Stats data
        stats = stats_data,
        
        -- Display settings
        display_settings = shared_data.get_display_settings(),
        
        -- Timestamp
        timestamp = os.time()
    }
    
    -- Serialize to JSON and save to file
    local success, message = pcall(function()
        local json_str = json.encode(data)
        debug_print("Saving JSON data: " .. string.sub(json_str, 1, 100) .. "...")
        love.filesystem.write(SAVE_FILE, json_str)
    end)
    
    if not success then
        print("[SaveManager] Error saving game: " .. tostring(message))
        return false
    end
    
    debug_print("Game saved successfully to " .. love.filesystem.getSaveDirectory() .. "/" .. SAVE_FILE)
    debug_print("File exists: " .. tostring(love.filesystem.getInfo(SAVE_FILE) ~= nil))
    return true
end

-- Load game data from file
function save_manager.load()
    -- Make sure save system is initialized
    init_save_system()
    
    if not love.filesystem.getInfo(SAVE_FILE) then
        debug_print("No save file found at " .. love.filesystem.getSaveDirectory() .. "/" .. SAVE_FILE)
        return false
    end
    
    local json_str = love.filesystem.read(SAVE_FILE)
    if not json_str or json_str == "" then
        print("[SaveManager] Save file is empty or couldn't be read")
        return false
    end
    
    debug_print("Loading JSON data: " .. string.sub(json_str, 1, 100) .. "...")
    
    local success, data = pcall(function()
        return json.decode(json_str)
    end)
    
    if not success then
        print("[SaveManager] JSON decode error: " .. tostring(data))
        return false
    end
    
    if not data then
        print("[SaveManager] Decoded data is nil")
        return false
    end
    
    -- Restore money
    if data.money then
        debug_print("Restoring money: " .. tostring(data.money))
        shared_data.set_money(data.money)
    else
        debug_print("No money data found")
    end
    
    -- Restore click count
    if data.clicks then
        debug_print("Restoring clicks: " .. tostring(data.clicks))
        shared_data.set_clicks(data.clicks)
    else
        debug_print("No clicks data found")
    end
    
    -- Restore businesses
    if data.businesses then
        debug_print("Restoring businesses")
        shared_data.set_businesses(data.businesses)
    else
        debug_print("No businesses data found")
    end
    
    -- Restore display settings
    if data.display_settings then
        debug_print("Restoring display settings")
        debug_print("Width: " .. tostring(data.display_settings.width))
        debug_print("Height: " .. tostring(data.display_settings.height))
        debug_print("Fullscreen: " .. tostring(data.display_settings.fullscreen))
        shared_data.set_display_settings(data.display_settings)
    else
        debug_print("No display settings found")
    end
    
    -- Restore stats if available
    if data.stats then
        debug_print("Restoring stats")
        shared_data.set_stats(data.stats)
    else
        debug_print("No stats data found")
    end
    
    -- Restore upgrade levels
    if data.upgrades then
        debug_print("Restoring upgrades data to shared_data")
        shared_data.set_upgrades(data.upgrades)
    else
        debug_print("No upgrades data found")
    end
    
    -- Initialize the manager system (which will load from the shared data)
    -- This is now handled in game.lua after the display settings are applied
    
    debug_print("Game loaded successfully")
    return true
end

-- Auto-save feature
local autosave_timer = 0
local AUTOSAVE_INTERVAL = 60 -- 60 seconds

function save_manager.update(dt)
    autosave_timer = autosave_timer + dt
    if autosave_timer >= AUTOSAVE_INTERVAL then
        save_manager.save()
        autosave_timer = 0
    end
end

-- Check if save file exists
function save_manager.has_save()
    local exists = love.filesystem.getInfo(SAVE_FILE) ~= nil
    debug_print("Checking for save file: " .. (exists and "Found" or "Not found"))
    return exists
end

-- Toggle debug mode
function save_manager.set_debug(enabled)
    DEBUG_MODE = enabled
end

return save_manager 