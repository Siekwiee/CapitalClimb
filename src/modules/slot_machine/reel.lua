local symbols = require("src.modules.slot_machine.symbols")

local reel = {}

function reel.create()
    return {
        symbols = {},
        position = 0,
        spinning = false,
        stop_time = 0
    }
end

function reel.generate_symbols()
    local result = {}
    
    for i = 1, 10 do
        local total_weight = 0
        for _, symbol_data in ipairs(symbols.types) do
            total_weight = total_weight + symbol_data.weight
        end
        
        local random_value = math.random(total_weight)
        local current_weight = 0
        
        for _, symbol_data in ipairs(symbols.types) do
            current_weight = current_weight + symbol_data.weight
            if random_value <= current_weight then
                table.insert(result, symbol_data.symbol)
                break
            end
        end
    end
    
    return result
end

function reel.update(reel_data, dt, spin_time)
    if reel_data.spinning then
        -- Calculate speed (start fast, slow down)
        local speed = 15
        if spin_time > reel_data.stop_time - 0.5 then
            speed = speed * (1 - ((spin_time - (reel_data.stop_time - 0.5)) / 0.5))
        end
        
        -- Update position
        reel_data.position = (reel_data.position + speed * dt) % #reel_data.symbols
        
        -- Check if reel should stop
        if spin_time >= reel_data.stop_time then
            reel_data.spinning = false
            reel_data.position = math.floor(reel_data.position)
            return true -- Indicates reel has stopped
        end
    end
    return false
end

function reel.draw(reel_data, x, y, width, height, symbol_size)
    love.graphics.setColor(0.1, 0.1, 0.1)
    love.graphics.rectangle("fill", x, y, width, height)
    
    love.graphics.setColor(0.6, 0.6, 0.6)
    love.graphics.rectangle("line", x, y, width, height)
    
    -- Draw visible symbols
    love.graphics.setScissor(x, y, width, height)
    for j = -1, 1 do
        local pos = reel_data.position
        local symbol_index = math.floor(pos + j) % #reel_data.symbols + 1
        if symbol_index <= 0 then symbol_index = #reel_data.symbols + symbol_index end
        
        local symbol = reel_data.symbols[symbol_index]
        local symbol_y = y + height/2 + j * (height/3) - symbol_size/2
        local frac = pos - math.floor(pos)
        symbol_y = symbol_y - frac * (height/3)
        
        love.graphics.setColor(1, 1, 1)
        local image = symbols.images[symbol]
        if image then
            love.graphics.draw(image, x + width/2 - symbol_size/2, symbol_y)
        end
    end
    love.graphics.setScissor()
end

return reel 