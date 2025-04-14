-- tab_selector.lua
-- Handles the tab selection UI for business tab

local tab_selector = {}
local button = require("src.ui.modules.button.button")
local visualization = require("src.ui.modules.visualization")

-- Tab buttons
local tab_buttons = {}
local callback = nil

function tab_selector.init(on_tab_selected)
    -- Store callback
    callback = on_tab_selected
    
    -- Create tab buttons
    tab_buttons = {}
    local tab_width = 120
    local tab_height = 40
    local tab_spacing = 10
    local start_x = 290
    
    -- Business tab button
    local business_button = button.new(
        start_x, 110, tab_width, tab_height,
        "BUSINESSES",
        "text_only"
    )
    business_button:set_on_click(function()
        if callback then
            callback("businesses")
        end
    end)
    table.insert(tab_buttons, {button = business_button, id = "businesses"})
    
    -- Upgrades tab button
    local upgrades_button = button.new(
        start_x + tab_width + tab_spacing, 110, tab_width, tab_height,
        "UPGRADES",
        "text_only"
    )
    upgrades_button:set_on_click(function()
        if callback then
            callback("upgrades")
        end
    end)
    table.insert(tab_buttons, {button = upgrades_button, id = "upgrades"})
    
    -- Milestones tab button
    local milestones_button = button.new(
        start_x + (tab_width + tab_spacing) * 2, 110, tab_width, tab_height,
        "MILESTONES",
        "text_only"
    )
    milestones_button:set_on_click(function()
        if callback then
            callback("milestones")
        end
    end)
    table.insert(tab_buttons, {button = milestones_button, id = "milestones"})
end

function tab_selector.update(dt)
    -- Update button positions on window resize
    local tab_width = 120
    local tab_spacing = 10
    local start_x = 290
    for i, btn_data in ipairs(tab_buttons) do
        btn_data.button.x = start_x + (i-1) * (tab_width + tab_spacing)
    end
    
    -- Update button states
    local mx, my = love.mouse.getPosition()
    local mouse_pressed = love.mouse.isDown(1)
    
    for i, btn_data in ipairs(tab_buttons) do
        btn_data.button:update(dt, mx, my, mouse_pressed)
    end
end

function tab_selector.draw(showing_upgrades, showing_milestones)
    -- Update visual state of buttons based on which tab is active
    for i, btn_data in ipairs(tab_buttons) do
        -- Set active state for tab buttons
        if (btn_data.id == "businesses" and not showing_upgrades and not showing_milestones) or
           (btn_data.id == "upgrades" and showing_upgrades) or
           (btn_data.id == "milestones" and showing_milestones) then
            -- Make sure style exists before setting it
            if visualization.button_styles.primary then
                btn_data.button.style = visualization.button_styles.primary
            end
        else
            -- Make sure style exists before setting it
            if visualization.button_styles.text_only then
                btn_data.button.style = visualization.button_styles.text_only
            end
        end
        
        -- Draw the button
        btn_data.button:draw()
    end
end

function tab_selector.mousepressed(x, y, button_num)
    for _, btn_data in ipairs(tab_buttons) do
        if btn_data.button:mouse_pressed(x, y, button_num) then
            return true
        end
    end
    return false
end

return tab_selector 