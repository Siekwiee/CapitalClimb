-- slot_machine.lua
-- Slot machine mini-game module
local love = require("love")
local button = require("src.ui.modules.button")
local visualization = require("src.ui.modules.visualization")
local shared_data = require("src.core.game.shared_data")

local slot_machine = {}

-- Slot machine variables
local slot_symbols = {
    {symbol = "cherry", weight = 35, multiplier = 10},
    {symbol = "money", weight = 25, multiplier = 25},
    {symbol = "diamond", weight = 15, multiplier = 100},
    {symbol = "clover", weight = 20, multiplier = 50},
    {symbol = "dice", weight = 5, multiplier = 200}
}

-- Images for symbols
local symbol_images = {}

local reels = {
    {symbols = {}, position = 0, spinning = false, stop_time = 0},
    {symbols = {}, position = 0, spinning = false, stop_time = 0},
    {symbols = {}, position = 0, spinning = false, stop_time = 0}
}

local bet_amount = 100
local bet_options = {100, 250, 500, 1000, 2500}
local bet_index = 1
local spin_button = nil
local bet_decrease_button = nil
local bet_increase_button = nil
local auto_spin_button = nil
local is_auto_spinning = false
local is_spinning = false
local spin_time = 0
local total_spin_time = 2 -- seconds
local spin_result = nil
local spin_win_amount = 0
local show_win_animation = false
local win_animation_time = 0

-- Symbol display data
local symbol_size = 48  -- Size of symbol images in pixels

-- Generate weighted random symbols for a reel
local function generate_reel_symbols()
    local symbols = {}
    
    -- Each reel has 10 positions
    for i = 1, 10 do
        local total_weight = 0
        for _, symbol_data in ipairs(slot_symbols) do
            total_weight = total_weight + symbol_data.weight
        end
        
        local random_value = math.random(total_weight)
        local current_weight = 0
        local selected_symbol = nil
        
        for _, symbol_data in ipairs(slot_symbols) do
            current_weight = current_weight + symbol_data.weight
            if random_value <= current_weight then
                selected_symbol = symbol_data.symbol
                break
            end
        end
        
        table.insert(symbols, selected_symbol)
    end
    
    return symbols
end

-- Initialize the slot machine
function slot_machine.init()
    local window_width = love.graphics.getWidth()
    
    -- Load symbol images
    for _, symbol_data in ipairs(slot_symbols) do
        local path = "assets/symbols/" .. symbol_data.symbol .. ".png"
        -- Using pcall to handle missing images gracefully
        local success, image = pcall(love.graphics.newImage, path)
        if success then
            symbol_images[symbol_data.symbol] = image
        else
            print("Warning: Could not load image for symbol " .. symbol_data.symbol)
            -- Create a fallback colored rectangle for missing images
            local fallback = love.graphics.newCanvas(symbol_size, symbol_size)
            love.graphics.setCanvas(fallback)
            love.graphics.clear()
            
            -- Different color for each symbol
            if symbol_data.symbol == "cherry" then
                love.graphics.setColor(1, 0, 0)  -- Red
            elseif symbol_data.symbol == "money" then
                love.graphics.setColor(0, 0.8, 0)  -- Green
            elseif symbol_data.symbol == "diamond" then
                love.graphics.setColor(0, 0.5, 1)  -- Blue
            elseif symbol_data.symbol == "clover" then
                love.graphics.setColor(0, 0.8, 0.2)  -- Green
            elseif symbol_data.symbol == "dice" then
                love.graphics.setColor(0.8, 0, 0.8)  -- Purple
            end
            
            love.graphics.rectangle("fill", 0, 0, symbol_size, symbol_size)
            love.graphics.setColor(1, 1, 1)
            love.graphics.rectangle("line", 0, 0, symbol_size, symbol_size)
            love.graphics.setCanvas()
            
            symbol_images[symbol_data.symbol] = fallback
        end
    end
    
    -- Initialize the reels with random symbols
    for i = 1, 3 do
        reels[i].symbols = generate_reel_symbols()
        reels[i].position = 0
        reels[i].spinning = false
        reels[i].stop_time = 0
    end
    
    -- Calculate positions based on screen size
    local button_y = 450
    if love.graphics.getHeight() < 600 then
        button_y = 380
    end
    
    -- Create spin button
    spin_button = button.new(
        window_width / 2 - 50, button_y, 100, 50,
        "",
        "accent"
    )
    
    spin_button:set_on_click(function()
        slot_machine.spin()
    end)
    
    -- Create auto spin button
    auto_spin_button = button.new(
        window_width / 2 + 105, button_y, 80, 50,
        "AUTO",
        "secondary"
    )
    
    auto_spin_button:set_on_click(function()
        is_auto_spinning = not is_auto_spinning
        if is_auto_spinning and not is_spinning then
            slot_machine.spin()
        end
    end)
    
    -- Create bet adjustment buttons
    bet_decrease_button = button.new(
        window_width / 2 - 110, button_y, 40, 50,
        "-",
        "secondary"
    )
    
    bet_decrease_button:set_on_click(function()
        if bet_index > 1 then
            bet_index = bet_index - 1
            bet_amount = bet_options[bet_index]
        end
    end)
    
    bet_increase_button = button.new(
        window_width / 2 + 55, button_y, 40, 50,
        "+",
        "secondary"
    )
    
    bet_increase_button:set_on_click(function()
        if bet_index < #bet_options then
            bet_index = bet_index + 1
            bet_amount = bet_options[bet_index]
        end
    end)
end

-- Spin the slot machine
function slot_machine.spin()
    -- Check if player has enough money
    if shared_data.get_money() < bet_amount then
        is_auto_spinning = false
        return false -- Not enough money to spin
    end
    
    -- Deduct bet amount
    shared_data.add_money(-bet_amount)
    
    -- Reset spin data
    is_spinning = true
    spin_time = 0
    spin_result = nil
    spin_win_amount = 0
    show_win_animation = false
    
    -- Regenerate symbols and start spinning
    for i = 1, 3 do
        reels[i].symbols = generate_reel_symbols()
        reels[i].spinning = true
        -- Stagger the stop times for dramatic effect
        reels[i].stop_time = total_spin_time * 0.6 + (i-1) * 0.4
    end
    
    return true
end

-- Check for winning combinations
local function check_win()
    -- Get the visible symbols (middle row)
    local visible_symbols = {}
    for i = 1, 3 do
        local symbol_index = math.floor(reels[i].position) % #reels[i].symbols + 1
        table.insert(visible_symbols, reels[i].symbols[symbol_index])
    end
    
    -- Check if all three symbols match
    if visible_symbols[1] == visible_symbols[2] and visible_symbols[2] == visible_symbols[3] then
        -- Find the multiplier for this symbol
        for _, symbol_data in ipairs(slot_symbols) do
            if symbol_data.symbol == visible_symbols[1] then
                spin_win_amount = bet_amount * symbol_data.multiplier
                shared_data.add_money(spin_win_amount)
                show_win_animation = true
                win_animation_time = 0
                break
            end
        end
    end
    
    spin_result = visible_symbols
end

-- Update slot machine animation and state
function slot_machine.update(dt)
    local window_width = love.graphics.getWidth()
    local window_height = love.graphics.getHeight()
    
    -- Calculate responsive panel size for positioning
    local panel_height = math.min(300, window_height - 350)
    local panel_y = 260
    
    -- Make sure panel fits on smaller screens
    if window_height < 600 then
        panel_y = 230
        panel_height = math.min(panel_height, 220)
    end
    
    -- Calculate button positions based on screen size
    local button_y = math.min(window_height - 150, panel_y + panel_height + 50)
    if window_height < 600 then
        button_y = math.min(window_height - 120, panel_y + panel_height + 40)
    end
    
    -- Update slot machine positions
    spin_button.x = window_width / 2 - 50
    spin_button.y = button_y
    bet_decrease_button.x = window_width / 2 - 110
    bet_decrease_button.y = button_y
    bet_increase_button.x = window_width / 2 + 55
    bet_increase_button.y = button_y
    auto_spin_button.x = window_width / 2 + 105
    auto_spin_button.y = button_y
    
    -- Update button states
    local mx, my = love.mouse.getPosition()
    local mouse_pressed = love.mouse.isDown(1)
    
    -- Update auto spin button style based on state
    if is_auto_spinning then
        auto_spin_button.style = visualization.button_styles.accent
    else
        auto_spin_button.style = visualization.button_styles.secondary
    end
    
    -- Update slot machine buttons
    spin_button:set_enabled(shared_data.get_money() >= bet_amount and not is_spinning)
    spin_button:update(dt, mx, my, mouse_pressed)
    bet_decrease_button:set_enabled(bet_index > 1 and not is_spinning)
    bet_decrease_button:update(dt, mx, my, mouse_pressed)
    bet_increase_button:set_enabled(bet_index < #bet_options and not is_spinning)
    bet_increase_button:update(dt, mx, my, mouse_pressed)
    auto_spin_button:set_enabled(shared_data.get_money() >= bet_amount)
    auto_spin_button:update(dt, mx, my, mouse_pressed)
    
    -- Update slot machine animation
    if is_spinning then
        spin_time = spin_time + dt
        
        -- Update each reel
        local all_stopped = true
        
        for i, reel in ipairs(reels) do
            if reel.spinning then
                -- Calculate speed (start fast, slow down)
                local speed = 15
                if spin_time > reel.stop_time - 0.5 then
                    -- Slow down before stopping
                    speed = speed * (1 - ((spin_time - (reel.stop_time - 0.5)) / 0.5))
                end
                
                -- Update position
                reel.position = (reel.position + speed * dt) % #reel.symbols
                
                -- Check if reel should stop
                if spin_time >= reel.stop_time then
                    reel.spinning = false
                    -- Snap to exact position (always land on a symbol)
                    reel.position = math.floor(reel.position)
                else
                    all_stopped = false
                end
            end
        end
        
        -- If all reels stopped, check for win
        if all_stopped and is_spinning then
            is_spinning = false
            check_win()
        end
    elseif is_auto_spinning and not is_spinning and not show_win_animation then
        -- If auto-spinning is enabled and not currently spinning or showing win animation, start a new spin
        slot_machine.spin()
    end
    
    -- Update win animation
    if show_win_animation then
        win_animation_time = win_animation_time + dt
        if win_animation_time > 3 then
            show_win_animation = false
        end
    end
end

-- Draw the slot machine
function slot_machine.draw()
    local window_width = love.graphics.getWidth()
    local window_height = love.graphics.getHeight()
    
    -- Calculate responsive panel size
    local panel_width = math.min(600, window_width - 60)
    local panel_height = math.min(300, window_height - 350)
    local panel_x = window_width / 2 - panel_width / 2
    local panel_y = 260
    
    -- Make sure panel fits on smaller screens
    if window_height < 600 then
        panel_y = 230
        panel_height = math.min(panel_height, 220)
    end
    
    -- Draw slot machine panel
    visualization.draw_panel(panel_x, panel_y, panel_width, panel_height)
    
    -- Draw slot machine title
    love.graphics.setColor(visualization.colors.text)
    love.graphics.print("SLOT MACHINE", panel_x + 20, panel_y + 20)
    
    -- Calculate reel sizes based on panel
    local reel_width = math.min(100, (panel_width - 100) / 3)
    local reel_height = math.min(150, panel_height - 100)
    local reel_spacing = 20
    local start_x = window_width / 2 - ((reel_width * 3 + reel_spacing * 2) / 2)
    local start_y = panel_y + 70
    
    -- Make sure reels fit vertically
    if panel_height < 250 then
        start_y = panel_y + 50
        reel_height = panel_height - 80
    end
    
    for i = 1, 3 do
        local reel_x = start_x + (i-1) * (reel_width + reel_spacing)
        
        -- Draw reel background
        love.graphics.setColor(0.1, 0.1, 0.1)
        love.graphics.rectangle("fill", reel_x, start_y, reel_width, reel_height)
        
        -- Draw reel border
        love.graphics.setColor(0.6, 0.6, 0.6)
        love.graphics.rectangle("line", reel_x, start_y, reel_width, reel_height)
        
        -- Draw symbols (3 visible positions)
        local pos = reels[i].position
        for j = -1, 1 do
            local symbol_index = math.floor(pos + j) % #reels[i].symbols + 1
            if symbol_index <= 0 then symbol_index = #reels[i].symbols + symbol_index end
            
            local symbol = reels[i].symbols[symbol_index]
            
            -- Calculate symbol position with bounds checking
            local symbol_y = start_y + reel_height/2 + j * (reel_height/3) - symbol_size/2
            
            -- Calculate fractional part for smooth animation
            local frac = pos - math.floor(pos)
            symbol_y = symbol_y - frac * (reel_height/3)
            
            -- Ensure symbols stay within reel bounds
            symbol_y = math.max(start_y, math.min(start_y + reel_height - symbol_size, symbol_y))
            
            -- Draw the symbol image
            love.graphics.setColor(1, 1, 1)
            local image = symbol_images[symbol]
            if image then
                love.graphics.draw(image, reel_x + reel_width/2 - symbol_size/2, symbol_y)
            end
        end
    end
    
    -- Draw highlight for center row (winning line)
    love.graphics.setColor(1, 0.8, 0, 0.3)
    love.graphics.rectangle("fill", start_x, start_y + reel_height/3, (reel_width * 3 + reel_spacing * 2), reel_height/3)
    
    -- Draw slot machine controls
    spin_button:draw()
    bet_decrease_button:draw()
    bet_increase_button:draw()
    auto_spin_button:draw()
    
    -- Draw auto spin button with indicator if active
    if is_auto_spinning then
        -- Draw a pulsing circle indicator
        local pulse = 0.7 + math.sin(love.timer.getTime() * 5) * 0.3
        love.graphics.setColor(0, 0.8, 0, pulse)  -- Green indicator with pulsing alpha
        love.graphics.circle("fill", auto_spin_button.x + auto_spin_button.width - 15, auto_spin_button.y + 15, 6)
        love.graphics.setColor(1, 1, 1)
        love.graphics.circle("line", auto_spin_button.x + auto_spin_button.width - 15, auto_spin_button.y + 15, 6)
    end
    
    -- Draw bet amount
    love.graphics.setColor(visualization.colors.text)
    -- Center the bet text properly on the button  
    local bet_text = "SPIN: $" .. bet_amount
    local font = love.graphics.getFont()
    local text_width = font:getWidth(bet_text)
    local text_height = font:getHeight()
    local bet_text_x = spin_button.x + (spin_button.width / 2) - (text_width / 2)
    local bet_text_y = spin_button.y + (spin_button.height / 2) - (text_height / 2)
    love.graphics.print(bet_text, bet_text_x, bet_text_y)
    
    -- Draw win information
    if spin_result and spin_win_amount > 0 then
        -- Flashing text for win animation
        if show_win_animation and math.floor(win_animation_time * 4) % 2 == 0 then
            love.graphics.setColor(1, 0.8, 0)
        else
            love.graphics.setColor(1, 0.5, 0)
        end
        
        love.graphics.print("WIN! $" .. spin_win_amount, window_width / 2 - 60, spin_button.y - 40, 0, 1.5, 1.5)
    end
    
    -- Draw slot machine payout info if there's room
    if window_height >= 700 then
        love.graphics.setColor(visualization.colors.text_secondary)
        love.graphics.print("PAYOUTS:", panel_x + 20, panel_y + panel_height + 20)
        
        for i, symbol_data in ipairs(slot_symbols) do
            -- Show image and multiplier
            local text_y = panel_y + panel_height + 20 + i * 20
            love.graphics.setColor(1, 1, 1)
            local image = symbol_images[symbol_data.symbol]
            if image then
                local scale = 0.5  -- Smaller scale for the payout table
                love.graphics.draw(image, panel_x + 20, text_y, 0, scale, scale)
            end
            
            love.graphics.setColor(visualization.colors.text_secondary)
            love.graphics.print("× 3: " .. symbol_data.multiplier .. "x bet", panel_x + 50, text_y)
        end
    end
end

-- Handle mouse pressed events for the slot machine
function slot_machine.mousepressed(x, y, button_num)
    if button_num == 1 then
        -- Check slot machine buttons
        if spin_button:mouse_pressed(x, y, button_num) then
            return true
        end
        
        if bet_decrease_button:mouse_pressed(x, y, button_num) then
            return true
        end
        
        if bet_increase_button:mouse_pressed(x, y, button_num) then
            return true
        end
        
        if auto_spin_button:mouse_pressed(x, y, button_num) then
            return true
        end
    end
    
    return false
end

return slot_machine 