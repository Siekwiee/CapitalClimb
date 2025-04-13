local animation = {}

function animation.create()
    return {
        show_win = false,
        win_time = 0,
        win_duration = 3,
    }
end

function animation.update(anim_state, dt)
    if anim_state.show_win then
        anim_state.win_time = anim_state.win_time + dt
        if anim_state.win_time > anim_state.win_duration then
            anim_state.show_win = false
            anim_state.win_time = 0
            return true -- Animation finished
        end
    end
    return false
end

function animation.start_win(anim_state)
    anim_state.show_win = true
    anim_state.win_time = 0
end

return animation 