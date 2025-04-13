local symbols = require("src.modules.slot_machine.symbols")
local visualization = require("src.ui.modules.visualization")
local data_loader = require("src.core.utils.data_loader")

local payouts = {}

function payouts.check_win(visible_symbols, bet_amount)
    -- Check if all three symbols match
    if visible_symbols[1] == visible_symbols[2] and visible_symbols[2] == visible_symbols[3] then
        -- Find the multiplier for this symbol
        for _, symbol_data in ipairs(symbols.types) do
            if symbol_data.symbol == visible_symbols[1] then
                return bet_amount * symbol_data.multiplier
            end
        end
    end
    return 0
end

function payouts.draw_table(x, y, width, height)
    -- Draw payout table background
    love.graphics.setColor(0.1, 0.1, 0.1, 0.8)
    visualization.draw_panel(x, y, width, height)
    
    -- Draw payout table header
    love.graphics.setColor(visualization.colors.text)
    love.graphics.print("PAYOUTS", x + width/2 - 30, y + 15)  -- Reduced padding
    
    for i, symbol_data in ipairs(symbols.types) do
        -- Show image and multiplier with reduced spacing
        local text_y = y + 40 + (i-1) * 30  -- Reduced row height from 40 to 30
        love.graphics.setColor(1, 1, 1)
        local image = symbols.images[symbol_data.symbol]
        if image then
            local scale = 0.6  -- Smaller scale
            love.graphics.draw(image, x + 15, text_y, 0, scale, scale)
        end
        
        -- Draw multiplier text
        love.graphics.setColor(visualization.colors.text_secondary)
        love.graphics.print("× 3:  " .. symbol_data.multiplier .. "x", x + 60, text_y + 10)
    end
end

function payouts.draw_win_amount(amount, x, y, animation_time)
    if amount > 0 then
        -- Flashing text for win animation
        if math.floor(animation_time * 4) % 2 == 0 then
            love.graphics.setColor(1, 0.8, 0)
        else
            love.graphics.setColor(1, 0.5, 0)
        end
        
        love.graphics.print(
            "WIN! $" .. data_loader.format_number_to_two_decimals(amount),
            x, y, 0, 1.5, 1.5
        )
    end
end

return payouts 