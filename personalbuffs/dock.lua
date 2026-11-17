----------------------------------------------------------------------
-- dock.lua: lets PersonalBuffs' boxes (Buffs, Recasts, Debuffs) snap
-- together. Drag a box near a side of another box and let go: it lines
-- up against that side (and with an edge, if close) and then moves with
-- it. Drag it away to unstick it. Only window positions; nothing is read
-- from the game. The math is in snap.lua (same as PersonalHud's).
----------------------------------------------------------------------
require('common')
local imgui = require('imgui')
local SN    = require('snap')

local M = {}

M.KEYS  = { 'buff', 'recast', 'debuff' }
M.NAMES = { buff = 'the Buff box', recast = 'the Recast box', debuff = 'the Debuff box' }
local POS = { buff = { 'x', 'y' }, recast = { 'rx', 'ry' }, debuff = { 'dx', 'dy' } }

local H     = {}   -- helpers from personalbuffs.lua (M.setup)
local known = {}   -- last spot of each box { x, y, w, h } (kept while hidden)
local seen  = {}   -- os.clock() each box was last drawn
local drag  = {}   -- box -> { x, y } where a drag started
local size  = {}   -- box -> { w, h } last frame

function M.setup(h) H = h end

local function snaps(c) return c.snap ~= nil and c.snapBoxes ~= false end

-- True if box j is stuck to box k, directly or through the other box.
local function depends(j, k)
    local c = H.cfg()
    for _ = 1, #M.KEYS + 1 do
        local s = c.snap[j]
        if s == nil or s.to == nil or s.to == '' then return false end
        if s.to == k then return true end
        j = s.to
    end
    return true   -- a loop: treat as stuck
end

-- Boxes on screen right now (drawn in the last quarter second).
local function visible()
    local t, now = {}, os.clock()
    for _, k in ipairs(M.KEYS) do
        if known[k] ~= nil and seen[k] ~= nil and now - seen[k] < 0.25 then t[k] = known[k] end
    end
    return t
end

-- Before imgui.Begin: where the box goes. move = X / Y typed in the menu
-- (or a profile loaded): use the saved spot; a typed spot unsticks it.
function M.place(k, move, typed)
    local c = H.cfg()
    local s = c.snap and c.snap[k] or nil
    if typed and s ~= nil then s.to, s.side = '', '' end
    local r = (s ~= nil and s.to ~= '' and s.side ~= '') and known[s.to] or nil
    if snaps(c) and r ~= nil and size[k] ~= nil and drag[k] == nil then
        local x, y = SN.pos(r, s.side, s.off, s.e, size[k][1], size[k][2])
        imgui.SetNextWindowPos({ x, y }, ImGuiCond_Always)
    else
        local p = POS[k]
        imgui.SetNextWindowPos({ c[p[1]], c[p[2]] }, move and ImGuiCond_Always or ImGuiCond_FirstUseEver)
    end
end

-- Inside the box, just before imgui.End: remember the spot, and after a
-- drag, stick to the nearest box or unstick.
function M.after(k)
    local c = H.cfg()
    local down = imgui.IsMouseDown(0)
    local wx, wy = H.xy(imgui.GetWindowPos())
    local ww, wh = H.xy(imgui.GetWindowSize())
    size[k]  = { ww, wh }
    known[k] = { wx, wy, ww, wh }
    seen[k]  = os.clock()

    if drag[k] == nil and imgui.IsWindowHovered ~= nil and imgui.IsWindowHovered()
            and imgui.IsMouseClicked(0) then
        drag[k] = { wx, wy }
    end
    if drag[k] ~= nil and not down then
        local start = drag[k]
        drag[k] = nil
        -- Only when the box really moved (a click on a row isn't a drag).
        if c.snap ~= nil and c.snap[k] ~= nil and (start[1] ~= wx or start[2] ~= wy) then
            local s = c.snap[k]
            local key, side, off, e = nil, nil, nil, nil
            if snaps(c) then
                key, side, off, e = SN.find(visible(),
                    function (j) return j == k or depends(j, k) end, wx, wy, ww, wh)
            end
            if key ~= nil then
                s.to, s.side, s.off, s.e = key, side, off, e
            else
                s.to, s.side = '', ''
            end
            H.save()
        end
    end

    local p = POS[k]
    if (wx ~= c[p[1]] or wy ~= c[p[2]]) and not down then
        c[p[1]], c[p[2]] = wx, wy
        H.save()
    end
end

-- Unsticks every box.
function M.unsnap_all()
    local c = H.cfg()
    if c.snap == nil then return end
    for _, k in ipairs(M.KEYS) do
        if c.snap[k] ~= nil then c.snap[k].to, c.snap[k].side = '', '' end
    end
    H.save()
end

-- "Recast box: below the Buff box", or nil when not stuck.
function M.status(k)
    local c = H.cfg()
    local s = c.snap and c.snap[k] or nil
    if s == nil or s.to == '' or s.side == '' then return nil end
    local side = ({ below = 'below', above = 'above', left = 'left of', right = 'right of' })[s.side] or s.side
    return side .. ' ' .. (M.NAMES[s.to] or s.to)
end

return M
