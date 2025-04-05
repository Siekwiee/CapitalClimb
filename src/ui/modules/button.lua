-- button.lua
-- Reusable button UI component

local button = {}
local Button = {}
Button.__index = Button

-- Create a new button
function button.new(x, y, width, height, text, colors)
    local self = {}
    setmetatable(self, Button)
    
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.text = text
    self.enabled = true
    
    -- Default colors if not specified
    self.colors = colors or {
        normal = {0.3, 0.6, 0.9, 1.0},
        hover = {0.4, 0.7, 1.0, 1.0},
        pressed = {0.2, 0.5, 0.8, 1.0},
        disabled = {0.5, 0.5, 0.5, 1.0},
        text = {1, 1, 1, 1}
    }
    
    -- Ensure all color states exist to avoid nil errors
    if not self.colors.normal then self.colors.normal = {0.3, 0.6, 0.9, 1.0} end
    if not self.colors.hover then self.colors.hover = {0.4, 0.7, 1.0, 1.0} end
    if not self.colors.pressed then self.colors.pressed = {0.2, 0.5, 0.8, 1.0} end
    if not self.colors.disabled then self.colors.disabled = {0.5, 0.5, 0.5, 1.0} end
    if not self.colors.text then self.colors.text = {1, 1, 1, 1} end
    
    self.state = "normal"  -- normal, hover, pressed
    self.on_click = nil
    
    return self
end

-- Check if point is inside button
function Button:is_inside(x, y)
    return x >= self.x and x <= self.x + self.width and
           y >= self.y and y <= self.y + self.height
end

-- Update button state based on mouse position
function Button:update(mx, my, mouse_pressed)
    if not self.enabled then
        self.state = "disabled"
        return
    end
    
    if self:is_inside(mx, my) then
        if mouse_pressed then
            self.state = "pressed"
        else
            self.state = "hover"
        end
    else
        self.state = "normal"
    end
end

-- Draw the button
function Button:draw()
    -- Set color based on state, with fallback to prevent nil
    local color = self.colors[self.state] or self.colors.normal
    
    -- Ensure color has all components
    local r = color[1] or 0.5
    local g = color[2] or 0.5
    local b = color[3] or 0.5
    local a = color[4] or 1.0
    
    love.graphics.setColor(r, g, b, a)
    
    -- Draw button background
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
    
    -- Draw button text
    local text_color = self.colors.text or {1, 1, 1, 1}
    love.graphics.setColor(text_color[1] or 1, text_color[2] or 1, text_color[3] or 1, text_color[4] or 1)
    
    local font = love.graphics.getFont()
    local text_width = font:getWidth(self.text)
    local text_height = font:getHeight()
    
    -- Center text in button
    local text_x = self.x + (self.width - text_width) / 2
    local text_y = self.y + (self.height - text_height) / 2
    
    love.graphics.print(self.text, text_x, text_y)
end

-- Handle mouse press
function Button:mouse_pressed(x, y, button_num)
    if button_num == 1 and self.enabled and self:is_inside(x, y) and self.on_click then
        self.on_click()
        return true
    end
    return false
end

-- Set button enabled state
function Button:set_enabled(enabled)
    self.enabled = enabled
end

-- Set click handler
function Button:set_on_click(handler)
    self.on_click = handler
end

return button 