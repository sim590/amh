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

local util = require("amh.util")

-- local members container
local amh = { }

-- spawn a command on all hosts
local function spawn(cmd, cb, verbose)
    for _,host in pairs(amh.hosts) do
        util.remote_spawn(host, cmd, cb, verbose)
    end
end

-- Starts synergy on a selected host in the `hosts` array.
local function synergy_on_all_hosts()
    local synergy = require("amh.exec.synergy")
    util.menu_iterator.iterate(synergy.menu(amh.hosts), 4, amh.synergy_icon)
end

-- Starts barrier on a selected host in the `hosts` array.
local function barrier_on_all_hosts()
    local barrier = require("amh.exec.barrier")
    util.menu_iterator.iterate(barrier.menu(amh.hosts), 4, amh.barrier_icon)
end

-- starts mpv to play an url on a selected host in the `hosts` array.
local function mpv_multi_host_menu(url)
    local mpv = require("amh.exec.mpv")
    util.menu_iterator.iterate(mpv.menu(amh.hosts, url), 4, amh.mpv_icon)
end

-- locks the screen on a selected host in the `hosts` array.
local function i3lock_fancy_multi_host_menu()
    local i3lock_fancy = require("amh.exec.i3lock-fancy")
    util.menu_iterator.iterate(i3lock_fancy.menu(amh.hosts), 4, amh.i3lock_fancy_icon)
end

-- export local members
amh.util              = util
amh.hosts             = {}
amh.spawn             = spawn
amh.synergy           = synergy_on_all_hosts
amh.synergy_icon      = nil
amh.barrier           = barrier_on_all_hosts
amh.barrier_icon      = nil
amh.mpv               = mpv_multi_host_menu
amh.mpv_icon          = "/usr/share/icons/hicolor/32x32/apps/mpv.png"
amh.i3lock_fancy      = i3lock_fancy_multi_host_menu
amh.i3lock_fancy_icon = nil

return amh

-- vim:set et sw=4 ts=4 tw=120:

