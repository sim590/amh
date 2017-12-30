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

local mpv_cmd = 'mpv --force-window --no-terminal --keep-open=yes --ytdl'

local function mpv(host, url)
    util.remote_spawn(host, mpv_cmd .. " '" ..  url .. "'")
end

local function menu(hosts, url)
    local m = {}
    for _,h in pairs(awful.util.table.join({ "localhost" }, hosts)) do
        if h == "localhost" then
            m[#m + 1] = {
                "Mpv: " .. h, {
                    function()
                        awful.spawn.easy_async(mpv_cmd .. " '" ..  url .. "'", util.async_dummy_cb)
                    end
                }
            }
        else
            m[#m + 1] = { "Mpv: " .. h, { function() mpv(h, url) end } }
        end
    end
    return m
end

local _mpv = {
    menu = menu,
    mpv  = mpv
}

return _mpv

-- vim:set et sw=4 ts=4 tw=120:

