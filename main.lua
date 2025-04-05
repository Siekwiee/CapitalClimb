-- main.lua
-- Capital Climb game main file

-- Require the main game module
local game = require("src.core.game.game")

-- Load resources and initialize game state
function love.load()
    -- Set default settings
    love.graphics.setBackgroundColor(0.1, 0.1, 0.1)
    
    -- Initialize the game
    game.init()
end

-- Update game logic - delegates to the game module
function love.update(dt)
    game.update(dt)
end

-- Draw everything to the screen - delegates to the game module
function love.draw()
    game.draw()
end

-- Handle key presses - delegates to the game module
function love.keypressed(key)
    if key == "escape" and love.keyboard.isDown("lctrl", "rctrl") then
        love.event.quit()
    else
        game.keypressed(key)
    end
end

-- Handle mouse presses - delegates to the game module
function love.mousepressed(x, y, button)
    game.mousepressed(x, y, button)
end
