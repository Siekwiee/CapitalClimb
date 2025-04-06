-- game.lua
-- Main game module that sets up tabs and game logic

local game = {}
local game_state = require("src.core.game.game_state")
local save_manager = require("src.core.utils.save_manager")
local navbar = require("src.ui.navbar")  -- Import navbar
local shared_data = require("src.core.game.shared_data")
local manager_system = require("src.core.managers.manager_system")

-- Import tabs
local click_tab = require("src.tabs.click_tab.click_tab")
local business_tab = require("src.tabs.business_tab.business_tab")
local settings_tab = require("src.tabs.settings_tab.settings_tab")

-- Game variables
local current_tab = nil
local tabs = {
    click_tab = click_tab,
    business_tab = business_tab,
    settings_tab = settings_tab
}

-- Keep track of which tabs have been initialized
local initialized_tabs = {}

-- Font variables
local title_font = nil
local menu_font = nil
local default_game_font = nil

-- Initialize the game
function game.init()
    -- Initialize fonts first
    default_game_font = love.graphics.newFont(14)  -- Default size for game
    title_font = love.graphics.newFont(36)
    menu_font = love.graphics.newFont(20)
    
    -- Set default font
    love.graphics.setFont(default_game_font)

    -- Register main game state
    game_state.register("main_game", {
        enter = function()
            -- Reset to default game font
            love.graphics.setFont(default_game_font)
            
            -- Initialize with default tab
            current_tab = "click_tab"
            
            -- Try to load saved game data
            local loaded_save = save_manager.load()
            
            -- Apply display settings from loaded data
            local display_settings = shared_data.get_display_settings()
            if display_settings then
                love.window.setMode(
                    display_settings.width or 1280, 
                    display_settings.height or 720, 
                    {
                        fullscreen = display_settings.fullscreen or false,
                        resizable = true,
                        vsync = true
                    }
                )
            end
            
            -- Initialize manager system after display settings are applied
            manager_system.init()
            
            -- If save was loaded, restore upgrade levels
            if loaded_save then
                -- Get saved upgrades from shared data
                local saved_upgrades = shared_data.get_upgrades()
                if saved_upgrades and next(saved_upgrades) then
                    -- Get all upgrades from manager
                    local all_upgrades = manager_system.upgrades.get_all_upgrades()
                    
                    -- Restore each upgrade level
                    for _, upgrade in ipairs(all_upgrades) do
                        if saved_upgrades[upgrade.id] then
                            upgrade.level = saved_upgrades[upgrade.id]
                        end
                    end
                    
                    -- Recalculate all effects
                    manager_system.upgrades.recalculate_all_effects()
                end
            end
            
            -- Initialize all tabs once
            for tab_id, tab in pairs(tabs) do
                if tab.init and not initialized_tabs[tab_id] then
                    tab.init()
                    initialized_tabs[tab_id] = true
                end
            end
            
            -- Initialize navbar with the current tab
            navbar.init(current_tab)
            
            -- Update navbar with passive income
            navbar.set_passive_income(manager_system.income.get_passive_income())
        end,
        update = function(dt)
            -- Update manager system
            manager_system.update(dt)
            
            -- Update navbar animations
            navbar.update(dt)
            
            -- Update passive income amount in navbar
            navbar.set_passive_income(manager_system.income.get_passive_income())
            
            -- Update current tab
            if tabs[current_tab] and tabs[current_tab].update then
                tabs[current_tab].update(dt)
            end
            
            -- Update save manager (for autosave)
            save_manager.update(dt)
        end,
        draw = function()
            -- Draw current tab
            if tabs[current_tab] and tabs[current_tab].draw then
                tabs[current_tab].draw()
            end
        end,
        keypressed = function(key)
            -- Quick save with F5
            if key == "f5" then
                if save_manager.save() then
                    print("Game saved successfully!")
                end
                return
            end
            
            -- Quick load with F9
            if key == "f9" then
                if save_manager.load() then
                    print("Game loaded successfully!")
                end
                return
            end
            
            -- Send keypressed to current tab
            if tabs[current_tab] and tabs[current_tab].keypressed then
                tabs[current_tab].keypressed(key)
            end
        end,
        mousepressed = function(x, y, button)
            -- Send mousepressed to current tab and check for tab change request
            if tabs[current_tab] and tabs[current_tab].mousepressed then
                local new_tab = tabs[current_tab].mousepressed(x, y, button)
                if new_tab and tabs[new_tab] then
                    current_tab = new_tab
                    
                    -- Only initialize if it hasn't been initialized yet
                    if tabs[current_tab].init and not initialized_tabs[new_tab] then
                        tabs[current_tab].init()
                        initialized_tabs[new_tab] = true
                    end
                    
                    -- Just update navbar for the tab
                    if current_tab == "click_tab" then
                        navbar.init("click_tab")
                    elseif current_tab == "business_tab" then
                        navbar.init("business_tab")
                    elseif current_tab == "settings_tab" then
                        navbar.init("settings_tab")
                    end
                end
            end
        end,
        wheelmoved = function(x, y)
            -- Send wheelmoved to current tab
            if tabs[current_tab] and tabs[current_tab].wheelmoved then
                tabs[current_tab].wheelmoved(x, y)
            end
        end,
        exit = function()
            -- Save game when exiting
            save_manager.save()
        end
    })

    -- Register title screen
    game_state.register("title", {
        enter = function()
            -- Set title screen font
            love.graphics.setFont(title_font)
        end,
        draw = function()
            -- Get window dimensions for centered positioning
            local width, height = love.graphics.getDimensions()
            
            -- Draw a simple gradient background
            love.graphics.setColor(0.1, 0.2, 0.3, 1)
            love.graphics.rectangle("fill", 0, 0, width, height)
            
            -- Draw title with larger font
            love.graphics.setFont(title_font)
            love.graphics.setColor(1, 0.8, 0.2)  -- Gold color for title
            
            local title_text = "Capital Climb"
            local title_width = title_font:getWidth(title_text)
            love.graphics.print(title_text, (width - title_width) / 2, height / 3)
            
            -- Draw menu options
            love.graphics.setFont(menu_font)
            love.graphics.setColor(1, 1, 1, 0.9)
            
            local start_text = "Press Enter to start"
            local start_width = menu_font:getWidth(start_text)
            love.graphics.print(start_text, (width - start_width) / 2, height / 2)
            
            -- Show continue option if save exists
            if save_manager.has_save() then
                local load_text = "Press L to load saved game"
                local load_width = menu_font:getWidth(load_text)
                love.graphics.print(load_text, (width - load_width) / 2, height / 2 + 40)
            end
            
            -- Draw version info at the bottom
            love.graphics.setColor(1, 1, 1, 0.5)
            local version_text = "Version 0.3"
            love.graphics.print(version_text, 10, height - 30)
        end,
        keypressed = function(key)
            if key == "return" or key == "space" then
                game_state.change("main_game")
            elseif key == "l" and save_manager.has_save() then
                -- Load saved game and start
                save_manager.load()
                game_state.change("main_game")
            end
        end,
        mousepressed = function(x, y, button)
            if button == 1 then
                game_state.change("main_game")
            end
        end,
        exit = function()
            -- Clean up is not needed since we keep fonts for potential reuse
        end
    })

    -- Set initial state
    game_state.init("title")
end

-- Getter for passive income value (for API completeness)
function game.get_passive_income()
    return manager_system.income.get_passive_income()
end

-- Forward Love2D callbacks to the game_state manager
function game.update(dt)
    game_state.update(dt)
end

function game.draw()
    game_state.draw()
end

function game.keypressed(key)
    game_state.keypressed(key)
end

function game.mousepressed(x, y, button)
    game_state.mousepressed(x, y, button)
end

function game.wheelmoved(x, y)
    if game_state.wheelmoved then
        game_state.wheelmoved(x, y)
    end
end

function game.quit()
    -- Save game when exiting
    if game_state.get_current() == "main_game" then
        --save_manager.save()
    end
end

return game 