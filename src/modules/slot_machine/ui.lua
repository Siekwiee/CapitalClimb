local button = require("src.ui.modules.button.button")
local visualization = require("src.ui.modules.visualization")

local ui = {}

function ui.create(window_width, window_height)
    local button_y = 520
    if window_height < 600 then
        button_y = 450
    end
    
    return {
        spin_button = button.new(
            window_width / 2 - 50, button_y, 100, 50,
            "", "accent"
        ),
        auto_spin_button = button.new(
            window_width / 2 + 105, button_y, 80, 50,
            "AUTO", "secondary"
        ),
        bet_decrease_button = button.new(
            window_width / 2 - 110, button_y, 40, 50,
            "-", "secondary"
        ),
        bet_increase_button = button.new(
            window_width / 2 + 55, button_y, 40, 50,
            "+", "secondary"
        ),
        button_y = button_y
    }
end

function ui.update_positions(ui_elements, window_width, window_height, panel_y, panel_height)
    local button_y = panel_y + panel_height + 30
    
    if window_height < 600 then
        button_y = math.min(window_height - 100, button_y)
    else
        button_y = math.min(window_height - 150, button_y)
    end
    
    ui_elements.spin_button.x = window_width / 2 - 60
    ui_elements.spin_button.y = button_y
    ui_elements.bet_decrease_button.x = window_width / 2 - 120
    ui_elements.bet_decrease_button.y = button_y
    ui_elements.bet_increase_button.x = window_width / 2 + 65
    ui_elements.bet_increase_button.y = button_y
    ui_elements.auto_spin_button.x = window_width / 2 + 115
    ui_elements.auto_spin_button.y = button_y
end

return ui 