-- shared_data.lua
-- Module to share data between different game tabs

local shared_data = {}

-- Shared variables
local money = 0
local clicks = 0
local businesses = {}
local upgrades = {}
local stats = {}
local display_settings = {
    fullscreen = false,
    width = 1920,
    height = 1080
}

-- Getters and setters for money
function shared_data.get_money()
    return money
end

function shared_data.add_money(amount)
    money = money + amount
end

function shared_data.set_money(amount)
    money = amount
end

-- Getters and setters for clicks
function shared_data.get_clicks()
    return clicks
end

function shared_data.add_clicks(amount)
    clicks = clicks + amount
end

function shared_data.set_clicks(amount)
    clicks = amount
end

-- Getters and setters for businesses
function shared_data.get_businesses()
    return businesses
end

function shared_data.set_businesses(new_businesses)
    businesses = new_businesses
end

function shared_data.update_business(index, new_business)
    businesses[index] = new_business
end

-- Getters and setters for upgrades
function shared_data.get_upgrades()
    return upgrades
end

function shared_data.set_upgrades(new_upgrades)
    upgrades = new_upgrades
end

function shared_data.update_upgrade(id, new_upgrade)
    for i, upgrade in ipairs(upgrades) do
        if upgrade.id == id then
            upgrades[i] = new_upgrade
            return true
        end
    end
    return false
end

-- Getters and setters for stats
function shared_data.get_stats()
    return stats
end

function shared_data.set_stats(new_stats)
    stats = new_stats
end

-- Getters and setters for display settings
function shared_data.get_display_settings()
    return display_settings
end

function shared_data.set_display_settings(new_settings)
    display_settings = new_settings
end

return shared_data 