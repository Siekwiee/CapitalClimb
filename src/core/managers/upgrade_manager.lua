-- upgrade_manager.lua
-- Manages all upgrades across different tabs

local upgrade_manager = {}
local shared_data = require("src.core.game.shared_data")
local income_manager = require("src.core.managers.income_manager")

-- List of all available upgrades
local upgrades = {
    {
        id = "finger_strength",
        name = "Finger Strength",
        description = "Increase money per click by 1",
        base_cost = 50,
        base_effect = 0.5,
        max_level = 10,
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
        id = "double_click",
        name = "Double Click",
        description = "5% chance to click twice",
        base_cost = 100,
        base_effect = 0.02,
        max_level = 5,
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
    },
    {
        id = "auto_clicker",
        name = "Auto Clicker",
        description = "Automatically clicks once per second",
        base_cost = 200,
        base_effect = 0.5,
        max_level = 3,
        level = 0,
        cost_multiplier = 4,
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

-- Initialize the upgrade manager (call once at game start)
function upgrade_manager.init()
    -- Apply upgrade effects
    upgrade_manager.recalculate_all_effects()
end

-- Get all upgrades
function upgrade_manager.get_all_upgrades()
    return upgrades
end

-- Find an upgrade by ID
function upgrade_manager.get_upgrade(id)
    for _, upgrade in ipairs(upgrades) do
        if upgrade.id == id then
            return upgrade
        end
    end
    return nil
end

-- Upgrade an item to the next level
function upgrade_manager.upgrade_item(id, money)
    for _, upgrade in ipairs(upgrades) do
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
            
            -- Recalculate effects
            upgrade_manager.recalculate_all_effects()
            
            return true, cost  -- Return success and cost
        end
    end
    return false, "Upgrade not found"
end

-- Recalculate all upgrade effects
function upgrade_manager.recalculate_all_effects()
    -- Reset to base values
    income_manager.set_money_per_click(1)
    income_manager.set_double_click_chance(0)
    income_manager.set_auto_click_rate(0)
    
    -- Apply all upgrade effects
    for _, upgrade in ipairs(upgrades) do
        local effect = upgrade:get_effect()
        
        if upgrade.id == "finger_strength" then
            income_manager.set_money_per_click(1 + effect)
        elseif upgrade.id == "double_click" then
            income_manager.set_double_click_chance(effect)
        elseif upgrade.id == "auto_clicker" then
            income_manager.set_auto_click_rate(effect)
        end
    end
end

return upgrade_manager 