-- navbar.lua
-- Navigation bar that appears in all tabs

local navbar = {}

-- Tab data
local tabs = {
    {id = "click_tab", name = "Clicker", active = false, icon = "💰"},
    {id = "business_tab", name = "Business", active = false, icon = "🏢"},
    {id = "settings_tab", name = "Settings", active = false, icon = "⚙️"}
}

local current_tab = nil
local passive_income = 0  -- Store passive income value locally

local animation = {
    active = false,
    from_tab = nil,
    to_tab = nil,
    progress = 0,
    duration = 0.3  -- animation duration in seconds
}

-- Colors for visual styling
local colors = {
    background = {0.15, 0.15, 0.18, 0.1},
    inactive_tab = {0.22, 0.22, 0.25},
    active_tab = {0.3, 0.4, 0.9},
    hover_tab = {0.25, 0.35, 0.7},
    text_inactive = {0.8, 0.8, 0.8},
    text_active = {1, 1, 1},
    title = {1, 0.8, 0.2},
    passive_income = {0.2, 0.9, 0.4},  -- Green color for passive income
    separator = {0.3, 0.3, 0.35}
}

-- Initialize the navbar
function navbar.init(active_tab)
    -- Set active tab
    for _, tab in ipairs(tabs) do
        tab.active = (tab.id == active_tab)
        if tab.active then
            current_tab = tab.id
        end
    end
    
    -- Reset animation
    animation.active = false
    animation.progress = 0
end

-- Update passive income display value
function navbar.set_passive_income(amount)
    passive_income = amount
end

-- Start tab switching animation
local function start_animation(from_tab, to_tab)
    animation.active = true
    animation.from_tab = from_tab
    animation.to_tab = to_tab
    animation.progress = 0
end

-- Update navbar animations
function navbar.update(dt)
    if animation.active then
        animation.progress = animation.progress + dt / animation.duration
        
        if animation.progress >= 1 then
            animation.active = false
            animation.progress = 0
        end
    end
end

-- Draw the navigation bar
function navbar.draw()
    -- Background
    love.graphics.setColor(colors.background)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), 60)
    
    -- Separator line
    love.graphics.setColor(colors.separator)
    love.graphics.rectangle("fill", 0, 60, love.graphics.getWidth(), 2)
    
    -- Show passive income if available
    if passive_income and passive_income > 0 then
        love.graphics.setColor(colors.passive_income)
        love.graphics.print("$" .. passive_income .. "/sec", 20, 20)
    end
    
    -- Tab buttons
    local button_width = 120
    local button_height = 40
    local start_x = love.graphics.getWidth() - (#tabs * button_width) - 20
    
    for i, tab in ipairs(tabs) do
        local x = start_x + (i-1) * button_width
        
        -- Determine button color based on state
        local is_hovered = false
        if love.mouse.getX() >= x and love.mouse.getX() <= x + button_width - 10 and
           love.mouse.getY() >= 10 and love.mouse.getY() <= 10 + button_height then
            is_hovered = true
        end
        
        -- Draw button background with animation if active
        if tab.active then
            love.graphics.setColor(colors.active_tab)
        elseif is_hovered then
            love.graphics.setColor(colors.hover_tab)
        else
            love.graphics.setColor(colors.inactive_tab)
        end
        
        -- Draw rounded rectangle for button
        love.graphics.rectangle("fill", x, 10, button_width - 10, button_height, 5, 5)
        
        -- Draw button text and icon
        if tab.active then
            love.graphics.setColor(colors.text_active)
        else
            love.graphics.setColor(colors.text_inactive)
        end
        
        -- Draw icon
        love.graphics.print(tab.icon, x + 15, 17)
        
        -- Draw name
        love.graphics.print(tab.name, x + 35, 17)
        
        -- Draw active indicator (underline)
        if tab.active then
            love.graphics.setColor(1, 1, 1, 0.8)
            love.graphics.rectangle("fill", x + 5, button_height + 8, button_width - 20, 2)
        end
    end
    
    -- Draw animation if active
    if animation.active then
        love.graphics.setColor(1, 1, 1, 0.3)
        local from_index, to_index = 1, 1
        
        -- Find indices of from/to tabs
        for i, tab in ipairs(tabs) do
            if tab.id == animation.from_tab then from_index = i end
            if tab.id == animation.to_tab then to_index = i end
        end
        
        -- Calculate positions
        local from_x = start_x + (from_index-1) * button_width
        local to_x = start_x + (to_index-1) * button_width
        
        -- Draw animation path
        local anim_x = from_x + (to_x - from_x) * animation.progress
        love.graphics.rectangle("fill", anim_x, button_height + 8, button_width - 20, 2)
    end
    
    -- Reset color
    love.graphics.setColor(1, 1, 1)
end

-- Check if a click hit any tab button and handle animations
function navbar.check_click(x, y)
    if y < 60 then
        local button_width = 120
        local button_height = 40
        local start_x = love.graphics.getWidth() - (#tabs * button_width) - 20
        
        for i, tab in ipairs(tabs) do
            local tab_x = start_x + (i-1) * button_width
            
            if x >= tab_x and x <= tab_x + button_width - 10 and y >= 10 and y <= 10 + button_height then
                if not tab.active then
                    -- Start animation
                    start_animation(current_tab, tab.id)
                    
                    -- Update active states
                    for _, t in ipairs(tabs) do
                        t.active = (t.id == tab.id)
                    end
                    
                    current_tab = tab.id
                end
                return tab.id
            end
        end
    end
    
    return nil
end

-- Get the current active tab
function navbar.get_current_tab()
    return current_tab
end

return navbar 