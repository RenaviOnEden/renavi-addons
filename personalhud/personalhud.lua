----------------------------------------------------------------------
-- PersonalHud (Ashita v4 / HorizonXI)
--
-- One small box with your name, jobs, HP, MP, TP and XP (or LP once
-- your XP is capped).
--
-- Looks and settings match PersonalBuffs: same themes, same Style
-- options, saved custom looks, and a /phud settings window.
--
-- Files: personalhud.lua (this), themes.lua (themes, copied from
--        PersonalBuffs so both addons look the same).
----------------------------------------------------------------------
addon.name    = 'personalhud'
addon.author  = 'Renavi'
addon.version = '1.0'
addon.desc    = 'Shows your HP, MP, TP and XP / LP in a small themed box.'
addon.link    = 'https://github.com/RenaviOnEden/renavi-addons'

require('common')
local chat     = require('chat')
local imgui    = require('imgui')
local settings = require('settings')
local TH       = require('themes')

----------------------------------------------------------------------
-- Settings (saved automatically)
----------------------------------------------------------------------
local defaults = T{
    x            = 100,     -- window position
    y            = 100,
    visible      = true,    -- HUD on / off
    theme        = 'Default',
    customThemes = T{},     -- your saved looks: { name, base theme, style, opacity }
    style        = T{},     -- your own style tweaks on top of the theme
    opacity      = 0,       -- background opacity in % (10-100); 0 = use the theme's own

    barWidth     = 180,     -- bar width in pixels
    barHeight    = 100,     -- bar height in % of the text height
    barColors    = 'classic', -- 'classic' (built-in colors) or 'theme'
    showTP       = true,
    showXP       = true,    -- XP bar (LP when your XP is capped)
    hideNoMP     = false,   -- hide the MP bar on jobs with no MP
    warnColors   = true,    -- HP / MP numbers turn yellow / orange / red when low
    clickThru    = false,   -- mouse goes through the HUD (can't drag it)
    followPB     = false,   -- copy the theme from PersonalBuffs
    hideFullLog  = true,    -- hide while the full chat log is open
}
local config = settings.load(defaults)

local function deep_copy(v)
    if type(v) ~= 'table' then return v end
    local out = T{}
    for k, x in pairs(v) do out[k] = deep_copy(x) end
    return out
end

-- Fills in anything missing from an older settings file, using the defaults.
local function fill_missing(cfg, def)
    for k, v in pairs(def) do
        if cfg[k] == nil then
            cfg[k] = deep_copy(v)
        elseif type(v) == 'table' and type(cfg[k]) == 'table' then
            fill_missing(cfg[k], v)
        end
    end
end
fill_missing(config, defaults)

settings.register('settings', 'phud_settings', function (s)
    if s ~= nil then config = s end
    fill_missing(config, defaults)
end)

----------------------------------------------------------------------
-- Colors. Picking a theme copies its colors into these tables.
----------------------------------------------------------------------
local COL_NAME    = { 0.88, 0.88, 0.88, 1.0 }
local COL_GREEN   = { 0.55, 0.80, 0.55, 1.0 }
local COL_YELLOW  = { 0.85, 0.78, 0.45, 1.0 }
local COL_RED     = { 0.82, 0.45, 0.45, 1.0 }
local COL_TARGET  = { 0.60, 0.72, 0.86, 1.0 }
local COL_BG      = { 0.05, 0.05, 0.08, 0.70 }
local COL_BORDER  = { 0.35, 0.35, 0.40, 0.80 }
local COL_BTN     = { 0.18, 0.20, 0.26, 0.90 }
local COL_BTN_SEL = { 0.28, 0.38, 0.30, 0.95 }
local COL_ACCENT  = { 0.60, 0.72, 0.86, 1.00 }

-- Built-in bar colors (the "classic" look).
local CLASSIC = {
    hp       = { 0.83, 0.33, 0.28, 1.0 },
    mp       = { 0.81, 0.81, 0.50, 1.0 },
    tp       = { 1.00, 1.00, 1.00, 1.0 },
    tpActive = { 0.23, 0.67, 0.91, 1.0 },
    xp       = { 0.01, 0.67, 0.07, 1.0 },
    lp       = { 0.61, 0.32, 0.71, 1.0 },
    barBg    = { 0.16, 0.17, 0.20, 1.0 },
}
local COL_ORANGE = { 1.00, 0.64, 0.00, 1.0 }

local THEMES        = TH.THEMES
local FAMILIES      = TH.FAMILIES
local DEFAULT_STYLE = TH.DEFAULT_STYLE

local THEME_COLS = { NAME = COL_NAME, GREEN = COL_GREEN, YELLOW = COL_YELLOW, RED = COL_RED,
                     TARGET = COL_TARGET, BG = COL_BG, BORDER = COL_BORDER,
                     BTN = COL_BTN, BTN_SEL = COL_BTN_SEL, ACCENT = COL_ACCENT }
local currentTheme = nil
local appliedTheme = nil

-- Finds a theme by name. Ignores case, spaces and ' so "sandoria" works.
local function theme_key(s)
    return (tostring(s or ''):lower():gsub('[^%a]', ''))
end
local function find_theme(name)
    local want = theme_key(name)
    for _, th in ipairs(THEMES) do
        if theme_key(th.name) == want then return th end
    end
    return nil
end

local function apply_theme(name)
    local th = find_theme(name) or THEMES[1]
    for k, dst in pairs(THEME_COLS) do
        for i = 1, 4 do dst[i] = th[k][i] end
    end
    currentTheme = th
    return th.name
end

----------------------------------------------------------------------
-- Match PersonalBuffs: read its saved settings now and then and use
-- its theme, style tweaks and opacity. PersonalBuffs isn't changed.
----------------------------------------------------------------------
local pbLook    = nil     -- { theme, style, opacity } read from PersonalBuffs
local pbFound   = false   -- was its settings file found and read?
local pbAt      = -100    -- os.clock() of the last read
local PB_EVERY  = 2       -- seconds between reads

-- PersonalBuffs' settings file sits next to ours:
-- config\addons\personalhud\<Name>_<ID>\  ->  config\addons\personalbuffs\<Name>_<ID>\
local function pb_file()
    local ok, p = pcall(settings.settings_path)
    if not ok or type(p) ~= 'string' then return nil end
    local i, j = p:find('\\personalhud\\', 1, true)
    if i == nil then return nil end
    return p:sub(1, i) .. 'personalbuffs\\' .. p:sub(j + 1) .. 'settings.lua'
end

local function read_pb()
    local file = pb_file()
    if file == nil or not ashita.fs.exists(file) then return nil end
    local ok, t = pcall(function () return loadfile(file)() end)
    if not ok or type(t) ~= 'table' then return nil end
    local st = T{}
    for k, v in pairs(type(t.style) == 'table' and t.style or {}) do st[k] = v end
    return { theme = t.theme or 'Default', style = st, opacity = tonumber(t.opacity) or 0 }
end

local function update_pb()
    if not config.followPB then return end
    local c = os.clock()
    if c - pbAt < PB_EVERY and c >= pbAt then return end
    pbAt = c
    local look = read_pb()
    pbFound = (look ~= nil)
    if look ~= nil then pbLook = look end
end

local function following() return config.followPB and pbLook ~= nil end
local function look_theme()   return following() and pbLook.theme   or config.theme end
local function look_style()   return following() and pbLook.style   or config.style end
local function look_opacity() return following() and pbLook.opacity or config.opacity end

-- One style setting: your own tweak if set, else the theme's, else the default.
local function S(key)
    local st   = look_style()
    local mine = st and st[key]
    if mine ~= nil then return mine end
    local ts = currentTheme and currentTheme.style
    if ts ~= nil and ts[key] ~= nil then return ts[key] end
    return DEFAULT_STYLE[key]
end

----------------------------------------------------------------------
-- Small helpers (same as PersonalBuffs)
----------------------------------------------------------------------
local function clamp(v, lo, hi, def)
    v = tonumber(v) or def
    if v < lo then return lo end
    if v > hi then return hi end
    return v
end

-- Ashita's imgui returns positions either as two numbers or as a table.
local function xy(a, b)
    if type(a) == 'table' then return a[1] or a.x or 0, a[2] or a.y or 0 end
    return a or 0, b or 0
end

local function u32(c) return imgui.GetColorU32(c) end
local function has(name) return imgui[name] ~= nil end

local function text_w(txt)
    local ok, w = pcall(imgui.CalcTextSize, txt)
    if ok then return (xy(w)) end
    return #txt * 7
end

local function can_scale()
    return has('SetWindowFontScale') or (has('PushFont') and has('PopFont') and has('GetFontSize'))
end

local function line(col)
    if not has('Separator') then imgui.Dummy({ 0, 4 }); return end
    imgui.PushStyleColor(ImGuiCol_Separator, col)
    imgui.Separator()
    imgui.PopStyleColor(1)
end

local fontPushed = false
local function box_scale()
    local sc = clamp(S('scale'), 80, 130, 100) / 100
    if has('SetWindowFontScale') then
        pcall(imgui.SetWindowFontScale, sc)
        return
    end
    if sc == 1 or not can_scale() then return end
    local okSize, base = pcall(imgui.GetFontSize)
    if not okSize or type(base) ~= 'number' then return end
    fontPushed = pcall(imgui.PushFont, nil, base * sc)
end

-- Side stripe and inner border, drawn just before the box ends.
local function box_decor()
    local stripe = clamp(S('stripe'), 0, 6, 0)
    local double = (S('border') == 'double')
    if stripe == 0 and not double then return end
    pcall(function ()
        local dl = imgui.GetWindowDrawList()
        local wx, wy = xy(imgui.GetWindowPos())
        local ww, wh = xy(imgui.GetWindowSize())
        local r = clamp(S('rounding'), 0, 12, 6)
        if stripe > 0 then
            local inset = math.max(2, r / 2)
            dl:AddRectFilled({ wx + 2, wy + inset }, { wx + 2 + stripe, wy + wh - inset },
                u32(COL_ACCENT), stripe / 2)
        end
        if double then
            dl:AddRect({ wx + 3, wy + 3 }, { wx + ww - 3, wy + wh - 3 },
                u32(COL_BORDER), math.max(0, r - 2), 0, 1)
        end
    end)
end

local function box_end()
    box_decor()
    if fontPushed then
        pcall(imgui.PopFont)
        fontPushed = false
    end
end

-- Pushes the look for a window. isBox = the HUD (gets stripe and spacing);
-- the settings window only gets colors, corners and border.
local styleStack = {}
local function push_style(isBox)
    local nc, nv = 0, 0
    local op = tonumber(look_opacity()) or 0
    if op > 0 then
        op = clamp(op, 10, 100, 100)
        imgui.PushStyleColor(ImGuiCol_WindowBg, { COL_BG[1], COL_BG[2], COL_BG[3], op / 100 })
    else
        imgui.PushStyleColor(ImGuiCol_WindowBg, COL_BG)
    end
    imgui.PushStyleColor(ImGuiCol_Border, COL_BORDER)
    nc = 2

    local r = clamp(S('rounding'), 0, 12, 6)
    imgui.PushStyleVar(ImGuiStyleVar_WindowRounding, r)
    imgui.PushStyleVar(ImGuiStyleVar_ChildRounding, r)
    imgui.PushStyleVar(ImGuiStyleVar_FrameRounding, math.floor(r / 2 + 0.5))

    local b = S('border')
    local bsize = (b == 'none') and 0 or (b == 'thick') and 2 or 1
    imgui.PushStyleVar(ImGuiStyleVar_WindowBorderSize, bsize)

    local stripe = isBox and clamp(S('stripe'), 0, 6, 0) or 0
    local padX = 6 + math.floor(r / 3) + (stripe > 0 and stripe + 2 or 0)
    local padY = 4 + math.floor(r / 4) + ((isBox and b == 'double') and 2 or 0)
    imgui.PushStyleVar(ImGuiStyleVar_WindowPadding, { padX, padY })
    nv = 5

    if isBox then
        local sp = S('spacing')
        local gap = (sp == 'compact') and 1 or (sp == 'roomy') and 7 or 4
        imgui.PushStyleVar(ImGuiStyleVar_ItemSpacing, { 8, gap })
        imgui.PushStyleVar(ImGuiStyleVar_FramePadding, { 0, 0 })
        nv = nv + 2
    end
    styleStack[#styleStack + 1] = { nc, nv }
end

local function pop_style()
    local t = table.remove(styleStack) or { 2, 5 }
    imgui.PopStyleVar(t[2])
    imgui.PopStyleColor(t[1])
end

-- Number control: a slider when available, else - / + buttons.
local function int_control(label, v, lo, hi, fmt)
    if has('SliderInt') then
        return imgui.SliderInt(label, v, lo, hi, fmt or '%d')
    end
    local changed = false
    local id = label:match('##(.*)$') or label
    local shown = label:gsub('##.*$', '')
    if imgui.SmallButton(' - ##m' .. id) and v[1] > lo then v[1] = v[1] - 1; changed = true end
    imgui.SameLine(0, 4)
    imgui.TextColored(COL_NAME, (string.format(fmt or '%d', v[1])))
    imgui.SameLine(0, 4)
    if imgui.SmallButton(' + ##p' .. id) and v[1] < hi then v[1] = v[1] + 1; changed = true end
    imgui.SameLine(0, 8)
    imgui.TextColored(COL_NAME, shown)
    return changed
end

local function width_push(w) if has('PushItemWidth') then imgui.PushItemWidth(w) end end
local function width_pop() if has('PushItemWidth') and has('PopItemWidth') then imgui.PopItemWidth() end end

local function item_done()
    if imgui.IsItemDeactivatedAfterEdit ~= nil then return imgui.IsItemDeactivatedAfterEdit() end
    if imgui.IsItemEdited ~= nil then return imgui.IsItemEdited() end
    return false
end

-- A button that looks "pressed" when selected.
local function pick_button(label, selected, width)
    imgui.PushStyleColor(ImGuiCol_Button, selected and COL_BTN_SEL or COL_BTN)
    local clicked = imgui.Button(label, { width or 0, 0 })
    imgui.PopStyleColor(1)
    return clicked
end

local moveHud    = false      -- position typed in the menu: move on next draw
local showConfig = { false }

----------------------------------------------------------------------
-- Reading the player
----------------------------------------------------------------------
local function job_abbr(id)
    if id == nil or id == 0 then return '' end
    local ok, s = pcall(function ()
        return AshitaCore:GetResourceManager():GetString('jobs.names_abbr', id)
    end)
    return (ok and s) or ''
end

-- 1234 -> "1234", 12345 -> "12.3k"
local function fmt_num(n)
    n = tonumber(n) or 0
    if n >= 10000 then return string.format('%.1fk', n / 1000) end
    return tostring(math.floor(n))
end

local function read_player()
    local mm     = AshitaCore:GetMemoryManager()
    local player = mm:GetPlayer()
    local party  = mm:GetParty()
    if player == nil or party == nil then return nil end
    if player:GetMainJob() == 0 or player:GetIsZoning() == 1 then return nil end

    local d = {}
    local ent = GetPlayerEntity and GetPlayerEntity() or nil
    d.name  = (ent ~= nil and ent.Name) or party:GetMemberName(0) or ''
    d.job   = player:GetMainJob()
    d.lvl   = player:GetMainJobLevel()
    d.sub   = player:GetSubJob()
    d.slvl  = player:GetSubJobLevel()
    d.hp    = party:GetMemberHP(0)
    d.hpMax = player:GetHPMax()
    d.mp    = party:GetMemberMP(0)
    d.mpMax = player:GetMPMax()
    d.tp    = party:GetMemberTP(0)

    -- LP once your XP is capped.
    local okLock, locked = pcall(function () return player:GetIsExperiencePointsLocked() end)
    if not okLock then locked = (d.lvl >= 75) end
    d.limit = locked == true or locked == 1
    if d.limit then
        d.xp, d.xpMax = player:GetLimitPoints(), 10000
    else
        d.xp, d.xpMax = player:GetExpCurrent(), player:GetExpNeeded()
    end
    return d
end

----------------------------------------------------------------------
-- Open game menu (same memory read HXUI uses). The full chat log
-- shows up as a menu named "fulllog".
----------------------------------------------------------------------
local pGameMenu = ashita.memory.find('FFXiMain.dll', 0, '8B480C85C974??8B510885D274??3B05', 16, 0)

local function menu_name()
    if pGameMenu == nil or pGameMenu == 0 then return '' end
    local ok, name = pcall(function ()
        local sub = ashita.memory.read_uint32(pGameMenu)
        if sub == nil or sub == 0 then return '' end
        local val = ashita.memory.read_uint32(sub)
        if val == nil or val == 0 then return '' end
        local head = ashita.memory.read_uint32(val + 4)
        if head == nil or head == 0 then return '' end
        return (ashita.memory.read_string(head + 0x46, 16):gsub('%z', ''))
    end)
    return (ok and name) or ''
end

local function full_log_open()
    return menu_name():find('fulllog', 1, true) ~= nil
end

----------------------------------------------------------------------
-- The HUD
----------------------------------------------------------------------
local FLAGS = bit.bor(
    ImGuiWindowFlags_NoTitleBar,
    ImGuiWindowFlags_NoResize,
    ImGuiWindowFlags_AlwaysAutoResize,
    ImGuiWindowFlags_NoScrollbar,
    ImGuiWindowFlags_NoCollapse,
    ImGuiWindowFlags_NoFocusOnAppearing,
    ImGuiWindowFlags_NoNav,
    ImGuiWindowFlags_NoSavedSettings
)

-- Number color: normal, or yellow / orange / red when low.
local function warn_color(cur, max)
    if not config.warnColors or max <= 0 then return COL_NAME end
    local f = cur / max
    if f > 0.75 then return COL_NAME end
    if f > 0.50 then return COL_YELLOW end
    if f > 0.25 then return COL_ORANGE end
    return COL_RED
end

-- Bar colors: built-in, or taken from the theme.
local function bar_colors()
    if config.barColors == 'theme' then
        return { hp = COL_RED, mp = COL_YELLOW, tp = COL_NAME, tpActive = COL_TARGET,
                 xp = COL_GREEN, lp = COL_ACCENT,
                 barBg = { COL_BORDER[1] * 0.4, COL_BORDER[2] * 0.4, COL_BORDER[3] * 0.4, 0.9 } }
    end
    return CLASSIC
end

-- One row: "HP  1156" then the bar.
local function draw_row(label, value, valueCol, cur, max, barCol, bgCol, overlay, numW, barH)
    local frac = (max > 0) and (cur / max) or 0
    if frac < 0 then frac = 0 elseif frac > 1 then frac = 1 end

    local x0 = imgui.GetCursorPosX()
    imgui.TextColored(COL_NAME, label)
    imgui.SameLine(0, 0)
    local v = tostring(value)
    imgui.SetCursorPosX(x0 + numW - text_w(v))
    imgui.TextColored(valueCol, v)
    imgui.SameLine(0, 8)

    imgui.PushStyleColor(ImGuiCol_PlotHistogram, barCol)
    imgui.PushStyleColor(ImGuiCol_FrameBg, bgCol)
    imgui.PushStyleColor(ImGuiCol_Text, COL_NAME)
    imgui.ProgressBar(frac, { config.barWidth, barH }, '')
    imgui.PopStyleColor(3)

    -- The % is drawn here, always centered on the bar (the game's own bar
    -- text moves along with the fill). Dark once the fill passes the
    -- middle of the text, light before that.
    if overlay ~= nil and overlay ~= '' then
        local ok = pcall(function ()
            local x1, y1 = xy(imgui.GetItemRectMin())
            local x2, y2 = xy(imgui.GetItemRectMax())
            local tw = text_w(overlay)
            local th = has('GetTextLineHeight') and imgui.GetTextLineHeight() or (y2 - y1)
            local tx = math.floor(x1 + ((x2 - x1) - tw) / 2 + 0.5)
            local ty = math.floor(y1 + ((y2 - y1) - th) / 2 + 0.5)
            local fillEnd = x1 + (x2 - x1) * frac
            local dl      = imgui.GetWindowDrawList()
            local dark    = u32({ 0.06, 0.06, 0.08, 1.0 })
            local light   = u32(COL_NAME)

            if fillEnd >= tx + tw then
                dl:AddText({ tx, ty }, dark, overlay)          -- all on the fill
            elseif fillEnd <= tx then
                dl:AddText({ tx, ty }, light, overlay)         -- all on the empty part
            else
                -- Fill edge is inside the text: dark left of it, light right of it.
                dl:PushClipRect({ x1, y1 }, { fillEnd, y2 }, true)
                dl:AddText({ tx, ty }, dark, overlay)
                dl:PopClipRect()
                dl:PushClipRect({ fillEnd, y1 }, { x2, y2 }, true)
                dl:AddText({ tx, ty }, light, overlay)
                dl:PopClipRect()
            end
        end)
        if not ok then
            imgui.SameLine(0, 6)
            imgui.TextColored(COL_NAME, overlay)
        end
    end
end

local function draw_hud()
    if not config.visible then return end
    if config.hideFullLog and full_log_open() then return end
    local ok, d = pcall(read_player)
    if not ok or d == nil then return end

    local flags = FLAGS
    if config.clickThru then flags = bit.bor(flags, ImGuiWindowFlags_NoInputs) end

    imgui.SetNextWindowPos({ config.x, config.y }, moveHud and ImGuiCond_Always or ImGuiCond_FirstUseEver)
    moveHud = false
    push_style(true)

    if imgui.Begin('personalhud', true, flags) then
        box_scale()
        local col = bar_colors()

        -- Sizes follow the text size.
        local lineH = has('GetTextLineHeight') and imgui.GetTextLineHeight() or 14
        local barH  = math.max(4, math.floor(lineH * clamp(config.barHeight, 50, 150, 100) / 100 + 0.5))
        local numW  = text_w('LP 00000')
        local total = numW + 8 + config.barWidth
        local x0    = imgui.GetCursorPosX()

        -- Header: name on the left, jobs on the right.
        local jobs = job_abbr(d.job) .. d.lvl
        if d.sub ~= nil and d.sub ~= 0 then jobs = jobs .. '/' .. job_abbr(d.sub) .. d.slvl end
        imgui.TextColored(COL_NAME, d.name)

        -- XP to next level (or LP to next merit), centered in the header.
        if config.showXP and d.xpMax > 0 then
            local left = d.xpMax - d.xp
            if left < 0 then left = 0 end
            local tnl = d.limit and (fmt_num(left) .. ' to merit') or (fmt_num(left) .. ' TNL')
            local nameEnd = x0 + text_w(d.name)
            local jobsAt  = x0 + total - text_w(jobs)
            local tx = math.floor(x0 + (total - text_w(tnl)) / 2 + 0.5)
            -- Only if it fits between the name and jobs.
            if tx > nameEnd + 6 and tx + text_w(tnl) < jobsAt - 6 then
                imgui.SameLine(0, 0)
                imgui.SetCursorPosX(tx)
                imgui.TextColored(COL_TARGET, tnl)
            end
        end

        imgui.SameLine(0, 0)
        imgui.SetCursorPosX(x0 + total - text_w(jobs))
        imgui.TextColored(S('header') and COL_ACCENT or COL_NAME, jobs)
        if S('header') then line(COL_ACCENT) elseif S('dividers') then line(COL_BORDER) end

        -- "62%" for the bars (blank when there's no max, e.g. no MP).
        local function pct(cur, max)
            if max == nil or max <= 0 then return '' end
            local n = math.floor(cur / max * 100)
            if n < 0 then n = 0 elseif n > 100 then n = 100 end
            return n .. '%'
        end

        draw_row('HP', d.hp, warn_color(d.hp, d.hpMax), d.hp, d.hpMax, col.hp, col.barBg, pct(d.hp, d.hpMax), numW, barH)
        if not (config.hideNoMP and d.mpMax <= 0) then
            draw_row('MP', d.mp, warn_color(d.mp, d.mpMax), d.mp, d.mpMax, col.mp, col.barBg, pct(d.mp, d.mpMax), numW, barH)
        end
        if config.showTP then
            local active = d.tp >= 1000
            draw_row('TP', d.tp, active and col.tpActive or COL_NAME, d.tp, 3000,
                     active and col.tpActive or col.tp, col.barBg, '', numW, barH)
        end
        if config.showXP then
            local pct = (d.xpMax > 0) and math.floor(d.xp / d.xpMax * 100) or 0
            if pct > 100 then pct = 100 end
            draw_row(d.limit and 'LP' or 'XP', fmt_num(d.xp), COL_NAME, d.xp, d.xpMax,
                     d.limit and col.lp or col.xp, col.barBg, pct .. '%', numW, barH)
        end

        box_end()

        -- Remember where the box was dragged to.
        local x, y = xy(imgui.GetWindowPos())
        if (x ~= config.x or y ~= config.y) and not imgui.IsMouseDown(0) then
            config.x, config.y = x, y
            settings.save()
        end
    end
    imgui.End()
    pop_style()
end

----------------------------------------------------------------------
-- Themes (same as PersonalBuffs)
----------------------------------------------------------------------
local STYLE_KEYS = { 'header', 'border', 'stripe', 'dividers', 'spacing', 'scale', 'rounding' }

local function find_family(name)
    for _, f in ipairs(FAMILIES) do
        if f.name == name then return f end
    end
    return nil
end

local function family_of(theme)
    for _, f in ipairs(FAMILIES) do
        for _, n in ipairs(f.themes) do
            if n == theme then return f.name end
        end
    end
    return 'Default'
end

local function short_name(fam, name)
    if fam.name == 'Glass' then
        if name == 'Glass' then return 'Clear' end
        return (name:gsub('^Glass ', ''))
    end
    return name
end

local function use_theme(name)
    config.theme        = name
    config.style        = T{}
    config.opacity      = 0
    config.activeCustom = nil
    settings.save()
end

local function find_custom(name)
    local want = theme_key(name)
    for i, c in ipairs(config.customThemes or {}) do
        if theme_key(c.name) == want then return c, i end
    end
    return nil, nil
end

local function save_custom(name)
    name = tostring(name or ''):gsub('^%s+', ''):gsub('%s+$', '')
    if name == '' then
        local n = 1
        repeat
            name = 'Custom ' .. n
            n = n + 1
        until find_custom(name) == nil
    end
    local st = T{}
    for _, k in ipairs(STYLE_KEYS) do st[k] = S(k) end
    local snap = T{ name = name, base = config.theme, style = st, opacity = tonumber(config.opacity) or 0 }
    local _, i = find_custom(name)
    if i ~= nil then config.customThemes[i] = snap else table.insert(config.customThemes, snap) end
    config.activeCustom = name
    settings.save()
    return name
end

local function use_custom(c)
    config.theme = find_theme(c.base) and c.base or 'Default'
    config.style = T{}
    for k, v in pairs(c.style or {}) do config.style[k] = v end
    config.opacity      = tonumber(c.opacity) or 0
    config.activeCustom = c.name
    settings.save()
end

local function delete_custom(name)
    local _, i = find_custom(name)
    if i ~= nil then table.remove(config.customThemes, i) end
    if config.activeCustom == name then config.activeCustom = nil end
    settings.save()
end

----------------------------------------------------------------------
-- Settings window (/phud)
----------------------------------------------------------------------
local selTab    = 'Bars'
local selFamily = nil
local nameBuf   = { '' }
local showStyle = false

local function fold(label, open)
    if imgui.SmallButton((open and '-  ' or '+  ') .. label .. '##fold' .. label) then
        return not open
    end
    return open
end

local function grid_button(i, label, selected)
    if (i - 1) % 4 ~= 0 then imgui.SameLine(0, 4) end
    return pick_button(label, selected, 84)
end

-- Checkbox for a plain setting.
local function check(label, key)
    local v = { config[key] == true }
    if imgui.Checkbox(label .. '##cfg_' .. key, v) then
        config[key] = v[1]
        settings.save()
    end
end

-- Slider for a plain setting.
local function slider(label, key, lo, hi, def, fmt)
    local v = { math.floor(clamp(config[key], lo, hi, def) + 0.5) }
    width_push(160)
    if int_control(label .. '##cfg_' .. key, v, lo, hi, fmt) then
        config[key] = v[1]
        if not has('SliderInt') then settings.save() end
    end
    local done = has('SliderInt') and item_done()
    width_pop()
    if done then settings.save() end
end

local function draw_bars_tab()
    check('Show the HUD', 'visible')
    check('TP bar', 'showTP')
    imgui.SameLine(0, 16)
    check('XP / LP bar', 'showXP')
    check('Hide the MP bar on jobs with no MP', 'hideNoMP')
    check('Low HP / MP numbers change color', 'warnColors')
    check('Click through (mouse goes through the HUD, can\'t drag it)', 'clickThru')
    check('Hide while the full chat log is open', 'hideFullLog')

    imgui.Dummy({ 0, 4 })
    imgui.TextColored(COL_NAME, 'Bar colors')
    imgui.SameLine(0, 4)
    if pick_button('Classic##bc1', config.barColors ~= 'theme', 64) then
        config.barColors = 'classic'; settings.save()
    end
    imgui.SameLine(0, 4)
    if pick_button('Theme##bc2', config.barColors == 'theme', 64) then
        config.barColors = 'theme'; settings.save()
    end
    imgui.TextColored(COL_NAME, 'Classic = the built-in colors. Theme = colors from your theme.')

    imgui.Dummy({ 0, 4 })
    slider('Bar width', 'barWidth', 80, 400, 180, '%d px')
    slider('Bar height', 'barHeight', 50, 150, 100, '%d%%')

    -- HUD position: type a number or use - / + (Ctrl + click moves 10).
    imgui.Dummy({ 0, 4 })
    imgui.TextColored(COL_ACCENT, 'HUD position')
    imgui.TextColored(COL_NAME, 'Type a number or use - / +. Ctrl + click moves 10.')
    for i, k in ipairs({ 'x', 'y' }) do
        if i > 1 then imgui.SameLine(0, 12) end
        local v = { math.floor((tonumber(config[k]) or 0) + 0.5) }
        local changed
        if has('InputInt') then
            width_push(110)
            changed = imgui.InputInt(k:upper() .. '##phpos' .. k, v, 1, 10)
            width_pop()
        else
            changed = int_control(k:upper() .. '##phpos' .. k, v, 0, 9999)
        end
        if changed then
            config[k] = math.max(0, v[1])
            moveHud = true
            settings.save()
        end
    end
end

local function draw_theme_tab()
    -- Match PersonalBuffs switch.
    local fv = { config.followPB == true }
    if imgui.Checkbox('Match PersonalBuffs##follow', fv) then
        config.followPB = fv[1]
        pbAt = -100          -- read it right away
        settings.save()
    end
    if config.followPB then
        if pbFound and pbLook ~= nil then
            imgui.TextColored(COL_ACCENT, 'Using PersonalBuffs\' theme: ' .. tostring(pbLook.theme))
            imgui.TextColored(COL_NAME, 'Change the theme in /pb and the HUD follows.')
            imgui.TextColored(COL_NAME, 'Turn this off to pick a theme here.')
            return
        end
        imgui.TextColored(COL_RED, 'PersonalBuffs settings not found. Using your own theme below.')
        imgui.TextColored(COL_NAME, 'Load PersonalBuffs once on this character, then wait a second.')
    end
    imgui.Dummy({ 0, 4 })

    if selFamily == nil then
        selFamily = config.activeCustom and 'Custom' or family_of(config.theme)
    end

    -- Main themes.
    local fams = {}
    for _, f in ipairs(FAMILIES) do fams[#fams + 1] = f.name end
    fams[#fams + 1] = 'Custom'
    for i, fname in ipairs(fams) do
        if i > 1 then imgui.SameLine(0, 4) end
        if pick_button(fname .. '##fam' .. i, selFamily == fname, 0) then
            selFamily = fname
            local f = find_family(fname)
            if f ~= nil and #f.themes == 1 then use_theme(f.themes[1]) end
        end
    end
    imgui.Dummy({ 0, 2 })

    -- Sub-themes of the chosen family (or your saved themes).
    if selFamily == 'Custom' then
        local list = config.customThemes or {}
        if #list == 0 then
            imgui.TextColored(COL_NAME, 'No saved themes yet. Make a look, then Save it below.')
        end
        for i, c in ipairs(list) do
            if grid_button(i, c.name .. '##cus' .. i, config.activeCustom == c.name) then use_custom(c) end
        end
    else
        local f = find_family(selFamily) or FAMILIES[1]
        if #f.themes > 1 then
            for i, n in ipairs(f.themes) do
                local sel = (config.theme == n and config.activeCustom == nil)
                if grid_button(i, short_name(f, n) .. '##var' .. i, sel) then use_theme(n) end
                local th = find_theme(n)
                if th ~= nil and th.desc ~= nil and has('IsItemHovered') and has('SetTooltip') and imgui.IsItemHovered() then
                    imgui.SetTooltip(th.desc)
                end
            end
        end
    end

    -- What's in use now.
    imgui.Dummy({ 0, 4 })
    local now = config.activeCustom or (currentTheme and currentTheme.name) or 'Default'
    imgui.TextColored(COL_ACCENT, 'Using: ' .. now)
    if config.activeCustom == nil and currentTheme ~= nil and currentTheme.desc ~= nil then
        imgui.TextColored(COL_NAME, currentTheme.desc)
    elseif config.activeCustom ~= nil then
        imgui.TextColored(COL_NAME, 'Your saved theme (based on ' .. tostring(config.theme) .. ').')
    end

    -- Save the current look as your own theme.
    imgui.Dummy({ 0, 4 })
    if has('InputText') then
        width_push(150)
        pcall(imgui.InputText, 'Name##phname', nameBuf, 24)
        width_pop()
        imgui.SameLine(0, 6)
    end
    if imgui.SmallButton('Save look##phsave') then
        save_custom(nameBuf[1])
        nameBuf[1] = ''
        selFamily  = 'Custom'
    end
    if config.activeCustom ~= nil then
        imgui.SameLine(0, 6)
        if imgui.SmallButton('Update "' .. config.activeCustom .. '"##phupd') then
            save_custom(config.activeCustom)
        end
        imgui.SameLine(0, 6)
        if imgui.SmallButton('Delete##phdel') then
            delete_custom(config.activeCustom)
        end
    end

    -- Style and position, folded away until opened.
    imgui.Dummy({ 0, 6 })
    showStyle = fold('Style', showStyle)
    if showStyle then
        if imgui.SmallButton("Use theme's style##stdef") then
            config.style        = T{}
            config.opacity      = 0
            config.activeCustom = nil
            settings.save()
        end
        imgui.SameLine(0, 8)
        imgui.TextColored(COL_NAME, 'Changes stay until you pick another theme.')

        local function scheck(label, key)
            local v = { S(key) == true }
            if imgui.Checkbox(label .. '##st_' .. key, v) then
                config.style[key] = v[1]
                settings.save()
            end
        end
        local function choice(label, key, opts)
            imgui.TextColored(COL_NAME, label)
            for _, o in ipairs(opts) do
                imgui.SameLine(0, 4)
                if pick_button(o[2] .. '##st_' .. key .. o[1], S(key) == o[1], 64) then
                    config.style[key] = o[1]
                    settings.save()
                end
            end
        end
        local function sslider(label, key, lo, hi, def, fmt)
            local v = { math.floor(clamp(S(key), lo, hi, def) + 0.5) }
            width_push(160)
            if int_control(label .. '##st_' .. key, v, lo, hi, fmt) then
                config.style[key] = v[1]
                if not has('SliderInt') then settings.save() end
            end
            local done = has('SliderInt') and item_done()
            width_pop()
            if done then settings.save() end
        end

        scheck('Header line', 'header')
        imgui.SameLine(0, 16)
        scheck('Line under the name', 'dividers')
        choice('Border ', 'border', { { 'none', 'None' }, { 'thin', 'Thin' },
                                      { 'thick', 'Thick' }, { 'double', 'Double' } })
        choice('Spacing', 'spacing', { { 'compact', 'Compact' }, { 'normal', 'Normal' },
                                       { 'roomy', 'Roomy' } })
        sslider('Side stripe', 'stripe', 0, 6, 0, '%d px')
        if can_scale() then sslider('Text size', 'scale', 80, 130, 100, '%d%%') end
        sslider('Corner roundness', 'rounding', 0, 12, 6)

        -- Background opacity. 0 means "use the theme's own".
        local thBg = (find_theme(config.theme) or THEMES[1]).BG[4]
        local cur  = tonumber(config.opacity) or 0
        local ov   = { cur > 0 and cur or math.floor(thBg * 100 + 0.5) }
        width_push(160)
        if int_control('Background opacity##opac', ov, 10, 100, '%d%%') then
            config.opacity = ov[1]
            if not has('SliderInt') then settings.save() end
        end
        local opDone = has('SliderInt') and item_done()
        width_pop()
        if opDone then settings.save() end
        imgui.SameLine(0, 8)
        if imgui.SmallButton('Theme default##opdef') then
            config.opacity = 0
            settings.save()
        end
    end

end

----------------------------------------------------------------------
-- Profiles: save every setting under a name, load it on another
-- character. Works the same as PersonalBuffs' profiles. Stored in
-- Ashita's config folder for this addon (shared by all characters):
--   config\addons\personalhud\profile_<name>.lua
-- plus profiles.txt, the list of names.
----------------------------------------------------------------------
local function profile_dir()
    local base = AshitaCore:GetInstallPath()
    if base:sub(-1) ~= '\\' and base:sub(-1) ~= '/' then base = base .. '\\' end
    return base .. 'config\\addons\\' .. addon.name .. '\\'
end

-- Letters, numbers, - and _ only, so it's a safe file name.
local function profile_clean(name)
    return (tostring(name or ''):gsub('[^%w%-_]', ''):sub(1, 32))
end

-- Turns a settings table into Lua text that can be loaded back.
local function to_lua(v, indent)
    indent = indent or ''
    local t = type(v)
    if t == 'string' then return string.format('%q', v) end
    if t == 'number' or t == 'boolean' then return tostring(v) end
    if t ~= 'table' then return 'nil' end
    local keys = {}
    for k in pairs(v) do
        if type(k) == 'string' or type(k) == 'number' then keys[#keys + 1] = k end
    end
    table.sort(keys, function (a, b)
        if type(a) == type(b) then return a < b end
        return type(a) == 'number'
    end)
    local inner = indent .. '    '
    local out = { '{' }
    for _, k in ipairs(keys) do
        local key = type(k) == 'number' and ('[' .. k .. ']') or ('[' .. string.format('%q', k) .. ']')
        out[#out + 1] = inner .. key .. ' = ' .. to_lua(v[k], inner) .. ','
    end
    out[#out + 1] = indent .. '}'
    return table.concat(out, '\n')
end

local function read_file(path)
    local f = io.open(path, 'r')
    if f == nil then return nil end
    local text = f:read('*a')
    f:close()
    return text
end

local function write_file(path, text)
    local f = io.open(path, 'w')
    if f == nil then return false end
    f:write(text)
    f:close()
    return true
end

-- Names of saved profiles (from profiles.txt).
local function profile_list()
    local names = {}
    local text = read_file(profile_dir() .. 'profiles.txt') or ''
    for line in text:gmatch('[^\r\n]+') do
        local n = profile_clean(line)
        if n ~= '' then names[#names + 1] = n end
    end
    table.sort(names)
    return names
end

local function profile_list_save(names)
    table.sort(names)
    return write_file(profile_dir() .. 'profiles.txt', table.concat(names, '\n') .. '\n')
end

-- Saves every setting. Returns true, name  or  false, reason.
local function profile_save(name)
    name = profile_clean(name)
    if name == '' then return false, 'Use letters, numbers, - or _ for the name.' end
    settings.save()   -- makes sure the folder exists
    local text = '-- PersonalHud profile "' .. name .. '"\nreturn ' .. to_lua(config) .. '\n'
    if not write_file(profile_dir() .. 'profile_' .. name .. '.lua', text) then
        return false, 'Could not write the profile file.'
    end
    local names, found = profile_list(), false
    for _, n in ipairs(names) do if n:lower() == name:lower() then found = true end end
    if not found then names[#names + 1] = name; profile_list_save(names) end
    return true, name
end

-- Loads a profile over this character's settings. Returns true, name  or  false, reason.
local function profile_load(name)
    name = profile_clean(name)
    local text = read_file(profile_dir() .. 'profile_' .. name .. '.lua')
    if text == nil then return false, 'No profile called "' .. name .. '".' end
    local chunk = (loadstring or load)(text)
    if chunk == nil then return false, 'That profile file is damaged.' end
    if setfenv ~= nil then setfenv(chunk, {}) end   -- data only, no access to anything else
    local ok, data = pcall(chunk)
    if not ok or type(data) ~= 'table' then return false, 'That profile file is damaged.' end

    -- Replace the settings in place (the settings library keeps this table).
    for k in pairs(config) do config[k] = nil end
    for k, v in pairs(data) do config[k] = deep_copy(v) end
    fill_missing(config, defaults)
    settings.save()

    -- Redraw with the new settings.
    appliedTheme = nil
    moveHud      = true
    pbAt         = -100
    selFamily    = nil
    return true, name
end

local function profile_delete(name)
    name = profile_clean(name)
    local names, kept = profile_list(), {}
    for _, n in ipairs(names) do
        if n:lower() ~= name:lower() then kept[#kept + 1] = n end
    end
    profile_list_save(kept)
    os.remove(profile_dir() .. 'profile_' .. name .. '.lua')
end

local profBuf = { '' }      -- profile name typed in
local profSel = nil         -- profile picked in the list
local profMsg = nil         -- last result shown in the tab

local function my_name()
    local ok, n = pcall(function ()
        return AshitaCore:GetMemoryManager():GetParty():GetMemberName(0)
    end)
    n = ok and profile_clean(n) or ''
    return n ~= '' and n or 'default'
end

local function draw_profiles_tab()
    imgui.TextColored(COL_NAME, 'Saves every HUD setting: look, bars, position, matching.')
    imgui.TextColored(COL_NAME, 'Tip: use the same name as your PersonalBuffs profile.')
    imgui.Dummy({ 0, 4 })
    if has('InputText') then
        width_push(150)
        pcall(imgui.InputText, 'Name##profname', profBuf, 32)
        width_pop()
        imgui.SameLine(0, 6)
    end
    if imgui.SmallButton('Save settings##profsave') then
        local name = profBuf[1]
        if not has('InputText') or profile_clean(name) == '' then name = my_name() end
        local ok, res = profile_save(name)
        profMsg = ok and ('Saved as "' .. res .. '".') or res
        if ok then profSel = res; profBuf[1] = '' end
    end
    imgui.Dummy({ 0, 4 })
    local list = profile_list()
    if #list == 0 then
        imgui.TextColored(COL_NAME, 'No profiles yet.')
    else
        for i, n in ipairs(list) do
            if grid_button(i, n .. '##prof' .. i, profSel == n) then profSel = n end
        end
    end
    if profSel ~= nil then
        imgui.Dummy({ 0, 4 })
        if imgui.SmallButton('Load "' .. profSel .. '" onto this character##profload') then
            local ok, res = profile_load(profSel)
            profMsg = ok and ('Loaded "' .. res .. '".') or res
        end
        imgui.SameLine(0, 6)
        if imgui.SmallButton('Delete##profdel') then
            profile_delete(profSel)
            profMsg = 'Deleted "' .. profSel .. '".'
            profSel = nil
        end
    end
    if profMsg ~= nil then imgui.TextColored(COL_ACCENT, profMsg) end
end

local function draw_config()
    if not showConfig[1] then return end

    imgui.SetNextWindowSize({ 460, 360 }, ImGuiCond_FirstUseEver)
    push_style()
    if imgui.Begin('PersonalHud##phconfig', showConfig, ImGuiWindowFlags_NoCollapse) then
        if pick_button('Bars##tabb', selTab == 'Bars', 62) then selTab = 'Bars' end
        imgui.SameLine(0, 4)
        if pick_button('Theme##tabt', selTab == 'Theme', 62) then selTab = 'Theme' end
        imgui.SameLine(0, 4)
        if pick_button('Profiles##tabp', selTab == 'Profiles', 62) then selTab = 'Profiles' end
        imgui.Dummy({ 0, 4 })

        if selTab == 'Theme' then draw_theme_tab()
        elseif selTab == 'Profiles' then draw_profiles_tab()
        else draw_bars_tab() end
    end
    imgui.End()
    pop_style()
end

----------------------------------------------------------------------
-- Draw every frame
----------------------------------------------------------------------
ashita.events.register('d3d_present', 'phud_present', function ()
    update_pb()
    -- Copy in the theme's colors when it changes (yours, or PersonalBuffs').
    local want = look_theme()
    if appliedTheme ~= want then
        local used = apply_theme(want)
        if not following() then config.theme = used end
        appliedTheme = want
    end
    draw_config()
    draw_hud()
end)

----------------------------------------------------------------------
-- Commands
----------------------------------------------------------------------
local function msg(text)
    print(chat.header(addon.name):append(chat.message(text)))
end

ashita.events.register('command', 'phud_command', function (e)
    local args = e.command:args()
    if #args == 0 then return end
    local c0 = args[1]:lower()
    if c0 ~= '/phud' and c0 ~= '/personalhud' then return end
    e.blocked = true

    local cmd  = (args[2] or ''):lower()
    local rest = table.concat(args, ' ', 3)

    if cmd == '' or cmd == 'config' then
        showConfig[1] = not showConfig[1]
        return
    end

    if cmd == 'toggle' or cmd == 'show' or cmd == 'hide' then
        if cmd == 'toggle' then config.visible = not config.visible else config.visible = (cmd == 'show') end
        settings.save()
        msg('HUD: ' .. (config.visible and 'shown' or 'hidden'))
        return
    end

    -- /phud profile save|load|delete <name>, /phud profile list
    if cmd == 'profile' or cmd == 'profiles' then
        local sub  = (args[3] or 'list'):lower()
        local name = table.concat(args, ' ', 4)
        if sub == 'save' then
            local ok, res = profile_save(name ~= '' and name or my_name())
            msg(ok and ('Settings saved as profile "' .. res .. '".') or res)
        elseif sub == 'load' and name ~= '' then
            local ok, res = profile_load(name)
            msg(ok and ('Loaded profile "' .. res .. '".') or res)
        elseif sub == 'delete' and name ~= '' then
            profile_delete(name)
            msg('Deleted profile "' .. profile_clean(name) .. '".')
        else
            local list = profile_list()
            msg(#list == 0 and 'No profiles yet. /phud profile save <name>'
                or ('Profiles: ' .. table.concat(list, ', ')))
        end
        return
    end

    -- /phud menu prints the name of the game menu open right now (for checking).
    if cmd == 'menu' then
        local n = menu_name()
        msg('Open menu: ' .. (n ~= '' and ('"' .. n .. '"') or '(none)'))
        return
    end

    -- /phud match turns "Match PersonalBuffs" on / off.
    if cmd == 'match' then
        config.followPB = not config.followPB
        pbAt = -100
        settings.save()
        msg('Match PersonalBuffs: ' .. (config.followPB and 'on' or 'off'))
        return
    end

    -- /phud theme lists themes; /phud theme <name> picks one.
    if cmd == 'theme' then
        if config.followPB and rest ~= '' then
            msg('Matching PersonalBuffs is on. Type /phud match to turn it off first.')
            return
        end
        if rest == '' then
            msg('Theme: ' .. (config.activeCustom or config.theme))
            for _, f in ipairs(FAMILIES) do
                msg('  ' .. f.name .. ': ' .. table.concat(f.themes, ', '))
            end
            local mine = {}
            for _, c in ipairs(config.customThemes or {}) do mine[#mine + 1] = c.name end
            if #mine > 0 then msg('  Custom: ' .. table.concat(mine, ', ')) end
            return
        end
        local c = find_custom(rest)
        if c ~= nil then
            use_custom(c)
            selFamily = 'Custom'
            msg('Theme: ' .. c.name)
            return
        end
        local th = find_theme(rest)
        if th == nil then
            msg('No theme called "' .. rest .. '". Type /phud theme to see the list.')
            return
        end
        use_theme(th.name)
        selFamily = family_of(th.name)
        msg('Theme: ' .. th.name)
        return
    end

    msg('Commands: /phud (settings window), /phud toggle, /phud show, /phud hide, /phud theme [name], /phud match, /phud profile save|load|delete|list [name]')
end)

ashita.events.register('unload', 'phud_unload', function ()
    settings.save()
end)
