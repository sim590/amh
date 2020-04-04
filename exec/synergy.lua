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

-- local modules
local util = require("amh.util")

-- Starts syenrgyc on synergyc_host and synergys on the this machine. This
-- requires the remote host permits ssh acces to $USER with ssh key.
local function synergy(host)
    util.remote_spawn(host, 'pkill -u $USER -x synergyc ; synergyc ' ..  util.myip(),
        function ()
            util.run_once('synergys')
        end
    )
end

local function menu(hosts)
    return util.menu({
        choices     = hosts,
        name        = "Synergy",
        selected_cb = function(host) synergy(host) end,
        rejected_cb = function(host) util.remote_spawn(host, "pkill -u $USER -x synergyc", nil, false) end,
        extra_choices = { { "None", nil } },
        combination = "powerset"
    })
end

return {
    menu    = menu,
    synergy = synergy
}

-- vim:set et sw=4 ts=4 tw=120:

