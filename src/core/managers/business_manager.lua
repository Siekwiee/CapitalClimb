-- business_manager.lua
-- Manages all businesses in the game

local business_manager = {}
local shared_data = require("src.core.game.shared_data")
local data_loader = require("src.core.utils.data_loader")
local income_manager = require("src.core.managers.income_manager")

-- Initialize businesses from data or defaults
function business_manager.init()
    local businesses = shared_data.get_businesses()
    
    -- Only load default businesses if none exist yet
    if not businesses or #businesses == 0 then
        -- Try to load from JSON file
        local loaded_businesses = data_loader.load_json("src/data/tabs/available_businesses.json")
        
        if loaded_businesses then
            shared_data.set_businesses(loaded_businesses)
        else
            -- Fallback default businesses if file can't be loaded
            shared_data.set_businesses({
                {
                    name = "Lemonade Stand",
                    cost = 10,
                    income = 2,
                    owned = 0
                },
                {
                    name = "Coffee Shop",
                    cost = 200,
                    income = 10,
                    owned = 0
                },
                {
                    name = "Restaurant",
                    cost = 1000,
                    income = 80,
                    owned = 0
                }
            })
        end
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
    
    if shared_data.get_money() < business.cost then
        return false, "Not enough money"
    end
    
    -- Purchase the business
    shared_data.add_money(-business.cost)
    business.owned = business.owned + 1
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
    
    return business.cost
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

return business_manager 