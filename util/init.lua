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
local awful   = require("awful")
local naughty = require("naughty")

-- local modules
local unpack = require("amh.util.unpack") -- compatibility with Lua 5.1

-- other modules
require("pl.stringx").import()

local util = { }

local function async_dummy_cb(stdout, stderr, exitreason, exitcode) end

-- Safely returns return value from os.execute(...)
local function os_exec_rv(os_execute_ret)
    local version = tonumber(_VERSION:split(' ')[2])
    if version > 5.1 then
        return os_execute_ret
    else
        return os_execute_ret == 0
    end
end

-- Gives the name of the program called in the command  ̀cmd`.
local function prg_name(cmd)
    firstspace = cmd:find(" ")
    if firstspace then
        return cmd:sub(0, firstspace-1)
    else
        return cmd
    end
end

-- Wrapper around pgrep program. Tells whether the called program from the
-- command ̀cmd` is running or not
local function pgrep(cmd)
    local prg = prg_name(cmd)
    local ret = os.execute("pgrep -u $USER -x " .. prg .. " > /dev/null")
    return os_exec_rv(ret)
end

-- Runs a command only if the program is not already running
local function run_once(cmd)
    if not pgrep(cmd) then awful.spawn.with_shell("(" .. cmd .. ")") end
end

local function singleton_subsets(set)
    local ss = {}
    for _,e in pairs(set) do
        ss[#ss+1] = {e}
    end
    return ss
end

-- returns the powerset of a given set
local function powerset(s)
    if not s then return {} end
    local t = {{}}
    for i = 1, #s do
        for j = 1, #t do
            t[#t+1] = {s[i],unpack(t[j])}
        end
    end
    return t
end

-- Returns the first valid ip address
local function myip()
    socket = require("socket")
    mysocket = socket.udp()
    mysocket:setpeername('8.8.8.8', "80")
    ip,_ = mysocket:getsockname()
    return ip
end

-- TODO: if host is IPv4 address, don't try to resolve it
-- Runs a command on a remote host. The host is resolved to IPv4 address, then
-- the command is run through SSH protocol.
--  * host:    the host on which to run the command
--  * cmd:     the command to spawn
--  * cb:      the callback to run upon success
--  * verbose: true for verbose message upon success/failure, false otherwise
--
-- System dependencies: {avahi}, {ssh}
local function remote_spawn(host, cmd, cb, verbose)
    if not host then return end

    verbose = verbose == nil and true or false
    local remotespawn_label = "Remote Spawn"

    awful.spawn.easy_async("avahi-resolve-host-name -4 " .. host,
        function (stdout, stderr, exitreason, exitcode)
            -- Invalid hostname
            local host_ip = stdout:split('\t')[2]
            host_ip = host_ip and host_ip:gsub('\n', '') or ''
            if not host_ip or host_ip == '' then
                if verbose then
                    naughty.notify({
                        preset = naughty.config.presets.critical,
                        title = remotespawn_label,
                        text = "Couldn't resolve host '" .. host .. "'"
                    })
                end
                return
            end

            awful.spawn.easy_async('ssh -o StrictHostKeyChecking=no ' .. host_ip
                                    .. ' "env LANG=' .. util.LANG .. ' DISPLAY=:0 bash -c \'' .. cmd .. '\'"',
                function(stdout, stderr, exitreason, exitcode)
                    if exitcode == 0 and verbose then
                        naughty.notify({
                            title = remotespawn_label,
                            text  = "Running command \n'" .. cmd
                                    .. "'\non " .. host
                                    .. " (" .. host_ip .. ")" .. "..."
                        })
                        if cb then cb() end
                    elseif verbose then
                        -- Valid hostname, but can't connect through
                        -- SSH to host
                        naughty.notify({ preset = naughty.config.presets.critical,
                            title = remotespawn_label,
                            text  = "Failed to run command on remote host \""
                                    .. host .. " (" .. host_ip .. ")" ..
                                    "\"... " .. "exit with code " .. tostring(exitcode)
                        })
                    end
                end)
        end)
end

-- Generates a menu compatible with the menu_iterator.iterate function argument
-- and suitable for the following cases:
-- * all possible choices are the hosts themselves
-- * all possible choices are all the possible subsets of the set of hosts (the
--   powerset)
--
-- The following describes the function arguments:
-- * args: an array containing the following members:
--   * hosts:         the list of hosts from which to generate the menu
--   * name:          the displayed name of the menu (in the form "name: choices")
--   * selected_cb:   the callback to execute for each selected host. Takes the
--                    host as a string argument.
--   * rejected_cb:   the callback to execute for each rejected host (in the set
--                    of possible hosts, but not selected). Takes the host as a
--                    string argument.
--   * extra_choices: an array of pairs { choice_text, cb } for extra choices to
--                    be added to the menu.
--   * combination:   the combination of host to generate. Possible choices are
--                    "powerset" and "single" (the default).
local function menu(args)
    local hosts       = assert(args.hosts or args[1])
    local name        = assert(args.name or args[2])
    local selected_cb = args.selected_cb
    local rejected_cb = args.rejected_cb
    local extra_choices = args.extra_choices or {}

    local h_combinations = args.combination == "powerset" and powerset(hosts) or singleton_subsets(hosts)
    for _,c in pairs(extra_choices) do
        h_combinations = awful.util.table.join(h_combinations, {{c[1]}})
    end

    local m = {}
    for _,c in pairs(h_combinations) do
        if #c > 0 then
            local cbs = {}
            -- selected hosts
            for _,h in pairs(c) do
                if awful.util.table.hasitem(hosts, h) then
                    cbs[#cbs + 1] = selected_cb and function() selected_cb(h) end or nil
                end
            end

            -- rejected hosts
            for _,h in pairs(hosts) do
                if not awful.util.table.hasitem(c, h) and awful.util.table.hasitem(hosts, h) then
                    cbs[#cbs + 1] = rejected_cb and function() rejected_cb(h) end or nil
                end
            end

            -- add user extra choices (like the choice "None" for e.g.)
            -- local i = awful.util.table.hasitem(extra_choices, c[1])
            for _,x in pairs(extra_choices) do
                if x[1] == c[1] then
                    cbs[#cbs + 1] = x[2]
                end
            end

            m[#m + 1] = { name .. ": " .. table.concat(c, " + "), cbs }
        end
    end

    return m
end

util.LANG              = "en_US.UTF-8"
util.async_dummy_cb    = async_dummy_cb
util.singleton_subsets = singleton_subsets
util.powerset          = powerset
util.run_once          = run_once
util.myip              = myip
util.remote_spawn      = remote_spawn
util.menu              = menu
util.menu_iterator     = require("amh.util.menu_iterator")

return util

-- vim:set et sw=4 ts=4 tw=120:

