local Background = {}
local love = require("love")

---@class Background
---@field drawBackground fun(game_state: GameState)
---@field particles table Particle systems for background effects
---@field symbols table Financial symbols for decoration
---@field gradients table Color gradients for different states
Background.particles = {}
Background.symbols = {}
Background.gradients = {
    menu = {
        top = {0.1, 0.2, 0.3, 1},    -- Deep business blue
        bottom = {0.2, 0.3, 0.4, 1}   -- Lighter business blue
    },
    playstate = {
        top = {0.05, 0.15, 0.25, 1},    -- Professional dark blue
        bottom = {0.15, 0.25, 0.35, 1}   -- Professional light blue
    }
}

-- Initialize background effects
function Background:init()
    -- Create particle system for money/business particles
    local particle_img = love.graphics.newCanvas(8, 8)
    love.graphics.setCanvas(particle_img)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.circle("fill", 4, 4, 3)
    love.graphics.setCanvas()
    
    -- Create main particle system
    self.particles.money = love.graphics.newParticleSystem(particle_img, 100)
    self.particles.money:setParticleLifetime(4, 10)
    self.particles.money:setEmissionRate(1.5)
    self.particles.money:setSizeVariation(1)
    self.particles.money:setLinearAcceleration(-3, -8, 3, 8)
    self.particles.money:setColors(
        0.2, 0.8, 0.2, 0.15,   -- Money green (reduced alpha)
        0.4, 0.6, 0.8, 0.2,    -- Business blue (reduced alpha)
        0.8, 0.8, 0.2, 0.15,   -- Gold (reduced alpha)
        0.2, 0.4, 0.6, 0       -- Fading blue
    )
    
    -- Generate financial symbols for decoration - scale based on window size
    self:generateSymbols()
    
    -- Start particle systems
    self.particles.money:start()
end

-- Generate symbols scaled to window size
function Background:generateSymbols()
    local width, height = love.graphics.getDimensions()
    local symbols = {"$", "€", "£", "¥", "₿", "📈", "📊", "💹", "💰", "💎"}
    self.symbols = {}
    
    -- Scale number of symbols based on window size
    local symbol_count = math.floor(15 * (width * height) / (1280 * 720))
    symbol_count = math.max(10, math.min(25, symbol_count))
    
    for i = 1, symbol_count do
        table.insert(self.symbols, {
            symbol = symbols[math.random(1, #symbols)],
            x = math.random(50, width - 50),
            y = math.random(50, height - 50),
            size = math.random(1, 2.5),
            alpha = math.random(5, 20) / 100,
            rotation = math.random(0, 360) * (math.pi/180)
        })
    end
end

function Background:update(dt)
    -- Update particle systems
    if self.particles.money then
        self.particles.money:update(dt)
    end
    
    -- Update particle emitter positions
    if self.particles.money then
        local width, height = love.graphics.getDimensions()
        self.particles.money:setPosition(width / 2, height + 50)
    end
    
    -- Animate symbols
    local width, height = love.graphics.getDimensions()
    for i, symbol in ipairs(self.symbols) do
        symbol.rotation = symbol.rotation + (0.1 * dt)
        if i % 3 == 0 then
            symbol.y = symbol.y - (3 * dt)
            if symbol.y < -30 then
                symbol.y = height + 30
                symbol.x = math.random(50, width - 50)
            end
        end
    end
    
    -- Check if window size has changed significantly and regenerate symbols if needed
    if self.last_width ~= width or self.last_height ~= height then
        if not self.last_width or not self.last_height or 
           math.abs(self.last_width - width) > 100 or 
           math.abs(self.last_height - height) > 100 then
            self:generateSymbols()
        end
        self.last_width = width
        self.last_height = height
    end
end

function Background:drawBackground(game_state)
    if not game_state then return end
    
    -- Initialize if needed
    if not self.particles.money then
        self:init()
    end
    
    -- Get dimensions
    local width, height = love.graphics.getDimensions()
    
    -- Draw gradient background based on state
    local gradient
    if game_state.state_name == "menu" then
        gradient = self.gradients.menu
    elseif game_state.state_name == "playstate" then
        gradient = self.gradients.playstate
    else
        gradient = { top = {0.1, 0.2, 0.3, 1}, bottom = {0.2, 0.3, 0.4, 1} }
    end
    
    -- Draw gradient background
    love.graphics.setColor(gradient.top)
    love.graphics.rectangle("fill", 0, 0, width, height / 2)
    love.graphics.setColor(gradient.bottom)
    love.graphics.rectangle("fill", 0, height / 2, width, height / 2)
    
    -- Draw subtle grid pattern (like a financial chart grid)
    -- Scale grid size based on window dimensions
    love.graphics.setColor(1, 1, 1, 0.03)
    local grid_size = math.floor(width / 32) -- Adaptive grid size
    for x = 0, width, grid_size do
        love.graphics.line(x, 0, x, height)
    end
    for y = 0, height, grid_size do
        love.graphics.line(0, y, width, y)
    end
    
    -- Draw financial symbols in background
    love.graphics.setColor(1, 1, 1, 0.1)
    for _, symbol in ipairs(self.symbols) do
        love.graphics.print(
            symbol.symbol, 
            symbol.x, 
            symbol.y, 
            symbol.rotation, 
            symbol.size, 
            symbol.size, 
            10, 
            10
        )
    end
    
    -- Draw particles
    love.graphics.setColor(1, 1, 1, 1)
    if self.particles.money then
        love.graphics.draw(self.particles.money)
    end
    
    -- Draw title with glow effect - scale based on window size
    if game_state.state_name == "menu" then
        self:drawTitle("Capital Climb", width / 2, height / 8, {0.2, 0.8, 0.4, 1})
    elseif game_state.state_name == "playstate" then
        -- Move title higher to avoid navbar interference
        local title_y = math.max(10, height / 72)  -- Reduced from height/36 to height/72
        self:drawTitle("Capital Climb", width / 2, title_y, {0.4, 0.6, 0.9, 1})
    end
end

function Background:drawTitle(title, x, y, color)
    -- Scale title based on window width
    local width = love.graphics.getWidth()
    local scale_factor = math.max(1.0, math.min(2.5, width / 640))
    
    -- Draw glow
    local glow_strength = 5
    for i = glow_strength, 1, -1 do
        local alpha = i / glow_strength * 0.15
        local size = scale_factor + (i / glow_strength * 0.3)
        love.graphics.setColor(color[1], color[2], color[3], alpha)
        
        local font = love.graphics.getFont()
        local text_width = font:getWidth(title) * scale_factor
        love.graphics.print(
            title, 
            x - text_width / 2 + math.random(-1, 1), 
            y + math.random(-1, 1), 
            0, 
            size, 
            size
        )
    end
    
    -- Draw actual text
    love.graphics.setColor(color[1], color[2], color[3], 1)
    local font = love.graphics.getFont()
    local text_width = font:getWidth(title) * scale_factor
    love.graphics.print(title, x - text_width / 2, y, 0, scale_factor, scale_factor)
end

function BasicBackground(game_state)
    Background:drawBackground(game_state)
end

return Background

