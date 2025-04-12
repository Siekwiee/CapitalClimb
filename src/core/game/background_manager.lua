-- background_manager.lua
-- Manages background integration with the game

local background_manager = {}
local Background = require("src.ui.modules.background.draw")

-- Initialize the background
function background_manager.init()
    Background:init()
end

-- Update the background
function background_manager.update(dt)
    Background:update(dt)
end

-- Draw the background based on current game state
function background_manager.draw(game_state_name)
    local game_state = {
        state_name = game_state_name
    }
    Background:drawBackground(game_state)
end

return background_manager 