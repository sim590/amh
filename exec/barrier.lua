-- Copyright © 2020 Simon Désaulniers
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

-- local modules
local util = require("amh.util")

-- Starts barrierc on host and barriers on the this machine. This requires the
-- remote host permits ssh acces to $USER with ssh key.
local function barrier(host)
    util.remote_kill_and_run(host, "barrierc " .. util.myip(),
        function ()
            util.run_once('barriers')
        end
    )
end

local function menu(hosts)
    return util.menu({
        choices     = hosts,
        name        = "barrier",
        selected_cb = function(host) barrier(host) end,
        rejected_cb = function(host) util.remote_spawn(host, "pkill -u $USER -x barrierc", nil, false) end,
        extra_choices = { { "None", nil } },
        combination = "powerset"
    })
end

return {
    menu    = menu,
    barrier = barrier
}

-- vim:set et sw=4 ts=4 tw=120:

