-- visualization.lua
-- Shared visual styles and constants for the game UI

local visualization = {}

-- Color palette
visualization.colors = {
    -- Primary colors
    primary = {0.2, 0.6, 1.0, 1.0},        -- Bright blue
    primary_hover = {0.3, 0.7, 1.0, 1.0},
    primary_pressed = {0.1, 0.5, 0.9, 1.0},
    
    -- Secondary colors
    secondary = {0.2, 0.8, 0.4, 1.0},      -- Green
    secondary_hover = {0.3, 0.9, 0.5, 1.0},
    secondary_pressed = {0.1, 0.7, 0.3, 1.0},
    
    -- Accent colors
    accent = {1.0, 0.6, 0.0, 1.0},         -- Orange
    accent_hover = {1.0, 0.7, 0.2, 1.0},
    accent_pressed = {0.9, 0.5, 0.0, 1.0},
    
    -- UI colors
    background = {0.15, 0.15, 0.18, 1.0},  -- Dark background
    panel = {0.2, 0.2, 0.25, 1.0},         -- Panel background
    text = {1.0, 1.0, 1.0, 1.0},           -- White text
    text_secondary = {0.8, 0.8, 0.85, 1.0}, -- Light gray text
    disabled = {0.5, 0.5, 0.5, 0.7},       -- Disabled state
    
    -- Status colors
    success = {0.2, 0.8, 0.2, 1.0},        -- Success green
    warning = {1.0, 0.8, 0.0, 1.0},        -- Warning yellow
    error = {1.0, 0.3, 0.3, 1.0}           -- Error red
}

-- Button styles
visualization.button_styles = {
    -- Primary button style
    primary = {
        normal = visualization.colors.primary,
        hover = visualization.colors.primary_hover,
        pressed = visualization.colors.primary_pressed,
        disabled = visualization.colors.disabled,
        text = visualization.colors.text,
        roundness = 8,      -- Corner radius
        border_width = 2,   -- Border width
        border_color = {1, 1, 1, 0.1},
        shadow_offset = 3
    },
    
    -- Secondary button style
    secondary = {
        normal = visualization.colors.secondary,
        hover = visualization.colors.secondary_hover,
        pressed = visualization.colors.secondary_pressed,
        disabled = visualization.colors.disabled,
        text = visualization.colors.text,
        roundness = 8,
        border_width = 2,
        border_color = {1, 1, 1, 0.1},
        shadow_offset = 3
    },
    
    -- Accent button style
    accent = {
        normal = visualization.colors.accent,
        hover = visualization.colors.accent_hover,
        pressed = visualization.colors.accent_pressed,
        disabled = visualization.colors.disabled,
        text = visualization.colors.text,
        roundness = 8,
        border_width = 2,
        border_color = {1, 1, 1, 0.1},
        shadow_offset = 3
    },
    
    -- Warning button style
    warning = {
        normal = {0.9, 0.3, 0.3, 1.0},  -- Red color
        hover = {1.0, 0.4, 0.4, 1.0},
        pressed = {0.8, 0.2, 0.2, 1.0},
        disabled = visualization.colors.disabled,
        text = visualization.colors.text,
        roundness = 8,
        border_width = 2,
        border_color = {1, 1, 1, 0.1},
        shadow_offset = 3
    },
    
    -- Text button style (no background)
    text_only = {
        normal = {0, 0, 0, 0},  -- Transparent
        hover = {1, 1, 1, 0.1},
        pressed = {1, 1, 1, 0.2},
        disabled = {0, 0, 0, 0},
        text = visualization.colors.primary,
        text_hover = visualization.colors.primary_hover,
        roundness = 4,
        border_width = 0,
        shadow_offset = 0
    }
}

-- Panel styles
visualization.panel_styles = {
    main = {
        background = visualization.colors.panel,
        border_width = 1,
        border_color = {1, 1, 1, 0.1},
        roundness = 8,
        padding = 15
    }
}

-- Draw a rounded rectangle
function visualization.draw_rounded_rect(x, y, width, height, radius)
    radius = radius or 0
    
    if radius > 0 then
        -- Draw rounded corners
        love.graphics.arc("fill", x + radius, y + radius, radius, math.pi, math.pi * 1.5)
        love.graphics.arc("fill", x + width - radius, y + radius, radius, math.pi * 1.5, math.pi * 2)
        love.graphics.arc("fill", x + width - radius, y + height - radius, radius, 0, math.pi * 0.5)
        love.graphics.arc("fill", x + radius, y + height - radius, radius, math.pi * 0.5, math.pi)
        
        -- Draw connecting rectangles
        love.graphics.rectangle("fill", x + radius, y, width - radius * 2, radius)
        love.graphics.rectangle("fill", x, y + radius, width, height - radius * 2)
        love.graphics.rectangle("fill", x + radius, y + height - radius, width - radius * 2, radius)
    else
        -- Draw regular rectangle if no radius specified
        love.graphics.rectangle("fill", x, y, width, height)
    end
end

-- Draw a panel with optional border and shadow
function visualization.draw_panel(x, y, width, height, style)
    style = style or visualization.panel_styles.main
    local radius = style.roundness or 0
    
    -- Draw shadow if specified
    if style.shadow_offset and style.shadow_offset > 0 then
        love.graphics.setColor(0, 0, 0, 0.3)
        visualization.draw_rounded_rect(
            x + style.shadow_offset, 
            y + style.shadow_offset, 
            width, height, radius
        )
    end
    
    -- Draw background
    love.graphics.setColor(style.background)
    visualization.draw_rounded_rect(x, y, width, height, radius)
    
    -- Draw border if specified
    if style.border_width and style.border_width > 0 and style.border_color then
        love.graphics.setColor(style.border_color)
        love.graphics.setLineWidth(style.border_width)
        if radius > 0 then
            -- Draw rounded border
            love.graphics.arc("line", x + radius, y + radius, radius, math.pi, math.pi * 1.5)
            love.graphics.arc("line", x + width - radius, y + radius, radius, math.pi * 1.5, math.pi * 2)
            love.graphics.arc("line", x + width - radius, y + height - radius, radius, 0, math.pi * 0.5)
            love.graphics.arc("line", x + radius, y + height - radius, radius, math.pi * 0.5, math.pi)
            
            love.graphics.line(x + radius, y, x + width - radius, y)
            love.graphics.line(x + width, y + radius, x + width, y + height - radius)
            love.graphics.line(x + width - radius, y + height, x + radius, y + height)
            love.graphics.line(x, y + height - radius, x, y + radius)
        else
            -- Draw regular border
            love.graphics.rectangle("line", x, y, width, height)
        end
    end
end

return visualization 