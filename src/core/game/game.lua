-- game.lua
-- Main game module that sets up tabs and game logic

local game = {}
local game_state = require("src.core.game.game_state")

-- Import tabs
local click_tab = require("src.tabs.click_tab.click_tab")
local business_tab = require("src.tabs.business_tab.business_tab")

-- Game variables
local current_tab = nil
local tabs = {
    click_tab = click_tab,
    business_tab = business_tab
}

-- Initialize the game
function game.init()
    -- Register main game state
    game_state.register("main_game", {
        enter = function()
            -- Initialize with default tab
            current_tab = "click_tab"
            -- Initialize all tabs
            for _, tab in pairs(tabs) do
                if tab.init then
                    tab.init()
                end
            end
        end,
        update = function(dt)
            -- Update current tab
            if tabs[current_tab] and tabs[current_tab].update then
                tabs[current_tab].update(dt)
            end
        end,
        draw = function()
            -- Draw current tab
            if tabs[current_tab] and tabs[current_tab].draw then
                tabs[current_tab].draw()
            end
        end,
        keypressed = function(key)
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
                    -- Initialize the newly selected tab
                    if tabs[current_tab].init then
                        tabs[current_tab].init()
                    end
                end
            end
        end
    })

    -- Register title screen
    game_state.register("title", {
        draw = function()
            love.graphics.setColor(1, 1, 1)
            love.graphics.print("Capital Climb", 300, 200)
            love.graphics.print("Press Enter to start", 270, 250)
        end,
        keypressed = function(key)
            if key == "return" or key == "space" then
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

return game 