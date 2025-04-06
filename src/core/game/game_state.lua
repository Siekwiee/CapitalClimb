-- game_state.lua
-- Manages game states and transitions

local game_state = {}
local states = {}
local current_state = nil

-- Initialize with default state
function game_state.init(initial_state)
    current_state = initial_state or "title"
end

-- Register a state with its handlers
function game_state.register(name, state_handlers)
    states[name] = state_handlers
end

-- Change to a different state
function game_state.change(new_state)
    if not states[new_state] then
        error("Attempted to change to non-existent state: " .. new_state)
    end
    
    -- Call exit function of current state if it exists
    if current_state and states[current_state].exit then
        states[current_state].exit()
    end
    
    -- Set new state
    current_state = new_state
    
    -- Call enter function of new state if it exists
    if states[current_state].enter then
        states[current_state].enter()
    end
end

-- Get current state name
function game_state.get_current()
    return current_state
end

-- Forward calls to current state
function game_state.update(dt)
    if current_state and states[current_state].update then
        states[current_state].update(dt)
    end
end

function game_state.draw()
    if current_state and states[current_state].draw then
        states[current_state].draw()
    end
end

function game_state.keypressed(key)
    if current_state and states[current_state].keypressed then
        states[current_state].keypressed(key)
    end
end

function game_state.mousepressed(x, y, button)
    if current_state and states[current_state].mousepressed then
        states[current_state].mousepressed(x, y, button)
    end
end

function game_state.wheelmoved(x, y)
    if current_state and states[current_state].wheelmoved then
        states[current_state].wheelmoved(x, y)
    end
end

return game_state
