-- button.lua
-- Reusable button UI component

local button = {}
local Button = {}
Button.__index = Button

local visualization = require("src.ui.modules.visualization")

-- Create a new button
function button.new(x, y, width, height, text, style_name)
    local self = {}
    setmetatable(self, Button)
    
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.text = text
    self.enabled = true
    
    -- Set style based on provided style_name or default to primary
    local style_name = style_name or "primary"
    self.style = visualization.button_styles[style_name] or visualization.button_styles.primary
    
    self.state = "normal"  -- normal, hover, pressed
    self.on_click = nil
    
    -- Animation properties
    self.scale = 1.0
    self.target_scale = 1.0
    self.animation_speed = 10  -- Higher value = faster animation
    
    return self
end

-- Check if point is inside button
function Button:is_inside(x, y)
    return x >= self.x and x <= self.x + self.width and
           y >= self.y and y <= self.y + self.height
end

-- Update button state based on mouse position
function Button:update(dt, mx, my, mouse_pressed)
    dt = dt or love.timer.getDelta()
    
    if not self.enabled then
        self.state = "disabled"
        self.target_scale = 1.0
    elseif self:is_inside(mx, my) then
        if mouse_pressed then
            self.state = "pressed"
            self.target_scale = 0.95  -- Slightly smaller when pressed
        else
            self.state = "hover"
            self.target_scale = 1.05  -- Slightly larger when hovered
        end
    else
        self.state = "normal"
        self.target_scale = 1.0
    end
    
    -- Animate scale
    if self.scale ~= self.target_scale then
        self.scale = self.scale + (self.target_scale - self.scale) * dt * self.animation_speed
    end
end

-- Draw the button
function Button:draw()
    -- Ensure style exists, if not use default primary style
    if not self.style then
        self.style = visualization.button_styles.primary or {}
    end
    
    -- Get style colors based on state
    local color = (self.style[self.state] or self.style.normal) or {0.5, 0.5, 0.5, 1.0}
    local text_color = self.style.text or visualization.colors.text or {1, 1, 1, 1}
    
    -- Calculate scaled dimensions and position
    local w = self.width * self.scale
    local h = self.height * self.scale
    local x = self.x + (self.width - w) / 2
    local y = self.y + (self.height - h) / 2
    
    -- Get style properties with safe defaults
    local roundness = self.style.roundness or 0
    local shadow_offset = self.style.shadow_offset or 0
    local border_width = self.style.border_width or 0
    local border_color = self.style.border_color or {1, 1, 1, 0.1}
    
    -- Draw shadow if specified
    if shadow_offset > 0 then
        love.graphics.setColor(0, 0, 0, 0.3)
        visualization.draw_rounded_rect(
            x + shadow_offset, 
            y + shadow_offset, 
            w, h, roundness * self.scale
        )
    end
    
    -- Draw button background
    love.graphics.setColor(color)
    visualization.draw_rounded_rect(x, y, w, h, roundness * self.scale)
    
    -- Draw border if specified
    if border_width > 0 then
        love.graphics.setColor(border_color)
        love.graphics.setLineWidth(border_width)
        
        if roundness > 0 then
            local r = roundness * self.scale
            -- Draw rounded border
            love.graphics.arc("line", x + r, y + r, r, math.pi, math.pi * 1.5)
            love.graphics.arc("line", x + w - r, y + r, r, math.pi * 1.5, math.pi * 2)
            love.graphics.arc("line", x + w - r, y + h - r, r, 0, math.pi * 0.5)
            love.graphics.arc("line", x + r, y + h - r, r, math.pi * 0.5, math.pi)
            
            love.graphics.line(x + r, y, x + w - r, y)
            love.graphics.line(x + w, y + r, x + w, y + h - r)
            love.graphics.line(x + w - r, y + h, x + r, y + h)
            love.graphics.line(x, y + h - r, x, y + r)
        else
            -- Draw regular border
            love.graphics.rectangle("line", x, y, w, h)
        end
    end
    
    -- Draw button text
    love.graphics.setColor(text_color)
    
    local font = love.graphics.getFont()
    local text_width = font:getWidth(self.text)
    local text_height = font:getHeight()
    
    -- Center text in button
    local text_x = x + (w - text_width) / 2
    local text_y = y + (h - text_height) / 2
    
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