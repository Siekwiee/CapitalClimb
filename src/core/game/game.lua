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

-- Initialize the game
function game.init()
    -- Register main game state
    game_state.register("main_game", {
        enter = function()
            -- Initialize with default tab
            current_tab = "click_tab"
            
            -- Try to load saved game data
            save_manager.load()
            
            -- Initialize manager system first
            manager_system.init()
            
            -- Initialize all tabs once
            for tab_id, tab in pairs(tabs) do
                if tab.init and not initialized_tabs[tab_id] then
                    tab.init()
                    initialized_tabs[tab_id] = true
                end
            end
            
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
        exit = function()
            -- Save game when exiting
            save_manager.save()
        end
    })

    -- Register title screen
    game_state.register("title", {
        draw = function()
            love.graphics.setColor(1, 1, 1)
            love.graphics.print("Capital Climb", 300, 200)
            love.graphics.print("Press Enter to start", 270, 250)
            
            -- Show continue option if save exists
            if save_manager.has_save() then
                love.graphics.print("Press L to load saved game", 260, 280)
            end
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

function game.quit()
    -- Save game when exiting
    if game_state.get_current() == "main_game" then
        save_manager.save()
    end
end

return game 