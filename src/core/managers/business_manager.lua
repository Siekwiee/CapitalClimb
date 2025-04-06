-- business_manager.lua
-- Manages all businesses in the game

local business_manager = {}
local shared_data = require("src.core.game.shared_data")
local data_loader = require("src.core.utils.data_loader")
local income_manager = require("src.core.managers.income_manager")

-- Local variables
local business_upgrades = {}
local business_milestones = {}
local completed_milestones = {}
local global_income_multiplier = 1.0
local global_cost_reduction = 0.0
local synergy_multipliers = {}

-- Initialize businesses from data or defaults
function business_manager.init()
    local businesses = shared_data.get_businesses()
    
    -- Only load default businesses if none exist yet
    if not businesses or #businesses == 0 then
        -- Try to load from JSON file
        local loaded_businesses = data_loader.load_json("src/data/tabs/available_businesses.json")
        
        if loaded_businesses then
            -- Add level property to each business
            for _, business in ipairs(loaded_businesses) do
                business.level = business.level or 1
                business.multiplier = business.multiplier or 1.0
            end
            shared_data.set_businesses(loaded_businesses)
        else
            -- Fallback default businesses if file can't be loaded
            shared_data.set_businesses({
                {
                    name = "Lemonade Stand",
                    cost = 10,
                    income = 2,
                    owned = 0,
                    level = 1,
                    multiplier = 1.0
                },
                {
                    name = "Coffee Shop",
                    cost = 200,
                    income = 10,
                    owned = 0,
                    level = 1,
                    multiplier = 1.0
                },
                {
                    name = "Restaurant",
                    cost = 1000,
                    income = 80,
                    owned = 0,
                    level = 1,
                    multiplier = 1.0
                }
            })
        end
    else
        -- Ensure all businesses have level and multiplier properties
        for i, business in ipairs(businesses) do
            business.level = business.level or 1
            business.multiplier = business.multiplier or 1.0
            shared_data.update_business(i, business)
        end
    end
    
    -- Load business upgrades
    local loaded_upgrades = data_loader.load_json("src/data/tabs/business_upgrades.json")
    if loaded_upgrades then
        business_upgrades = loaded_upgrades
        -- Add purchased field to each upgrade
        for i, upgrade in ipairs(business_upgrades) do
            business_upgrades[i].purchased = false
        end
    end
    
    -- Load business milestones
    local loaded_milestones = data_loader.load_json("src/data/tabs/business_milestones.json")
    if loaded_milestones then
        business_milestones = loaded_milestones
        -- Initialize completed milestones list
        completed_milestones = {}
    end
    
    -- Calculate initial passive income
    income_manager.calculate_passive_income()
end

-- Get all businesses
function business_manager.get_businesses()
    return shared_data.get_businesses()
end

-- Buy a business
function business_manager.buy_business(index)
    local businesses = shared_data.get_businesses()
    local business = businesses[index]
    
    if not business then
        return false, "Business not found"
    end
    
    local actual_cost = business.cost
    if global_cost_reduction > 0 then
        actual_cost = math.floor(actual_cost * (1.0 - global_cost_reduction))
    end
    
    if shared_data.get_money() < actual_cost then
        return false, "Not enough money"
    end
    
    -- Purchase the business
    shared_data.add_money(-actual_cost)
    business.owned = business.owned + 1
    shared_data.update_business(index, business)
    
    -- Check for milestones after purchase
    business_manager.check_milestones()
    
    -- Recalculate synergies
    business_manager.calculate_synergies()
    
    -- Recalculate passive income
    income_manager.calculate_passive_income()
    
    return true, business
end

-- Upgrade a business to the next level
function business_manager.upgrade_business_level(index)
    local businesses = shared_data.get_businesses()
    local business = businesses[index]
    
    if not business then
        return false, "Business not found"
    end
    
    -- Level upgrade cost formula: base_cost * level * 2
    local upgrade_cost = business.cost * business.level * 2
    
    if shared_data.get_money() < upgrade_cost then
        return false, "Not enough money"
    end
    
    -- Apply the upgrade
    shared_data.add_money(-upgrade_cost)
    business.level = business.level + 1
    
    -- Each level increases income by 50%
    business.income = math.floor(business.income * 1.5)
    
    shared_data.update_business(index, business)
    
    -- Recalculate passive income
    income_manager.calculate_passive_income()
    
    return true, business
end

-- Get the cost of a business
function business_manager.get_business_cost(index)
    local businesses = shared_data.get_businesses()
    local business = businesses[index]
    
    if not business then
        return 0
    end
    
    local cost = business.cost
    if global_cost_reduction > 0 then
        cost = math.floor(cost * (1.0 - global_cost_reduction))
    end
    
    return cost
end

-- Get the upgrade cost for a business level
function business_manager.get_business_upgrade_cost(index)
    local businesses = shared_data.get_businesses()
    local business = businesses[index]
    
    if not business then
        return 0
    end
    
    return business.cost * business.level * 2
end

-- Get the number of a specific business owned
function business_manager.get_business_owned(index)
    local businesses = shared_data.get_businesses()
    local business = businesses[index]
    
    if not business then
        return 0
    end
    
    return business.owned
end

-- Get all business upgrades
function business_manager.get_business_upgrades()
    return business_upgrades
end

-- Purchase a business upgrade
function business_manager.purchase_upgrade(upgrade_id)
    -- Find the upgrade
    local upgrade = nil
    for i, up in ipairs(business_upgrades) do
        if up.id == upgrade_id then
            upgrade = up
            upgrade_index = i
            break
        end
    end
    
    if not upgrade then
        return false, "Upgrade not found"
    end
    
    if upgrade.purchased then
        return false, "Upgrade already purchased"
    end
    
    -- Check if player meets requirements
    local businesses = shared_data.get_businesses()
    local target_business = businesses[upgrade.business_index]
    
    if upgrade.business_index > 0 and target_business and
       target_business.owned < upgrade.required_businesses then
        return false, "Not enough businesses owned"
    end
    
    if shared_data.get_money() < upgrade.cost then
        return false, "Not enough money"
    end
    
    -- Purchase the upgrade
    shared_data.add_money(-upgrade.cost)
    upgrade.purchased = true
    business_upgrades[upgrade_index] = upgrade
    
    -- Apply upgrade effect
    if upgrade.effect.type == "income_boost" and upgrade.business_index > 0 then
        -- Income boost for specific business
        local business = businesses[upgrade.business_index]
        business.multiplier = business.multiplier + upgrade.effect.value
        shared_data.update_business(upgrade.business_index, business)
    elseif upgrade.effect.type == "cost_reduction" and upgrade.business_index > 0 then
        -- Cost reduction for specific business
        local business = businesses[upgrade.business_index]
        business.cost = math.floor(business.cost * (1 - upgrade.effect.value))
        shared_data.update_business(upgrade.business_index, business)
    elseif upgrade.effect.type == "synergy_multiplier" then
        -- Create synergy between businesses
        synergy_multipliers[#synergy_multipliers + 1] = {
            businesses = upgrade.effect.businesses,
            value = upgrade.effect.value
        }
        business_manager.calculate_synergies()
    end
    
    -- Recalculate passive income
    income_manager.calculate_passive_income()
    
    return true, upgrade
end

-- Check for completed milestones
function business_manager.check_milestones()
    local businesses = shared_data.get_businesses()
    local total_businesses_owned = 0
    
    -- Count total businesses
    for _, business in ipairs(businesses) do
        total_businesses_owned = total_businesses_owned + business.owned
    end
    
    -- Get total income from stats manager
    local stats_manager = require("src.core.managers.stats_manager")
    local total_income = stats_manager.get_total_income()
    
    -- Check each milestone
    for i, milestone in ipairs(business_milestones) do
        -- Skip already completed milestones
        if not completed_milestones[milestone.id] then
            local completed = false
            
            if milestone.type == "business_count" and milestone.business_index > 0 then
                local target_business = businesses[milestone.business_index]
                if target_business and target_business.owned >= milestone.target then
                    completed = true
                end
            elseif milestone.type == "total_income" and total_income >= milestone.target then
                completed = true
            elseif milestone.type == "total_businesses" and total_businesses_owned >= milestone.target then
                completed = true
            end
            
            if completed then
                -- Mark as completed
                completed_milestones[milestone.id] = true
                
                -- Apply reward
                business_manager.apply_milestone_reward(milestone)
                
                -- Notify player (in a real game, you'd want a notification system)
                print("Milestone completed: " .. milestone.name)
            end
        end
    end
end

-- Apply milestone reward
function business_manager.apply_milestone_reward(milestone)
    local reward = milestone.reward
    local businesses = shared_data.get_businesses()
    
    if reward.type == "unlock_upgrade" then
        -- Find the upgrade and make it available
        for i, upgrade in ipairs(business_upgrades) do
            if upgrade.id == reward.upgrade_id then
                -- No action needed, just notify the player
                print("New upgrade available: " .. upgrade.name)
                break
            end
        end
    elseif reward.type == "unlock_business_bonus" and reward.business_index > 0 then
        -- Add bonus to specific business
        local business = businesses[reward.business_index]
        if business then
            business.multiplier = business.multiplier + reward.bonus_amount
            shared_data.update_business(reward.business_index, business)
        end
    elseif reward.type == "money_bonus" then
        -- Give money bonus
        shared_data.add_money(reward.amount)
    elseif reward.type == "global_income_multiplier" then
        -- Apply global income boost
        global_income_multiplier = global_income_multiplier + reward.value
    elseif reward.type == "global_cost_reduction" then
        -- Apply global cost reduction
        global_cost_reduction = global_cost_reduction + reward.value
    end
    
    -- Recalculate passive income
    income_manager.calculate_passive_income()
end

-- Calculate business synergies
function business_manager.calculate_synergies()
    local businesses = shared_data.get_businesses()
    
    -- Reset all multipliers to base value
    for i, business in ipairs(businesses) do
        business.multiplier = 1.0
        shared_data.update_business(i, business)
    end
    
    -- Apply synergy multipliers
    for _, synergy in ipairs(synergy_multipliers) do
        local synergy_active = true
        
        -- Check if all required businesses are owned
        for _, business_index in ipairs(synergy.businesses) do
            if business_index > 0 and business_index <= #businesses then
                if businesses[business_index].owned == 0 then
                    synergy_active = false
                    break
                end
            end
        end
        
        -- Apply synergy if active
        if synergy_active then
            for _, business_index in ipairs(synergy.businesses) do
                if business_index > 0 and business_index <= #businesses then
                    businesses[business_index].multiplier = 
                        businesses[business_index].multiplier + synergy.value
                    shared_data.update_business(business_index, businesses[business_index])
                end
            end
        end
    end
    
    -- Apply global income multiplier
    for i, business in ipairs(businesses) do
        business.multiplier = business.multiplier * global_income_multiplier
        shared_data.update_business(i, business)
    end
end

-- Get global income multiplier
function business_manager.get_global_income_multiplier()
    return global_income_multiplier
end

-- Get global cost reduction
function business_manager.get_global_cost_reduction()
    return global_cost_reduction
end

-- Get all milestones
function business_manager.get_milestones()
    return business_milestones, completed_milestones
end

return business_manager 