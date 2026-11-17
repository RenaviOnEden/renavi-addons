----------------------------------------------------------------------
-- split.lua: PersonalHud's split mode. The HUD becomes separate boxes
-- (name / TNL / jobs, HP, MP, TP, XP) that you can drag anywhere.
-- Drag one near another and it snaps and sticks to it (snap.lua).
-- Uses the same player data and drawing as the normal HUD.
----------------------------------------------------------------------
require('common')
local imgui = require('imgui')
local SN    = require('snap')

local M = {}

M.KEYS  = { 'head', 'hp', 'mp', 'tp', 'xp' }
M.NAMES = { head = 'the name box', hp = 'the HP box', mp = 'the MP box',
            tp = 'the TP box', xp = 'the XP box', hud = 'the HUD' }

local H     = {}   -- helpers from personalhud.lua (M.setup)
local drag  = {}   -- box being dragged right now
local size  = {}   -- { w, h } of each box last frame
local shown = {}   -- boxes shown this frame

function M.setup(h) H = h end

-- The box k, or (when k is hidden, like MP on a job without MP) the box
-- it's stuck to. Returns { x, y, w, h } or nil.
function M.rect_for(k)
    local c = H.cfg()
    for _ = 1, #M.KEYS + 1 do
        if k == nil or k == '' or c.parts[k] == nil then return nil end
        if shown[k] then return H.rects()[k] or H.prev()[k] end
        k = c.parts[k].to
    end
    return nil
end

-- True if box j is stuck to box k, directly or through other boxes.
local function depends(j, k)
    local c = H.cfg()
    for _ = 1, #M.KEYS + 1 do
        local p = c.parts[j]
        if p == nil or p.to == nil or p.to == '' then return false end
        if p.to == k then return true end
        j = p.to
    end
    return true   -- a loop: treat as stuck
end

-- Every shown box (this frame's spot, or last frame's if not drawn yet).
local function all_rects()
    local t = {}
    for _, k in ipairs(M.KEYS) do
        if shown[k] then t[k] = H.rects()[k] or H.prev()[k] end
    end
    return t
end

-- Puts all the boxes back in one stack under the name box.
function M.restack()
    local c = H.cfg()
    local prev = ''
    for _, k in ipairs(M.KEYS) do
        local p = c.parts[k]
        p.to, p.side, p.off, p.e = prev, (prev ~= '' and 'below' or ''), 0, false
        prev = k
    end
    H.save()
end

-- Draws the boxes. moveHead = the name box's X / Y was typed in the menu.
function M.draw(d, moveHead)
    local c = H.cfg()
    for _, k in ipairs(M.KEYS) do shown[k] = H.part_shown(d, k) end

    local flags = H.FLAGS
    if c.clickThru then flags = bit.bor(flags, ImGuiWindowFlags_NoInputs) end
    local down = imgui.IsMouseDown(0)

    for _, k in ipairs(M.KEYS) do
        if shown[k] then
            local p = c.parts[k]
            local px, py = p.x, p.y
            if k == 'head' then px, py = c.x, c.y end

            -- Stuck to another box: follow it (but not while being dragged).
            local r = (p.to ~= '' and p.side ~= '') and M.rect_for(p.to) or nil
            if r ~= nil and size[k] ~= nil and not drag[k] then
                local sx, sy = SN.pos(r, p.side, p.off, p.e, size[k][1], size[k][2])
                imgui.SetNextWindowPos({ sx, sy }, ImGuiCond_Always)
            else
                imgui.SetNextWindowPos({ px, py },
                    (k == 'head' and moveHead) and ImGuiCond_Always or ImGuiCond_FirstUseEver)
            end

            H.push_style(true)
            if imgui.Begin('personalhud_' .. k, true, flags) then
                if H.has('IsWindowHovered') and imgui.IsWindowHovered() and imgui.IsMouseClicked(0) then
                    drag[k] = true
                end
                H.box_scale()
                H.hud_content(d, k)
                H.box_end()

                local wx, wy = H.xy(imgui.GetWindowPos())
                local ww, wh = H.xy(imgui.GetWindowSize())
                size[k] = { ww, wh }
                H.rects()[k] = { wx, wy, ww, wh }

                -- Drag let go: stick to the nearest box, or unstick.
                if drag[k] and not down then
                    drag[k] = false
                    local key, side, off, e = SN.find(all_rects(),
                        function (j) return j == k or depends(j, k) end, wx, wy, ww, wh)
                    if key ~= nil then
                        p.to, p.side, p.off, p.e = key, side, off, e
                    else
                        p.to, p.side = '', ''
                    end
                    H.save()
                end

                -- Remember where it is.
                if not down then
                    if k == 'head' then
                        if wx ~= c.x or wy ~= c.y then c.x, c.y = wx, wy; H.save() end
                    elseif wx ~= p.x or wy ~= p.y then
                        p.x, p.y = wx, wy
                        H.save()
                    end
                end
            end
            imgui.End()
            H.pop_style()
        end
    end
end

return M
