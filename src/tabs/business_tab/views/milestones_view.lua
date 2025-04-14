-- milestones_view.lua
-- Handles the display of business milestones

local milestones_view = {}
local visualization = require("src.ui.modules.visualization")
local manager_system = require("src.core.managers.manager_system")
local data_loader = require("src.core.utils.data_loader")

function milestones_view.init()
    -- No initialization needed for milestones view
end

function milestones_view.update(dt, animation_time)
    -- No update needed for milestones view
end

function milestones_view.draw(scroll_offset_y, animation_time)
    local window_width = love.graphics.getWidth()
    local window_height = love.graphics.getHeight()
    
    -- Draw milestones tab content
    love.graphics.setColor(visualization.colors.text)
    love.graphics.print("BUSINESS MILESTONES", 40, 200)
    
    -- Get milestones data
    local milestones, completed = manager_system.businesses.get_milestones()
    
    -- Display milestone info
    for i, milestone in ipairs(milestones) do
        local y = 240 + (i-1) * 70 - scroll_offset_y
        
        -- Skip if offscreen
        if y + 60 < 240 or y > window_height - 20 then
            goto continue_milestones
        end
        
        -- Create milestone panel with status color
        if completed[milestone.id] then
            -- Green background pulse animation for completed milestones
            local alpha = 0.1 + math.abs(math.sin(animation_time * 2)) * 0.1
            love.graphics.setColor(0.2, 0.6, 0.2, alpha)
            love.graphics.rectangle("fill", 40, y, window_width - 80, 60)
            visualization.draw_panel(40, y, window_width - 80, 60)
        else
            -- Get progress towards milestone for visual representation
            local progress = 0
            local progress_text = ""
            
            if milestone.type == "business_count" and milestone.business_index > 0 then
                local businesses = manager_system.businesses.get_businesses()
                local target_business = businesses[milestone.business_index]
                if target_business then
                    progress = math.min(1.0, target_business.owned / milestone.target)
                    progress_text = target_business.owned .. "/" .. milestone.target
                end
            elseif milestone.type == "total_income" then
                local total_income = manager_system.stats.get_total_income()
                progress = math.min(1.0, total_income / milestone.target)
                progress_text = data_loader.format_number_to_two_decimals(total_income) .. "/" .. milestone.target
            elseif milestone.type == "total_businesses" then
                local total_businesses = 0
                local businesses = manager_system.businesses.get_businesses()
                for _, business in ipairs(businesses) do
                    total_businesses = total_businesses + business.owned
                end
                progress = math.min(1.0, total_businesses / milestone.target)
                progress_text = data_loader.format_number_to_two_decimals(total_businesses) .. "/" .. milestone.target
            end
            
            -- Draw progress bar background
            love.graphics.setColor(0.2, 0.2, 0.3, 0.5)
            love.graphics.rectangle("fill", 40, y, window_width - 80, 60)
            
            -- Draw progress bar
            if progress > 0 then
                local bar_width = (window_width - 80) * progress
                love.graphics.setColor(0.3, 0.4, 0.6, 0.5)
                love.graphics.rectangle("fill", 40, y, bar_width, 60)
            end
            
            visualization.draw_panel(40, y, window_width - 80, 60)
        end
        
        -- Milestone info
        love.graphics.setColor(visualization.colors.text)
        love.graphics.print(milestone.name, 60, y + 10)
        love.graphics.setColor(visualization.colors.text_secondary)
        love.graphics.print(milestone.description, 60, y + 30)
        
        -- Status and reward
        if completed[milestone.id] then
            love.graphics.setColor(visualization.colors.success)
            love.graphics.print("COMPLETED", window_width - 300, y + 15)
        else
            love.graphics.setColor(visualization.colors.text)
            love.graphics.print("IN PROGRESS", window_width - 300, y + 15)
        end
        
        -- Reward description
        love.graphics.setColor(visualization.colors.text_secondary)
        local reward_text = "Reward: "
        if milestone.reward.type == "unlock_upgrade" then
            reward_text = reward_text .. "Unlock New Upgrade"
        elseif milestone.reward.type == "money_bonus" then
            reward_text = reward_text .. "$" .. data_loader.format_number_to_two_decimals(milestone.reward.amount) .. " Bonus"
        elseif milestone.reward.type == "global_income_multiplier" then
            reward_text = reward_text .. "+" .. data_loader.format_number_to_two_decimals(milestone.reward.value * 100) .. "% Global Income"
        elseif milestone.reward.type == "global_cost_reduction" then
            reward_text = reward_text .. data_loader.format_number_to_two_decimals(milestone.reward.value * 100) .. "% Cost Reduction"
        end
        love.graphics.print(reward_text, window_width - 300, y + 35)
        
        ::continue_milestones::
    end
end

function milestones_view.mousepressed(x, y, button_num)
    -- No clickable elements in milestones view
    return false
end

return milestones_view 