-- business_tab.lua
-- Business tab where players can buy businesses to earn passive income

local business_tab = {}
local navbar = require("src.ui.navbar")
local shared_data = require("src.core.game.shared_data")
local data_loader = require("src.core.utils.data_loader")

-- Tab variables
local passive_income = 0
local last_update_time = 0
local update_interval = 1  -- 1 second passive income tick

-- Load businesses from JSON
local businesses = {}

local function load_businesses()
    -- Try to load from JSON file
    local loaded_businesses = data_loader.load_json("src/data/tabs/available_businesses.json")
    
    if loaded_businesses then
        businesses = loaded_businesses
    else
        -- Fallback default businesses if file can't be loaded
        businesses = {
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
        }
    end
    
    -- Calculate initial passive income based on owned businesses
    passive_income = 0
    for _, business in ipairs(businesses) do
        passive_income = passive_income + (business.income * business.owned)
    end
end

function business_tab.init()
    navbar.init("business_tab")
    last_update_time = love.timer.getTime()
    load_businesses()
end

function business_tab.update(dt)
    -- Calculate passive income
    local current_time = love.timer.getTime()
    if current_time - last_update_time >= update_interval then
        shared_data.add_money(passive_income)
        last_update_time = current_time
    end
end

function business_tab.draw()
    -- Draw the navbar
    navbar.draw()
    
    -- Draw the content area (below navbar)
    love.graphics.setColor(0.15, 0.15, 0.15)
    love.graphics.rectangle("fill", 0, 50, love.graphics.getWidth(), love.graphics.getHeight() - 50)
    
    -- Draw business info
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Money: $" .. shared_data.get_money(), 50, 70)
    love.graphics.print("Passive Income: $" .. passive_income .. "/sec", 50, 100)
    
    -- Draw business list
    love.graphics.print("BUSINESSES", 50, 140)
    
    for i, business in ipairs(businesses) do
        local y = 170 + (i-1) * 80
        
        -- Business info
        love.graphics.print(business.name, 50, y)
        love.graphics.print("Cost: $" .. business.cost, 50, y + 20)
        love.graphics.print("Income: $" .. business.income .. "/sec", 50, y + 40)
        love.graphics.print("Owned: " .. business.owned, 250, y + 20)
        
        -- Buy button
        if shared_data.get_money() >= business.cost then
            love.graphics.setColor(0.2, 0.7, 0.3)
        else
            love.graphics.setColor(0.5, 0.5, 0.5)
        end
        
        love.graphics.rectangle("fill", 350, y + 10, 120, 40)
        love.graphics.setColor(1, 1, 1)
        love.graphics.print("BUY", 395, y + 25)
    end
end

function business_tab.keypressed(key)
    -- Handle keypress for business tab
end

function business_tab.mousepressed(x, y, button)
    if button == 1 then
        -- Check navbar clicks
        local tab_id = navbar.check_click(x, y)
        if tab_id then
            -- Signal to change tab
            return tab_id
        end
        
        -- Check buy buttons
        for i, business in ipairs(businesses) do
            local button_y = 170 + (i-1) * 80 + 10
            if x >= 350 and x <= 470 and y >= button_y and y <= button_y + 40 then
                -- Try to buy business
                if shared_data.get_money() >= business.cost then
                    shared_data.add_money(-business.cost)
                    business.owned = business.owned + 1
                    -- Update passive income
                    passive_income = passive_income + business.income
                end
            end
        end
    end
    
    return nil
end

return business_tab 