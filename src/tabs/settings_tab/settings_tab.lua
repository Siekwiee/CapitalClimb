-- settings_tab.lua
-- Settings tab where players can adjust game settings

local settings_tab = {}
local navbar = require("src.ui.navbar")
local button = require("src.ui.modules.button")
local save_manager = require("src.core.utils.save_manager")

-- Settings variables
local settings = {
    fullscreen = false,
    width = 800,
    height = 600
}

-- UI Components
local fullscreen_button = nil
local resolution_buttons = {}
local apply_button = nil
local save_button = nil
local load_button = nil
local save_message = ""
local save_message_timer = 0

-- Available resolutions
local available_resolutions = {
    {width = 800, height = 600, label = "800 x 600"},
    {width = 1024, height = 768, label = "1024 x 768"},
    {width = 1280, height = 720, label = "1280 x 720"},
    {width = 1366, height = 768, label = "1366 x 768"},
    {width = 1920, height = 1080, label = "1920 x 1080"}
}

-- Initialize the tab
function settings_tab.init()
    navbar.init("settings_tab")
    
    -- Get current settings
    settings.fullscreen = love.window.getFullscreen()
    local current_width, current_height = love.window.getMode()
    settings.width = current_width
    settings.height = current_height
    
    -- Create fullscreen toggle button
    fullscreen_button = button.new(
        300, 100, 200, 50,
        settings.fullscreen and "Fullscreen: ON" or "Fullscreen: OFF",
        {
            normal = {0.3, 0.6, 0.9, 1.0},
            hover = {0.4, 0.7, 1.0, 1.0},
            pressed = {0.2, 0.5, 0.8, 1.0}
        }
    )
    
    fullscreen_button:set_on_click(function()
        settings.fullscreen = not settings.fullscreen
        fullscreen_button.text = settings.fullscreen and "Fullscreen: ON" or "Fullscreen: OFF"
    end)
    
    -- Create resolution buttons
    resolution_buttons = {}
    for i, res in ipairs(available_resolutions) do
        local y_pos = 170 + (i-1) * 60
        
        local is_selected = (res.width == settings.width and res.height == settings.height)
        local res_button = button.new(
            300, y_pos, 200, 50,
            res.label,
            {
                normal = is_selected and {0.2, 0.7, 0.3, 1.0} or {0.3, 0.6, 0.9, 1.0},
                hover = {0.4, 0.7, 1.0, 1.0},
                pressed = {0.2, 0.5, 0.8, 1.0}
            }
        )
        
        res_button:set_on_click(function()
            select_resolution(i)
        end)
        
        table.insert(resolution_buttons, {button = res_button, resolution = res})
    end
    
    -- Create apply button
    apply_button = button.new(
        300, 170 + #available_resolutions * 60, 200, 50,
        "Apply Settings",
        {
            normal = {0.2, 0.7, 0.3, 1.0},
            hover = {0.3, 0.8, 0.4, 1.0},
            pressed = {0.1, 0.6, 0.2, 1.0}
        }
    )
    
    apply_button:set_on_click(function()
        apply_settings()
    end)
    
    -- Create save game button
    save_button = button.new(
        500, 100, 200, 50,
        "Save Game",
        {
            normal = {0.2, 0.7, 0.3, 1.0},
            hover = {0.3, 0.8, 0.4, 1.0},
            pressed = {0.1, 0.6, 0.2, 1.0}
        }
    )
    
    save_button:set_on_click(function()
        if save_manager.save() then
            save_message = "Game saved successfully!"
            save_message_timer = 3 -- Display for 3 seconds
        else
            save_message = "Failed to save game."
            save_message_timer = 3
        end
    end)
    
    -- Create load game button
    load_button = button.new(
        500, 160, 200, 50,
        "Load Game",
        {
            normal = {0.3, 0.6, 0.9, 1.0},
            hover = {0.4, 0.7, 1.0, 1.0},
            pressed = {0.2, 0.5, 0.8, 1.0}
        }
    )
    
    load_button:set_on_click(function()
        if save_manager.load() then
            save_message = "Game loaded successfully!"
            save_message_timer = 3
        else
            save_message = "No save data found."
            save_message_timer = 3
        end
    end)
end

-- Select a resolution
function select_resolution(index)
    settings.width = available_resolutions[index].width
    settings.height = available_resolutions[index].height
    
    -- Update button colors to show selection
    for i, btn_data in ipairs(resolution_buttons) do
        local is_selected = (i == index)
        btn_data.button.colors.normal = is_selected and {0.2, 0.7, 0.3, 1.0} or {0.3, 0.6, 0.9, 1.0}
    end
end

-- Apply the settings
function apply_settings()
    love.window.setMode(settings.width, settings.height, {
        fullscreen = settings.fullscreen,
        resizable = true,
        vsync = true
    })
end

-- Update function
function settings_tab.update(dt)
    -- Update button states
    local mx, my = love.mouse.getPosition()
    local mouse_pressed = love.mouse.isDown(1)
    
    fullscreen_button:update(mx, my, mouse_pressed)
    apply_button:update(mx, my, mouse_pressed)
    save_button:update(mx, my, mouse_pressed)
    load_button:update(mx, my, mouse_pressed)
    
    for _, btn_data in ipairs(resolution_buttons) do
        btn_data.button:update(mx, my, mouse_pressed)
    end
    
    -- Update save message timer
    if save_message_timer > 0 then
        save_message_timer = save_message_timer - dt
        if save_message_timer <= 0 then
            save_message = ""
        end
    end
end

-- Draw function
function settings_tab.draw()
    -- Draw the navbar
    navbar.draw()
    
    -- Draw the content area (below navbar)
    love.graphics.setColor(0.15, 0.15, 0.15)
    love.graphics.rectangle("fill", 0, 50, love.graphics.getWidth(), love.graphics.getHeight() - 50)
    
    -- Draw settings title
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("GAME SETTINGS", 300, 70)
    
    -- Draw fullscreen button
    fullscreen_button:draw()
    
    -- Draw resolution section title
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("SCREEN RESOLUTION", 300, 150)
    
    -- Draw resolution buttons
    for _, btn_data in ipairs(resolution_buttons) do
        btn_data.button:draw()
    end
    
    -- Draw apply button
    apply_button:draw()
    
    -- Draw game save/load section
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("GAME DATA", 500, 70)
    
    -- Draw save and load buttons
    save_button:draw()
    load_button:draw()
    
    -- Draw save message if there is one
    if save_message ~= "" then
        love.graphics.setColor(1, 1, 0)
        love.graphics.print(save_message, 500, 220)
    end
    
    -- Draw save shortcuts info
    love.graphics.setColor(0.8, 0.8, 0.8)
    love.graphics.print("Quick Save: F5", 500, 250)
    love.graphics.print("Quick Load: F9", 500, 270)
end

-- Key press handler
function settings_tab.keypressed(key)
    -- No specific key handling for settings tab
end

-- Mouse press handler
function settings_tab.mousepressed(x, y, button_num)
    if button_num == 1 then
        -- Check navbar clicks
        local tab_id = navbar.check_click(x, y)
        if tab_id then
            -- Signal to change tab
            return tab_id
        end
        
        -- Check fullscreen button
        if fullscreen_button:mouse_pressed(x, y, button_num) then
            return nil
        end
        
        -- Check resolution buttons
        for _, btn_data in ipairs(resolution_buttons) do
            if btn_data.button:mouse_pressed(x, y, button_num) then
                return nil
            end
        end
        
        -- Check apply button
        if apply_button:mouse_pressed(x, y, button_num) then
            return nil
        end
        
        -- Check save button
        if save_button:mouse_pressed(x, y, button_num) then
            return nil
        end
        
        -- Check load button
        if load_button:mouse_pressed(x, y, button_num) then
            return nil
        end
    end
    
    return nil
end

return settings_tab 