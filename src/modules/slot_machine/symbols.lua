local love = require("love")

local symbols = {}

-- Symbol definitions
symbols.types = {
    {symbol = "cherry", weight = 35, multiplier = 10},
    {symbol = "money", weight = 25, multiplier = 25},
    {symbol = "diamond", weight = 15, multiplier = 100},
    {symbol = "clover", weight = 20, multiplier = 50},
    {symbol = "luckySeven", weight = 5, multiplier = 200}
}

-- Cache for symbol images
symbols.images = {}

function symbols.load_images()
    for _, symbol_data in ipairs(symbols.types) do
        local path = "assets/symbols/" .. symbol_data.symbol .. ".png"
        local success, image = pcall(love.graphics.newImage, path)
        
        if success then
            symbols.images[symbol_data.symbol] = image
        else
            symbols.images[symbol_data.symbol] = symbols.create_fallback_image(symbol_data.symbol)
        end
    end
end

function symbols.create_fallback_image(symbol_name)
    local symbol_size = 64
    local fallback = love.graphics.newCanvas(symbol_size, symbol_size)
    love.graphics.setCanvas(fallback)
    love.graphics.clear()
    
    -- Color mapping for fallback images
    local colors = {
        cherry = {1, 0, 0},      -- Red
        money = {0, 0.8, 0},     -- Green
        diamond = {0, 0.5, 1},   -- Blue
        clover = {0, 0.8, 0.2},  -- Green
        luckySeven = {0.8, 0, 0.8} -- Purple
    }
    
    love.graphics.setColor(unpack(colors[symbol_name] or {1, 1, 1}))
    love.graphics.rectangle("fill", 0, 0, symbol_size, symbol_size)
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("line", 0, 0, symbol_size, symbol_size)
    love.graphics.setCanvas()
    
    return fallback
end

return symbols 