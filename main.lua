-- main.lua
-- Capital Climb game main file

-- Require the main game module
local game = require("src.core.game.game")
-- Save test module is only needed when troubleshooting
-- local save_test = require("src.core.utils.save_test")

-- Load resources and initialize game state
function love.load()
    -- Set default settings
    love.graphics.setBackgroundColor(0.1, 0.1, 0.1)
    
    -- Test save functionality (uncomment for debugging)
    -- save_test.run()
    
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

-- Handle quit event - save game before quitting
function love.quit()
    if game.quit then
        game.quit()
    end
end
