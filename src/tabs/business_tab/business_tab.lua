-- business_tab.lua
-- Business tab where players can buy businesses to earn passive income

local business_tab = {}
local navbar = require("src.ui.navbar")
local shared_data = require("src.core.game.shared_data")
local manager_system = require("src.core.managers.manager_system")
local data_loader = require("src.core.utils.data_loader")

-- Sub-module imports
local business_list_view = require("src.tabs.business_tab.views.business_list_view")
local upgrades_view = require("src.tabs.business_tab.views.upgrades_view")
local milestones_view = require("src.tabs.business_tab.views.milestones_view")
local tab_selector = require("src.tabs.business_tab.components.tab_selector")

-- Tab variables
local scroll_offset_y = 0
local showing_upgrades = false
local showing_milestones = false
local animation_time = 0

function business_tab.init()
    navbar.init("business_tab")
    animation_time = 0
    
    -- Initialize tab selector
    tab_selector.init(function(tab_id)
        if tab_id == "businesses" then
            showing_upgrades = false
            showing_milestones = false
        elseif tab_id == "upgrades" then
            showing_upgrades = true
            showing_milestones = false
        elseif tab_id == "milestones" then
            showing_upgrades = false
            showing_milestones = true
        end
        scroll_offset_y = 0
    end)
    
    -- Initialize views
    business_list_view.init()
    upgrades_view.init()
    milestones_view.init()
    
    -- Reset scroll position
    scroll_offset_y = 0
    
    -- Default to showing businesses
    showing_upgrades = false
    showing_milestones = false
end

function business_tab.update(dt)
    -- Update animation time
    animation_time = animation_time + dt
    
    -- Update tab selector
    tab_selector.update(dt)
    
    -- Update active view
    if showing_upgrades then
        upgrades_view.update(dt)
    elseif showing_milestones then
        milestones_view.update(dt, animation_time)
    else
        business_list_view.update(dt, animation_time)
    end
end

function business_tab.draw()
    local window_width = love.graphics.getWidth()
    local window_height = love.graphics.getHeight()
    
    -- Draw the navbar
    navbar.draw()
    
    -- Draw main panel and stats
    business_tab.draw_common_elements()
    
    -- Draw tab selector
    tab_selector.draw(showing_upgrades, showing_milestones)
    
    -- Draw active view
    if showing_upgrades then
        upgrades_view.draw(scroll_offset_y)
    elseif showing_milestones then
        milestones_view.draw(scroll_offset_y, animation_time)
    else
        business_list_view.draw(animation_time)
    end
end

function business_tab.draw_common_elements()
    local window_width = love.graphics.getWidth()
    local window_height = love.graphics.getHeight()
    
    -- Draw main panel
    require("src.ui.modules.visualization").draw_panel(20, 82, window_width - 40, window_height - 102)
    
    -- Draw stats panel (Increased height for token info)
    require("src.ui.modules.visualization").draw_panel(20, 100, 220, 140)
    
    -- Draw global business stats
    local visualization = require("src.ui.modules.visualization")
    love.graphics.setColor(visualization.colors.text)
    love.graphics.print("Money: $" .. data_loader.format_number_to_two_decimals(shared_data.get_money()), 40, 110)
    love.graphics.print("Passive Income: $" .. data_loader.format_number_to_two_decimals(manager_system.income.get_passive_income()) .. "/sec", 40, 140)
    -- Add token display and generation rate
    love.graphics.print("Tokens: T" .. data_loader.format_number_to_two_decimals(shared_data.get_tokens()), 40, 170)
    love.graphics.print("Token Gen: T" .. data_loader.format_number_to_two_decimals(manager_system.income.get_passive_token_generation()) .. "/sec", 40, 200)
    
    -- Draw businesses panel (moved down to accommodate larger stats panel)
    require("src.ui.modules.visualization").draw_panel(20, 250, window_width - 40, window_height - 270)
end

function business_tab.keypressed(key)
    -- No specific key handling for business tab
end

-- Add wheel moved handler
function business_tab.wheelmoved(x, y)
    if y ~= 0 then
        scroll_offset_y = scroll_offset_y - y * 20
        -- Limit scrolling
        scroll_offset_y = math.max(0, scroll_offset_y)
    end
end

function business_tab.mousepressed(x, y, button_num)
    if button_num == 1 then
        -- Check navbar clicks
        local tab_id = navbar.check_click(x, y)
        if tab_id then
            -- Signal to change tab
            return tab_id
        end
        
        -- Check tab selector clicks
        if tab_selector.mousepressed(x, y, button_num) then
            return nil
        end
        
        -- Check active view clicks
        if showing_upgrades then
            if upgrades_view.mousepressed(x, y, button_num) then
                return nil
            end
        elseif showing_milestones then
            if milestones_view.mousepressed(x, y, button_num) then
                return nil
            end
        else
            if business_list_view.mousepressed(x, y, button_num) then
                return nil
            end
        end
    end
    
    return nil
end

function business_tab.get_scroll_offset()
    return scroll_offset_y
end

return business_tab 