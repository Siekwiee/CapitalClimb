-- shared_data.lua
-- Module to share data between different game tabs

local shared_data = {}

-- Shared variables
local money = 0
local clicks = 0
local businesses = {}

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

return shared_data 