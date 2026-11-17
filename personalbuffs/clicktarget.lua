----------------------------------------------------------------------
-- clicktarget.lua: OPTIONAL. Right-click a name in the Buff or Debuff
-- box to target that mob or person.
--
-- This is the only file in PersonalBuffs that sends anything to the
-- game. It sends one thing: the game's own "/target" command, once,
-- when you right-click a name, and only if you turned the option on
-- (off by default). Nothing here runs on its own or on a timer.
--
-- Delete this file and the feature is gone: the rest of the addon has
-- no code that sends a command, and still works the same otherwise.
----------------------------------------------------------------------
require('common')
local imgui = require('imgui')

local M = {}

-- Helpers from personalbuffs.lua, set with M.setup().
local H = {}
function M.setup(h) H = h end

-- Sends "/target <what>". Mode 0 is needed for the game to take an ID
-- (a "typed" mode 1 command only takes names).
local function send(what, label)
    if what == nil or what == '' then return end
    local cmd = '/target ' .. what
    AshitaCore:GetChatManager():QueueCommand(0, cmd)
    H.dlog('Sent: ' .. cmd .. (label ~= nil and ('  (' .. tostring(label) .. ')') or ''))
end

-- True on a right-click between two screen rows of the box being drawn.
function M.right_clicked(rowTop, rowBottom)
    if not H.cfg().targetClick then return false end
    local _, my = imgui.GetMousePos()
    return imgui.IsWindowHovered() and my >= rowTop and my < rowBottom and imgui.IsMouseClicked(1)
end

-- Targets a mob by its ID, so it is always the exact one clicked.
function M.mob(id, label)
    if type(id) ~= 'number' or id <= 0 then return end
    send(string.format('%d', id), label)
end

-- Targets a person: yourself, a party member (by ID), or by name.
function M.person(who)
    if who == nil or who == '' then return end
    if who == H.my_name() then send('<me>', who); return end
    local party = AshitaCore:GetMemoryManager():GetParty()
    for i = 0, 5 do
        if party:GetMemberIsActive(i) == 1 and party:GetMemberName(i) == who then
            local id = party:GetMemberServerId(i)
            if id ~= nil and id > 0 then send(string.format('%d', id), who); return end
        end
    end
    send(who, who)
end

return M
