-- conf.lua
-- Configuration for Capital Climb

function love.conf(t)
    t.title = "Capital Climb"         -- The title of the window
    t.version = "11.3"                -- The LÖVE version this game was made for
    t.window.width = 800              -- Window width
    t.window.height = 600             -- Window height
    t.window.resizable = false        -- Let the window be user-resizable
    
    -- For debugging
    t.console = false                 -- Attach a console for debug output
    
    -- Modules to disable
    t.modules.joystick = true         -- Enable joystick module
    t.modules.physics = true          -- Enable the physics module
    t.modules.touch = true            -- Enable touch module
    
    -- Disable unused modules to save memory
    t.modules.video = false           -- Disable the video module
end