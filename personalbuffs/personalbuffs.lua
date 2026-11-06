----------------------------------------------------------------------
-- PersonalBuffs (Ashita v4 / HorizonXI)
--
-- Four windows:
--   * Buff box    - buffs you cast (and, if switched on, your party's casts,
--                   marked "Haste (Name)"). One row per buff, lowest timer
--                   first; click a row to see each person and their timer.
--   * Recast box  - your ability and spell recasts, read from game memory.
--   * Debuff box  - debuffs you (and, if switched on, your party) put on
--                   mobs, one section per mob. Same rules as kazenoeye.
--   * /pb menu    - per-job checkboxes to hide buffs / recasts, plus the
--                   party on/off switch and per-person checkboxes.
--
-- How buff times are found (best first):
--   1. Real time read from the same buff on you (counts all your gear).
--   2. A real time saved earlier for the same buff + gear setup (you only).
--   3. Base time (durations.lua, from LandSandBoat) + known gear bonuses,
--      shown with "~" because it's a guess.
--
-- Files: personalbuffs.lua (this), debuffs.lua (Debuff box tracking),
--        durations.lua (base times by spell ID),
--        jobdata.lua (which job gets each spell / ability, level 75 cap;
--        generated from LandSandBoat spell_list.sql / abilities.sql).
--
-- Reads packets 0x028 (actions) and 0x029 (wear-off / defeated messages).
-- Packet layout and message IDs (230, 266, 420-427, ...) follow
-- LandSandBoat's msg enum. Trusts (spell ID 896+) are never tracked.
----------------------------------------------------------------------
addon.name    = 'personalbuffs'
addon.author  = 'Renavi'
addon.version = '1.3.0'
addon.desc    = 'Shows time left on buffs you give to yourself and others.'
addon.link    = 'https://github.com/RenaviOnEden/personalbuffs'

require('common')
local chat     = require('chat')
local imgui    = require('imgui')
local settings = require('settings')
local BASE     = require('durations')   -- base times by spell ID (from LandSandBoat)

----------------------------------------------------------------------
-- Settings (saved automatically)
----------------------------------------------------------------------
local defaults = T{
    x            = 250,     -- window position
    y            = 650,
    fallback     = 120,     -- seconds, used when nothing else is known
    theme        = 'Default', -- color theme (see THEMES)
    customThemes = T{},     -- your saved looks: { name, base theme, style, opacity }
    recastLabels = true,    -- "Abilities" / "Spells" labels in the recast box
    hideFullLog  = true,    -- hide the boxes while the full chat log is open
    clickThrough = false,   -- mouse clicks pass through the boxes (can't drag them then)
    style        = T{},     -- your own style tweaks on top of the theme (see THEMES)
    opacity      = 0,       -- background opacity in % (10-100); 0 = use the theme's own
    durations    = T{},     -- [buff|gear] = real full time read from your own buff
    hidden       = T{},     -- [buff name]  = true when switched off
    hiddenGroups = T{},     -- [group name] = true when switched off
    seen         = T{},     -- [buff name]  = group (fills the settings window)

    -- Recast box (separate window, own position)
    rx           = 250,
    ry           = 450,
    hiddenRecast = T{},     -- [name] = true when switched off
    hiddenRecastGroups = T{}, -- ['Abilities' / 'Spells'] = true when switched off
    seenRecast   = T{},     -- [name] = 'Abilities' or 'Spells'

    -- Debuff box (separate window, own position)
    debuffs      = true,    -- track debuffs you put on mobs
    hiddenDebuffs      = T{}, -- [name] = true when switched off
    hiddenDebuffGroups = T{}, -- [group name] = true when switched off
    dx           = 250,
    dy           = 250,

    -- Party members' buffs (shown in the same box, marked with the caster).
    -- Off by default. Only your party, never alliance or outsiders.
    party        = T{
        enabled   = false,  -- main on / off switch
        hidden    = T{},    -- [caster name] = true when you've turned that person off
        known     = T{},    -- [caster name] = true (people seen, for the menu)
        gear      = T{},    -- [caster name] = { [item] = true } set by you in the Party tab
                            -- (their gear can't be seen, so you tell the addon)
    },

    -- Gear that adds time to buffs. Only used when the real time
    -- can't be read from your own buff (that already counts the gear).
    rules = T{
        T{ item = 'Dilation Ring', buffs = T{ 'Haste', 'Refresh' }, add = 30 },
    },
}
local config = settings.load(defaults)

-- Fills in anything missing from an older settings file, using the defaults.
local function deep_copy(v)
    if type(v) ~= 'table' then return v end
    local out = T{}
    for k, x in pairs(v) do out[k] = deep_copy(x) end
    return out
end

local function fill_missing(cfg, def)
    for k, v in pairs(def) do
        if cfg[k] == nil then
            cfg[k] = deep_copy(v)
        elseif type(v) == 'table' and type(cfg[k]) == 'table' and k ~= 'rules' then
            fill_missing(cfg[k], v)
        end
    end
end
-- Older settings had one "rounding" value; it now lives in your style tweaks.
local function migrate(cfg)
    if cfg.rounding ~= nil then
        if tonumber(cfg.rounding) ~= 6 and cfg.style.rounding == nil then
            cfg.style.rounding = tonumber(cfg.rounding)
        end
        cfg.rounding = nil
    end
end
fill_missing(config, defaults)
migrate(config)

settings.register('settings', 'pb_settings', function (s)
    if s ~= nil then config = s end
    fill_missing(config, defaults)
    migrate(config)
end)

----------------------------------------------------------------------
-- Colors (soft, to match the rest of the UI)
----------------------------------------------------------------------
local COL_NAME   = { 0.88, 0.88, 0.88, 1.0 }
local COL_GREEN  = { 0.55, 0.80, 0.55, 1.0 }
local COL_YELLOW = { 0.85, 0.78, 0.45, 1.0 }
local COL_RED    = { 0.82, 0.45, 0.45, 1.0 }
local COL_TARGET = { 0.60, 0.72, 0.86, 1.0 }   -- soft blue for names
local COL_BG     = { 0.05, 0.05, 0.08, 0.70 }
local COL_BORDER = { 0.35, 0.35, 0.40, 0.80 }
local COL_BTN     = { 0.18, 0.20, 0.26, 0.90 }   -- menu buttons
local COL_BTN_SEL = { 0.28, 0.38, 0.30, 0.95 }   -- selected menu button

local COL_ACCENT  = { 0.60, 0.72, 0.86, 1.00 }   -- headers, side stripe
local currentTheme = nil                          -- theme in use (set by apply_theme)

----------------------------------------------------------------------
-- Themes. "Default" is the original look. Picking a theme copies its
-- colors into the COL_ tables above, so everything else just works.
--
-- style (anything left out uses DEFAULT_STYLE):
--   bars      timer bar under each row            true / false
--   barH      bar height in pixels                2 - 8
--   header    title strip at the top of each box  true / false
--   border    'none', 'thin', 'thick', 'double'
--   stripe    colored stripe down the left side   0 (off) - 6 px
--   dividers  lines between groups (instead of a gap)
--   spacing   'compact', 'normal', 'roomy'
--   scale     text size in %                      80 - 130
--   rounding  corner roundness                    0 - 12
----------------------------------------------------------------------
local DEFAULT_STYLE = { bars = false, barH = 3, header = false, border = 'thin', stripe = 0,
                        dividers = false, spacing = 'normal', scale = 100, rounding = 6 }

local THEMES = {
    { name = 'Default', desc = 'The original look.',
      NAME = { 0.88, 0.88, 0.88, 1.0 }, GREEN = { 0.55, 0.80, 0.55, 1.0 },
      YELLOW = { 0.85, 0.78, 0.45, 1.0 }, RED = { 0.82, 0.45, 0.45, 1.0 },
      TARGET = { 0.60, 0.72, 0.86, 1.0 }, BG = { 0.05, 0.05, 0.08, 0.70 },
      BORDER = { 0.35, 0.35, 0.40, 0.80 }, BTN = { 0.18, 0.20, 0.26, 0.90 },
      BTN_SEL = { 0.28, 0.38, 0.30, 0.95 }, ACCENT = { 0.60, 0.72, 0.86, 1.0 },
      style = {} },
    { name = 'Classic', desc = 'Blue with a double border, like the game menus.',
      NAME = { 0.95, 0.95, 0.95, 1.0 }, GREEN = { 0.55, 0.90, 0.55, 1.0 },
      YELLOW = { 0.95, 0.85, 0.40, 1.0 }, RED = { 0.95, 0.45, 0.45, 1.0 },
      TARGET = { 0.70, 0.85, 1.00, 1.0 }, BG = { 0.05, 0.10, 0.32, 0.85 },
      BORDER = { 0.75, 0.75, 0.85, 0.90 }, BTN = { 0.12, 0.20, 0.45, 0.90 },
      BTN_SEL = { 0.25, 0.35, 0.65, 0.95 }, ACCENT = { 0.85, 0.88, 1.00, 1.0 },
      style = { border = 'double', header = true, rounding = 4 } },
    { name = 'Minimal', desc = 'See-through, no border, thin bars.',
      NAME = { 0.90, 0.90, 0.90, 1.0 }, GREEN = { 0.60, 0.85, 0.60, 1.0 },
      YELLOW = { 0.90, 0.82, 0.45, 1.0 }, RED = { 0.90, 0.48, 0.48, 1.0 },
      TARGET = { 0.70, 0.78, 0.88, 1.0 }, BG = { 0.00, 0.00, 0.00, 0.30 },
      BORDER = { 0.50, 0.50, 0.50, 0.00 }, BTN = { 0.20, 0.20, 0.20, 0.80 },
      BTN_SEL = { 0.30, 0.40, 0.30, 0.90 }, ACCENT = { 0.80, 0.80, 0.80, 1.0 },
      style = { border = 'none', bars = true, barH = 2, spacing = 'compact', rounding = 4 } },
    { name = 'Midnight', desc = 'Dark and solid, with a side stripe.',
      NAME = { 0.80, 0.80, 0.82, 1.0 }, GREEN = { 0.45, 0.72, 0.55, 1.0 },
      YELLOW = { 0.80, 0.70, 0.40, 1.0 }, RED = { 0.78, 0.38, 0.40, 1.0 },
      TARGET = { 0.55, 0.62, 0.80, 1.0 }, BG = { 0.01, 0.01, 0.02, 0.92 },
      BORDER = { 0.20, 0.20, 0.25, 0.90 }, BTN = { 0.10, 0.10, 0.14, 0.95 },
      BTN_SEL = { 0.20, 0.26, 0.22, 0.95 }, ACCENT = { 0.45, 0.50, 0.95, 1.0 },
      style = { border = 'none', stripe = 3, bars = true, barH = 2, spacing = 'compact' } },
    { name = 'Glass', desc = 'Frosted, very round, with headers and bars.',
      NAME = { 0.95, 0.97, 1.00, 1.0 }, GREEN = { 0.60, 0.92, 0.70, 1.0 },
      YELLOW = { 0.98, 0.88, 0.50, 1.0 }, RED = { 0.98, 0.55, 0.55, 1.0 },
      TARGET = { 0.70, 0.85, 1.00, 1.0 }, BG = { 0.16, 0.20, 0.28, 0.45 },
      BORDER = { 0.85, 0.90, 1.00, 0.35 }, BTN = { 0.25, 0.30, 0.40, 0.60 },
      BTN_SEL = { 0.35, 0.50, 0.65, 0.80 }, ACCENT = { 0.75, 0.88, 1.00, 1.0 },
      style = { rounding = 10, header = true, bars = true, barH = 3 } },
    { name = 'Glass Rose', desc = 'Frosted pink glass.',
      NAME = { 1.00, 0.95, 0.97, 1.00 }, GREEN = { 0.65, 0.92, 0.72, 1.00 },
      YELLOW = { 0.98, 0.86, 0.55, 1.00 }, RED = { 1.00, 0.55, 0.62, 1.00 },
      TARGET = { 1.00, 0.78, 0.88, 1.00 }, BG = { 0.30, 0.14, 0.22, 0.45 },
      BORDER = { 1.00, 0.80, 0.90, 0.35 }, BTN = { 0.40, 0.20, 0.30, 0.60 },
      BTN_SEL = { 0.60, 0.30, 0.45, 0.80 }, ACCENT = { 1.00, 0.70, 0.85, 1.00 },
      style = { rounding = 10, header = true, bars = true, barH = 3 } },
    { name = 'Glass Mint', desc = 'Frosted mint-green glass.',
      NAME = { 0.94, 1.00, 0.97, 1.00 }, GREEN = { 0.55, 0.95, 0.75, 1.00 },
      YELLOW = { 0.95, 0.90, 0.55, 1.00 }, RED = { 0.98, 0.55, 0.55, 1.00 },
      TARGET = { 0.65, 0.98, 0.88, 1.00 }, BG = { 0.10, 0.24, 0.20, 0.45 },
      BORDER = { 0.75, 1.00, 0.90, 0.35 }, BTN = { 0.15, 0.32, 0.27, 0.60 },
      BTN_SEL = { 0.22, 0.50, 0.40, 0.80 }, ACCENT = { 0.55, 1.00, 0.85, 1.00 },
      style = { rounding = 10, header = true, bars = true, barH = 3 } },
    { name = 'Glass Amber', desc = 'Frosted warm gold glass.',
      NAME = { 1.00, 0.97, 0.90, 1.00 }, GREEN = { 0.70, 0.92, 0.60, 1.00 },
      YELLOW = { 1.00, 0.85, 0.45, 1.00 }, RED = { 1.00, 0.55, 0.45, 1.00 },
      TARGET = { 1.00, 0.85, 0.60, 1.00 }, BG = { 0.28, 0.20, 0.08, 0.45 },
      BORDER = { 1.00, 0.88, 0.60, 0.35 }, BTN = { 0.38, 0.27, 0.10, 0.60 },
      BTN_SEL = { 0.58, 0.42, 0.15, 0.80 }, ACCENT = { 1.00, 0.80, 0.40, 1.00 },
      style = { rounding = 10, header = true, bars = true, barH = 3 } },
    { name = 'Glass Violet', desc = 'Frosted purple glass.',
      NAME = { 0.97, 0.95, 1.00, 1.00 }, GREEN = { 0.62, 0.92, 0.78, 1.00 },
      YELLOW = { 0.98, 0.88, 0.58, 1.00 }, RED = { 1.00, 0.55, 0.68, 1.00 },
      TARGET = { 0.82, 0.75, 1.00, 1.00 }, BG = { 0.20, 0.14, 0.32, 0.45 },
      BORDER = { 0.88, 0.80, 1.00, 0.35 }, BTN = { 0.28, 0.20, 0.45, 0.60 },
      BTN_SEL = { 0.42, 0.32, 0.68, 0.80 }, ACCENT = { 0.80, 0.68, 1.00, 1.00 },
      style = { rounding = 10, header = true, bars = true, barH = 3 } },
    { name = 'Glass Ocean', desc = 'Frosted deep teal glass, side stripe.',
      NAME = { 0.93, 0.98, 1.00, 1.00 }, GREEN = { 0.55, 0.92, 0.80, 1.00 },
      YELLOW = { 0.95, 0.88, 0.55, 1.00 }, RED = { 0.98, 0.55, 0.58, 1.00 },
      TARGET = { 0.60, 0.88, 1.00, 1.00 }, BG = { 0.05, 0.18, 0.26, 0.48 },
      BORDER = { 0.65, 0.90, 1.00, 0.35 }, BTN = { 0.08, 0.26, 0.36, 0.60 },
      BTN_SEL = { 0.12, 0.40, 0.55, 0.80 }, ACCENT = { 0.40, 0.85, 1.00, 1.00 },
      style = { rounding = 10, header = true, bars = true, barH = 3, stripe = 3 } },
    { name = 'Glass Smoke', desc = 'Dark smoky glass, no tint.',
      NAME = { 0.94, 0.94, 0.96, 1.00 }, GREEN = { 0.60, 0.88, 0.68, 1.00 },
      YELLOW = { 0.95, 0.86, 0.52, 1.00 }, RED = { 0.96, 0.55, 0.55, 1.00 },
      TARGET = { 0.80, 0.84, 0.90, 1.00 }, BG = { 0.08, 0.08, 0.10, 0.50 },
      BORDER = { 0.90, 0.90, 0.95, 0.25 }, BTN = { 0.18, 0.18, 0.22, 0.60 },
      BTN_SEL = { 0.30, 0.32, 0.38, 0.80 }, ACCENT = { 0.85, 0.88, 0.95, 1.00 },
      style = { rounding = 10, header = true, bars = true, barH = 3 } },
    { name = 'Glass Frost', desc = 'Very light, icy glass.',
      NAME = { 1.00, 1.00, 1.00, 1.00 }, GREEN = { 0.62, 0.95, 0.75, 1.00 },
      YELLOW = { 1.00, 0.90, 0.55, 1.00 }, RED = { 1.00, 0.58, 0.58, 1.00 },
      TARGET = { 0.80, 0.92, 1.00, 1.00 }, BG = { 0.40, 0.48, 0.58, 0.38 },
      BORDER = { 1.00, 1.00, 1.00, 0.50 }, BTN = { 0.45, 0.52, 0.62, 0.60 },
      BTN_SEL = { 0.55, 0.68, 0.82, 0.80 }, ACCENT = { 0.90, 0.97, 1.00, 1.00 },
      style = { rounding = 10, header = true, bars = true, barH = 3 } },
    { name = 'Crystal', desc = 'Purple and cyan, stripe, headers, bars.',
      NAME = { 0.92, 0.90, 0.98, 1.0 }, GREEN = { 0.50, 0.90, 0.85, 1.0 },
      YELLOW = { 0.95, 0.85, 0.55, 1.0 }, RED = { 0.95, 0.50, 0.65, 1.0 },
      TARGET = { 0.55, 0.85, 0.95, 1.0 }, BG = { 0.12, 0.06, 0.22, 0.85 },
      BORDER = { 0.55, 0.40, 0.85, 0.90 }, BTN = { 0.22, 0.12, 0.38, 0.90 },
      BTN_SEL = { 0.30, 0.45, 0.60, 0.95 }, ACCENT = { 0.45, 0.90, 0.95, 1.0 },
      style = { stripe = 3, header = true, bars = true, barH = 3, rounding = 8, dividers = true } },
    { name = 'Ember', desc = 'Charcoal and orange, thick bars.',
      NAME = { 0.95, 0.88, 0.80, 1.0 }, GREEN = { 0.70, 0.85, 0.45, 1.0 },
      YELLOW = { 0.98, 0.75, 0.30, 1.0 }, RED = { 0.98, 0.40, 0.25, 1.0 },
      TARGET = { 0.98, 0.70, 0.45, 1.0 }, BG = { 0.10, 0.06, 0.04, 0.88 },
      BORDER = { 0.55, 0.30, 0.12, 0.90 }, BTN = { 0.25, 0.12, 0.06, 0.90 },
      BTN_SEL = { 0.50, 0.25, 0.08, 0.95 }, ACCENT = { 0.98, 0.55, 0.15, 1.0 },
      style = { stripe = 4, bars = true, barH = 4, rounding = 5, border = 'none' } },
    { name = 'Terminal', desc = 'Green on black, square, compact.',
      NAME = { 0.30, 0.95, 0.40, 1.0 }, GREEN = { 0.30, 0.95, 0.40, 1.0 },
      YELLOW = { 0.85, 0.95, 0.30, 1.0 }, RED = { 0.95, 0.45, 0.30, 1.0 },
      TARGET = { 0.55, 1.00, 0.60, 1.0 }, BG = { 0.00, 0.03, 0.00, 0.90 },
      BORDER = { 0.20, 0.80, 0.30, 0.90 }, BTN = { 0.02, 0.15, 0.04, 0.95 },
      BTN_SEL = { 0.05, 0.35, 0.10, 0.95 }, ACCENT = { 0.30, 0.95, 0.40, 1.0 },
      style = { rounding = 0, header = true, dividers = true, spacing = 'compact' } },
    { name = 'High Contrast', desc = 'Easiest to read: big text, thick border, bars.',
      NAME = { 1.00, 1.00, 1.00, 1.0 }, GREEN = { 0.30, 1.00, 0.30, 1.0 },
      YELLOW = { 1.00, 0.90, 0.10, 1.0 }, RED = { 1.00, 0.30, 0.30, 1.0 },
      TARGET = { 0.40, 0.80, 1.00, 1.0 }, BG = { 0.00, 0.00, 0.00, 0.95 },
      BORDER = { 1.00, 1.00, 1.00, 1.00 }, BTN = { 0.15, 0.15, 0.15, 1.00 },
      BTN_SEL = { 0.10, 0.45, 0.10, 1.00 }, ACCENT = { 1.00, 0.90, 0.10, 1.0 },
      style = { border = 'thick', header = true, bars = true, barH = 5, spacing = 'roomy',
                scale = 115, rounding = 2 } },
    { name = "San d'Oria", desc = 'Red and gold, double border, headers.',
      NAME = { 0.95, 0.90, 0.85, 1.0 }, GREEN = { 0.60, 0.82, 0.55, 1.0 },
      YELLOW = { 0.95, 0.80, 0.40, 1.0 }, RED = { 0.95, 0.45, 0.40, 1.0 },
      TARGET = { 0.95, 0.78, 0.50, 1.0 }, BG = { 0.22, 0.04, 0.06, 0.82 },
      BORDER = { 0.75, 0.60, 0.30, 0.90 }, BTN = { 0.35, 0.08, 0.10, 0.90 },
      BTN_SEL = { 0.55, 0.15, 0.15, 0.95 }, ACCENT = { 0.90, 0.72, 0.35, 1.0 },
      style = { border = 'double', header = true, dividers = true, rounding = 3 } },
    { name = 'Bastok', desc = 'Steel, square, thick border, stripe and bars.',
      NAME = { 0.90, 0.90, 0.92, 1.0 }, GREEN = { 0.55, 0.80, 0.60, 1.0 },
      YELLOW = { 0.88, 0.76, 0.42, 1.0 }, RED = { 0.85, 0.45, 0.42, 1.0 },
      TARGET = { 0.62, 0.78, 0.92, 1.0 }, BG = { 0.10, 0.12, 0.16, 0.85 },
      BORDER = { 0.55, 0.60, 0.68, 0.90 }, BTN = { 0.20, 0.25, 0.32, 0.90 },
      BTN_SEL = { 0.30, 0.42, 0.55, 0.95 }, ACCENT = { 0.55, 0.75, 0.95, 1.0 },
      style = { border = 'thick', stripe = 4, dividers = true, bars = true, barH = 3, rounding = 0 } },
    { name = 'Windurst', desc = 'Green and earth, very round and roomy.',
      NAME = { 0.92, 0.92, 0.85, 1.0 }, GREEN = { 0.60, 0.88, 0.50, 1.0 },
      YELLOW = { 0.92, 0.82, 0.45, 1.0 }, RED = { 0.88, 0.48, 0.42, 1.0 },
      TARGET = { 0.75, 0.88, 0.60, 1.0 }, BG = { 0.06, 0.14, 0.07, 0.82 },
      BORDER = { 0.55, 0.65, 0.35, 0.90 }, BTN = { 0.14, 0.26, 0.14, 0.90 },
      BTN_SEL = { 0.25, 0.42, 0.22, 0.95 }, ACCENT = { 0.70, 0.90, 0.45, 1.0 },
      style = { header = true, bars = true, barH = 4, spacing = 'roomy', rounding = 12 } },

    -- Expansions (75 era)
    { name = "Vana'diel", desc = 'Original game: parchment brown and gold, double border.',
      NAME = { 0.96, 0.92, 0.82, 1.0 }, GREEN = { 0.62, 0.82, 0.50, 1.0 },
      YELLOW = { 0.96, 0.82, 0.42, 1.0 }, RED = { 0.90, 0.45, 0.38, 1.0 },
      TARGET = { 0.92, 0.80, 0.58, 1.0 }, BG = { 0.18, 0.12, 0.07, 0.85 },
      BORDER = { 0.80, 0.66, 0.38, 0.90 }, BTN = { 0.30, 0.20, 0.11, 0.90 },
      BTN_SEL = { 0.48, 0.34, 0.16, 0.95 }, ACCENT = { 0.92, 0.76, 0.40, 1.0 },
      style = { border = 'double', header = true, rounding = 4 } },
    { name = 'Zilart', desc = 'Rise of the Zilart: sky blue and pale gold, glassy.',
      NAME = { 0.94, 0.98, 1.00, 1.0 }, GREEN = { 0.55, 0.92, 0.80, 1.0 },
      YELLOW = { 0.98, 0.90, 0.60, 1.0 }, RED = { 0.98, 0.55, 0.58, 1.0 },
      TARGET = { 0.65, 0.90, 1.00, 1.0 }, BG = { 0.05, 0.16, 0.28, 0.70 },
      BORDER = { 0.85, 0.85, 0.65, 0.60 }, BTN = { 0.08, 0.24, 0.38, 0.80 },
      BTN_SEL = { 0.15, 0.40, 0.55, 0.90 }, ACCENT = { 0.98, 0.92, 0.65, 1.0 },
      style = { header = true, stripe = 3, rounding = 10 } },
    { name = 'Promathia', desc = 'Chains of Promathia: black and blood red, square, thick border.',
      NAME = { 0.85, 0.83, 0.85, 1.0 }, GREEN = { 0.50, 0.75, 0.55, 1.0 },
      YELLOW = { 0.85, 0.72, 0.40, 1.0 }, RED = { 0.90, 0.30, 0.30, 1.0 },
      TARGET = { 0.72, 0.66, 0.78, 1.0 }, BG = { 0.04, 0.02, 0.04, 0.92 },
      BORDER = { 0.50, 0.10, 0.12, 0.95 }, BTN = { 0.14, 0.06, 0.08, 0.95 },
      BTN_SEL = { 0.38, 0.08, 0.10, 0.95 }, ACCENT = { 0.80, 0.18, 0.20, 1.0 },
      style = { border = 'thick', dividers = true, rounding = 0, spacing = 'compact' } },
    { name = 'Aht Urhgan', desc = 'Treasures of Aht Urhgan: deep indigo and desert gold.',
      NAME = { 0.98, 0.94, 0.84, 1.0 }, GREEN = { 0.55, 0.88, 0.70, 1.0 },
      YELLOW = { 1.00, 0.84, 0.40, 1.0 }, RED = { 0.98, 0.50, 0.40, 1.0 },
      TARGET = { 0.45, 0.85, 0.85, 1.0 }, BG = { 0.08, 0.07, 0.22, 0.88 },
      BORDER = { 0.85, 0.68, 0.30, 0.90 }, BTN = { 0.16, 0.13, 0.36, 0.90 },
      BTN_SEL = { 0.45, 0.34, 0.12, 0.95 }, ACCENT = { 1.00, 0.78, 0.30, 1.0 },
      style = { header = true, stripe = 4, rounding = 6 } },
    { name = 'Goddess', desc = 'Wings of the Goddess: faded sepia with soft rose, very round.',
      NAME = { 0.96, 0.92, 0.88, 1.0 }, GREEN = { 0.66, 0.85, 0.62, 1.0 },
      YELLOW = { 0.95, 0.84, 0.55, 1.0 }, RED = { 0.95, 0.55, 0.55, 1.0 },
      TARGET = { 0.95, 0.78, 0.84, 1.0 }, BG = { 0.20, 0.16, 0.13, 0.80 },
      BORDER = { 0.92, 0.80, 0.82, 0.55 }, BTN = { 0.32, 0.25, 0.22, 0.85 },
      BTN_SEL = { 0.55, 0.38, 0.42, 0.90 }, ACCENT = { 0.98, 0.76, 0.84, 1.0 },
      style = { header = true, rounding = 12, spacing = 'roomy' } },

    -- FFXIV-style: dark charcoal glass, gold highlights, thin light border.
    { name = 'FFXIV', desc = 'Dark charcoal with gold highlights, like the FFXIV UI.',
      NAME = { 0.95, 0.94, 0.90, 1.0 }, GREEN = { 0.55, 0.85, 0.45, 1.0 },
      YELLOW = { 0.93, 0.80, 0.50, 1.0 }, RED = { 0.92, 0.42, 0.40, 1.0 },
      TARGET = { 0.60, 0.85, 0.95, 1.0 }, BG = { 0.11, 0.11, 0.12, 0.82 },
      BORDER = { 0.78, 0.74, 0.64, 0.55 }, BTN = { 0.22, 0.21, 0.20, 0.90 },
      BTN_SEL = { 0.50, 0.40, 0.20, 0.95 }, ACCENT = { 0.85, 0.70, 0.42, 1.0 },
      style = { header = true, rounding = 5, border = 'thin' } },
}

local THEME_COLS = { NAME = COL_NAME, GREEN = COL_GREEN, YELLOW = COL_YELLOW, RED = COL_RED,
                     TARGET = COL_TARGET, BG = COL_BG, BORDER = COL_BORDER,
                     BTN = COL_BTN, BTN_SEL = COL_BTN_SEL, ACCENT = COL_ACCENT }

-- Finds a theme by name. Ignores case, spaces and ' so "sandoria" or
-- "high contrast" both work. nil if there's no such theme.
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

-- Copies a theme's colors in. Returns the name actually used.
local function apply_theme(name)
    local th = find_theme(name) or THEMES[1]
    for k, dst in pairs(THEME_COLS) do
        for i = 1, 4 do dst[i] = th[k][i] end
    end
    currentTheme = th
    return th.name
end
local appliedTheme = nil   -- theme currently copied in (checked each frame)

-- One style setting: your own tweak if set, else the theme's, else the default.
local function S(key)
    local mine = config.style and config.style[key]
    if mine ~= nil then return mine end
    local ts = currentTheme and currentTheme.style
    if ts ~= nil and ts[key] ~= nil then return ts[key] end
    return DEFAULT_STYLE[key]
end

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

-- Not every Ashita build has the same imgui calls, so newer ones are
-- only used when they exist.
local function has(name) return imgui[name] ~= nil end

-- Can the text size be changed on this Ashita build?
local function can_scale()
    return has('SetWindowFontScale') or (has('PushFont') and has('PopFont') and has('GetFontSize'))
end

-- A line across the box (or a small gap if lines aren't supported).
local function line(col)
    if not has('Separator') then imgui.Dummy({ 0, 4 }); return end
    imgui.PushStyleColor(ImGuiCol_Separator, col)
    imgui.Separator()
    imgui.PopStyleColor(1)
end

-- Text size for a box. Older builds: SetWindowFontScale. Newer builds:
-- PushFont with a size (popped again in box_end).
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

-- Start of a box: text size, then the title strip (when the style has headers).
local function box_header(title)
    box_scale()
    if not S('header') then return end
    imgui.TextColored(COL_ACCENT, title)
    line(COL_ACCENT)
end

-- Space between groups: a line or a small gap.
local function group_gap()
    if S('dividers') then line(COL_BORDER) else imgui.Dummy({ 0, 4 }) end
end

-- Timer bar under a row: frac is 0-1 (time left / full time).
-- x1 / x2 are the row's left and right edges on screen.
local function timer_bar(frac, col, x1, x2)
    if not S('bars') or frac == nil then return end
    local h = clamp(S('barH'), 2, 8, 3)
    pcall(function ()
        if frac < 0 then frac = 0 elseif frac > 1 then frac = 1 end
        local _, cy = xy(imgui.GetCursorScreenPos())
        cy = cy - 2
        local dl = imgui.GetWindowDrawList()
        dl:AddRectFilled({ x1, cy }, { x2, cy + h },
            u32({ COL_BORDER[1], COL_BORDER[2], COL_BORDER[3], 0.35 }), h / 2)
        if frac > 0 then
            dl:AddRectFilled({ x1, cy }, { x1 + (x2 - x1) * frac, cy + h }, u32(col), h / 2)
        end
    end)
    imgui.Dummy({ 0, h - 2 })
end

-- Right edge of the last thing drawn (for bar width).
local function last_right(x1)
    local ok, a, b = pcall(imgui.GetItemRectMax)
    if ok then
        local x = xy(a, b)
        if x > x1 then return x end
    end
    return x1 + 150
end

-- Side stripe and inner border, drawn just before a box ends.
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

-- End of a box: draw the stripe / inner border, undo the text size.
local function box_end()
    box_decor()
    if fontPushed then
        pcall(imgui.PopFont)
        fontPushed = false
    end
end

-- Number control: a slider when available, else - / + buttons.
-- Returns true when the value changed; v is { number }.
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

-- Set when a box's position is typed in or nudged in the menu, so the box
-- jumps there on the next draw (instead of only on first use).
local moveBox = { buff = false, recast = false, debuff = false }

local KEEP_AFTER = 5    -- seconds to keep a buff at 0:00
local SONG_MAX   = 600  -- seconds; no song lasts longer than this (longer reads are the wrong buff)

-- /pb debug: chat lines when a buff starts and when it leaves the list.
local debugMode = false
local function dlog(text)
    if debugMode then print(chat.header(addon.name):append(chat.message('[debug] ' .. text))) end
end
local function mmss(sec)
    sec = math.max(0, math.floor(sec + 0.5))
    if sec >= 3600 then
        return string.format('%d:%02d:%02d', math.floor(sec / 3600), math.floor(sec / 60) % 60, sec % 60)
    end
    return string.format('%d:%02d', math.floor(sec / 60), sec % 60)
end
local SRC_TEXT = { read = 'read from your buffs', saved = 'saved time', estimate = 'estimate ~' }

-- Your own name shows as "You" (like test mode). Names are still used inside
-- to keep track of who has what; this only changes what you see.
local myName = nil
local function update_my_name()
    local ok, n = pcall(function () return AshitaCore:GetMemoryManager():GetParty():GetMemberName(0) end)
    if ok and n ~= nil and n ~= '' then myName = n end
end
local function show_who(who)
    if who ~= nil and who == myName then return 'You' end
    return who
end

-- Display order of the groups.
local GROUPS = T{ 'Songs', 'Rolls', 'White Magic', 'Black Magic', 'Ninjutsu',
                  'Blue Magic', 'Geomancy', 'Abilities', 'Other' }

----------------------------------------------------------------------
-- State
----------------------------------------------------------------------
local timers     = T{}   -- [buff name] = { name, group, kind, effect, total, people = { [who] = { exp, est } } }
local pending    = T{}   -- buffs that just landed, waiting for their time
local open       = T{}   -- [buff name] = true when its name list is shown
local press      = nil   -- row clicked on, waiting for mouse release
local showConfig = { false }

-- Party buffs
local partyTimers = T{}  -- [caster] = { [buff name] = row } (same shape as timers)
local partyOpen   = T{}  -- [caster .. '|' .. buff] = true when its name list is shown
local lastRollBy  = T{}  -- [caster] = their most recent roll

local function party_store(caster)
    if partyTimers[caster] == nil then partyTimers[caster] = T{} end
    return partyTimers[caster]
end

----------------------------------------------------------------------
-- Test mode: fake buffs, party buffs and recasts so the boxes can be
-- seen and arranged without casting anything. Real tracking keeps
-- running in the background. Fake data is never saved.
----------------------------------------------------------------------
local testMode = false
local test     = nil   -- { timers, party, recasts, start }

-- One fake row. people = { { name, seconds, guessed? }, ... }
local function test_row(name, group, kind, effect, people, total)
    local row = { name = name, group = group, kind = kind, effect = effect,
                  total = total, people = T{} }
    for _, p in ipairs(people) do
        row.people[p[1]] = { exp = os.time() + p[2], est = p[3] == true, dur = p[2] }
    end
    return row
end

local function build_test()
    local me = 'You'
    local t = T{}
    t['Valor Minuet IV'] = test_row('Valor Minuet IV', 'Songs', 'song', 198,
        { { me, 144 }, { 'Aria', 144 }, { 'Bo', 25 } })
    t['Sword Madrigal']  = test_row('Sword Madrigal', 'Songs', 'song', 199, { { me, 12 } })
    t['Chaos Roll']      = test_row('Chaos Roll', 'Rolls', 'roll', 317, { { me, 290 }, { 'Aria', 290 } }, 11)
    t['Haste']           = test_row('Haste', 'White Magic', 'spell', 33, { { me, 210 } })
    t['Protect III']     = test_row('Protect III', 'White Magic', 'spell', 40,
        { { me, 1790 }, { 'Aria', 1790 }, { 'Bo', 1650, true } })
    t['Reraise']         = test_row('Reraise', 'White Magic', 'spell', 113, { { me, 3590 } })
    t['Utsusemi: Ni']    = test_row('Utsusemi: Ni', 'Ninjutsu', 'spell', 66, { { me, 880 } })

    local party = T{}
    party['Aria'] = T{
        ['Victory March'] = test_row('Victory March', 'Songs', 'song', 214, { { me, 140, true }, { 'Bo', 140, true } }),
        ['Refresh']       = test_row('Refresh', 'White Magic', 'spell', 43, { { me, 150 } }),
        ['Fighter\'s Roll'] = test_row("Fighter's Roll", 'Rolls', 'roll', 310, { { 'Aria', 280 }, { 'Bo', 280 } }, 5),
        -- Same buffs you also cast, to show yours and theirs side by side.
        ['Haste']           = test_row('Haste', 'White Magic', 'spell', 33, { { 'Aria', 200 }, { 'Bo', 200, true } }),
        ['Valor Minuet IV'] = test_row('Valor Minuet IV', 'Songs', 'song', 198, { { 'Bo', 30, true } }),
    }
    party['Bartholomewson'] = T{   -- long name, to show it being shortened
        ["Mage's Ballad II"] = test_row("Mage's Ballad II", 'Songs', 'song', 196, { { me, 95, true } }),
    }

    -- name, group, full recast in seconds (they count down, hit Ready, restart)
    local recasts = {
        { 'Soul Voice', 'Abilities', 3600 }, { 'Nightingale', 'Abilities', 590 },
        { 'Pianissimo', 'Abilities', 15 },  { 'Haste', 'Spells', 20 },
        { 'Valor Minuet IV', 'Spells', 9 },  { 'Cure IV', 'Spells', 40 },
    }
    -- Fake mobs for the debuff box: name, is your target, { label, seconds left, full time }
    local now = os.time()
    local function mob(name, isTarget, list)
        local m = { name = name, test = isTarget, fx = T{} }
        for i, d in ipairs(list) do
            m.fx[i] = { label = d[1], exp = now + d[2], dur = d[3], key = d[1], group = d[4], caster = d[5] }
        end
        return m
    end
    local debuffs = T{
        [1] = mob('Goblin Smithy', true, { { 'Slow II', 150, 180, 'White Magic' }, { 'Paralyze', 40, 120, 'White Magic' }, { 'Dia II', 12, 120, 'White Magic' } }),
        [2] = mob('Goblin Mugger', false, { { 'Carnage Elegy', 170, 216, 'Songs', 'Aria' } }),
        [3] = mob('Goblin Pathfinder', false, {}),
    }
    debuffs[1].index, debuffs[2].index, debuffs[3].index = 0x1A3, 0x1A4, 0x1B0
    -- AoE example: Horde Lullaby on three mobs (one row, click it for each mob).
    for id, left in pairs({ [1] = 21, [2] = 24, [3] = 24 }) do
        debuffs[id].fx[99] = { label = 'Horde Lullaby', exp = now + left, dur = 30,
                               key = 'Horde Lullaby', group = 'Songs', aoe = true }
    end
    test = { timers = t, party = party, recasts = recasts, debuffs = debuffs, start = os.time() }
end

-- Restarts fake timers that have run out, so test mode keeps going.
local function refresh_test(now)
    local stores = T{ test.timers }
    for _, st in pairs(test.party) do stores:append(st) end
    for _, st in ipairs(stores) do
        for _, row in pairs(st) do
            for _, pp in pairs(row.people) do
                if now > pp.exp + KEEP_AFTER then pp.exp = now + pp.dur end
            end
        end
    end
    for _, m in pairs(test.debuffs) do
        for _, d in pairs(m.fx) do
            if now > d.exp + KEEP_AFTER then d.exp = now + d.dur end
        end
    end
end

-- Fake recasts in the same shape as read_recasts().
local function test_recasts(now)
    local out = { Abilities = T{}, Spells = T{} }
    local t = now - test.start
    for _, r in ipairs(test.recasts) do
        -- Counts down from the full time, is ready for 8 seconds, then restarts.
        local cycle = r[3] + 8
        local left  = r[3] - (t % cycle)
        if left > 0 then out[r[2]]:append({ name = r[1], left = left }) end
    end
    return out
end

----------------------------------------------------------------------
-- Reading the game clock so buff timers can be turned into seconds
----------------------------------------------------------------------
local VANA_BASE = 0x3C307D70
local timePtr   = ashita.memory.find('FFXiMain.dll', 0,
    '8B0D????????8B410C8B49108D04808D04808D04808D04C1C3', 2, 0)

local function get_stamp()
    if timePtr == nil or timePtr == 0 then return nil end
    local p = ashita.memory.read_uint32(timePtr)
    if p == nil or p == 0 then return nil end
    p = ashita.memory.read_uint32(p)
    if p == nil or p == 0 then return nil end
    return ashita.memory.read_uint32(p + 0x0C)
end

local function seconds_left(raw)
    if raw == nil or raw == 0x7FFFFFFF or raw == -1 then return nil end
    local stamp = get_stamp()
    if stamp == nil then return nil end
    local diff = (raw - (stamp - VANA_BASE) * 60) % 4294967296
    if diff >= 2147483648 then diff = diff - 4294967296 end
    local secs = math.ceil(diff / 60)
    if secs < 1 or secs > 7200 then return nil end
    return secs
end

-- Some buffs show on you under a different icon ID than the effect the
-- spell reports. Utsusemi reports Copy Image (66) but shows as
-- Copy Image 2 / 3 / 4+ (444-446) depending on how many shadows are left.
local BUFF_ICONS = {
    [66] = { [66] = true, [444] = true, [445] = true, [446] = true },
}

-- Time left on the newest copy of a buff on yourself.
local function read_self_buff(buffId)
    if buffId == nil or buffId <= 0 then return nil end
    local player = AshitaCore:GetMemoryManager():GetPlayer()
    if player == nil then return nil end
    -- The icon list is in the same order as the timer list. (GetBuffs can be
    -- in a different order, which paired buffs with the wrong timer, e.g.
    -- Blade Madrigal with your food.) GetBuffs is only a fallback.
    local okIcons, buffs = pcall(function () return player:GetStatusIcons() end)
    if not okIcons or buffs == nil then buffs = player:GetBuffs() end
    local raws = player:GetStatusTimers()
    if buffs == nil or raws == nil then return nil end

    local match = BUFF_ICONS[buffId] or { [buffId] = true }
    local best, bestId = nil, nil
    for i, id in pairs(buffs) do
        if match[id] then
            local s = seconds_left(raws[i])
            if s ~= nil and (best == nil or s > best) then best, bestId = s, id end
        end
    end
    return best, bestId
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
-- Names
----------------------------------------------------------------------
local function name_of(serverId)
    local party = AshitaCore:GetMemoryManager():GetParty()
    for i = 0, 17 do
        if party:GetMemberIsActive(i) == 1 and party:GetMemberServerId(i) == serverId then
            local n = party:GetMemberName(i)
            if n ~= nil and n ~= '' then return n end
        end
    end

    local ent = AshitaCore:GetMemoryManager():GetEntity()
    for i = 0, 2303 do
        if ent:GetServerId(i) == serverId then
            local n = ent:GetName(i)
            if n ~= nil and n ~= '' then return n end
        end
    end

    return 'Unknown'
end

-- Players have server IDs below 0x01000000; monsters and NPCs are above.
local function is_player(serverId)
    return serverId > 0 and serverId < 0x01000000
end

----------------------------------------------------------------------
-- Gear checks (read when the action lands, so midcast gear is counted)
----------------------------------------------------------------------
local function equipped(slot)
    local inv = AshitaCore:GetMemoryManager():GetInventory()
    local e   = inv:GetEquippedItem(slot)
    if e == nil then return nil end
    local idx = bit.band(e.Index, 0x00FF)
    if idx == 0 then return nil end
    local cont = bit.rshift(bit.band(e.Index, 0xFF00), 8)
    local item = inv:GetContainerItem(cont, idx)
    if item == nil or item.Id == 0 then return nil end
    return AshitaCore:GetResourceManager():GetItemById(item.Id)
end

local function all_equipped()
    local list = T{}
    for slot = 0, 15 do
        local res = equipped(slot)
        if res ~= nil then list:append(res) end
    end
    return list
end

local SONG_TYPES = T{ 'Minuet', 'Madrigal', 'March', 'Minne', 'Mambo', 'Etude', 'Prelude',
                      'Carol', 'Paeon', 'Ballad', 'Mazurka', 'Hymnus', 'Operetta', 'Pastoral',
                      'Gavotte', 'Round', 'Aubade', 'Fantasia', 'Capriccio', 'Scherzo',
                      'Virelai', 'Sirvente', 'Dirge' }

local function song_type(name)
    for _, t in ipairs(SONG_TYPES) do
        if name:find(t, 1, true) then return t end
    end
    return nil
end

-- Reads "Minuet"+2 / All songs +1 style bonuses from item text.
local function text_bonus(desc, word)
    if desc == nil or word == nil then return 0 end
    local n = desc:lower():match(word:lower() .. '"?%s*%+%s*(%d+)')
    return tonumber(n) or 0
end

-- Works out the gear "signature" and bonus for a buff.
-- sig is used so real times are saved per gear setup (instrument, ring...).
local function gear_info(name, kind)
    local gear    = all_equipped()
    local sig     = T{}
    local ruleAdd = 0
    local bonus   = 0

    if kind == 'song' then
        local inst = equipped(2)   -- range slot
        sig:append(inst ~= nil and inst.Name[1] or 'no instrument')
        local stype = song_type(name)
        for _, res in ipairs(gear) do
            local desc = res.Description and res.Description[1] or nil
            bonus = bonus + text_bonus(desc, stype) + text_bonus(desc, 'All songs')
        end
    end

    for _, rule in ipairs(config.rules or T{}) do
        local applies = false
        for _, b in ipairs(rule.buffs or T{}) do
            if b == name then applies = true end
        end
        if applies then
            for _, res in ipairs(gear) do
                if res.Name[1] == rule.item then
                    ruleAdd = ruleAdd + (rule.add or 0)
                    sig:append(rule.item)
                end
            end
        end
    end

    return table.concat(sig, '+'), ruleAdd, bonus
end

----------------------------------------------------------------------
-- Groups
----------------------------------------------------------------------
local MAGIC_TYPE_GROUP = { [1] = 'White Magic', [2] = 'Black Magic', [4] = 'Ninjutsu',
                           [5] = 'Songs', [6] = 'Blue Magic', [7] = 'Geomancy' }

-- Trusts are spells too; they're never tracked.
-- Trust spell IDs start at 896, and the game marks them as magic type 8.
local function is_trust(id, spell)
    if id ~= nil and id >= 896 then return true end
    return spell ~= nil and spell.Type == 8
end

-- Removes any Trusts that were saved before they were filtered out.
local trustsPurged = false
local function purge_trusts()
    trustsPurged = true
    local rm    = AshitaCore:GetResourceManager()
    local names = {}
    for id = 896, 1100 do
        local sp = rm:GetSpellById(id)
        if sp ~= nil and sp.Name[1] ~= nil and sp.Name[1] ~= '' then names[sp.Name[1]] = true end
    end
    local changed = false
    for _, tbl in ipairs({ config.seen, config.seenRecast, config.hidden, config.hiddenRecast }) do
        for n, _ in pairs(tbl) do
            if names[n] then tbl[n] = nil; changed = true end
        end
    end
    if changed then settings.save() end
end

local function spell_group(spell)
    if spell.Skill == 40 then return 'Songs' end
    if spell.Skill == 39 then return 'Ninjutsu' end
    return MAGIC_TYPE_GROUP[spell.Type] or 'Other'
end

-- Roll ability ID -> roll status ID (to read the roll's time on you).
local function roll_effect(abilityId)
    if abilityId >= 98 and abilityId <= 122 then return 310 + (abilityId - 98) end
    if abilityId >= 302 and abilityId <= 305 then return 335 + (abilityId - 302) end
    if abilityId == 390 then return 339 end
    if abilityId == 391 then return 600 end
    return nil
end

----------------------------------------------------------------------
-- Watch your actions (packet 0x028)
----------------------------------------------------------------------
local SPELL_MSGS = { [230] = true, [266] = true, [205] = true, [319] = true }
-- Job ability messages that mean "gained a buff". 115-121 are the
-- "attacks / defense / accuracy / evasion enhanced" lines (Berserk, Warcry,
-- Defender, Aggressor, Focus, Dodge...), 285 is Warcry landing on others.
local JA_MSGS    = { [100] = true, [115] = true, [116] = true, [117] = true, [118] = true,
                     [120] = true, [121] = true, [266] = true, [285] = true,
                     [319] = true, [320] = true, [441] = true }

-- Abilities marked as buffs in jobdata.lua. For these, any message counts,
-- as long as the number it carries is a real status effect.
local buffAbilities = nil
local function is_buff_ability(id)
    if buffAbilities == nil then
        buffAbilities = {}
        local ok, data = pcall(require, 'jobdata')
        if ok and type(data) == 'table' then
            for aid, info in pairs(data.abilities or {}) do
                if info.buff then buffAbilities[aid] = true end
            end
        end
    end
    return buffAbilities[id] == true
end

-- True when id is a status effect with a name (so it's a buff, not damage).
local function is_status(id)
    if id == nil or id <= 0 or id > 1023 then return false end
    local rm = AshitaCore:GetResourceManager()
    local ok, name = pcall(function () return rm:GetString('buffs.names', id) end)
    if not ok then return true end   -- can't check on this build; trust the range
    return name ~= nil and name ~= ''
end
local ROLL_MSGS  = { [420] = true, [421] = true }
local DOUBLE_UP  = { [424] = true }
local BUST_MSGS  = { [426] = true, [427] = true }

-- Bonus time for a party member's cast, from the gear you ticked for them
-- in the Party tab (e.g. Dilation Ring: +30s on Haste / Refresh).
local function party_gear_add(caster, name)
    local mine = config.party.gear[caster]
    if mine == nil then return 0 end
    local add = 0
    for _, rule in ipairs(config.rules or T{}) do
        if mine[rule.item] then
            for _, b in ipairs(rule.buffs or T{}) do
                if b == name then add = add + (rule.add or 0) end
            end
        end
    end
    return add
end

local function add_pending(p)
    if p.caster ~= nil then
        -- Their gear can't be seen; use what you ticked for them.
        p.sig, p.ruleAdd, p.bonus = 'party', party_gear_add(p.caster, p.name), 0
    else
        p.sig, p.ruleAdd, p.bonus = gear_info(p.name, p.kind)
    end
    p.t = os.time()
    -- A newer cast of the same buff by the same caster takes over; the older
    -- one stops re-reading so it can't overwrite the newer time.
    for _, old in ipairs(pending) do
        if old.name == p.name and old.caster == p.caster then old.superseded = true end
    end
    pending:append(p)
end

-- True when the server ID is someone in your party (not you, not alliance).
local function in_party(serverId)
    local party = AshitaCore:GetMemoryManager():GetParty()
    for i = 1, 5 do
        if party:GetMemberIsActive(i) == 1 and party:GetMemberServerId(i) == serverId then
            return true
        end
    end
    return false
end

-- Buffs a party member can only put on themselves. Those aren't buffs they
-- give out, so party tracking skips them when they land only on the caster.
-- (Party-wide ones like Protectra or Warcry still show when they hit others.)
--
-- Spells, by spell ID:
local SELF_ONLY_SPELLS = {
    [53]  = true, -- Blink
    [54]  = true, -- Stoneskin
    [55]  = true, -- Aquaveil
    [97]  = true, -- Reprisal
    [100] = true, [101] = true, [102] = true, [103] = true, [104] = true, [105] = true, -- Enfire .. Enwater
    [312] = true, [313] = true, [314] = true, [315] = true, [316] = true, [317] = true, -- Enfire II .. Enwater II
    [310] = true, -- Enlight
    [106] = true, -- Phalanx (Phalanx II can target others, so it's not here)
    [135] = true, [141] = true, [142] = true, -- Reraise, II, III
    [249] = true, [250] = true, [251] = true, -- Blaze / Ice / Shock Spikes
    [277] = true, -- Dread Spikes
    [287] = true, -- Klimaform
}
-- Whole magic skills that only ever buff the caster:
-- Dark magic (Dread Spikes, Absorbs), Ninjutsu (Utsusemi, Tonko, Monomi...),
-- Blue magic (Cocoon, Metallic Body, Refueling...).
local SELF_ONLY_SKILLS = { [37] = true, [39] = true, [43] = true }

-- True when a party member's spell / ability should be skipped: it landed
-- only on them, and it's on the lists above. Job abilities that buff others
-- always hit them too (Warcry, circles...), so any job ability that landed
-- only on the caster counts as self-only.
local function self_only(kind, id, res, hit, casterName)
    for _, who in ipairs(hit) do
        if who ~= casterName then return false end
    end
    if kind == 'ability' then return true end
    if SELF_ONLY_SPELLS[id] then return true end
    return res ~= nil and SELF_ONLY_SKILLS[res.Skill] == true
end

local function handle_action(e)
    local data    = e.data_raw
    local maxBits = e.size * 8
    local function u(pos, len)
        if pos + len > maxBits then error('short packet') end
        return ashita.bits.unpack_be(data, 0, pos, len)
    end

    local myId  = AshitaCore:GetMemoryManager():GetParty():GetMemberServerId(0)
    local actor = u(40, 32)

    -- Who cast it: you, or someone else (only when party tracking is on).
    local caster = nil      -- nil means you
    if actor ~= myId then
        if not config.party.enabled or not is_player(actor) then return end
        if not in_party(actor) then return end   -- party only
        caster = name_of(actor)
    end
    local rollKey = caster or '__me'
    -- Where this caster's rows live (made only when needed).
    local function get_store()
        return (caster == nil) and timers or party_store(caster)
    end

    local tcount = u(72, 6)
    local cat    = u(82, 4)
    local param  = u(86, 32)

    if cat ~= 4 and cat ~= 6 and cat ~= 14 and cat ~= 15 then return end

    -- Read every target / result.
    local results = T{}
    local pos = 150
    for _ = 1, tcount do
        local tid    = u(pos, 32); pos = pos + 32
        local acount = u(pos, 4);  pos = pos + 4
        for _ = 1, acount do
            results:append({ tid = tid, value = u(pos + 27, 17), msg = u(pos + 44, 10) })
            pos = pos + 85
            if u(pos, 1) == 1 then pos = pos + 1 + 37 else pos = pos + 1 end
            if u(pos, 1) == 1 then pos = pos + 1 + 34 else pos = pos + 1 end
        end
    end

    local rm = AshitaCore:GetResourceManager()

    -- Collects the players who got the buff.
    local function gather(msgs)
        local hit, seen, onSelf, effect, value = T{}, {}, false, nil, nil
        for _, r in ipairs(results) do
            if msgs[r.msg] and is_player(r.tid) then
                local who = name_of(r.tid)
                if not seen[who] then
                    seen[who] = true
                    hit:append(who)
                end
                if r.tid == myId then onSelf = true end
                effect = effect or r.value
                value  = value or r.value
            end
        end
        return hit, onSelf, effect, value
    end

    ------------------------------------------------------------------
    -- Spells
    ------------------------------------------------------------------
    if cat == 4 then
        local spell = rm:GetSpellById(param)
        if spell == nil or is_trust(param, spell) then return end
        local hit, onSelf, effect = gather(SPELL_MSGS)
        if #hit == 0 or effect == nil or effect == 0 then return end
        if caster ~= nil and self_only('spell', param, spell, hit, caster) then return end

        local group = spell_group(spell)
        add_pending({
            name    = spell.Name[1],
            group   = group,
            kind    = (group == 'Songs') and 'song' or 'spell',
            spellId = param,
            effect  = effect,
            onSelf  = onSelf,
            targets = hit,
            caster  = caster,
        })
        return
    end

    ------------------------------------------------------------------
    -- Job abilities (and rolls)
    ------------------------------------------------------------------
    local ability = rm:GetAbilityById(param + 512)
    if ability == nil then return end
    local name = ability.Name[1]

    -- Bust: the roll is gone for everyone.
    for _, r in ipairs(results) do
        if BUST_MSGS[r.msg] then
            local lr = lastRollBy[rollKey]
            if lr ~= nil then
                get_store()[lr] = nil
                if caster == nil then open[lr] = nil end
                -- Also drop the roll if it hasn't been timed yet.
                for i = #pending, 1, -1 do
                    if pending[i].name == lr and pending[i].caster == caster then
                        table.remove(pending, i)
                    end
                end
            end
            return
        end
    end

    -- Double-Up: new total, same timer.
    if name == 'Double-Up' then
        local hit, _, _, total = gather(DOUBLE_UP)
        local lr = lastRollBy[rollKey]
        if lr == nil or #hit == 0 then return end

        -- The roll may still be waiting for its time; update it there too.
        for _, p in ipairs(pending) do
            if p.name == lr and p.caster == caster then p.total = total end
        end

        local row = get_store()[lr]
        if row ~= nil then
            row.total = total
            -- Timer doesn't change. Anyone newly in range gets the roll's
            -- current lowest timer.
            local lowest = nil
            for _, pp in pairs(row.people) do
                if lowest == nil or pp.exp < lowest then lowest = pp.exp end
            end
            for _, who in ipairs(hit) do
                if row.people[who] == nil and lowest ~= nil then
                    row.people[who] = { exp = lowest, est = true }
                end
            end
        end
        return
    end

    -- Rolls
    local hit, onSelf, _, total = gather(ROLL_MSGS)
    if #hit > 0 then
        lastRollBy[rollKey] = name
        add_pending({
            name    = name,
            group   = 'Rolls',
            kind    = 'roll',
            effect  = roll_effect(param),
            total   = total,
            onSelf  = onSelf,
            targets = hit,
            caster  = caster,
        })
        return
    end

    -- Other abilities
    local hit2, onSelf2, effect2 = gather(JA_MSGS)
    if #hit2 == 0 and is_buff_ability(param) then
        -- Buff ability with a message we don't know: accept it if the
        -- number it carries is a real status effect.
        local anyMsg = setmetatable({}, { __index = function () return true end })
        hit2, onSelf2, effect2 = gather(anyMsg)
        if not is_status(effect2) then return end
    end
    if #hit2 == 0 or effect2 == nil or effect2 == 0 then return end
    if caster ~= nil and self_only('ability', param, ability, hit2, caster) then return end
    add_pending({
        name    = name,
        group   = 'Abilities',
        kind    = 'ability',
        effect  = effect2,
        onSelf  = onSelf2,
        targets = hit2,
        caster  = caster,
    })
end

----------------------------------------------------------------------
-- Debuffs on mobs: the tracking lives in debuffs.lua.
----------------------------------------------------------------------
local DB = require('debuffs')
DB.setup({
    cfg = function () return config end,   -- config can be swapped by the settings library
    dlog = dlog, mmss = mmss, is_player = is_player, is_trust = is_trust, spell_group = spell_group,
})

ashita.events.register('packet_in', 'pb_packet', function (e)
    if e.id == 0x029 then
        if config.debuffs then pcall(DB.handle_message, e) end
        return
    end
    if e.id ~= 0x028 then return end
    pcall(handle_action, e)
    if config.debuffs then pcall(DB.handle_action, e) end
end)

----------------------------------------------------------------------
-- Turn pending buffs into timers
----------------------------------------------------------------------
-- Best guess when the real time can't be read. Returns seconds, guessed?
local function estimate(p)
    -- Your saved real times include your gear, so they're only used for you.
    if p.caster == nil then
        local saved = config.durations[p.name .. '|' .. p.sig]
        if saved ~= nil and not (p.kind == 'song' and saved > SONG_MAX) then return saved, false, 'saved' end
    end
    if p.kind == 'song' then
        return math.floor(120 * (1 + 0.1 * (p.bonus or 0))) + p.ruleAdd, true, 'estimate'
    end
    if p.kind == 'roll' then
        return 300, true, 'estimate'
    end
    if p.spellId ~= nil and BASE[p.spellId] ~= nil then
        return BASE[p.spellId] + p.ruleAdd, true, 'estimate'
    end
    return config.fallback + p.ruleAdd, true, 'estimate'
end

local function apply(p, expires, est, src)
    local store = (p.caster == nil) and timers or party_store(p.caster)
    local row = store[p.name]
    if row == nil then
        row = { name = p.name, people = T{} }
        store[p.name] = row
    end
    row.group  = p.group
    row.kind   = p.kind
    row.effect = p.effect
    if p.total ~= nil then row.total = p.total end

    for _, who in ipairs(p.targets) do
        -- A new buff of the same kind replaces the old one on that person
        -- (Protect III replaces Protect II). Songs can stack, so they don't.
        -- This also works across casters (their Protect IV replaces your Protect III).
        if p.kind ~= 'song' and p.effect ~= nil then
            local stores = T{ timers }
            for _, st in pairs(partyTimers) do stores:append(st) end
            for _, st in ipairs(stores) do
                for n, other in pairs(st) do
                    if (st ~= store or n ~= p.name) and other.kind ~= 'song' and other.effect == p.effect then
                        if other.people[who] ~= nil then
                            dlog(n .. ' on ' .. show_who(who) .. ': replaced by ' .. p.name)
                        end
                        other.people[who] = nil
                    end
                end
            end
        end
        -- dur = full time, so a timer bar knows how much is left.
        row.people[who] = { exp = expires, est = est, src = src, dur = math.max(1, expires - p.t) }
    end

    if p.caster == nil then
        if config.seen[p.name] ~= p.group then
            config.seen[p.name] = p.group
            settings.save()
        end
    elseif not config.party.known[p.caster] then
        config.party.known[p.caster] = true
        settings.save()
    end
end

-- Your own buff timer is read for a few seconds after a buff lands, and the
-- longest time seen wins. Right after a recast (songs especially) your buff
-- list can still show the OLD copy for a moment; reading only once could pick
-- up that shorter time and drop the buff early.
local READ_WINDOW = 4

local function who_text(p)
    local names = {}
    for i, w in ipairs(p.targets) do names[i] = show_who(w) end
    return table.concat(names, ', ') .. ' (by ' .. (p.caster or 'you') .. ')'
end

local function process_pending(now)
    for i = #pending, 1, -1 do
        local p   = pending[i]
        local age = now - p.t
        local done = false

        if p.caster ~= nil and not config.party.enabled then
            -- Party tracking was switched off while this was waiting.
            done = true
        elseif p.superseded and (p.bestFull ~= nil or not p.onSelf) then
            -- A newer cast of the same buff took over.
            done = true
        elseif p.onSelf then
            if age >= 1 and not p.superseded then
                local left, gotId = read_self_buff(p.effect)
                local full = left and (left + age) or nil
                -- Safety net: a song never lasts anywhere near 10 minutes, so a
                -- longer read is the wrong buff; ignore it.
                if full ~= nil and p.kind == 'song' and full > SONG_MAX then
                    if not p.warned then
                        dlog(p.name .. ': ignored a read of ' .. mmss(full) .. ' (buff ' .. tostring(gotId)
                             .. ', too long for a song)')
                        p.warned = true
                    end
                    full = nil
                end
                if full ~= nil then
                    p.readId = gotId
                    if p.bestFull == nil or full > p.bestFull + 1 then
                        p.bestFull = full
                        apply(p, p.t + full, false, 'read')
                    end
                end
            end
            if age >= READ_WINDOW or (p.superseded and p.bestFull == nil) then
                if p.bestFull ~= nil then
                    -- Save the real full time (only when it really changed).
                    local key = p.name .. '|' .. p.sig
                    local old = config.durations[key]
                    if p.caster == nil and (old == nil or math.abs(old - p.bestFull) > 2) then
                        config.durations[key] = p.bestFull
                        settings.save()
                    end
                    dlog(p.name .. ' on ' .. who_text(p) .. ': ' .. mmss(p.bestFull) .. ', ' .. SRC_TEXT.read
                         .. ' (effect ' .. tostring(p.effect) .. ', matched buff ' .. tostring(p.readId) .. ')')
                elseif not p.superseded then
                    local d, est, src = estimate(p)
                    apply(p, p.t + d, est, src)
                    dlog(p.name .. ' on ' .. who_text(p) .. ': ' .. mmss(d) .. ', ' .. SRC_TEXT[src]
                         .. ' (could not read it from your buffs)')
                end
                done = true
            end
        else
            local d, est, src = estimate(p)
            apply(p, p.t + d, est, src)
            dlog(p.name .. ' on ' .. who_text(p) .. ': ' .. mmss(d) .. ', ' .. SRC_TEXT[src])
            done = true
        end

        if done then table.remove(pending, i) end
    end
end

----------------------------------------------------------------------
-- Draw helpers
----------------------------------------------------------------------
local function time_color(left)
    if left <= 10 then return COL_RED end
    if left <= 30 then return COL_YELLOW end
    return COL_GREEN
end

-- Name column width. It grows to fit the longest spell / song name, which is
-- never shortened. Only other people's names (the caster) get shortened.
local NAME_WIDTH = 20
local MIN_CASTER = 4    -- shortest a caster name is cut to

-- Cuts text to n characters, without a trailing space or dot.
local function cut(text, n)
    if n <= 0 then return '' end
    if #text <= n then return text end
    return (text:sub(1, n):gsub('[%s%.:,\']+$', ''))
end

-- Buff name plus roll total, never shortened.
local function base_label(t)
    local b = t.name
    if t.total ~= nil then b = b .. ' (' .. tostring(t.total) .. ')' end
    return b
end

-- Column width for a set of rows: fits every full buff name and person
-- name, and leaves at least MIN_CASTER letters for caster names.
local function column_width(rows)
    local w = NAME_WIDTH
    for _, t in ipairs(rows) do
        local n = #base_label(t)
        if t.caster ~= nil then n = n + 3 + math.min(#t.caster, MIN_CASTER) end
        if n > w then w = n end
        -- Dropdown lines are indented, so they get one less character.
        for _, e in ipairs(t.entries or {}) do
            local m = #show_who(e.who) + 1
            if e.caster ~= nil then m = m + 3 + math.min(#e.caster, MIN_CASTER) end
            if m > w then w = m end
        end
    end
    return w
end

-- Dropdown line for one person: "Aria" (your cast) or "Aria (Caster)".
local function entry_label(e, width)
    local who = show_who(e.who)
    if e.caster == nil then return who end
    local room = math.max(MIN_CASTER, (width - 1) - #who - 3)
    return who .. ' (' .. cut(e.caster, room) .. ')'
end

-- Full label for a row; the caster name is cut only as much as needed.
local function row_label(t, width)
    local b = base_label(t)
    if t.caster == nil then return b end
    local room = math.max(MIN_CASTER, width - #b - 3)
    return b .. ' (' .. cut(t.caster, room) .. ')'
end

local function fmt_time(left, est)
    local s
    if left >= 3600 then
        s = string.format('%d:%02d:%02d', math.floor(left / 3600), math.floor(left / 60) % 60, left % 60)
    else
        s = string.format('%d:%02d', math.floor(left / 60), left % 60)
    end
    return est and ('~' .. s) or s
end

local function is_hidden(name, group)
    return config.hidden[name] == true or config.hiddenGroups[group] == true
end

-- Window flags for the boxes. With click-through on, NoInputs is added
-- each frame (see the Begin calls), so the mouse goes to the game.
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

-- Pushes the look for a window. isBox = buff / recast box (gets stripe and
-- spacing); the settings window only gets colors, corners and border.
local styleStack = {}
local function push_style(isBox)
    local nc, nv = 0, 0
    -- Background: theme color, with your own opacity if you set one.
    local op = tonumber(config.opacity) or 0
    if op > 0 then
        op = clamp(op, 10, 100, 100)
        imgui.PushStyleColor(ImGuiCol_WindowBg, { COL_BG[1], COL_BG[2], COL_BG[3], op / 100 })
    else
        imgui.PushStyleColor(ImGuiCol_WindowBg, COL_BG)
    end
    imgui.PushStyleColor(ImGuiCol_Border, COL_BORDER)
    nc = 2

    -- Rounded corners on the boxes, the inner panels, and buttons / checkboxes.
    local r = clamp(S('rounding'), 0, 12, 6)
    imgui.PushStyleVar(ImGuiStyleVar_WindowRounding, r)
    imgui.PushStyleVar(ImGuiStyleVar_ChildRounding, r)
    imgui.PushStyleVar(ImGuiStyleVar_FrameRounding, math.floor(r / 2 + 0.5))

    -- Border: none / thin / thick (double = thin plus an inner line, see box_decor).
    local b = S('border')
    local bsize = (b == 'none') and 0 or (b == 'thick') and 2 or 1
    imgui.PushStyleVar(ImGuiStyleVar_WindowBorderSize, bsize)

    -- A bit more side room so text doesn't touch the rounded corners / stripe.
    local stripe = isBox and clamp(S('stripe'), 0, 6, 0) or 0
    local padX = 6 + math.floor(r / 3) + (stripe > 0 and stripe + 2 or 0)
    local padY = 4 + math.floor(r / 4) + ((isBox and b == 'double') and 2 or 0)
    imgui.PushStyleVar(ImGuiStyleVar_WindowPadding, { padX, padY })
    nv = 5

    -- Row spacing (boxes only). "normal" leaves the game's own spacing alone.
    if isBox then
        local sp = S('spacing')
        if sp == 'compact' then
            imgui.PushStyleVar(ImGuiStyleVar_ItemSpacing, { 8, 1 }); nv = nv + 1
        elseif sp == 'roomy' then
            imgui.PushStyleVar(ImGuiStyleVar_ItemSpacing, { 8, 7 }); nv = nv + 1
        end
    end
    styleStack[#styleStack + 1] = { nc, nv }
end

local function pop_style()
    local t = table.remove(styleStack) or { 2, 5 }
    imgui.PopStyleVar(t[2])
    imgui.PopStyleColor(t[1])
end

----------------------------------------------------------------------
-- Recasts
----------------------------------------------------------------------
local RECAST_GROUPS = T{ 'Abilities', 'Spells' }

local TWO_HOURS = {
    [1] = 'Mighty Strikes', [2] = 'Hundred Fists', [3] = 'Benediction', [4] = 'Manafont',
    [5] = 'Chainspell', [6] = 'Perfect Dodge', [7] = 'Invincible', [8] = 'Blood Weapon',
    [9] = 'Familiar', [10] = 'Soul Voice', [11] = 'Eagle Eye Shot', [12] = 'Meikyo Shisui',
    [13] = 'Mijin Gakure', [14] = 'Spirit Surge', [15] = 'Astral Flow', [16] = 'Azure Lore',
    [17] = 'Wild Card', [18] = 'Overdrive', [19] = 'Trance', [20] = 'Tabula Rasa',
    [21] = 'Bolster', [22] = 'Elemental Sforzo',
}

local abilityNames = {}   -- [recast timer id] = name (cached)
local readyUntil   = T{}  -- [name] = { group, until } for "Ready" lines
local lastRecasts  = T{}  -- [name] = group, seen on cooldown last frame
local recastTotal  = T{}  -- [name] = longest time seen this cooldown (for timer bars)

local function ability_name(id)
    if abilityNames[id] ~= nil then return abilityNames[id] end
    local rm = AshitaCore:GetResourceManager()
    local name = nil
    local ab = rm:GetAbilityByTimerId(id)
    if ab ~= nil then name = ab.Name[1] end
    if name == nil or name == '' then
        for x = 0, 2048 do
            local a = rm:GetAbilityById(x)
            if a ~= nil and a.RecastTimerId == id then
                name = a.Name[1]
                break
            end
        end
    end
    name = name or ('Ability ' .. tostring(id))
    abilityNames[id] = name
    return name
end

-- Recast colors: a low timer is good, so the order is reversed.
local function recast_color(left)
    if left <= 10 then return COL_GREEN end
    if left <= 30 then return COL_YELLOW end
    return COL_RED
end

-- Returns { Abilities = list, Spells = list } of { name, left }.
local SP2_TIMER = 254

local function read_recasts()
    local out = { Abilities = T{}, Spells = T{} }
    local mm  = AshitaCore:GetMemoryManager()
    local rc  = mm:GetRecast()
    local rm  = AshitaCore:GetResourceManager()
    if rc == nil then return out end

    local job = mm:GetPlayer():GetMainJob()
    for x = 0, 31 do
        local id    = rc:GetAbilityTimerId(x)
        local timer = rc:GetAbilityTimer(x)
        -- Timer 254 is the second special ability slot (Brazen Rush etc.), which
        -- doesn't exist at level 75. The game also puts your 2-hour there, so
        -- it's skipped to avoid a fake "Brazen Rush" next to your real 2-hour.
        if (id ~= 0 or x == 0) and id ~= SP2_TIMER and timer > 0 then
            local name
            if x == 0 then
                name = TWO_HOURS[job] or 'Special'
            else
                name = ability_name(id)
            end
            out.Abilities:append({ name = name, left = math.ceil(timer / 60) })
        end
    end

    for id = 0, 1024 do
        local timer = rc:GetSpellTimer(id)
        if timer > 0 and not is_trust(id, nil) then
            local spell = rm:GetSpellById(id)
            local name  = (spell ~= nil and spell.Name[1] ~= '') and spell.Name[1] or ('Spell ' .. id)
            out.Spells:append({ name = name, left = math.ceil(timer / 60) })
        end
    end
    return out
end

-- Recasts are read 4 times a second, not every frame.
local RECAST_EVERY = 0.25
local recastCache, recastAt = nil, -1

local function draw_recasts(now)
    local ok, cur
    if testMode then
        ok, cur = true, test_recasts(now)
    else
        local c = os.clock()
        if recastCache == nil or c - recastAt >= RECAST_EVERY or c < recastAt then
            local good, res = pcall(read_recasts)
            recastCache = good and res or nil
            recastAt    = c
        end
        ok, cur = recastCache ~= nil, recastCache
    end
    if not ok or cur == nil then return end
    local live = T{}

    -- Note new names for the settings window; spot things that just came off cooldown.
    local changed = false
    for _, g in ipairs(RECAST_GROUPS) do
        for _, r in ipairs(cur[g]) do
            live[r.name] = g
            if not testMode and config.seenRecast[r.name] ~= g then
                config.seenRecast[r.name] = g
                changed = true
            end
        end
    end
    if changed then settings.save() end

    for name, g in pairs(lastRecasts) do
        if live[name] == nil then
            readyUntil[name] = { group = g, untilT = now + KEEP_AFTER }
            recastTotal[name] = nil
        end
    end
    lastRecasts = live
    -- Full time of each cooldown = the longest time left seen for it.
    for _, g in ipairs(RECAST_GROUPS) do
        for _, r in ipairs(cur[g]) do
            if (recastTotal[r.name] or 0) < r.left then recastTotal[r.name] = r.left end
        end
    end

    -- Build what to show.
    local show  = { Abilities = T{}, Spells = T{} }
    local count = 0
    for _, g in ipairs(RECAST_GROUPS) do
        if not config.hiddenRecastGroups[g] then
            for _, r in ipairs(cur[g]) do
                if not config.hiddenRecast[r.name] then
                    show[g]:append(r)
                    count = count + 1
                end
            end
        end
    end
    for name, r in pairs(readyUntil) do
        if now > r.untilT or live[name] ~= nil then
            readyUntil[name] = nil
        elseif not config.hiddenRecast[name] and not config.hiddenRecastGroups[r.group] then
            show[r.group]:append({ name = name, left = 0, ready = true })
            count = count + 1
        end
    end
    if count == 0 then return end

    imgui.SetNextWindowPos({ config.rx, config.ry },
        moveBox.recast and ImGuiCond_Always or ImGuiCond_FirstUseEver)
    moveBox.recast = false
    push_style(true)
    -- Name column fits the longest name (nothing is shortened here).
    local rwidth = NAME_WIDTH
    for _, g in ipairs(RECAST_GROUPS) do
        for _, r in ipairs(show[g]) do
            if #r.name > rwidth then rwidth = #r.name end
        end
    end

    if imgui.Begin('personalbuffs_recast', true, config.clickThrough
            and bit.bor(FLAGS, ImGuiWindowFlags_NoInputs or ImGuiWindowFlags_NoMouseInputs or 0) or FLAGS) then
        box_header('Recasts')
        local first = true
        for _, g in ipairs(RECAST_GROUPS) do
            local list = show[g]
            if #list > 0 then
                table.sort(list, function (a, b)
                    if a.left ~= b.left then return a.left < b.left end
                    return a.name < b.name
                end)
                if not first then group_gap() end
                first = false
                if config.recastLabels then imgui.TextColored(COL_ACCENT, g) end
                for _, r in ipairs(list) do
                    local x1 = xy(imgui.GetCursorScreenPos())
                    imgui.TextColored(COL_NAME, string.format('%-' .. rwidth .. 's :', r.name))
                    imgui.SameLine(0, 6)
                    if r.ready then
                        imgui.TextColored(COL_GREEN, 'Ready')
                        timer_bar(0, COL_GREEN, x1, last_right(x1))
                    else
                        imgui.TextColored(recast_color(r.left), fmt_time(r.left, false))
                        local total = recastTotal[r.name]
                        timer_bar(total and total > 0 and (r.left / total) or nil,
                                  recast_color(r.left), x1, last_right(x1))
                    end
                end
            end
        end

        box_end()

        -- Remember where the box was dragged to.
        local x, y = imgui.GetWindowPos()
        if (x ~= config.rx or y ~= config.ry) and not imgui.IsMouseDown(0) then
            config.rx, config.ry = x, y
            settings.save()
        end
    end
    imgui.End()
    pop_style()
end

----------------------------------------------------------------------
-- Debuff box: one section per mob, your target first.
----------------------------------------------------------------------
local function draw_debuffs(now, partyOn)
    local mobs
    if testMode then
        mobs = test.debuffs
    else
        if not config.debuffs then return end
        DB.prune(now)
        mobs = DB.mobs
    end

    local tgtIdx = nil
    pcall(function ()
        local t = AshitaCore:GetMemoryManager():GetTarget()
        tgtIdx = t:GetTargetIndex(t:GetIsSubTargetActive())
    end)

    -- Mob name with its ID (the mob's index, in hex), e.g. "Goblin Smithy (1A3)".
    local function mob_title(mob)
        if mob.index ~= nil then
            return mob.name .. string.format(' (%03X)', mob.index)
        end
        return mob.name
    end

    -- Build what to show (party members' debuffs only while party is on).
    -- AoE debuffs (landed on 2+ mobs at once) go in one row per spell;
    -- everything else is listed under its mob.
    local list  = T{}     -- mob sections
    local aoe   = {}      -- [shown name] = { shown, entries = { { who, exp, dur } } }
    local aoeList = T{}
    local width = NAME_WIDTH
    for id, mob in pairs(mobs) do
        local rows = T{}
        for _, d in pairs(mob.fx) do
            local okCaster = d.caster == nil
                or (partyOn and not config.party.hidden[d.caster])
            local hiddenFx = config.hiddenDebuffs[d.key or ''] == true
                or config.hiddenDebuffGroups[d.group or ''] == true
            if okCaster and not hiddenFx then
                -- Someone else's debuff shows who landed it: "Slow II (Aria)".
                d.shown = d.label
                if d.caster ~= nil then d.shown = d.label .. ' (' .. cut(d.caster, 12) .. ')' end
                if d.aoe then
                    local a = aoe[d.shown]
                    if a == nil then
                        a = { shown = d.shown, entries = T{} }
                        aoe[d.shown] = a
                        aoeList:append(a)
                    end
                    a.entries:append({ who = mob_title(mob), exp = d.exp, dur = d.dur })
                else
                    rows:append(d)
                    if #d.shown > width then width = #d.shown end
                end
            end
        end
        if #rows > 0 then
            table.sort(rows, function (a, b)
                if a.exp ~= b.exp then return a.exp < b.exp end
                return a.label < b.label
            end)
            local isTarget = mob.test or (mob.index ~= nil and mob.index == tgtIdx)
            list:append({ id = id, name = mob.name, index = mob.index, title = mob_title(mob),
                          target = isTarget, rows = rows })
        end
    end
    -- AoE rows: "Horde Lullaby (4)", lowest timer first.
    for _, a in ipairs(aoeList) do
        table.sort(a.entries, function (x, y) return x.exp < y.exp end)
        a.exp, a.dur = a.entries[1].exp, a.entries[1].dur
        a.label = a.shown .. ' (' .. #a.entries .. ')'
        if #a.label > width then width = #a.label end
        for _, e in ipairs(a.entries) do
            if #e.who + 1 > width then width = #e.who + 1 end
        end
    end
    table.sort(aoeList, function (x, y)
        if x.exp ~= y.exp then return x.exp < y.exp end
        return x.shown < y.shown
    end)
    if #list == 0 and #aoeList == 0 then return end
    table.sort(list, function (a, b)
        if a.target ~= b.target then return a.target end
        if a.name ~= b.name then return a.name < b.name end
        return (a.index or 0) < (b.index or 0)
    end)

    imgui.SetNextWindowPos({ config.dx, config.dy },
        moveBox.debuff and ImGuiCond_Always or ImGuiCond_FirstUseEver)
    moveBox.debuff = false
    push_style(true)

    -- One timer line: "name : 0:00" plus its bar.
    local function timer_line(text, exp, dur, col)
        local left = exp - now
        if left < 0 then left = 0 end
        local x1 = xy(imgui.GetCursorScreenPos())
        imgui.TextColored(col, string.format('%-' .. width .. 's :', text))
        imgui.SameLine(0, 6)
        imgui.TextColored(time_color(left), fmt_time(left, false))
        timer_bar(dur and dur > 0 and (left / dur) or nil, time_color(left), x1, last_right(x1))
    end

    if imgui.Begin('personalbuffs_debuff', true, config.clickThrough
            and bit.bor(FLAGS, ImGuiWindowFlags_NoInputs or ImGuiWindowFlags_NoMouseInputs or 0) or FLAGS) then
        box_header('Debuffs')
        DB.open = DB.open or {}   -- [AoE row] = true when its mob list is shown
        DB.shut = DB.shut or {}   -- [mob ID] = true when its debuffs are folded away
        for id in pairs(DB.shut) do
            if mobs[id] == nil then DB.shut[id] = nil end
        end

        -- True when a row was clicked (press and release on it, not a box drag).
        local function row_clicked(key, rowTop, rowBottom)
            local _, my = imgui.GetMousePos()
            local hovered = imgui.IsWindowHovered() and my >= rowTop and my < rowBottom
            if hovered and imgui.IsMouseClicked(0) then
                local wx, wy = imgui.GetWindowPos()
                press = { name = key, x = wx, y = wy }
            end
            if press ~= nil and press.name == key and imgui.IsMouseReleased(0) then
                local wx, wy = imgui.GetWindowPos()
                return hovered and wx == press.x and wy == press.y
            end
            return false
        end

        for _, a in ipairs(aoeList) do
            local key = 'aoe|' .. a.shown
            local _, rowTop = imgui.GetCursorScreenPos()
            timer_line(a.label, a.exp, a.dur, COL_NAME)
            local _, rowBottom = imgui.GetCursorScreenPos()

            -- Click the row to see each mob.
            if row_clicked(key, rowTop, rowBottom) then
                DB.open[a.shown] = not DB.open[a.shown] or nil
            end
            if DB.open[a.shown] then
                for _, e in ipairs(a.entries) do
                    timer_line('   ' .. e.who, e.exp, e.dur, COL_TARGET)
                end
            end
        end

        for i, m in ipairs(list) do
            if i > 1 or #aoeList > 0 then group_gap() end
            -- Click the mob's name to fold its debuffs away (shows how many).
            local shut = DB.shut[m.id] == true
            local _, rowTop = imgui.GetCursorScreenPos()
            imgui.TextColored(m.target and COL_TARGET or COL_ACCENT,
                shut and (m.title .. ' (' .. #m.rows .. ')') or m.title)
            local _, rowBottom = imgui.GetCursorScreenPos()
            if row_clicked('mob|' .. tostring(m.id), rowTop, rowBottom) then
                DB.shut[m.id] = not shut or nil
            end
            if not shut then
                for _, d in ipairs(m.rows) do
                    timer_line(d.shown or d.label, d.exp, d.dur, COL_NAME)
                end
            end
        end
        -- Clicks in this box are done once the mouse is let go.
        if imgui.IsMouseReleased(0) and press ~= nil
                and (press.name:sub(1, 4) == 'aoe|' or press.name:sub(1, 4) == 'mob|') then
            press = nil
        end

        box_end()

        -- Remember where the box was dragged to.
        local x, y = imgui.GetWindowPos()
        if (x ~= config.dx or y ~= config.dy) and not imgui.IsMouseDown(0) then
            config.dx, config.dy = x, y
            settings.save()
        end
    end
    imgui.End()
    pop_style()
end

----------------------------------------------------------------------
-- Party buffs helpers
----------------------------------------------------------------------
-- Drops people 5s after their timer ends; returns rows sorted by lowest timer.
local function prune_rows(store, now, openTbl, keyPrefix)
    local list = T{}
    for name, t in pairs(store) do
        local lowest, lowEst = nil, false
        for who, pp in pairs(t.people) do
            if now > pp.exp + KEEP_AFTER then
                if not testMode then
                    dlog(name .. ' on ' .. show_who(who) .. ': timer ran out (' .. mmss(pp.dur or 0) .. ', '
                         .. (SRC_TEXT[pp.src or ''] or 'unknown') .. ')')
                end
                t.people[who] = nil
            elseif lowest == nil or pp.exp < lowest then
                lowest, lowEst = pp.exp, pp.est
            end
        end
        if lowest == nil then
            store[name] = nil
            openTbl[keyPrefix .. name] = nil
        else
            t.expires = lowest
            t.est     = lowEst
            list:append(t)
        end
    end
    table.sort(list, function (a, b) return a.expires < b.expires end)
    return list
end

----------------------------------------------------------------------
-- Job catalog: every spell / ability each job gets (level 75 cap).
-- Names come from the game's own data so they match what's shown.
----------------------------------------------------------------------
local JOB_NAMES = { 'WAR', 'MNK', 'WHM', 'BLM', 'RDM', 'THF', 'PLD', 'DRK', 'BST', 'BRD',
                    'RNG', 'SAM', 'NIN', 'DRG', 'SMN', 'BLU', 'COR', 'PUP', 'DNC', 'SCH' }
local catalog = nil   -- [job] = { buffs = {name=group}, recasts = {name=group}, debuffs = {name=group} }
local spellOrder = {} -- [spell name] = spell ID (used to order tiers)
local songNames  = {} -- [spell name] = true for songs

local function build_catalog()
    local ok, data = pcall(require, 'jobdata')
    catalog = {}
    for job = 1, #JOB_NAMES do
        catalog[job] = { buffs = {}, recasts = {}, debuffs = {} }
    end

    -- Debuffs that don't come from jobdata: weapon skills, procs and other
    -- effects for every job; job abilities and pet moves for their job.
    local JOB = { PLD = 7, DRK = 8, BST = 9, SMN = 15, COR = 17, PUP = 18 }
    for job = 1, #JOB_NAMES do
        local d = catalog[job].debuffs
        for _, ws in pairs(DB.WS) do d[ws.n] = 'Weapon Skills' end
        d[DB.PROCS] = 'Other'
        d[DB.OTHER] = 'Other'
    end
    catalog[JOB.PLD].debuffs[DB.BASH[46]] = 'Abilities'
    catalog[JOB.DRK].debuffs[DB.BASH[77]] = 'Abilities'
    for _, ja in pairs(DB.JA) do catalog[JOB.COR].debuffs[ja.n] = 'Abilities' end
    for _, pact in pairs(DB.PACTS) do catalog[JOB.SMN].debuffs[pact.n] = 'Pets' end
    catalog[JOB.SMN].debuffs['Nightmare'] = 'Pets'
    for id, mv in pairs(DB.PETS) do
        local job = DB.AUTOMATON[id] and JOB.PUP or JOB.BST
        catalog[job].debuffs[mv.n] = 'Pets'
    end

    if not ok or data == nil then return end
    local rm = AshitaCore:GetResourceManager()

    for id, info in pairs(data.spells or {}) do
        local spell = rm:GetSpellById(id)
        if spell ~= nil and not is_trust(id, spell) and spell.Name[1] ~= nil and spell.Name[1] ~= '' then
            local name = spell.Name[1]
            spellOrder[name] = id
            if spell.Skill == 40 then songNames[name] = true end
            for job, _ in pairs(info.jobs) do
                if catalog[job] ~= nil then
                    if info.buff then catalog[job].buffs[name] = spell_group(spell) end
                    if DB.SPELLS[id] then catalog[job].debuffs[name] = spell_group(spell) end
                    catalog[job].recasts[name] = 'Spells'
                end
            end
        end
    end

    for id, info in pairs(data.abilities or {}) do
        local job = info.job
        local ab  = rm:GetAbilityById(id + 512)
        if catalog[job] ~= nil and ab ~= nil and ab.Name[1] ~= nil and ab.Name[1] ~= '' then
            local name = ab.Name[1]
            if info.buff then
                catalog[job].buffs[name] = name:match(' Roll$') and 'Rolls' or 'Abilities'
            end
            local rname
            if ab.RecastTimerId == nil then
                rname = nil
            elseif ab.RecastTimerId == 0 then
                rname = TWO_HOURS[job]
            else
                rname = ability_name(ab.RecastTimerId)
            end
            if rname ~= nil then catalog[job].recasts[rname] = 'Abilities' end
        end
    end
end

-- Turns test mode on / off. Real data is untouched either way.
local function toggle_test()
    testMode = not testMode
    if testMode then build_test() else test = nil end
    open, partyOpen, readyUntil, lastRecasts = T{}, T{}, T{}, T{}
end

-- Menu state
local draw_party_tab   -- defined below
local selJob = nil         -- job shown on the right
local selTab = 'Buffs'     -- 'Buffs', 'Recasts', 'Debuffs', 'Party' or 'Theme'
local CHILD_BORDER = ImGuiChildFlags_Borders or true

-- A button that looks "pressed" when selected.
local function pick_button(label, selected, width)
    imgui.PushStyleColor(ImGuiCol_Button, selected and COL_BTN_SEL or COL_BTN)
    local clicked = imgui.Button(label, { width or 0, 0 })
    imgui.PopStyleColor(1)
    return clicked
end

-- Tier helpers: "Valor Minuet IV" -> "Valor Minuet", "Utsusemi: Ni" -> "Utsusemi".
local ROMAN = { I = 1, II = 2, III = 3, IV = 4, V = 5, VI = 6, VII = 7, VIII = 8 }
local JP    = { Ichi = 1, Ni = 2, San = 3 }
local famOpen = {}   -- [group id .. base] = true when its tiers are shown

-- Songs whose tiers have different names are grouped by song type.
local SONG_FAMILIES = {
    { 'Minuet', 'Minuets' }, { 'Madrigal', 'Madrigals' }, { 'March', 'Marches' },
    { 'Minne', 'Minnes' }, { 'Mambo', 'Mambos' }, { 'Etude', 'Etudes' },
    { 'Prelude', 'Preludes' }, { 'Carol', 'Carols' }, { 'Paeon', 'Paeons' },
    { 'Ballad', 'Ballads' }, { 'Mazurka', 'Mazurkas' }, { 'Hymnus', 'Hymnus' },
    { 'Lullaby', 'Lullabies' }, { 'Elegy', 'Elegies' }, { 'Requiem', 'Requiems' },
    { 'Threnody', 'Threnodies' }, { 'Finale', 'Finales' }, { 'Operetta', 'Operettas' },
    { 'Pastoral', 'Pastorals' }, { 'Gavotte', 'Gavottes' }, { 'Round', 'Rounds' },
    { 'Virelai', 'Virelais' }, { 'Capriccio', 'Capriccios' }, { 'Fantasia', 'Fantasias' },
}

-- Enspells are split by element; this maps the name to the element.
local EN_ELEMENTS = { fire = 'Fire', blizzard = 'Ice', aero = 'Wind', stone = 'Earth',
                      thunder = 'Thunder', water = 'Water', light = 'Light', dark = 'Dark' }
local ELEMENT_ORDER = { Fire = 1, Ice = 2, Wind = 3, Earth = 4, Thunder = 5, Water = 6, Light = 7, Dark = 8 }

-- Returns the family a name belongs to, and a sub-family (or nil).
local function family_name(n)
    if songNames[n] then
        for _, f in ipairs(SONG_FAMILIES) do
            if n:find(f[1], 1, true) then return f[2] end
        end
    end
    if spellOrder[n] ~= nil then
        if n:match('^Bar%l') then return 'Bar Spells' end
        local e = n:match('^En(%l+)')
        if e ~= nil and EN_ELEMENTS[e] ~= nil then
            -- Sub-family is the spell without its tier: Enfire / Enfire II -> Enfire
            return 'Enspells', (n:gsub(' [IVX]+$', ''))
        end
    end
    local base, r = n:match('^(.-) ([IVX]+)$')
    if base ~= nil and ROMAN[r] ~= nil then return base end
    local b2, j = n:match('^(.-): (%a+)$')
    if b2 ~= nil and JP[j] ~= nil then return b2 end
    return n
end

local function tier_rank(n)
    -- Game spell order puts lower tiers first (Hunter's Prelude before Archer's).
    if spellOrder[n] ~= nil then return spellOrder[n] end
    local r = n:match(' ([IVX]+)$')
    if r ~= nil and ROMAN[r] ~= nil then return ROMAN[r] end
    local j = n:match(': (%a+)$')
    if j ~= nil and JP[j] ~= nil then return JP[j] end
    return 1
end

-- A single on/off checkbox for one spell / ability.
local function item_checkbox(n, hidden, id)
    local v = { not hidden[n] }
    imgui.PushStyleColor(ImGuiCol_Text, COL_NAME)
    if imgui.Checkbox(n .. '##i' .. id .. n, v) then
        hidden[n] = (not v[1]) or nil
        settings.save()
    end
    imgui.PopStyleColor(1)
end

-- A family row: one checkbox for all of it, and a clickable name that
-- opens / closes it. Sorts the list by tier. Returns true when open.
local function family_row(label, list, hidden, key)
    table.sort(list, function (a, b) return tier_rank(a) < tier_rank(b) end)

    local shown = 0
    for _, n in ipairs(list) do
        if not hidden[n] then shown = shown + 1 end
    end
    local v = { shown == #list }
    if imgui.Checkbox('##f' .. key, v) then
        for _, n in ipairs(list) do hidden[n] = (not v[1]) or nil end
        settings.save()
    end

    imgui.SameLine(0, 4)
    imgui.PushStyleColor(ImGuiCol_Button, { 0, 0, 0, 0 })
    imgui.PushStyleColor(ImGuiCol_Text, COL_NAME)
    local text = label .. (famOpen[key] and '  -' or '  +')
    if shown > 0 and shown < #list then text = text .. ' (some)' end
    if imgui.SmallButton(text .. '##fb' .. key) then
        famOpen[key] = not famOpen[key] or nil
    end
    imgui.PopStyleColor(2)
    return famOpen[key] == true
end

-- One group: group checkbox, All / None buttons, then items in 2 columns.
local function draw_group(g, names, hidden, hiddenGroups, id)
    local gv = { not hiddenGroups[g] }
    imgui.PushStyleColor(ImGuiCol_Text, COL_GREEN)
    if imgui.Checkbox(g .. '##g' .. id, gv) then
        hiddenGroups[g] = (not gv[1]) or nil
        settings.save()
    end
    imgui.PopStyleColor(1)

    imgui.SameLine(0, 12)
    if imgui.SmallButton('All##a' .. id) then
        for _, n in ipairs(names) do hidden[n] = nil end
        hiddenGroups[g] = nil
        settings.save()
    end
    imgui.SameLine(0, 4)
    if imgui.SmallButton('None##n' .. id) then
        for _, n in ipairs(names) do hidden[n] = true end
        settings.save()
    end

    -- Put tiers together under one name (Valor Minuet -> I, II, III, IV...).
    -- families[base] = { items = list, subs = { [sub] = list } or nil }
    local families, order = {}, T{}
    for _, n in ipairs(names) do
        local base, sub = family_name(n)
        if families[base] == nil then
            families[base] = { items = T{} }
            order:append(base)
        end
        local f = families[base]
        f.items:append(n)
        if sub ~= nil then
            f.subs = f.subs or {}
            f.subs[sub] = f.subs[sub] or T{}
            f.subs[sub]:append(n)
        end
    end

    -- Songs with no other tiers go together under "Other".
    local others = T{}
    local kept   = T{}
    for _, base in ipairs(order) do
        local f = families[base]
        if #f.items == 1 and f.subs == nil and songNames[f.items[1]] then
            others:append(f.items[1])
            families[base] = nil
        else
            kept:append(base)
        end
    end
    order = kept
    table.sort(order)
    if #others > 0 then
        families['Other'] = { items = others, forced = true }
        order:append('Other')   -- always last
    end

    if imgui.BeginTable('t' .. id, 2) then
        for _, base in ipairs(order) do
            local f = families[base]
            imgui.TableNextColumn()

            if #f.items == 1 and not f.forced and f.subs == nil then
                item_checkbox(f.items[1], hidden, id)
            elseif family_row(base, f.items, hidden, id .. base) then
                imgui.Indent(22)
                if f.subs ~= nil then
                    -- Sub-families (Enspells -> Fire -> Enfire, Enfire II).
                    local subs = T{}
                    for sname, _ in pairs(f.subs) do subs:append(sname) end
                    -- Element order: Enfire, Enblizzard, Enaero, Enstone, Enthunder, Enwater, Enlight.
                    local function eorder(x)
                        local e = x:match('^En(%l+)')
                        return ELEMENT_ORDER[EN_ELEMENTS[e or ''] or ''] or 99
                    end
                    table.sort(subs, function (a, b) return eorder(a) < eorder(b) end)
                    for _, sname in ipairs(subs) do
                        local list = f.subs[sname]
                        if #list == 1 then
                            item_checkbox(list[1], hidden, id)
                        elseif family_row(sname, list, hidden, id .. base .. sname) then
                            imgui.Indent(22)
                            for _, n in ipairs(list) do item_checkbox(n, hidden, id) end
                            imgui.Unindent(22)
                        end
                    end
                else
                    for _, n in ipairs(f.items) do item_checkbox(n, hidden, id) end
                end
                imgui.Unindent(22)
            end
        end
        imgui.EndTable()
    end
    imgui.Dummy({ 0, 6 })
end

-- Party tab: main switch, options, and one checkbox per person.
-- The main switch never changes the per-person choices.
draw_party_tab = function()
    local v = { config.party.enabled == true }
    imgui.PushStyleColor(ImGuiCol_Text, COL_GREEN)
    if imgui.Checkbox('Track party buffs (main switch)##pt_main', v) then
        config.party.enabled = v[1]
        if not v[1] then partyTimers = T{} end
        settings.save()
    end
    imgui.PopStyleColor(1)

    imgui.TextColored(COL_NAME, 'Their buffs show in your list as  Haste (Name).')
    imgui.TextColored(COL_NAME, 'Their debuffs on mobs show in the Debuff box.')
    imgui.Dummy({ 0, 6 })

    -- People: only who is in your party right now (no Trusts). Their
    -- checkboxes are saved by name, so they come back when that person rejoins.
    local names, seenName = T{}, {}
    local party = AshitaCore:GetMemoryManager():GetParty()
    for i = 1, 5 do
        if party:GetMemberIsActive(i) == 1 and is_player(party:GetMemberServerId(i)) then
            local n = party:GetMemberName(i)
            if n ~= nil and n ~= '' and not seenName[n] then
                seenName[n] = true
                names:append(n)
            end
        end
    end
    table.sort(names)

    imgui.TextColored(COL_TARGET, 'People')
    if #names == 0 then
        imgui.TextColored(COL_NAME, 'Nobody in your party right now.')
        return
    end
    imgui.TextColored(COL_NAME, 'Tick gear a person wears so their buffs get the extra time.')

    -- One row per person: show on/off, then one box per gear item (Dilation Ring...).
    local rules = config.rules or T{}
    if imgui.BeginTable('pt_people', 1 + #rules) then
        for _, n in ipairs(names) do
            imgui.TableNextColumn()
            local pv = { not config.party.hidden[n] }
            imgui.PushStyleColor(ImGuiCol_Text, COL_NAME)
            if imgui.Checkbox(n .. '##pp_' .. n, pv) then
                config.party.hidden[n] = (not pv[1]) or nil
                settings.save()
            end

            for ri, rule in ipairs(rules) do
                imgui.TableNextColumn()
                local mine = config.party.gear[n]
                local gv   = { mine ~= nil and mine[rule.item] == true }
                if imgui.Checkbox(rule.item .. '##pg_' .. ri .. '_' .. n, gv) then
                    if gv[1] then
                        config.party.gear[n] = config.party.gear[n] or T{}
                        config.party.gear[n][rule.item] = true
                    elseif mine ~= nil then
                        mine[rule.item] = nil
                        if next(mine) == nil then config.party.gear[n] = nil end
                    end
                    settings.save()
                end
            end
            imgui.PopStyleColor(1)
        end
        imgui.EndTable()
    end
end

-- True when the last slider was just let go after a change (so we save once,
-- not on every step). Older imgui builds without that call save on each
-- change instead; anything left unsaved is saved on unload anyway.
local function item_done()
    if imgui.IsItemDeactivatedAfterEdit ~= nil then
        return imgui.IsItemDeactivatedAfterEdit()
    end
    if imgui.IsItemEdited ~= nil then return imgui.IsItemEdited() end
    return false
end

-- Theme tab: one button per theme, with a small color sample next to it.
----------------------------------------------------------------------
-- Theme families (main theme -> sub-themes) and saved custom themes
----------------------------------------------------------------------
local FAMILIES = {
    { name = 'Default', themes = { 'Default' } },
    { name = 'Glass',   themes = { 'Glass', 'Glass Rose', 'Glass Mint', 'Glass Amber',
                                   'Glass Violet', 'Glass Ocean', 'Glass Smoke', 'Glass Frost' } },
    { name = 'Nations', themes = { "San d'Oria", 'Bastok', 'Windurst' } },
    { name = 'Expansions', themes = { "Vana'diel", 'Zilart', 'Promathia', 'Aht Urhgan', 'Goddess' } },
    { name = 'FFXIV',   themes = { 'FFXIV' } },
    { name = 'Dark',    themes = { 'Midnight', 'Ember', 'Crystal', 'Terminal' } },
    { name = 'Simple',  themes = { 'Classic', 'Minimal', 'High Contrast' } },
}
local STYLE_KEYS = { 'bars', 'barH', 'header', 'border', 'stripe', 'dividers', 'spacing', 'scale', 'rounding' }

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

-- Button label inside a family: "Glass Rose" -> "Rose", "Glass" -> "Clear".
local function short_name(fam, name)
    if fam.name == 'Glass' then
        if name == 'Glass' then return 'Clear' end
        return (name:gsub('^Glass ', ''))
    end
    return name
end

-- Picks a built-in theme (its full look, your tweaks cleared).
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

-- Saves the current look (base theme + every style setting + opacity).
-- A blank name becomes "Custom 1", "Custom 2"... Same name = overwrite.
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

-- Theme tab UI state
----------------------------------------------------------------------
-- Profiles: save every setting under a name, load it on another character.
-- Stored in Ashita's config folder for this addon (shared by all characters):
--   config\addons\personalbuffs\profile_<name>.lua
-- plus profiles.txt, the list of names.
-- Profile / preset file code and the menu's typed-in state live in these
-- two tables to stay under Lua's 200-locals limit for the main file.
local files = {}
local ui    = {}

----------------------------------------------------------------------
function files.profile_dir()
    local base = AshitaCore:GetInstallPath()
    if base:sub(-1) ~= '\\' and base:sub(-1) ~= '/' then base = base .. '\\' end
    return base .. 'config\\addons\\' .. addon.name .. '\\'
end

-- Letters, numbers, - and _ only, so it's a safe file name.
function files.profile_clean(name)
    return (tostring(name or ''):gsub('[^%w%-_]', ''):sub(1, 32))
end

-- Turns a settings table into Lua text that can be loaded back.
function files.to_lua(v, indent)
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
        out[#out + 1] = inner .. key .. ' = ' .. files.to_lua(v[k], inner) .. ','
    end
    out[#out + 1] = indent .. '}'
    return table.concat(out, '\n')
end

function files.read_file(path)
    local f = io.open(path, 'r')
    if f == nil then return nil end
    local text = f:read('*a')
    f:close()
    return text
end

function files.write_file(path, text)
    local f = io.open(path, 'w')
    if f == nil then return false end
    f:write(text)
    f:close()
    return true
end

-- Names of saved profiles (from profiles.txt).
function files.profile_list()
    local names = {}
    local text = files.read_file(files.profile_dir() .. 'profiles.txt') or ''
    for line in text:gmatch('[^\r\n]+') do
        local n = files.profile_clean(line)
        if n ~= '' then names[#names + 1] = n end
    end
    table.sort(names)
    return names
end

function files.profile_list_save(names)
    table.sort(names)
    return files.write_file(files.profile_dir() .. 'profiles.txt', table.concat(names, '\n') .. '\n')
end

-- Saves every setting. Returns true, name  or  false, reason.
function files.profile_save(name)
    name = files.profile_clean(name)
    if name == '' then return false, 'Use letters, numbers, - or _ for the name.' end
    settings.save()   -- makes sure the folder exists
    local text = '-- PersonalBuffs profile "' .. name .. '"\nreturn ' .. files.to_lua(config) .. '\n'
    if not files.write_file(files.profile_dir() .. 'profile_' .. name .. '.lua', text) then
        return false, 'Could not write the profile file.'
    end
    local names, found = files.profile_list(), false
    for _, n in ipairs(names) do if n:lower() == name:lower() then found = true end end
    if not found then names[#names + 1] = name; files.profile_list_save(names) end
    return true, name
end

-- Loads a profile over this character's settings. Returns true, name  or  false, reason.
function files.profile_load(name)
    name = files.profile_clean(name)
    local text = files.read_file(files.profile_dir() .. 'profile_' .. name .. '.lua')
    if text == nil then return false, 'No profile called "' .. name .. '".' end
    local chunk = (loadstring or load)(text)
    if chunk == nil then return false, 'That profile file is damaged.' end
    if setfenv ~= nil then setfenv(chunk, {}) end   -- data only, no access to anything else
    local ok, data = pcall(chunk)
    if not ok or type(data) ~= 'table' then return false, 'That profile file is damaged.' end

    -- Replace the settings in place (the settings library keeps this table).
    for k in pairs(config) do config[k] = nil end
    local function copy(v)
        if type(v) ~= 'table' then return v end
        local o = T{}
        for k, x in pairs(v) do o[k] = copy(x) end
        return o
    end
    for k, v in pairs(data) do config[k] = copy(v) end
    fill_missing(config, defaults)
    migrate(config)
    settings.save()

    -- Redraw everything with the new settings.
    appliedTheme   = nil
    moveBox.buff   = true
    moveBox.recast = true
    moveBox.debuff = true
    if not config.party.enabled then partyTimers = T{} end
    return true, name
end

function files.profile_delete(name)
    name = files.profile_clean(name)
    local names, kept = files.profile_list(), {}
    for _, n in ipairs(names) do
        if n:lower() ~= name:lower() then kept[#kept + 1] = n end
    end
    files.profile_list_save(kept)
    os.remove(files.profile_dir() .. 'profile_' .. name .. '.lua')
end

----------------------------------------------------------------------
-- Presets: just the show / hide choices (buffs, recasts, debuffs), saved
-- by name. Shared by all characters, next to the profiles:
-- preset_<name>.lua + presets.txt. Look and box positions are not touched.
----------------------------------------------------------------------
files.PRESET_KEYS = { 'hidden', 'hiddenGroups', 'hiddenRecast', 'hiddenRecastGroups',
                      'hiddenDebuffs', 'hiddenDebuffGroups' }

function files.preset_list()
    local names = {}
    local text = files.read_file(files.profile_dir() .. 'presets.txt') or ''
    for line in text:gmatch('[^\r\n]+') do
        local n = files.profile_clean(line)
        if n ~= '' then names[#names + 1] = n end
    end
    table.sort(names)
    return names
end

function files.preset_list_save(names)
    table.sort(names)
    return files.write_file(files.profile_dir() .. 'presets.txt', table.concat(names, '\n') .. '\n')
end

-- Saves what is hidden right now. Returns true, name  or  false, reason.
function files.preset_save(name)
    name = files.profile_clean(name)
    if name == '' then return false, 'Use letters, numbers, - or _ for the name.' end
    settings.save()   -- makes sure the folder exists
    local data = {}
    for _, k in ipairs(files.PRESET_KEYS) do data[k] = config[k] or {} end
    local text = '-- PersonalBuffs preset "' .. name .. '" (what is hidden)\nreturn ' .. files.to_lua(data) .. '\n'
    if not files.write_file(files.profile_dir() .. 'preset_' .. name .. '.lua', text) then
        return false, 'Could not write the preset file.'
    end
    local names, found = files.preset_list(), false
    for _, n in ipairs(names) do if n:lower() == name:lower() then found = true end end
    if not found then names[#names + 1] = name; files.preset_list_save(names) end
    return true, name
end

-- Loads a preset's show / hide choices. Returns true, name  or  false, reason.
function files.preset_load(name)
    name = files.profile_clean(name)
    local text = files.read_file(files.profile_dir() .. 'preset_' .. name .. '.lua')
    if text == nil then return false, 'No preset called "' .. name .. '".' end
    local chunk = (loadstring or load)(text)
    if chunk == nil then return false, 'That preset file is damaged.' end
    if setfenv ~= nil then setfenv(chunk, {}) end   -- data only, no access to anything else
    local ok, data = pcall(chunk)
    if not ok or type(data) ~= 'table' then return false, 'That preset file is damaged.' end
    for _, k in ipairs(files.PRESET_KEYS) do
        local t = T{}
        if type(data[k]) == 'table' then
            for n, v in pairs(data[k]) do
                if type(n) == 'string' and v == true then t[n] = true end
            end
        end
        config[k] = t
    end
    settings.save()
    return true, name
end

function files.preset_delete(name)
    name = files.profile_clean(name)
    local names, kept = files.preset_list(), {}
    for _, n in ipairs(names) do
        if n:lower() ~= name:lower() then kept[#kept + 1] = n end
    end
    files.preset_list_save(kept)
    os.remove(files.profile_dir() .. 'preset_' .. name .. '.lua')
end

ui.selFamily = nil         -- family shown in the sub-theme row
ui.nameBuf   = { '' }      -- name typed for a custom theme
ui.showStyle = false       -- Style section open?
ui.showPos   = false       -- Box position section open?
ui.showProf  = false       -- Profiles section open?
ui.profBuf   = { '' }      -- profile name typed in
ui.profSel   = nil         -- profile picked in the list
ui.profMsg   = nil         -- last result line shown under the buttons

-- A small "+ Label" / "- Label" button that opens / closes a section.
local function fold(label, open)
    if imgui.SmallButton((open and '-  ' or '+  ') .. label .. '##fold' .. label) then
        return not open
    end
    return open
end

-- Buttons laid out 4 per row.
local function grid_button(i, label, selected)
    if (i - 1) % 4 ~= 0 then imgui.SameLine(0, 4) end
    return pick_button(label, selected, 84)
end

local function draw_theme_tab()
    if ui.selFamily == nil then
        ui.selFamily = config.activeCustom and 'Custom' or family_of(config.theme)
    end

    -- Main themes.
    local fams = {}
    for _, f in ipairs(FAMILIES) do fams[#fams + 1] = f.name end
    fams[#fams + 1] = 'Custom'
    for i, fname in ipairs(fams) do
        if i > 1 then imgui.SameLine(0, 4) end
        if pick_button(fname .. '##fam' .. i, ui.selFamily == fname, 0) then
            ui.selFamily = fname
            local f = find_family(fname)
            if f ~= nil and #f.themes == 1 then use_theme(f.themes[1]) end
        end
    end
    imgui.Dummy({ 0, 2 })

    -- Sub-themes of the chosen family (or your saved themes).
    if ui.selFamily == 'Custom' then
        local list = config.customThemes or {}
        if #list == 0 then
            imgui.TextColored(COL_NAME, 'No saved themes yet. Make a look, then Save it below.')
        end
        for i, c in ipairs(list) do
            if grid_button(i, c.name .. '##cus' .. i, config.activeCustom == c.name) then use_custom(c) end
        end
    else
        local f = find_family(ui.selFamily) or FAMILIES[1]
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

    -- What's in use now, with a small color sample.
    imgui.Dummy({ 0, 4 })
    local now = config.activeCustom or (currentTheme and currentTheme.name) or 'Default'
    imgui.TextColored(COL_ACCENT, 'Using: ' .. now)
    imgui.SameLine(0, 10)
    imgui.TextColored(COL_NAME, 'Haste :')
    imgui.SameLine(0, 6)
    imgui.TextColored(COL_GREEN, '2:40')
    imgui.SameLine(0, 8)
    imgui.TextColored(COL_YELLOW, '0:25')
    imgui.SameLine(0, 8)
    imgui.TextColored(COL_RED, '0:08')
    if config.activeCustom == nil and currentTheme ~= nil and currentTheme.desc ~= nil then
        imgui.TextColored(COL_NAME, currentTheme.desc)
    elseif config.activeCustom ~= nil then
        imgui.TextColored(COL_NAME, 'Your saved theme (based on ' .. tostring(config.theme) .. ').')
    end

    -- Save the current look as your own theme.
    imgui.Dummy({ 0, 4 })
    if has('InputText') then
        width_push(150)
        pcall(imgui.InputText, 'Name##pbname', ui.nameBuf, 24)
        width_pop()
        imgui.SameLine(0, 6)
    end
    if imgui.SmallButton('Save look##pbsave') then
        save_custom(ui.nameBuf[1])
        ui.nameBuf[1] = ''
        ui.selFamily  = 'Custom'
    end
    if config.activeCustom ~= nil then
        imgui.SameLine(0, 6)
        if imgui.SmallButton('Update "' .. config.activeCustom .. '"##pbupd') then
            save_custom(config.activeCustom)
        end
        imgui.SameLine(0, 6)
        if imgui.SmallButton('Delete##pbdel') then
            delete_custom(config.activeCustom)
        end
    end

    -- Style and position, folded away until opened.
    imgui.Dummy({ 0, 6 })
    ui.showStyle = fold('Style', ui.showStyle)
    if ui.showStyle then
        -- Style: your tweaks on top of the theme.
        if imgui.SmallButton("Use theme's style##stdef") then
            config.style        = T{}
            config.opacity      = 0
            config.activeCustom = nil
            settings.save()
        end
        imgui.SameLine(0, 8)
        imgui.TextColored(COL_NAME, 'Changes stay until you pick another theme.')

        local function check(label, key)
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
        local function slider(label, key, lo, hi, def, fmt)
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

        check('Timer bars', 'bars')
        if S('bars') then
            imgui.SameLine(0, 16)
            slider('Bar height', 'barH', 2, 8, 3, '%d px')
        end
        check('Box headers', 'header')
        imgui.SameLine(0, 16)
        check('Lines between groups', 'dividers')
        local lv = { config.recastLabels == true }
        if imgui.Checkbox('Abilities / Spells labels in the recast box##st_rlabels', lv) then
            config.recastLabels = lv[1]
            settings.save()
        end
        choice('Border ', 'border', { { 'none', 'None' }, { 'thin', 'Thin' },
                                      { 'thick', 'Thick' }, { 'double', 'Double' } })
        choice('Spacing', 'spacing', { { 'compact', 'Compact' }, { 'normal', 'Normal' },
                                       { 'roomy', 'Roomy' } })
        slider('Side stripe', 'stripe', 0, 6, 0, '%d px')
        if can_scale() then slider('Text size', 'scale', 80, 130, 100, '%d%%') end
        slider('Corner roundness', 'rounding', 0, 12, 6)

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
    ui.showPos = fold('Box position', ui.showPos)
    if ui.showPos then
        -- Box position: type a number, or click - / + (hold Ctrl for steps of 10).
        imgui.TextColored(COL_NAME, 'Type a number or use - / +. Ctrl + click moves 10.')
        local function pos_row(label, id, xKey, yKey, box)
            imgui.TextColored(COL_NAME, label)
            for _, k in ipairs({ xKey, yKey }) do
                imgui.SameLine(0, 8)
                local v = { math.floor((tonumber(config[k]) or 0) + 0.5) }
                local axis = (k == xKey) and 'X' or 'Y'
                local changed
                if has('InputInt') then
                    width_push(110)
                    changed = imgui.InputInt(axis .. '##' .. id .. k, v, 1, 10)
                    width_pop()
                else
                    changed = int_control(axis .. '##' .. id .. k, v, 0, 9999)
                end
                if changed then
                    config[k] = math.max(0, v[1])
                    moveBox[box] = true
                    settings.save()
                end
            end
        end
        pos_row('Buff box  ', 'pbuff', 'x', 'y', 'buff')
        pos_row('Recast box', 'prec', 'rx', 'ry', 'recast')
        pos_row('Debuff box', 'pdeb', 'dx', 'dy', 'debuff')
        imgui.TextColored(COL_NAME, 'A box only shows when it has something in it. Test mode helps.')
    end
    imgui.Dummy({ 0, 4 })
    local dv = { config.debuffs == true }
    if imgui.Checkbox('Track debuffs on mobs (Debuff box)##debuffs', dv) then
        config.debuffs = dv[1]
        if not dv[1] then DB.mobs = T{} end
        settings.save()
    end
    local cv = { config.clickThrough == true }
    if imgui.Checkbox('Click-through (mouse goes to the game; move boxes with X / Y above)##clickthru', cv) then
        config.clickThrough = cv[1]
        settings.save()
    end
    local hv = { config.hideFullLog == true }
    if imgui.Checkbox('Hide the boxes while the full chat log is open##hidelog', hv) then
        config.hideFullLog = hv[1]
        settings.save()
    end
    ui.showProf = fold('Profiles (copy settings to another character)', ui.showProf)
    if ui.showProf then
        imgui.TextColored(COL_NAME, 'Saves every setting: look, positions, hidden buffs, party, saved times.')
        if has('InputText') then
            width_push(150)
            pcall(imgui.InputText, 'Name##profname', ui.profBuf, 32)
            width_pop()
            imgui.SameLine(0, 6)
        end
        if imgui.SmallButton('Save settings##profsave') then
            local name = ui.profBuf[1]
            if not has('InputText') or files.profile_clean(name) == '' then name = myName or 'default' end
            local ok, res = files.profile_save(name)
            ui.profMsg = ok and ('Saved as "' .. res .. '".') or res
            if ok then ui.profSel = res; ui.profBuf[1] = '' end
        end
        local list = files.profile_list()
        if #list == 0 then
            imgui.TextColored(COL_NAME, 'No profiles yet.')
        else
            for i, n in ipairs(list) do
                if grid_button(i, n .. '##prof' .. i, ui.profSel == n) then ui.profSel = n end
            end
        end
        if ui.profSel ~= nil then
            if imgui.SmallButton('Load "' .. ui.profSel .. '" onto this character##profload') then
                local ok, res = files.profile_load(ui.profSel)
                ui.profMsg = ok and ('Loaded "' .. res .. '".') or res
            end
            imgui.SameLine(0, 6)
            if imgui.SmallButton('Delete##profdel') then
                files.profile_delete(ui.profSel)
                ui.profMsg = 'Deleted "' .. ui.profSel .. '".'
                ui.profSel = nil
            end
        end
        if ui.profMsg ~= nil then imgui.TextColored(COL_ACCENT, ui.profMsg) end
    end
    imgui.TextColored(COL_NAME, 'Tip: turn Test on to see the boxes while you pick.')
end

-- Presets section, shown at the top of the Buffs / Recasts / Debuffs tabs.
ui.showPreset = false
ui.presetBuf  = { '' }
ui.presetSel  = nil
ui.presetMsg  = nil
local function draw_presets()
    ui.showPreset = fold('Presets (save what is hidden, load it any time)', ui.showPreset)
    if not ui.showPreset then return end
    imgui.TextColored(COL_NAME, 'Saves which buffs, debuffs and recasts are hidden. Any character can load them.')
    if has('InputText') then
        width_push(150)
        pcall(imgui.InputText, 'Name##presetname', ui.presetBuf, 32)
        width_pop()
        imgui.SameLine(0, 6)
    end
    if imgui.SmallButton('Save what is hidden##presetsave') then
        local name = ui.presetBuf[1]
        if not has('InputText') or files.profile_clean(name) == '' then name = 'preset' .. (#files.preset_list() + 1) end
        local ok, res = files.preset_save(name)
        ui.presetMsg = ok and ('Saved as "' .. res .. '".') or res
        if ok then ui.presetSel = res; ui.presetBuf[1] = '' end
    end
    local list = files.preset_list()
    if #list == 0 then
        imgui.TextColored(COL_NAME, 'No presets yet.')
    else
        for i, n in ipairs(list) do
            if grid_button(i, n .. '##preset' .. i, ui.presetSel == n) then ui.presetSel = n end
        end
    end
    if ui.presetSel ~= nil then
        if imgui.SmallButton('Load "' .. ui.presetSel .. '"##presetload') then
            local ok, res = files.preset_load(ui.presetSel)
            ui.presetMsg = ok and ('Loaded "' .. res .. '".') or res
        end
        imgui.SameLine(0, 6)
        if imgui.SmallButton('Delete##presetdel') then
            files.preset_delete(ui.presetSel)
            ui.presetMsg = 'Deleted "' .. ui.presetSel .. '".'
            ui.presetSel = nil
        end
    end
    if ui.presetMsg ~= nil then imgui.TextColored(COL_ACCENT, ui.presetMsg) end
    imgui.Dummy({ 0, 4 })
end

local function draw_config()
    if not showConfig[1] then return end
    if catalog == nil then build_catalog() end

    local player = AshitaCore:GetMemoryManager():GetPlayer()
    local main   = player:GetMainJob()
    local sub    = player:GetSubJob()
    if selJob == nil or JOB_NAMES[selJob] == nil then
        selJob = JOB_NAMES[main] ~= nil and main or 1
    end

    imgui.SetNextWindowSize({ 600, 420 }, ImGuiCond_FirstUseEver)
    push_style()
    if imgui.Begin('PersonalBuffs##pbconfig', showConfig, ImGuiWindowFlags_NoCollapse) then

        -- Left: job list (main and sub first).
        -- Wide enough for the longest label ("BRD (main)") plus padding and a scrollbar.
        local tw = 0
        local ok, w = pcall(imgui.CalcTextSize, 'WWW (main)')
        if ok and type(w) == 'number' then tw = w end
        -- Extra room for button padding, the box's own padding and the scroll bar.
        local listWidth = math.max(150, tw + 75)
        imgui.BeginChild('pb_jobs', { listWidth, 0 }, CHILD_BORDER)
        local order = T{}
        if JOB_NAMES[main] ~= nil then order:append({ main, JOB_NAMES[main] .. ' (main)' }) end
        if JOB_NAMES[sub] ~= nil and sub ~= main then order:append({ sub, JOB_NAMES[sub] .. ' (sub)' }) end
        for _, o in ipairs(order) do
            if pick_button(o[2] .. '##top' .. o[1], selJob == o[1], -1) then selJob = o[1] end
        end
        if #order > 0 then imgui.Dummy({ 0, 6 }) end
        for job = 1, #JOB_NAMES do
            if pick_button(JOB_NAMES[job] .. '##job' .. job, selJob == job, -1) then selJob = job end
        end
        imgui.EndChild()

        imgui.SameLine(0, 6)

        -- Right: Buffs / Recasts tabs and the groups.
        imgui.BeginChild('pb_items', { 0, 0 }, CHILD_BORDER)
        if pick_button('Buffs##tabb', selTab == 'Buffs', 62) then selTab = 'Buffs' end
        imgui.SameLine(0, 4)
        if pick_button('Recasts##tabr', selTab == 'Recasts', 62) then selTab = 'Recasts' end
        imgui.SameLine(0, 4)
        if pick_button('Debuffs##tabd', selTab == 'Debuffs', 62) then selTab = 'Debuffs' end
        imgui.SameLine(0, 4)
        if pick_button('Party##tabp', selTab == 'Party', 62) then selTab = 'Party' end
        imgui.SameLine(0, 4)
        if pick_button('Theme##tabt', selTab == 'Theme', 62) then selTab = 'Theme' end
        imgui.SameLine(0, 12)
        if pick_button((testMode and 'Test: on' or 'Test: off') .. '##test', testMode, 70) then
            toggle_test()
        end
        if selTab ~= 'Party' and selTab ~= 'Theme' then
            imgui.SameLine(0, 12)
            imgui.TextColored(COL_TARGET, JOB_NAMES[selJob])
        end
        imgui.Dummy({ 0, 4 })

        if selTab == 'Party' or selTab == 'Theme' then
            if selTab == 'Party' then draw_party_tab() else draw_theme_tab() end
            imgui.EndChild()
            imgui.End()
            pop_style()
            return
        end

        draw_presets()

        local map, groups, hidden, hgroups
        if selTab == 'Buffs' then
            map, groups = catalog[selJob].buffs, GROUPS
            hidden, hgroups = config.hidden, config.hiddenGroups
        elseif selTab == 'Debuffs' then
            map, groups = catalog[selJob].debuffs, DB.GROUPS
            hidden, hgroups = config.hiddenDebuffs, config.hiddenDebuffGroups
        else
            map, groups = catalog[selJob].recasts, RECAST_GROUPS
            hidden, hgroups = config.hiddenRecast, config.hiddenRecastGroups
        end

        local any = false
        for _, g in ipairs(groups) do
            local names = T{}
            for n, grp in pairs(map) do
                if grp == g then names:append(n) end
            end
            if #names > 0 then
                any = true
                table.sort(names)
                draw_group(g, names, hidden, hgroups, selTab .. selJob .. g)
            end
        end
        if not any then
            imgui.TextColored(COL_NAME, 'Nothing for this job.')
        end
        imgui.EndChild()
    end
    imgui.End()
    pop_style()
end

----------------------------------------------------------------------
-- Main list
----------------------------------------------------------------------
ashita.events.register('d3d_present', 'pb_present', function ()
    local now = os.time()
    update_my_name()
    if not trustsPurged then purge_trusts() end
    -- Copy in the theme's colors when it changes (or a bad name was saved).
    if appliedTheme ~= config.theme then
        config.theme = apply_theme(config.theme)
        appliedTheme = config.theme
    end
    process_pending(now)
    draw_config()
    -- Hide the boxes while the full chat log is open (timers keep running).
    if config.hideFullLog and full_log_open() then return end
    draw_recasts(now)

    -- In test mode the fake stores are shown instead of the real ones.
    local myStore, partyStores = timers, partyTimers
    if testMode then
        refresh_test(now)
        myStore, partyStores = test.timers, test.party
    end
    local partyOn = testMode or config.party.enabled
    draw_debuffs(now, partyOn)

    -- Build the rows. Everyone's casts of the same buff share one row, and
    -- the dropdown shows who cast it on each person: "Aria (Aria)" means Aria
    -- cast it on herself; no name in brackets means you cast it.
    -- Rolls stay one row per corsair, because each roll has its own total.
    local merged = {}
    local rows   = T{}
    local function add(t, caster)
        local row
        if t.kind == 'roll' and caster ~= nil then
            row = { name = t.name, group = t.group, total = t.total, caster = caster,
                    key = caster .. '|' .. t.name, openTbl = partyOpen, entries = T{} }
            rows:append(row)
        else
            row = merged[t.name]
            if row == nil then
                row = { name = t.name, group = t.group, key = t.name, openTbl = open, entries = T{} }
                merged[t.name] = row
                rows:append(row)
            end
            if caster == nil then row.total = t.total end
        end
        for who, pp in pairs(t.people) do
            row.entries:append({ who = who, exp = pp.exp, est = pp.est, dur = pp.dur, caster = caster })
        end
    end

    -- Drop people 5s after their timer ends; drop buffs with nobody left.
    -- (A shared row's open state is kept, so it isn't cleared here.)
    prune_rows(myStore, now, {}, '')
    for name, t in pairs(myStore) do
        if not is_hidden(name, t.group) then add(t, nil) end
    end
    for caster, store in pairs(partyStores) do
        prune_rows(store, now, partyOpen, caster .. '|')
        if next(store) == nil then
            partyStores[caster] = nil
        elseif partyOn and not config.party.hidden[caster] then
            -- Buffs you turned off in the Buffs tab are hidden for everyone's casts.
            for name, t in pairs(store) do
                if not is_hidden(name, t.group) then add(t, caster) end
            end
        end
    end

    -- Each row uses the lowest timer among its people.
    local byGroup = {}
    local shown   = T{}
    for _, row in ipairs(rows) do
        if #row.entries > 0 then
            for _, e in ipairs(row.entries) do
                if row.expires == nil or e.exp < row.expires then
                    row.expires, row.est, row.dur = e.exp, e.est, e.dur
                end
            end
            local g = row.group or 'Other'
            byGroup[g] = byGroup[g] or T{}
            byGroup[g]:append(row)
            shown:append(row)
        end
    end
    if #shown == 0 then return end
    local width = column_width(shown)

    imgui.SetNextWindowPos({ config.x, config.y },
        moveBox.buff and ImGuiCond_Always or ImGuiCond_FirstUseEver)
    moveBox.buff = false
    push_style(true)

    if imgui.Begin('personalbuffs', true, config.clickThrough
            and bit.bor(FLAGS, ImGuiWindowFlags_NoInputs or ImGuiWindowFlags_NoMouseInputs or 0) or FLAGS) then
        box_header('Buffs')
        local first = true
        for _, g in ipairs(GROUPS) do
            local list = byGroup[g]
            if list ~= nil then
                table.sort(list, function (a, b) return a.expires < b.expires end)

                -- Small gap (or a line) between groups.
                if not first then group_gap() end
                first = false

                for _, t in ipairs(list) do
                    local left = t.expires - now
                    if left < 0 then left = 0 end

                    local label   = row_label(t, width)
                    local key     = t.key
                    local openTbl = t.openTbl

                    local rowLeft, rowTop = imgui.GetCursorScreenPos()
                    imgui.TextColored(COL_NAME, string.format('%-' .. width .. 's :', label))
                    imgui.SameLine(0, 6)
                    imgui.TextColored(time_color(left), fmt_time(left, t.est))
                    timer_bar(t.dur and (left / t.dur) or nil, time_color(left),
                              rowLeft, last_right(rowLeft))
                    local _, rowBottom = imgui.GetCursorScreenPos()

                    -- The whole row (full box width) counts as the click area.
                    local _, my = imgui.GetMousePos()
                    local rowHovered = imgui.IsWindowHovered() and my >= rowTop and my < rowBottom

                    if rowHovered and imgui.IsMouseClicked(0) then
                        local wx, wy = imgui.GetWindowPos()
                        press = { name = key, x = wx, y = wy }
                    end

                    -- Toggle the name list on click (but not when dragging the box).
                    if press ~= nil and press.name == key and imgui.IsMouseReleased(0) then
                        local wx, wy = imgui.GetWindowPos()
                        if rowHovered and wx == press.x and wy == press.y then
                            openTbl[key] = not openTbl[key] or nil
                        end
                    end

                    -- Dropdown: each person and their own timer, lowest first.
                    -- Someone else's cast shows as "Name (Caster)".
                    if openTbl[key] then
                        table.sort(t.entries, function (a, b) return a.exp < b.exp end)
                        for _, e in ipairs(t.entries) do
                            local pl = e.exp - now
                            if pl < 0 then pl = 0 end
                            imgui.TextColored(COL_TARGET, string.format('   %-' .. (width - 1) .. 's', entry_label(e, width)))
                            imgui.SameLine(0, 6)
                            imgui.TextColored(time_color(pl), fmt_time(pl, e.est))
                        end
                    end
                end
            end
        end
        if imgui.IsMouseReleased(0) then press = nil end

        box_end()

        -- Remember where the box was dragged to.
        local x, y = imgui.GetWindowPos()
        if (x ~= config.x or y ~= config.y) and not imgui.IsMouseDown(0) then
            config.x, config.y = x, y
            settings.save()
        end
    end
    imgui.End()
    pop_style()
end)

----------------------------------------------------------------------
-- Commands
----------------------------------------------------------------------
local function msg(text)
    print(chat.header(addon.name):append(chat.message(text)))
end

-- Matches a typed name to a known buff name (ignores case).
local function find_name(typed)
    local low = typed:lower()
    for n, _ in pairs(config.seen) do
        if n:lower() == low then return n end
    end
    for n, _ in pairs(timers) do
        if n:lower() == low then return n end
    end
    return typed
end

ashita.events.register('command', 'pb_command', function (e)
    local args = e.command:args()
    if #args == 0 or args[1]:lower() ~= '/pb' then return end
    e.blocked = true

    local cmd  = (args[2] or ''):lower()
    local rest = table.concat(args, ' ', 3)

    if cmd == '' or cmd == 'config' then
        showConfig[1] = not showConfig[1]
        return
    end

    if cmd == 'test' then
        toggle_test()
        msg('Test mode: ' .. (testMode and 'on (fake buffs and recasts)' or 'off'))
        return
    end

    if cmd == 'party' then
        config.party.enabled = not config.party.enabled
        if not config.party.enabled then partyTimers = T{} end
        settings.save()
        msg('Party buffs: ' .. (config.party.enabled and 'on' or 'off'))
        return
    end

    -- /pb profile save|load|delete <name>, /pb profile list
    if cmd == 'profile' or cmd == 'profiles' then
        local sub  = (args[3] or 'list'):lower()
        local name = args[4] or ''
        if sub == 'save' then
            if name == '' then name = myName or 'default' end
            local ok, res = files.profile_save(name)
            msg(ok and ('Settings saved as profile "' .. res .. '".') or res)
        elseif sub == 'load' then
            local ok, res = files.profile_load(name)
            msg(ok and ('Loaded profile "' .. res .. '".') or res)
        elseif sub == 'delete' then
            files.profile_delete(name)
            msg('Deleted profile "' .. files.profile_clean(name) .. '".')
        else
            local list = files.profile_list()
            msg(#list == 0 and 'No profiles yet. /pb profile save <name>'
                or ('Profiles: ' .. table.concat(list, ', ')))
        end
        return
    end

    if cmd == 'lock' then
        config.clickThrough = not config.clickThrough
        settings.save()
        msg('Click-through: ' .. (config.clickThrough and 'on (boxes can\'t be dragged)' or 'off'))
        return
    end

    if cmd == 'debuffs' then
        config.debuffs = not config.debuffs
        if not config.debuffs then DB.mobs = T{} end
        settings.save()
        msg('Debuffs on mobs: ' .. (config.debuffs and 'on' or 'off'))
        return
    end

    if cmd == 'debug' then
        debugMode = not debugMode
        msg('Debug: ' .. (debugMode and 'on (chat lines when buffs / debuffs start and leave)' or 'off'))
        return
    end

    if cmd == 'clear' then
        timers     = T{}
        pending    = T{}
        open       = T{}
        readyUntil = T{}
        partyTimers = T{}
        partyOpen   = T{}
        lastRollBy  = T{}
        DB.mobs  = T{}
        msg('Buff list cleared.')
        return
    end

    -- /pb hide <name> hides the buff; /pb hide recast <name> hides the recast;
    -- /pb hide debuff <name> hides the debuff (by the spell / skill that puts it on).
    if (cmd == 'hide' or cmd == 'show') and rest ~= '' then
        local kind  = (args[3] or ''):lower()
        local typed = rest
        if kind == 'recast' or kind == 'debuff' then
            typed = table.concat(args, ' ', 4)
        else
            kind = 'buff'
        end
        if typed == '' then
            msg('Use: /pb hide <buff>, /pb hide recast <name>  or  /pb hide debuff <name>')
            return
        end
        local n = typed
        if kind == 'buff' then
            n = find_name(typed)
        elseif kind == 'recast' then
            for r, _ in pairs(config.seenRecast) do
                if r:lower() == typed:lower() then n = r end
            end
        else
            -- Match the name as shown in the Debuffs tab (any job).
            if catalog == nil then build_catalog() end
            for job = 1, #JOB_NAMES do
                for d, _ in pairs(catalog[job].debuffs) do
                    if d:lower() == typed:lower() then n = d end
                end
            end
        end
        local tbl = (kind == 'recast' and config.hiddenRecast)
                 or (kind == 'debuff' and config.hiddenDebuffs) or config.hidden
        tbl[n] = (cmd == 'hide') or nil
        settings.save()
        msg((cmd == 'hide' and 'Hidden: ' or 'Showing: ') .. n
            .. ((kind ~= 'buff') and (' (' .. kind .. ')') or ''))
        return
    end

    -- /pb preset save|load|delete <name>, /pb preset list
    if cmd == 'preset' or cmd == 'presets' then
        local sub  = (args[3] or 'list'):lower()
        local name = args[4] or ''
        if sub == 'save' then
            local ok, res = files.preset_save(name)
            msg(ok and ('Saved what is hidden as preset "' .. res .. '".') or res)
        elseif sub == 'load' then
            local ok, res = files.preset_load(name)
            msg(ok and ('Loaded preset "' .. res .. '".') or res)
        elseif sub == 'delete' then
            files.preset_delete(name)
            msg('Deleted preset "' .. files.profile_clean(name) .. '".')
        else
            local list = files.preset_list()
            msg(#list == 0 and 'No presets yet. /pb preset save <name>'
                or ('Presets: ' .. table.concat(list, ', ')))
        end
        return
    end

    -- /pb theme lists themes; /pb theme <name> picks one.
    if cmd == 'theme' then
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
            ui.selFamily = 'Custom'
            msg('Theme: ' .. c.name)
            return
        end
        local th = find_theme(rest)
        if th == nil then
            msg('No theme called "' .. rest .. '". Type /pb theme to see the list.')
            return
        end
        use_theme(th.name)
        ui.selFamily = family_of(th.name)
        msg('Theme: ' .. th.name)
        return
    end

    if cmd == 'list' then
        local names = T{}
        for n, v in pairs(config.hidden) do
            if v then names:append(n) end
        end
        for g, v in pairs(config.hiddenGroups) do
            if v then names:append(g .. ' (group)') end
        end
        for n, v in pairs(config.hiddenRecast) do
            if v then names:append(n .. ' (recast)') end
        end
        for g, v in pairs(config.hiddenRecastGroups) do
            if v then names:append(g .. ' (recast group)') end
        end
        for n, v in pairs(config.hiddenDebuffs) do
            if v then names:append(n .. ' (debuff)') end
        end
        for g, v in pairs(config.hiddenDebuffGroups) do
            if v then names:append(g .. ' (debuff group)') end
        end
        table.sort(names)
        if #names == 0 then
            msg('Nothing is hidden.')
        else
            msg('Hidden: ' .. table.concat(names, ', '))
        end
        return
    end

    msg('Commands: /pb (settings window), /pb test (on/off), /pb party (on/off), /pb debuffs (on/off), /pb lock (click-through on/off), /pb clear, /pb hide <buff>, /pb show <buff>, /pb hide recast <name>, /pb show recast <name>, /pb hide debuff <name>, /pb show debuff <name>, /pb list, /pb preset save|load|delete|list [name], /pb theme [name], /pb profile save|load|delete|list [name], /pb debug')
end)

ashita.events.register('unload', 'pb_unload', function ()
    settings.save()
end)
