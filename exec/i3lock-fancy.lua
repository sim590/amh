-- Copyright © 2017 Simon Désaulniers
-- Author: Simon Désaulniers <sim.desaulniers@gmail.com>
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
local awful = require("awful")

-- local modules
local util = require("amh.util")

local lock_cmd = 'i3lock-fancy -- scrot -z'

local function lock(host, url)
    util.remote_spawn(host, "pgrep -u $USER -x i3lock || " .. lock_cmd, nil, false)
end

local function menu(hosts)
    return util.menu({
        hosts       = hosts,
        name        = "i3lock-fancy",
        selected_cb = function(host) lock(host) end,
        rejected_cb = nil,
        combination = "powerset"
    })
end

local i3lock_fancy = {
    menu = menu,
    lock = lock
}

return i3lock_fancy

-- vim:set et sw=4 ts=4 tw=120:

