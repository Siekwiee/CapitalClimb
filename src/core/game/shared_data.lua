-- shared_data.lua
-- Module to share data between different game tabs

local shared_data = {}

-- Shared variables
local money = 0

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

return shared_data 