local love = require("love")
local shared_data = require("src.core.game.shared_data")
local data_loader = require("src.core.utils.data_loader")
local visualization = require("src.ui.modules.visualization")
local symbols = require("src.modules.slot_machine.symbols")
local reel_module = require("src.modules.slot_machine.reel")
local ui_module = require("src.modules.slot_machine.ui")
local payouts = require("src.modules.slot_machine.payouts")
local animation = require("src.modules.slot_machine.animation")

local slot_machine = {}

-- State variables
local reels = {}
local ui_elements
local bet_amount = 100
local bet_options = {100, 250, 500, 1000, 2500}
local bet_index = 1
local is_auto_spinning = false
local is_spinning = false
local spin_time = 0
local total_spin_time = 2
local spin_result = nil
local spin_win_amount = 0
local anim_state

function slot_machine.init()
    -- Load symbol images
    symbols.load_images()
    
    -- Initialize reels
    for i = 1, 3 do
        reels[i] = reel_module.create()
        reels[i].symbols = reel_module.generate_symbols()
    end
    
    -- Initialize UI
    ui_elements = ui_module.create(love.graphics.getWidth(), love.graphics.getHeight())
    
    -- Initialize animation state
    anim_state = animation.create()
    
    -- Set up button callbacks
    ui_elements.spin_button:set_on_click(function()
        slot_machine.spin()
    end)
    
    ui_elements.auto_spin_button:set_on_click(function()
        is_auto_spinning = not is_auto_spinning
        if is_auto_spinning and not is_spinning then
            slot_machine.spin()
        end
    end)
    
    ui_elements.bet_decrease_button:set_on_click(function()
        if bet_index > 1 then
            bet_index = bet_index - 1
            bet_amount = bet_options[bet_index]
        end
    end)
    
    ui_elements.bet_increase_button:set_on_click(function()
        if bet_index < #bet_options then
            bet_index = bet_index + 1
            bet_amount = bet_options[bet_index]
        end
    end)
end

function slot_machine.spin()
    -- Check if player has enough money
    if shared_data.get_money() < bet_amount then
        is_auto_spinning = false
        return false
    end
    
    -- Deduct bet amount
    shared_data.add_money(-bet_amount)
    
    -- Reset spin data
    is_spinning = true
    spin_time = 0
    spin_result = nil
    spin_win_amount = 0
    anim_state.show_win = false
    
    -- Start spinning reels
    for i = 1, 3 do
        reels[i].symbols = reel_module.generate_symbols()
        reels[i].spinning = true
        reels[i].stop_time = total_spin_time * 0.6 + (i-1) * 0.4
    end
    
    return true
end

function slot_machine.update(dt)
    local window_width = love.graphics.getWidth()
    local window_height = love.graphics.getHeight()
    
    -- Calculate panel position for UI positioning
    local panel_width = math.min(800, window_width - 60)
    local panel_height = math.min(350, window_height - 400)
    local panel_y = 180
    
    if window_height < 600 then
        panel_y = 150
        panel_height = math.min(panel_height, 280)
    end
    
    -- Update UI positions with panel information
    ui_module.update_positions(ui_elements, window_width, window_height, panel_y, panel_height)
    
    -- Update button states
    local mx, my = love.mouse.getPosition()
    local mouse_pressed = love.mouse.isDown(1)
    
    -- Update auto spin button style
    if is_auto_spinning then
        ui_elements.auto_spin_button.style = visualization.button_styles.accent
    else
        ui_elements.auto_spin_button.style = visualization.button_styles.secondary
    end
    
    -- Update buttons
    ui_elements.spin_button:set_enabled(shared_data.get_money() >= bet_amount and not is_spinning)
    ui_elements.spin_button:update(dt, mx, my, mouse_pressed)
    ui_elements.bet_decrease_button:set_enabled(bet_index > 1 and not is_spinning)
    ui_elements.bet_decrease_button:update(dt, mx, my, mouse_pressed)
    ui_elements.bet_increase_button:set_enabled(bet_index < #bet_options and not is_spinning)
    ui_elements.bet_increase_button:update(dt, mx, my, mouse_pressed)
    ui_elements.auto_spin_button:set_enabled(shared_data.get_money() >= bet_amount)
    ui_elements.auto_spin_button:update(dt, mx, my, mouse_pressed)
    
    -- Update animation
    if animation.update(anim_state, dt) and is_auto_spinning then
        slot_machine.spin()
    end
    
    -- Update slot machine animation
    if is_spinning then
        spin_time = spin_time + dt
        
        -- Update each reel
        local all_stopped = true
        for i, reel in ipairs(reels) do
            if reel_module.update(reel, dt, spin_time) then
                -- Reel has stopped
            else
                all_stopped = false
            end
        end
        
        -- If all reels stopped, check for win
        if all_stopped and is_spinning then
            is_spinning = false
            
            -- Get visible symbols
            local visible_symbols = {}
            for i = 1, 3 do
                local symbol_index = math.floor(reels[i].position) % #reels[i].symbols + 1
                table.insert(visible_symbols, reels[i].symbols[symbol_index])
            end
            
            spin_result = visible_symbols
            spin_win_amount = payouts.check_win(visible_symbols, bet_amount)
            
            if spin_win_amount > 0 then
                shared_data.add_money(spin_win_amount)
                animation.start_win(anim_state)
            elseif is_auto_spinning then
                slot_machine.spin()
            end
        end
    end
end

function slot_machine.draw()
    local window_width = love.graphics.getWidth()
    local window_height = love.graphics.getHeight()
    
    -- Calculate responsive panel size - moved higher up on screen
    local panel_width = math.min(800, window_width - 60)
    local panel_height = math.min(350, window_height - 400)  -- Reduced height
    local panel_x = window_width / 2 - panel_width / 2
    local panel_y = 180  -- Moved up from 260
    
    if window_height < 600 then
        panel_y = 150
        panel_height = math.min(panel_height, 280)
    end
    
    -- Draw main panel
    visualization.draw_panel(panel_x, panel_y, panel_width, panel_height)
    
    -- Draw title
    love.graphics.setColor(visualization.colors.text)
    love.graphics.print("SLOT MACHINE", panel_x + 20, panel_y + 20)
    
    -- Calculate reel dimensions
    local reel_width = math.min(140, (panel_width - 120) / 3)
    local reel_height = math.min(220, panel_height - 80)  -- Reduced height
    local reel_spacing = 30
    local start_x = window_width / 2 - ((reel_width * 3 + reel_spacing * 2) / 2)
    local start_y = panel_y + 60
    
    if panel_height < 350 then
        start_y = panel_y + 50
        reel_height = panel_height - 80
    end
    
    -- Draw reels
    for i = 1, 3 do
        local reel_x = start_x + (i-1) * (reel_width + reel_spacing)
        reel_module.draw(reels[i], reel_x, start_y, reel_width, reel_height, 64)
    end
    
    -- Draw highlight for center row (winning line)
    love.graphics.setColor(1, 0.8, 0, 0.3)
    love.graphics.rectangle("fill", start_x, start_y + reel_height/3, (reel_width * 3 + reel_spacing * 2), reel_height/3)
    
    -- Draw UI elements
    ui_elements.spin_button:draw()
    ui_elements.bet_decrease_button:draw()
    ui_elements.bet_increase_button:draw()
    ui_elements.auto_spin_button:draw()
    
    -- Draw bet amount on spin button
    love.graphics.setColor(visualization.colors.text)
    local bet_text = "SPIN: $" .. bet_amount
    local font = love.graphics.getFont()
    local text_width = font:getWidth(bet_text)
    local text_height = font:getHeight()
    local bet_text_x = ui_elements.spin_button.x + (ui_elements.spin_button.width / 2) - (text_width / 2)
    local bet_text_y = ui_elements.spin_button.y + (ui_elements.spin_button.height / 2) - (text_height / 2)
    love.graphics.print(bet_text, bet_text_x, bet_text_y)
    
    -- Draw win amount if applicable
    if spin_result and spin_win_amount > 0 then
        payouts.draw_win_amount(
            spin_win_amount,
            window_width / 2 - 60,
            ui_elements.spin_button.y - 40,
            anim_state.win_time
        )
    end
    
    -- Draw payout table - moved to bottom right instead of right side
    if window_height >= 600 then
        local payout_panel_width = 200
        local payout_panel_height = (#symbols.types * 30) + 50  -- Reduced height
        local payout_x = window_width - payout_panel_width - 20  -- Right aligned
        local payout_y = window_height - payout_panel_height - 20  -- Bottom aligned
        
        payouts.draw_table(payout_x, payout_y, payout_panel_width, payout_panel_height)
    end
end

function slot_machine.mousepressed(x, y, button)
    if button == 1 then
        return ui_elements.spin_button:mouse_pressed(x, y, button) or
               ui_elements.bet_decrease_button:mouse_pressed(x, y, button) or
               ui_elements.bet_increase_button:mouse_pressed(x, y, button) or
               ui_elements.auto_spin_button:mouse_pressed(x, y, button)
    end
    return false
end

return slot_machine 