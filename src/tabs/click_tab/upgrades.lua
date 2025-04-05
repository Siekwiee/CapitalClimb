-- upgrades.lua
-- Defines upgrades for the clicker functionality

local upgrades = {}

-- List of available upgrades
upgrades.items = {
    {
        id = "finger_strength",
        name = "Finger Strength",
        description = "Increase money per click by 1",
        base_cost = 10,
        base_effect = 1,
        max_level = 10,
        level = 0,
        cost_multiplier = 1.5,  -- Each level becomes 1.5x more expensive
        get_cost = function(self)
            return math.floor(self.base_cost * (self.cost_multiplier ^ self.level))
        end,
        get_effect = function(self)
            return self.base_effect * self.level
        end,
        get_next_effect = function(self)
            if self.level >= self.max_level then return 0 end
            return self.base_effect * (self.level + 1)
        end
    },
    {
        id = "double_click",
        name = "Double Click",
        description = "5% chance to click twice",
        base_cost = 50,
        base_effect = 0.05,  -- 5% per level
        max_level = 5,
        level = 0,
        cost_multiplier = 2,
        get_cost = function(self)
            return math.floor(self.base_cost * (self.cost_multiplier ^ self.level))
        end,
        get_effect = function(self)
            return self.base_effect * self.level
        end,
        get_next_effect = function(self)
            if self.level >= self.max_level then return 0 end
            return self.base_effect * (self.level + 1)
        end
    },
    {
        id = "auto_clicker",
        name = "Auto Clicker",
        description = "Automatically clicks once per second",
        base_cost = 100,
        base_effect = 1,  -- 1 click per second per level
        max_level = 3,
        level = 0,
        cost_multiplier = 3,
        get_cost = function(self)
            return math.floor(self.base_cost * (self.cost_multiplier ^ self.level))
        end,
        get_effect = function(self)
            return self.base_effect * self.level
        end,
        get_next_effect = function(self)
            if self.level >= self.max_level then return 0 end
            return self.base_effect * (self.level + 1)
        end
    }
}

-- Calculate current money per click based on upgrades
function upgrades.calculate_money_per_click()
    -- Start with base value of 1
    local money_per_click = 1
    
    -- Add finger strength upgrade
    for _, upgrade in ipairs(upgrades.items) do
        if upgrade.id == "finger_strength" then
            money_per_click = money_per_click + upgrade:get_effect()
        end
    end
    
    return money_per_click
end

-- Check if a double click should happen based on upgrades
function upgrades.should_double_click()
    for _, upgrade in ipairs(upgrades.items) do
        if upgrade.id == "double_click" then
            -- Random chance based on upgrade level
            return math.random() < upgrade:get_effect()
        end
    end
    return false
end

-- Get auto-click rate (clicks per second)
function upgrades.get_auto_click_rate()
    for _, upgrade in ipairs(upgrades.items) do
        if upgrade.id == "auto_clicker" then
            return upgrade:get_effect()
        end
    end
    return 0
end

-- Upgrade an item to the next level
function upgrades.upgrade_item(id, money)
    for _, upgrade in ipairs(upgrades.items) do
        if upgrade.id == id then
            -- Check if max level reached
            if upgrade.level >= upgrade.max_level then
                return false, "Max level reached"
            end
            
            -- Check if enough money
            local cost = upgrade:get_cost()
            if money < cost then
                return false, "Not enough money"
            end
            
            -- Perform upgrade
            upgrade.level = upgrade.level + 1
            return true, cost  -- Return success and cost
        end
    end
    return false, "Upgrade not found"
end

return upgrades 