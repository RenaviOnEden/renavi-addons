----------------------------------------------------------------------
-- snap.lua: box snapping math (the same file is in PersonalHud). Drag a
-- box near a side of another box and let go: it lines up against that
-- side (and with an edge, if close) and then sticks to it. Used by
-- dock.lua. Only window positions; nothing is read from the game.
----------------------------------------------------------------------
local M = {}

M.SNAP = 20   -- how close (pixels) counts as "near"
M.GAP  = 2    -- space left between two boxes

local function overlap(a1, a2, b1, b2) return a1 < b2 and a2 > b1 end

-- Finds the closest side of any box in rects ({ key = { x, y, w, h } })
-- to a box at x, y with size w, h. skip(key) = true leaves that box out.
-- Returns key, side, offset, atEnd  or nil when nothing is near.
function M.find(rects, skip, x, y, w, h)
    local bestK, bestS, bd = nil, nil, M.SNAP
    for k, r in pairs(rects) do
        if r ~= nil and not (skip ~= nil and skip(k)) then
            local hx, hy, hw, hh = r[1], r[2], r[3], r[4]
            local ox = overlap(x, x + w, hx, hx + hw)
            local oy = overlap(y, y + h, hy, hy + hh)
            local tests = {
                { 'below', y - (hy + hh + M.GAP), ox },
                { 'above', (y + h + M.GAP) - hy,  ox },
                { 'right', x - (hx + hw + M.GAP), oy },
                { 'left',  (x + w + M.GAP) - hx,  oy },
            }
            for _, t in ipairs(tests) do
                local dist = math.abs(t[2])
                if t[3] and dist < bd then bestK, bestS, bd = k, t[1], dist end
            end
        end
    end
    if bestK == nil then return nil end

    local r = rects[bestK]
    local off, room
    if bestS == 'below' or bestS == 'above' then off, room = x - r[1], r[3] - w
    else off, room = y - r[2], r[4] - h end
    local atEnd = false
    if math.abs(off) < M.SNAP then off = 0                                -- line up the near edges
    elseif math.abs(off - room) < M.SNAP then off, atEnd = 0, true end  -- line up the far edges
    return bestK, bestS, math.floor(off + 0.5), atEnd
end

-- Where a box of size w, h goes while stuck to box r.
function M.pos(r, side, off, atEnd, w, h)
    local hx, hy, hw, hh = r[1], r[2], r[3], r[4]
    off = tonumber(off) or 0
    local x, y
    if side == 'below' or side == 'above' then
        x = atEnd and (hx + hw - w) or (hx + off)
        y = (side == 'below') and (hy + hh + M.GAP) or (hy - h - M.GAP)
    else
        y = atEnd and (hy + hh - h) or (hy + off)
        x = (side == 'right') and (hx + hw + M.GAP) or (hx - w - M.GAP)
    end
    return math.floor(x + 0.5), math.floor(y + 0.5)
end

return M
