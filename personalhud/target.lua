----------------------------------------------------------------------
-- target.lua: PersonalHud's target bar. Its own box with your target's
-- name, distance, HP bar and a row of debuff letters.
--
-- Name, HP and distance come from game memory. The debuff letters use
-- debuffs.lua (packets 0x028 and 0x029), the same tracker PersonalBuffs
-- uses; those packets are only read while the letters are turned on.
-- The letters count every debuff seen landing on a mob, whoever cast it.
-- The row shows for every target, but only mobs are tracked.
----------------------------------------------------------------------
require('common')
local chat  = require('chat')
local imgui = require('imgui')
local DB    = require('debuffs')
local SN    = require('snap')

local M = {}
M.move = false   -- position typed in the menu: move on next draw
M.test = false   -- test mode: fake target, every other letter lit (not saved)

-- Helpers from personalhud.lua, set with M.setup().
local H = {}

-- Players have server IDs below 0x01000000; monsters and NPCs are above.
local function is_player(id) return id ~= nil and id > 0 and id < 0x01000000 end

local dbCfg = { anyone = true, party = { enabled = true } }

function M.setup(h)
    H = h
    DB.setup({
        cfg = function () return dbCfg end,
        dlog        = function () end,
        mmss        = function (sec) return tostring(sec) end,
        is_player   = is_player,
        is_trust    = function (id, spell)
            if id ~= nil and id >= 896 then return true end
            return spell ~= nil and spell.Type == 8
        end,
        spell_group = function () return 'Other' end,
    })
end

----------------------------------------------------------------------
-- Debuff letters, in the order shown. Each letter lights up in its
-- element's color while any of its effects is on the mob (from any
-- caster). Each entry: letter, effect IDs, element.
----------------------------------------------------------------------
local ELEMENT = {
    fire    = { 1.00, 0.38, 0.30, 1.0 },
    ice     = { 0.55, 0.88, 1.00, 1.0 },
    wind    = { 0.45, 0.90, 0.45, 1.0 },
    earth   = { 0.92, 0.76, 0.32, 1.0 },
    thunder = { 0.88, 0.50, 1.00, 1.0 },
    water   = { 0.36, 0.56, 1.00, 1.0 },
    light   = { 1.00, 1.00, 1.00, 1.0 },
    dark    = { 0.56, 0.46, 0.70, 1.0 },
}
-- Effects whose element differs from their letter's (Lullaby is light).
local FX_ELEMENT = { [193] = 'light' }

local SLOTS = {
    { gap = 0, { 'D', { 134 }, 'light' }, { 'B', { 135 }, 'dark' } },          -- Dia, Bio
    { gap = 0, { 'P', { 4 }, 'ice' }, { 'S', { 13 }, 'earth' },                -- Paralyze, Slow
               { 'E', { 194 }, 'earth' }, { 'G', { 12 }, 'wind' },             -- Elegy, Gravity
               { 'B', { 5 }, 'dark' }, { 'F', { 156 }, 'light' } },            -- Blind, Flash
    { gap = 1, { 'Si', { 6 }, 'wind' }, { 'Sl', { 2, 19, 193 }, 'dark' },      -- Silence, Sleep
               { 'Bi', { 11 }, 'ice' }, { 'Po', { 3 }, 'water' },              -- Bind, Poison
               { 'Rq', { 192 }, 'light' } },                                   -- Requiem
    { gap = 0, { 'S', { 132 }, 'thunder' }, { 'R', { 131 }, 'earth' },         -- Shock, Rasp
               { 'C', { 130 }, 'wind' }, { 'F', { 129 }, 'ice' },              -- Choke, Frost
               { 'B', { 128 }, 'fire' }, { 'D', { 133 }, 'water' } },          -- Burn, Drown
}

local COL_OTHERS = { 0.72, 0.52, 0.86, 1.0 }   -- mob claimed by someone else

-- Width of each group of letters, and of the whole row at its tightest.
local function letters_size()
    local sp     = H.text_w(' ')
    local widths = {}
    local sum    = 0
    for gi, g in ipairs(SLOTS) do
        local w = 0
        for i, s in ipairs(g) do
            w = w + H.text_w(s[1])
            if i > 1 then w = w + g.gap * sp end
        end
        widths[gi] = w
        sum = sum + w
    end
    return widths, sum, sum + (#SLOTS - 1) * sp * 2, sp
end

----------------------------------------------------------------------
-- Reading the target (game memory only)
----------------------------------------------------------------------
local function read_target()
    local mm = AshitaCore:GetMemoryManager()
    local t  = mm:GetTarget()
    if t == nil then return nil end
    local idx = t:GetTargetIndex(t:GetIsSubTargetActive())
    if idx == nil or idx <= 0 or idx > 2303 then return nil end

    local ent  = mm:GetEntity()
    local name = ent:GetName(idx)
    if name == nil or name == '' then return nil end

    local d = { idx = idx, name = name }
    d.id  = ent:GetServerId(idx) or 0
    d.hpp = ent:GetHPPercent(idx) or 0
    local okD, dist = pcall(function () return ent:GetDistance(idx) end)
    d.dist = (okD and type(dist) == 'number' and dist >= 0) and math.sqrt(dist) or nil

    -- Player, NPC or mob.
    local okF, flags = pcall(function () return ent:GetSpawnFlags(idx) end)
    if okF and type(flags) == 'number' then
        if bit.band(flags, 0x01) ~= 0 then d.kind = 'pc'
        elseif bit.band(flags, 0x02) ~= 0 then d.kind = 'npc'
        else d.kind = 'mob' end
    else
        d.kind = is_player(d.id) and 'pc' or 'mob'
    end

    -- Mobs: unclaimed, claimed by your party / alliance, or by others.
    if d.kind == 'mob' then
        d.claim = 'none'
        local okC, cs = pcall(function () return ent:GetClaimStatus(idx) end)
        local claimId = (okC and type(cs) == 'number') and bit.band(cs, 0xFFFF) or 0
        if claimId ~= 0 then
            d.claim = 'others'
            local party = mm:GetParty()
            for i = 0, 17 do
                if party:GetMemberIsActive(i) == 1
                        and bit.band(party:GetMemberServerId(i), 0xFFFF) == claimId then
                    d.claim = 'ours'
                    break
                end
            end
        end
    end
    return d
end

-- Runs fn with the text "mul" times the box's normal size.
local function scaled(mul, fn)
    local base = H.clamp(H.S('scale'), 80, 200, 100) / 100
    if H.has('SetWindowFontScale') then
        pcall(imgui.SetWindowFontScale, base * mul)
        fn()
        pcall(imgui.SetWindowFontScale, base)
    elseif H.has('PushFont') and H.has('PopFont') and H.has('GetFontSize') then
        local okS, size = pcall(imgui.GetFontSize)
        local pushed = okS and type(size) == 'number' and pcall(imgui.PushFont, nil, size * mul)
        fn()
        if pushed then pcall(imgui.PopFont) end
    else
        fn()
    end
end

local function name_color(d)
    if not H.cfg().tgtColors then return H.COL_NAME end
    if d.kind == 'npc' then return H.COL_GREEN end
    if d.kind == 'mob' then
        if d.claim == 'ours' then return H.COL_RED end
        if d.claim == 'others' then return COL_OTHERS end
        return H.COL_YELLOW
    end
    return H.COL_NAME
end

-- Cuts text with "..." so it fits in w pixels.
local function fit_text(txt, w)
    if H.text_w(txt) <= w then return txt end
    local n = #txt
    while n > 1 and H.text_w(txt:sub(1, n) .. '...') > w do n = n - 1 end
    return txt:sub(1, n) .. '...'
end

----------------------------------------------------------------------
-- Snapping to the HUD (snap.lua)
-- Drag the target bar near a side of the HUD, or of any split HUD box, and
-- let go: it clicks into place and then moves with it. Drag away to unstick.
----------------------------------------------------------------------
M.drag = false    -- the target bar is being dragged right now
M.size = nil      -- { w, h } of the target bar last frame

local SIDE_NAME = { below = 'below', above = 'above', left = 'left of', right = 'right of' }

----------------------------------------------------------------------
-- The box
----------------------------------------------------------------------
function M.draw()
    local config = H.cfg()
    if not config.target or not config.tgtDebuffs then
        if H.set_min_w then H.set_min_w(0) end
    end
    if not config.target then return end
    if config.hideFullLog and H.full_log_open() then return end

    local now     = os.time()
    local letters = config.tgtDebuffs == true or M.test
    if letters then pcall(DB.prune, now) end

    local ok, d = pcall(read_target)
    -- Test mode with no target: show a made-up mob.
    if M.test and (not ok or d == nil) then
        ok, d = true, { idx = 0x1A3, id = 0, name = 'Test Mob', hpp = 62, dist = 5.3,
                        kind = 'mob', claim = 'ours' }
    end
    if not ok or d == nil then M.drag = false; return end

    local flags = H.FLAGS
    if config.clickThru then flags = bit.bor(flags, ImGuiWindowFlags_NoInputs) end

    -- Stuck to the HUD: follow it (but not while being dragged).
    local stuck = config.tSnap ~= nil and config.tSnap ~= ''
    local hud = stuck and H.snap_rect(config.tSnapTo or 'hud') or nil
    if hud ~= nil and M.size ~= nil and not M.drag then
        local px, py = SN.pos(hud, config.tSnap, config.tSnapOff, config.tSnapEnd, M.size[1], M.size[2])
        imgui.SetNextWindowPos({ px, py }, ImGuiCond_Always)
    else
        imgui.SetNextWindowPos({ config.tx, config.ty }, M.move and ImGuiCond_Always or ImGuiCond_FirstUseEver)
    end
    M.move = false
    H.push_style(true)

    if imgui.Begin('personalhud_target', true, flags) then
        -- A click on the box starts a drag.
        if H.has('IsWindowHovered') and imgui.IsWindowHovered() and imgui.IsMouseClicked(0) then
            M.drag = true
        end
        H.box_scale()
        local col   = H.bar_colors()
        local lineH = H.has('GetTextLineHeight') and imgui.GetTextLineHeight() or 14
        local barH  = math.max(4, math.floor(lineH * H.clamp(config.barHeight, 50, 150, 100) / 100 + 0.5))
        local x0    = imgui.GetCursorPosX()

        -- "Goblin Smithy (1A3)" and the distance.
        local title = d.name
        if config.tgtId and d.kind == 'mob' then title = title .. string.format(' (%03X)', d.idx) end
        local dist = (config.tgtDist and d.dist ~= nil) and string.format('%.1fm', d.dist) or ''

        -- The distance sits to the right of the HP bar, in bigger text.
        local distOn = dist ~= ''
        local mul    = H.clamp(config.tgtDistSize, 100, 200, 140) / 100
        local distW, distH = 0, lineH
        if distOn then
            scaled(mul, function ()
                distW = H.text_w(dist)
                distH = H.has('GetTextLineHeight') and imgui.GetTextLineHeight() or (lineH * mul)
            end)
        end

        -- Always the same width as the HUD. Letters that don't fit on one row
        -- wrap to a second row. Long names are cut with "...".
        local showLetters = letters
        local total = H.text_w('LP 00000') + 8 + config.barWidth
        local widths, sum, minW, sp, rows
        if showLetters then
            widths, sum, minW, sp = letters_size()
            -- Put whole groups on each row while they fit (at least 1 space
            -- between groups; more when there's room).
            rows = {}
            local row, rowW, widest = nil, 0, 0
            for gi = 1, #SLOTS do
                local w = widths[gi]
                if w > widest then widest = w end
                if row ~= nil and rowW + sp + w <= total then
                    table.insert(row, gi)
                    rowW = rowW + sp + w
                else
                    row, rowW = { gi }, w
                    table.insert(rows, row)
                end
            end
            -- Only if one group alone is wider than the HUD does the HUD widen.
            if widest > total then total = widest end
            if H.set_min_w then H.set_min_w(math.ceil(widest)) end
        elseif H.set_min_w then
            H.set_min_w(0)
        end
        total = math.floor(total + 0.5)
        title = fit_text(title, total)

        local canY = H.has('GetCursorPosY') and H.has('SetCursorPosY')
        local yA   = canY and imgui.GetCursorPosY() or 0
        imgui.TextColored(name_color(d), title)
        -- Gap the theme leaves between two lines.
        local gapY = canY and math.max(0, imgui.GetCursorPosY() - yA - lineH) or 4
        if H.S('header') then H.line(H.COL_ACCENT) elseif H.S('dividers') then H.line(H.COL_BORDER) end

        -- HP bar with the % centered on it. With the distance on, the bar is
        -- shortened and the distance goes to its right; both are centered
        -- on the same row.
        local hpp  = H.clamp(d.hpp, 0, 100, 0)
        local barW = total
        if distOn then
            barW = math.floor(total * H.clamp(config.tgtBarPct, 40, 100, 70) / 100 + 0.5)
            barW = math.max(20, math.min(barW, total - distW - 8))
        end
        local rowH = math.max(barH, distOn and distH or 0)
        local y0   = canY and imgui.GetCursorPosY() or 0
        if canY then imgui.SetCursorPosY(y0 + math.floor((rowH - barH) / 2 + 0.5)) end
        H.draw_bar(hpp / 100, barW, barH, col.hp, col.barBg, math.floor(hpp) .. '%')
        if distOn then
            imgui.SameLine(0, 0)
            imgui.SetCursorPosX(x0 + total - distW)
            if canY then imgui.SetCursorPosY(y0 + math.floor((rowH - distH) / 2 + 0.5)) end
            scaled(mul, function () imgui.TextColored(H.COL_NAME, dist) end)
        end
        if showLetters and canY then
            imgui.SetCursorPosY(math.floor(y0 + rowH + gapY + 0.5))
        end

        -- Debuff letters: dim when off; the debuff's element color when on.
        if showLetters then
            local mob = DB.mobs[d.id]
            local dimA = H.clamp(config.tgtDimPct, 10, 100, 55) / 100
            local dim = { H.COL_NAME[1], H.COL_NAME[2], H.COL_NAME[3], dimA }
            local n = 0   -- letter count, for test mode
            for _, row in ipairs(rows) do
              -- Groups spread out to fill the row; a lone group sits on the left.
              local rowSum = 0
              for _, gi in ipairs(row) do rowSum = rowSum + widths[gi] end
              local gapW = (#row > 1) and (total - rowSum) / (#row - 1) or 0
              local x = x0
              local first = true
              for _, gi in ipairs(row) do
                local g = SLOTS[gi]
                for i, s in ipairs(g) do
                    if i > 1 then x = x + g.gap * sp end
                    local c, left = dim, nil
                    n = n + 1
                    if M.test then
                        if n % 2 == 1 then c = ELEMENT[s[3]] or H.COL_NAME end
                    elseif mob ~= nil then
                        for _, fx in ipairs(s[2]) do
                            local rec = mob.fx[fx]
                            if rec ~= nil and rec.exp > now and (left == nil or rec.exp - now > left) then
                                left = rec.exp - now
                                c = ELEMENT[FX_ELEMENT[fx] or s[3]] or H.COL_NAME
                            end
                        end
                    end
                    if not first then imgui.SameLine(0, 0) end
                    first = false
                    imgui.SetCursorPosX(math.floor(x + 0.5))
                    imgui.TextColored(c, s[1])
                    x = x + H.text_w(s[1])
                end
                x = x0
                for _, k in ipairs(row) do
                    x = x + widths[k] + gapW
                    if k == gi then break end
                end
              end
            end
        end

        H.box_end()

        -- Remember where the box was dragged to.
        local wx, wy = H.xy(imgui.GetWindowPos())
        local ww, wh = H.xy(imgui.GetWindowSize())
        M.size = { ww, wh }

        -- Drag let go: snap to the HUD if near it, unstick if not.
        if M.drag and not imgui.IsMouseDown(0) then
            M.drag = false
            local key, side, off, e = nil, nil, nil, nil
            if config.tSnapOn ~= false then
                key, side, off, e = SN.find(H.rects(), nil, wx, wy, ww, wh)
            end
            if key ~= nil then
                config.tSnapTo, config.tSnap, config.tSnapOff, config.tSnapEnd = key, side, off, e
            else
                config.tSnap = ''
            end
            H.save()
        end

        if (wx ~= config.tx or wy ~= config.ty) and not imgui.IsMouseDown(0) then
            config.tx, config.ty = wx, wy
            H.save()
        end
    end
    imgui.End()
    H.pop_style()
end

----------------------------------------------------------------------
-- Settings tab
----------------------------------------------------------------------
local function check(label, key)
    local config = H.cfg()
    local v = { config[key] == true }
    if imgui.Checkbox(label .. '##tg_' .. key, v) then
        config[key] = v[1]
        if key == 'tgtDebuffs' and not v[1] then DB.mobs = T{} end
        H.save()
    end
end

function M.draw_tab()
    local config = H.cfg()
    check('Show the target bar', 'target')
    check('Distance', 'tgtDist')
    imgui.SameLine(0, 16)
    check('Mob ID', 'tgtId')
    if config.tgtDist and M.slider ~= nil then
        M.slider('HP bar length', 'tgtBarPct', 40, 100, 70, '%d%%')
        M.slider('Distance text size', 'tgtDistSize', 100, 200, 140, '%d%%')
    end
    check('Name color by type', 'tgtColors')
    imgui.TextColored(H.COL_NAME, 'Player')
    imgui.SameLine(0, 8)
    imgui.TextColored(H.COL_GREEN, 'NPC')
    imgui.SameLine(0, 8)
    imgui.TextColored(H.COL_YELLOW, 'Unclaimed mob')
    imgui.SameLine(0, 8)
    imgui.TextColored(H.COL_RED, 'Your mob')
    imgui.SameLine(0, 8)
    imgui.TextColored(COL_OTHERS, 'Someone else\'s mob')

    imgui.Dummy({ 0, 4 })
    check('Debuff letters', 'tgtDebuffs')
    imgui.SameLine(0, 16)
    if imgui.SmallButton((M.test and 'Test mode: ON' or 'Test mode: off') .. '##tgtest') then
        M.test = not M.test
    end
    if config.tgtDebuffs then
        if M.slider ~= nil then
            M.slider('Off letter brightness', 'tgtDimPct', 10, 100, 55, '%d%%')
        end
        imgui.TextColored(H.COL_NAME, 'Lights up for every debuff seen landing on a mob, from anyone.')
        imgui.TextColored(H.COL_NAME, 'D B = Dia, Bio.   P S E G B F = Paralyze, Slow, Elegy,')
        imgui.TextColored(H.COL_NAME, 'Gravity, Blind, Flash.   Si Sl Bi Po Rq = Silence, Sleep,')
        imgui.TextColored(H.COL_NAME, 'Bind, Poison, Requiem.   S R C F B D = Shock, Rasp, Choke,')
        imgui.TextColored(H.COL_NAME, 'Frost, Burn, Drown.')
        imgui.TextColored(H.COL_NAME, 'Lit color = element:')
        for _, e in ipairs({ 'fire', 'ice', 'wind', 'earth', 'thunder', 'water', 'light', 'dark' }) do
            imgui.SameLine(0, 6)
            imgui.TextColored(ELEMENT[e], e:sub(1, 1):upper() .. e:sub(2))
        end
    end
    imgui.TextColored(H.COL_NAME, 'Bar size, colors, click through and theme follow the HUD.')

    -- Position: type a number or use - / + (Ctrl + click moves 10).
    imgui.Dummy({ 0, 4 })
    imgui.TextColored(H.COL_ACCENT, 'Target bar position')
    check('Snap to the HUD when dragged near it', 'tSnapOn')
    if config.tSnap ~= nil and config.tSnap ~= '' then
        local what = H.part_name(config.tSnapTo or 'hud') or 'the HUD'
        imgui.TextColored(H.COL_NAME, 'Stuck ' .. (SIDE_NAME[config.tSnap] or config.tSnap)
            .. ' ' .. what .. '. It moves with it.')
        imgui.SameLine(0, 8)
        if imgui.Button('Unsnap##tgunsnap') then
            config.tSnap = ''
            H.save()
        end
    else
        imgui.TextColored(H.COL_NAME, 'Not stuck to the HUD.')
    end
    for i, k in ipairs({ 'tx', 'ty' }) do
        if i > 1 then imgui.SameLine(0, 12) end
        local v = { math.floor((tonumber(config[k]) or 0) + 0.5) }
        local label = (k == 'tx' and 'X' or 'Y') .. '##tgpos' .. k
        local changed
        if H.has('InputInt') then
            H.width_push(110)
            changed = imgui.InputInt(label, v, 1, 10)
            H.width_pop()
        else
            changed = H.int_control(label, v, 0, 9999)
        end
        if changed then
            config[k] = math.max(0, v[1])
            config.tSnap = ''   -- a typed spot unsticks it
            M.move = true
            H.save()
        end
    end
end

-- /phud test
function M.toggle_test()
    M.test = not M.test
    return M.test
end

-- /phud target
function M.toggle()
    local config = H.cfg()
    config.target = not config.target
    H.save()
    return config.target
end

----------------------------------------------------------------------
-- Packets 0x028 (actions) and 0x029 (wear-off / defeated messages),
-- only while the debuff letters are on.
----------------------------------------------------------------------
ashita.events.register('packet_in', 'phud_packet', function (e)
    if e.id ~= 0x028 and e.id ~= 0x029 then return end
    if H.cfg == nil then return end
    local config = H.cfg()
    if not config.target or not config.tgtDebuffs then return end

    -- If the last packet hit a game-memory error, say where it stopped.
    local note = DB.crash_note()
    if note ~= nil then print(chat.header(addon.name):append(chat.message(note))) end

    if e.id == 0x029 then
        DB.step = 'debuffs: wear-off message'
        pcall(DB.handle_message, e)
    else
        DB.step = 'debuffs: start'
        pcall(DB.handle_action, e)
    end
    DB.step = nil
end)

return M
