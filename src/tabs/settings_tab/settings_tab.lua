-- settings_tab.lua
-- Settings tab where players can adjust game settings

local settings_tab = {}
local navbar = require("src.ui.navbar")
local button = require("src.ui.modules.button")
local save_manager = require("src.core.utils.save_manager")
local visualization = require("src.ui.modules.visualization")
local shared_data = require("src.core.game.shared_data")
local manager_system = require("src.core.managers.manager_system")

-- Settings variables
local settings = {
    fullscreen = false,
    width = 1280,
    height = 720
}

-- UI Components
local fullscreen_button = nil
local resolution_buttons = {}
local apply_button = nil
local save_button = nil
local load_button = nil
local save_message = ""
local save_message_timer = 0

-- Available resolutions - minimum of 1280x720
local available_resolutions = {
    {width = 1280, height = 720, label = "1280 x 720"},
    {width = 1366, height = 768, label = "1366 x 768"},
    {width = 1600, height = 900, label = "1600 x 900"},
    {width = 1920, height = 1080, label = "1920 x 1080"},
    {width = 2560, height = 1440, label = "2560 x 1440"}
}

-- Initialize the tab
function settings_tab.init()
    navbar.init("settings_tab")
    
    -- Get current settings
    settings.fullscreen = love.window.getFullscreen()
    local current_width, current_height = love.window.getMode()
    settings.width = current_width
    settings.height = current_height
    
    -- Enforce minimum resolution of 1280x720
    if settings.width < 1280 or settings.height < 720 then
        settings.width = 1280
        settings.height = 720
        apply_settings()
    end
    
    -- Create fullscreen toggle button
    fullscreen_button = button.new(
        100, 140, 200, 50,
        settings.fullscreen and "Fullscreen: ON" or "Fullscreen: OFF",
        "primary"
    )
    
    fullscreen_button:set_on_click(function()
        settings.fullscreen = not settings.fullscreen
        fullscreen_button.text = settings.fullscreen and "Fullscreen: ON" or "Fullscreen: OFF"
    end)
    
    -- Create resolution buttons
    resolution_buttons = {}
    for i, res in ipairs(available_resolutions) do
        local y_pos = 220 + (i-1) * 60
        
        local is_selected = (res.width == settings.width and res.height == settings.height)
        local style = is_selected and "secondary" or "primary"
        
        local res_button = button.new(
            100, y_pos, 200, 50,
            res.label,
            style
        )
        
        res_button:set_on_click(function()
            select_resolution(i)
        end)
        
        table.insert(resolution_buttons, {button = res_button, resolution = res})
    end
    
    -- Create apply button
    apply_button = button.new(
        100, 220 + #available_resolutions * 60, 200, 50,
        "Apply Settings",
        "accent"
    )
    
    apply_button:set_on_click(function()
        apply_settings()
        save_settings()
    end)
    
    -- Create save game button
    save_button = button.new(
        love.graphics.getWidth() - 300, 140, 200, 50,
        "Save Game",
        "secondary"
    )
    
    save_button:set_on_click(function()
        save_settings()
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
        love.graphics.getWidth() - 300, 200, 200, 50,
        "Load Game",
        "primary"
    )
    
    load_button:set_on_click(function()
        if save_manager.load() then
            load_settings()
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
    
    -- Update button styles to show selection
    for i, btn_data in ipairs(resolution_buttons) do
        -- Use secondary style for selected and primary for others
        local style = (i == index) and "secondary" or "primary"
        btn_data.button.style = visualization.button_styles[style]
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

-- Save settings to game data
function save_settings()
    -- Store display settings in shared data for saving
    shared_data.set_display_settings({
        fullscreen = settings.fullscreen,
        width = settings.width,
        height = settings.height
    })
end

-- Load settings from game data
function load_settings()
    -- Get display settings from shared data
    local display_settings = shared_data.get_display_settings()
    if display_settings then
        settings.fullscreen = display_settings.fullscreen
        settings.width = display_settings.width
        settings.height = display_settings.height
        
        -- Update fullscreen button text
        if fullscreen_button then
            fullscreen_button.text = settings.fullscreen and "Fullscreen: ON" or "Fullscreen: OFF"
        end
        
        -- Update resolution button styles
        for i, btn_data in ipairs(resolution_buttons) do
            local res = btn_data.resolution
            local is_selected = (res.width == settings.width and res.height == settings.height)
            local style = is_selected and "secondary" or "primary"
            btn_data.button.style = visualization.button_styles[style]
        end
        
        -- Apply loaded settings
        apply_settings()
    end
end

-- Update function
function settings_tab.update(dt)
    -- Update button positions on window resize
    local window_width = love.graphics.getWidth()
    save_button.x = window_width - 300
    load_button.x = window_width - 300
    
    -- Update button states
    local mx, my = love.mouse.getPosition()
    local mouse_pressed = love.mouse.isDown(1)
    
    fullscreen_button:update(dt, mx, my, mouse_pressed)
    apply_button:update(dt, mx, my, mouse_pressed)
    save_button:update(dt, mx, my, mouse_pressed)
    load_button:update(dt, mx, my, mouse_pressed)
    
    for _, btn_data in ipairs(resolution_buttons) do
        btn_data.button:update(dt, mx, my, mouse_pressed)
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
    local window_width = love.graphics.getWidth()
    local window_height = love.graphics.getHeight()
    
    -- Draw the navbar
    navbar.draw()
    
    -- Draw the content area (below navbar)
    love.graphics.setColor(visualization.colors.background)
    love.graphics.rectangle("fill", 0, 62, window_width, window_height - 62)
    
    -- Draw main panel
    visualization.draw_panel(20, 82, window_width - 40, window_height - 102)
    
    -- Draw window settings panel
    visualization.draw_panel(40, 100, 320, window_height - 140)
    
    -- Draw game data panel
    visualization.draw_panel(window_width - 360, 100, 320, 260)
    
    -- Draw settings title
    love.graphics.setColor(visualization.colors.text)
    love.graphics.print("WINDOW SETTINGS", 50, 110)
    
    -- Draw fullscreen button
    fullscreen_button:draw()
    
    -- Draw resolution options
    love.graphics.setColor(visualization.colors.text)
    love.graphics.print("RESOLUTION", 50, 200)
    
    -- Draw resolution buttons
    for _, btn_data in ipairs(resolution_buttons) do
        btn_data.button:draw()
    end
    
    -- Draw apply button
    apply_button:draw()
    
    -- Draw game data panel title
    love.graphics.setColor(visualization.colors.text)
    love.graphics.print("GAME DATA", window_width - 350, 110)
    
    -- Draw save/load buttons
    save_button:draw()
    load_button:draw()
    
    -- Draw save message if any
    if save_message ~= "" then
        love.graphics.setColor(visualization.colors.text_secondary)
        love.graphics.print(save_message, window_width - 350, 260)
    end
    
    -- Draw game statistics panel
    visualization.draw_panel(window_width - 360, 380, 320, 200)
    
    -- Draw stats title
    love.graphics.setColor(visualization.colors.text)
    love.graphics.print("GAME STATISTICS", window_width - 350, 390)
    
    -- Draw game statistics from stats manager
    love.graphics.setColor(visualization.colors.text_secondary)
    love.graphics.print("Play time: " .. manager_system.stats.get_formatted_play_time(), window_width - 350, 420)
    love.graphics.print("Total clicks: " .. manager_system.stats.get_total_clicks(), window_width - 350, 450)
    love.graphics.print("Total income earned: $" .. manager_system.stats.get_total_income(), window_width - 350, 480)
    love.graphics.print("Total businesses owned: " .. manager_system.stats.get_total_businesses(), window_width - 350, 510)
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