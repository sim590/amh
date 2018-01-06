-- Copyright © 2017 Simon Désaulniers
-- Author(s): Simon Désaulniers <sim.desaulniers@gmail.com>
--            Uli Schlachter
--            Jeferson Siqueira <jefersonlsiq@gmail.com>
--
-- This file is part of amh.
--
-- amh is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 2 of the License, or
-- (at your option) any later version.
--
-- amh is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with amh. If not, see <http://www.gnu.org/licenses/>.

-- awesome modules
local naughty = require("naughty")

local state = { cid = nil }

local function naughty_destroy_callback(reason)
    if reason == naughty.notificationClosedReason.expired or
        reason == naughty.notificationClosedReason.dismissedByUser then
        local actions = state.index and state.menu[state.index - 1][2]
        if actions then
            for _,action in pairs(actions) do
                if action then action() end
            end
            state.index = nil
        end
    end
end

-- Iterates over a list of pairs {label, {callbacks}}. After timeout, the last
-- visited choice associated callbacks are executed.
-- * menu:    a list of pairs {label, {callbacks}
-- * timeout: time to wait before confirming menu selection
-- * icon:    icon to display left to the choiced label
local function iterate(menu, timeout, icon)
    timeout = timeout or 4 -- default timeout for each menu entry
    icon    = icon or nil  -- icon to display on the menu

    -- Build the list of choices
    if not state.index then
        state.menu = menu
        state.index = 1
    end

    -- Select one and display the appropriate notification
    local label, action
    local next  = state.menu[state.index]
    state.index = state.index + 1

    if not next then
        label = "Cancel"
        state.index = nil
    else
        label, _ = unpack(next)
    end
    state.cid = naughty.notify({
        text = label,
        icon = icon,
        timeout = timeout,
        screen = mouse.screen,
        replaces_id = state.cid,
        destroy = naughty_destroy_callback
    }).id
end

return { iterate = iterate }

-- vim:set et sw=4 ts=4 tw=120:

