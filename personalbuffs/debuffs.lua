----------------------------------------------------------------------
-- debuffs.lua: debuffs you (and your party) put on mobs, for
-- PersonalBuffs' Debuff box. Kept in its own file because Lua allows
-- only 200 locals in the main file.
----------------------------------------------------------------------
require('common')

local M = {}

-- Helpers from personalbuffs.lua, set with M.setup().
local H = {}
function M.setup(h) H = h end
local function dlog(text) H.dlog(text) end
local function mmss(sec) return H.mmss(sec) end
local function is_player(id) return H.is_player(id) end
local function is_trust(id, spell) return H.is_trust(id, spell) end
local function spell_group(spell) return H.spell_group(spell) end

----------------------------------------------------------------------
-- Debuffs on mobs (packets 0x028 and 0x029)
--
-- Same rules kazenoeye uses (it tracks well on HorizonXI):
--   * A debuff starts when your action lands on a mob (0x028). Its time
--     comes from the tables below (fixed base times, no gear).
--   * It ends early when the game says so (0x029 "wears off", or the mob
--     dies), or when an action removes it (0x028 dispel messages).
--   * Everything is cleared when you zone.
-- Party members' debuffs are tracked only when the party switch is on.
-- Only mobs: never players, and never your own / your party's pets.
----------------------------------------------------------------------
local DEBUFF_KEEP = 3   -- seconds a debuff stays at 0:00 (same as kazenoeye)

-- Message IDs (LandSandBoat msg enum).
local MSG_ON    = { [101] = true, [127] = true, [160] = true, [164] = true, [166] = true, [186] = true,
                    [194] = true, [203] = true, [205] = true, [230] = true, [236] = true, [237] = true,
                    [266] = true, [267] = true, [268] = true, [269] = true, [271] = true, [272] = true,
                    [277] = true, [278] = true, [279] = true, [280] = true, [319] = true, [320] = true,
                    [375] = true, [412] = true, [645] = true, [754] = true, [755] = true, [804] = true }
local MSG_OFF   = { [64] = true, [159] = true, [168] = true, [204] = true, [206] = true, [321] = true,
                    [322] = true, [341] = true, [342] = true, [343] = true, [344] = true, [350] = true,
                    [378] = true, [531] = true, [647] = true, [805] = true, [806] = true }
local MSG_DEATH = { [6] = true, [20] = true, [97] = true, [113] = true, [406] = true, [605] = true, [646] = true }
local MSG_SPELL_DMG = { [2] = true, [252] = true, [264] = true, [265] = true }
local MSG_PET   = { [185] = true, [186] = true, [242] = true, [243] = true, [264] = true, [277] = true }
local MSG_PACT  = { [144] = true, [317] = true, [320] = true }
local MSG_PROC  = { [160] = true, [164] = true }

-- Effect IDs used below.
local FX_SLEEP, FX_SLEEP2, FX_LULLABY = 2, 19, 193
local FX_STUN, FX_DIA, FX_BIO, FX_HELIX = 10, 134, 135, 186

-- Spells: [spell ID] = { secs, fx = effect (if not the one the game reports),
--                        fxs = several effects, clears = effects it replaces }
local DB_SPELLS = {
    -- Dia / Bio (they land with a damage message; see M.handle_action)
    [23]  = { 60 },  [24] = { 120 }, [25] = { 150 }, [33] = { 60 },   -- Dia, II, III, Diaga
    [230] = { 60 }, [231] = { 120 }, [232] = { 75 },                  -- Bio, II, III
    -- Paralyze, Slow, Gravity, Blind, Silence
    [58]  = { 120 }, [80] = { 120 }, [56] = { 180 }, [79] = { 180 },
    [216] = { 120 }, [254] = { 180 }, [276] = { 180 }, [59] = { 120 }, [359] = { 120 },
    -- Sleep, Sleepga (I), Sleep II / Sleepga II (replace Sleep)
    [253] = { 60 }, [273] = { 60 }, [363] = { 60 },
    [259] = { 90, fx = FX_SLEEP2, clears = { FX_SLEEP, FX_LULLABY } },
    [274] = { 90, fx = FX_SLEEP2, clears = { FX_SLEEP, FX_LULLABY } },
    [364] = { 90, fx = FX_SLEEP2, clears = { FX_SLEEP, FX_LULLABY } },
    -- Bind, Bindga, Stun, Poison, Poison II
    [258] = { 60 }, [362] = { 60 }, [252] = { 5 }, [220] = { 90 }, [221] = { 120 },
    -- Ninjutsu: Kurayami, Hojo, Dokumori (Ichi / Ni)
    [341] = { 180 }, [344] = { 180 }, [347] = { 180 },
    [342] = { 300 }, [345] = { 300 }, [348] = { 300 },
    -- Burn, Frost, Choke, Rasp, Shock, Drown
    [235] = { 120 }, [236] = { 120 }, [237] = { 120 }, [238] = { 120 }, [239] = { 120 }, [240] = { 120 },
    -- Threnodies
    [454] = { 78 }, [455] = { 78 }, [456] = { 78 }, [457] = { 78 },
    [458] = { 78 }, [459] = { 78 }, [460] = { 78 }, [461] = { 78 },
    -- Battlefield / Carnage Elegy, Foe / Horde Lullaby
    [421] = { 216 }, [422] = { 216 }, [376] = { 30 }, [463] = { 30 },
    [321] = { 60 },
    -- Blue magic
    [513] = { 60, fx = 3 },   -- Venom Shell
    [515] = { 60, fx = 136 }, -- Maelstrom
    [524] = { 60, fx = 146 }, -- Sandspin
    [531] = { 30, fx = 11 },  -- Ice Break
    [532] = { 5, fx = 10 },   -- Blitzstrahl
    [534] = { 120, fx = 12 }, -- Mysterious Light
    [535] = { 60, fx = 129 }, -- Cold Wave
    [536] = { 60, fx = 3 },   -- Poison Breath
    [537] = { 60, fx = 138 }, -- Stinking Gas
    [539] = { 60, fx = 147 }, -- Terror Touch
    [548] = { 90, fx = 13 },  -- Filamented Hold
    [555] = { 60, fx = 12 },  -- Magnetite Cloud
    [561] = { 180, fx = 149 },-- Frightful Roar
    [563] = { 60, fx = 5 },   -- Hecatomb Wave
    [565] = { 90, fxs = { 6, 13 } },  -- Radiant Breath
    [572] = { 30, fx = 140 }, -- Sound Blast
    [575] = { 5, fx = 28 },   -- Jettatura
    [576] = { 80, fx = 2 },   -- Yawn
    [582] = { 120, fx = 6 },  -- Chaotic Eye
    [584] = { 60, fx = 2 },   -- Sheep Song
    [588] = { 60, fx = 31 },  -- Lowing
    [596] = { 90, fx = 2 },   -- Pinecone Bomb
    [597] = { 180, fx = 13 }, -- Sprout Smack
    [598] = { 90, fx = 2 },   -- Soporific
    [599] = { 180, fx = 3 },  -- Queasyshroom
    [603] = { 60, fx = 138 }, -- Wild Oats
    [604] = { 60, fxs = { 4, 6, 3, 12, 11, 13, 5 } },  -- Bad Breath
    [606] = { 30, fx = 136 }, -- Awful Eye
    [608] = { 60, fx = 4 },   -- Frost Breath
    [610] = { 60, fx = 148 }, -- Infrasonics
    [611] = { 180, fx = 3 },  -- Disseverment
    [612] = { 12, fx = 156 }, -- Actinic Burst
    [616] = { 5, fx = 10 },   -- Temporal Shift
    [618] = { 60, fx = 11 },  -- Blastbomb
    [620] = { 60, fx = 137 }, -- Battle Dance
    [621] = { 120, fx = 5 },  -- Sandspray
    [623] = { 5, fx = 10 },   -- Head Butt
    [628] = { 5, fx = 10 },   -- Frypan
    [631] = { 180, fx = 171 },-- Hydro Shot
    [633] = { 30, fxs = { 149, 167 } },  -- Enervation
    [634] = { 30, fxs = { 5, 11 } },     -- Light of Penance
    [638] = { 90, fx = 3 },   -- Feather Storm
    [640] = { 5, fx = 10 },   -- Tail Slap
    [644] = { 90, fx = 4 },   -- Mind Blast
    [648] = { 60, fx = 11 },  -- Regurgitation
    [650] = { 120, fx = 147 },-- Seedspray
    [651] = { 90, fxs = { 147, 149 } },  -- Corrosive Ooze
    [652] = { 60, fx = 146 }, -- Spiral Spin
    [654] = { 180, fx = 4 },  -- Sub-zero Smash
}
-- Helix spells (278-285, 885-892) all put the same Helix effect on.
for id = 278, 285 do DB_SPELLS[id] = { 90, fx = FX_HELIX } end
for id = 885, 892 do DB_SPELLS[id] = { 90, fx = FX_HELIX } end
local DIA = { [23] = true, [24] = true, [25] = true, [33] = true }
local BIO = { [230] = true, [231] = true, [232] = true }

-- Weapon skills: [WS ID] = { secs, fx } or { secs, fxs = { ... } }
local DB_WS = {
    [181] = { 180, fx = 149, n = 'Shell Crusher' },  -- Shell Crusher (Defense Down)
    [83]  = { 180, fx = 149, n = 'Armor Break' },  -- Armor Break
    [87]  = { 180, fxs = { 149, 147 }, n = 'Full Break' },  -- Full Break (Defense + Attack Down)
    [155] = { 180, fx = 149, n = 'Tachi: Ageha' },  -- Tachi: Ageha
    [187] = { 180, fx = 149, n = 'Garland of Bliss' },  -- Garland of Bliss
    [89]  = { 180, fx = 149, n = 'Metatron Torment' },  -- Metatron Torment
    [85]  = { 180, fx = 147, n = 'Weapon Break' },  -- Weapon Break (Attack Down)
    [185] = { 180, fx = 147, n = 'Gate of Tartarus' },  -- Gate of Tartarus
    [107] = { 180, fx = 147, n = 'Infernal Scythe' },  -- Infernal Scythe
    [16]  = { 90, fx = 3, n = 'Wasp Sting' },     -- Wasp Sting (Poison)
    [17]  = { 90, fx = 3, n = 'Viper Bite' },     -- Viper Bite
    [18]  = { 30, fx = 11, n = 'Shadowstitch' },    -- Shadowstitch (Bind)
    [35]  = { 5, fx = 10, n = 'Flat Blade' },     -- Flat Blade (Stun)
    [115] = { 5, fx = 10, n = 'Leg Sweep' },     -- Leg Sweep
    [2]   = { 5, fx = 10, n = 'Shoulder Tackle' },     -- Shoulder Tackle
    [65]  = { 5, fx = 10, n = 'Smash Axe' },     -- Smash Axe
    [162] = { 5, fx = 10, n = 'Brainshaker' },     -- Brainshaker
    [145] = { 5, fx = 10, n = 'Tachi: Hobaku' },     -- Tachi: Hobaku
    [80]  = { 180, fx = 148, n = 'Shield Break' },  -- Shield Break (Evasion Down)
    [73]  = { 120, fx = 146, n = 'Onslaught' },  -- Onslaught (Accuracy Down)
    [170] = { 120, fx = 148, n = 'Randgrith' },  -- Randgrith
    [22]  = { 210, fx = 13, n = 'Energy Drain' },   -- Energy Drain (Slow)
}

-- Shield Bash / Weapon Bash land as a category 3 action (Stun).
local DB_BASH = { [46] = 'Shield Bash', [77] = 'Weapon Bash' }

-- Job abilities that land with message 127: [ability ID] = { secs, fx }
local DB_JA = {
    [131] = { 60, fx = FX_SLEEP, n = 'Light Shot' },
}

-- Avatar blood pacts: [ID] = { secs, fx } / { secs, fxs }
local DB_PACTS = {
    [513] = { 90, fx = 3, n = 'Poison Nails' },    -- Poison Nails
    [560] = { 60, fx = 13, n = 'Rock Throw' },   -- Rock Throw
    [562] = { 60, fx = 11, n = 'Rock Buster' },   -- Rock Buster
    [563] = { 120, fx = 13, n = 'Megalith Throw' },  -- Megalith Throw
    [566] = { 60, fx = 11, n = 'Mountain Buster' },   -- Mountain Buster
    [578] = { 60, fx = 12, n = 'Tail Whip' },   -- Tail Whip
    [624] = { 12, fx = 10, n = 'Shock Strike' },   -- Shock Strike
    [627] = { 60, fx = 4, n = 'Thunderspark' },    -- Thunderspark
    [630] = { 12, fx = 10, n = 'Chaotic Strike' },   -- Chaotic Strike
    [528] = { 60, fx = 5, n = 'Moonlit Charge' },    -- Moonlit Charge
    [529] = { 60, fx = 4, n = 'Crescent Fang' },    -- Crescent Fang
    [530] = { 180, fxs = { 146, 148 }, n = 'Lunar Cry' },  -- Lunar Cry
    [611] = { 90, fx = 2, n = 'Sleepga (avatar)' },    -- Sleepga (avatar)
}
local PACT_NIGHTMARE = 1908    -- Nightmare: Sleep, 60s

-- Jug pet Ready moves and automaton attacks (category 11): [ID] = { secs, fx }
local DB_PETS = {
    [3841] = { 120, fx = 5, n = 'Dust Cloud' },   -- Dust Cloud
    [3860] = { 30, fx = 2, n = 'Sheep Song' },    -- Sheep Song
    [3848] = { 120, fx = 4, n = 'Roar' },   -- Roar
    [3843] = { 4, fx = 10, n = 'Head Butt' },    -- Head Butt
    [3844] = { 30, fx = 2, n = 'Dream Flower' },    -- Dream Flower
    [3845] = { 112, fx = 138, n = 'Wild Oats' }, -- Wild Oats
    [3846] = { 18, fx = 3, n = 'Leaf Dagger' },    -- Leaf Dagger
    [3847] = { 35, fx = 141, n = 'Scream' },  -- Scream
    [660]  = { 60, fx = 3, n = 'Venom' },    -- Venom
    [3851] = { 4, fx = 10, n = 'Tail Blow' },    -- Tail Blow
    [3855] = { 120, fx = 148, n = 'Infrasonics' }, -- Infrasonics
    [3854] = { 30, fx = 6, n = 'Brain Crush' },    -- Brain Crush
    [3876] = { 120, fx = 148, n = 'High-Frequency Field' }, -- High-Frequency Field
    [3879] = { 35, fx = 136, n = 'Spoil' },  -- Spoil
    [3861] = { 100, fx = 136, n = 'Bubble Shower' }, -- Bubble Shower
    [3886] = { 30, fx = 2, n = 'Soporific' },    -- Soporific
    [3887] = { 180, fx = 13, n = 'Gloeosuccus' },  -- Gloeosuccus
    [3888] = { 60, fx = 4, n = 'Palsy Pollen' },    -- Palsy Pollen
    [3890] = { 5, fx = 10, n = 'Numbing Noise' },    -- Numbing Noise
    [3893] = { 30, fx = 3, n = 'Toxic Spit' },    -- Toxic Spit
    [3882] = { 180, fx = 5, n = 'Sandblast' },   -- Sandblast
    [3883] = { 60, fx = 11, n = 'Sandpit' },   -- Sandpit
    [3884] = { 120, fx = 3, n = 'Venom Spray' },   -- Venom Spray
    [3896] = { 120, fx = 13, n = 'Filamented Hold' },  -- Filamented Hold
    [3869] = { 180, fx = 4, n = 'Spore' },   -- Spore
    [3870] = { 60, fx = 3, n = 'Queasyshroom' },    -- Queasyshroom
    [3871] = { 180, fx = 4, n = 'Numbshroom' },   -- Numbshroom
    [3873] = { 50, fx = 6, n = 'Silence Gas' },    -- Silence Gas
    [3874] = { 90, fx = 5, n = 'Dark Spore' },    -- Dark Spore
    -- Automaton
    [2067] = { 30, fx = 148, n = 'Knockout' },  -- Knockout
    [2299] = { 4, fx = 10, n = 'Bone Crusher' },    -- Bone Crusher
    [2066] = { 4, fx = 10, n = 'Daze' },    -- Daze
}

-- Automaton attacks (in DB_PETS), listed under PUP in the menu.
local DB_AUTOMATON = { [2067] = true, [2299] = true, [2066] = true }

-- Debuff groups in the menu and for hiding, in display order.
local DEBUFF_GROUPS = T{ 'White Magic', 'Black Magic', 'Songs', 'Ninjutsu', 'Blue Magic',
                         'Weapon Skills', 'Abilities', 'Pets', 'Other' }
local DEBUFF_PROCS = 'Weapon procs'    -- name for all additional effects
local DEBUFF_OTHER = 'Other effects'   -- name for anything not listed

-- Weapon procs (additional effects): [effect ID] = secs. Others get 30s.
local DB_PROCS = { [2] = 25, [149] = 60, [12] = 30, [6] = 60, [10] = 5, [3] = 30 }

-- State: [mob server ID] = { name, index, fx = { [effect ID] = { label, exp, dur, caster, key, group } } }
-- key / group = what to hide it by: the spell, weapon skill, ability or pet move that put it on.
M.mobs = T{}
M.zone = nil

local function effect_name(id)
    local ok, n = pcall(function () return AshitaCore:GetResourceManager():GetString('buffs.names', id) end)
    if ok and n ~= nil and n ~= '' then return n end
    return 'Effect ' .. tostring(id)
end

-- Name and entity index of a mob. A mob's index is the low 12 bits of its ID.
local function mob_info(serverId)
    local ent = AshitaCore:GetMemoryManager():GetEntity()
    local idx = bit.band(serverId, 0xFFF)
    if ent:GetServerId(idx) == serverId then
        local n = ent:GetName(idx)
        if n ~= nil and n ~= '' then return n, idx end
    end
    for i = 0, 2303 do
        if ent:GetServerId(i) == serverId then return ent:GetName(i) or 'Mob', i end
    end
    return 'Mob', nil
end

-- Who did the action: you (or your pet), a party member (or their pet),
-- or someone we don't track. Returns ok, caster (nil = you), pets.
-- pets = server IDs of your party's pets (they're never debuff targets).
local function debuff_actor(actor)
    local mm    = AshitaCore:GetMemoryManager()
    local party = mm:GetParty()
    local ent   = mm:GetEntity()
    local pets  = {}
    local ok, caster = false, nil
    for i = 0, 5 do
        if party:GetMemberIsActive(i) == 1 then
            local sid = party:GetMemberServerId(i)
            local pet = nil
            local idx = party:GetMemberTargetIndex(i)
            if idx ~= nil and idx > 0 then
                local pi = ent:GetPetTargetIndex(idx)
                if pi ~= nil and pi > 0 then
                    pet = ent:GetServerId(pi)
                    if pet ~= nil and pet ~= 0 then pets[pet] = true end
                end
            end
            if sid == actor or (pet ~= nil and pet == actor) then
                if i == 0 then
                    ok, caster = true, nil
                elseif H.cfg().party.enabled and is_player(sid) then   -- never Trusts
                    ok, caster = true, party:GetMemberName(i)
                end
            end
        end
    end
    return ok, caster, pets
end

local function debuff_clear(mobId, fx, why)
    local mob = M.mobs[mobId]
    if mob == nil or mob.fx[fx] == nil then return end
    dlog(mob.fx[fx].label .. ' on ' .. mob.name .. ': ' .. why)
    mob.fx[fx] = nil
end

function M.handle_action(e)
    local data    = e.data_raw
    local maxBits = e.size * 8
    local function u(pos, len)
        if pos + len > maxBits then error('short packet') end
        return ashita.bits.unpack_be(data, 0, pos, len)
    end

    local actor  = u(40, 32)
    local tcount = u(72, 6)
    local cat    = u(82, 4)
    if cat == 7 or cat == 8 or cat == 9 or cat == 12 then return end   -- "starts casting" etc.
    local param  = u(86, 32)

    -- Read every target / result, with the additional effect (procs).
    local results = T{}
    local pos = 150
    for _ = 1, tcount do
        local tid    = u(pos, 32); pos = pos + 32
        local acount = u(pos, 4);  pos = pos + 4
        for _ = 1, acount do
            local r = { tid = tid, value = u(pos + 27, 17), msg = u(pos + 44, 10) }
            pos = pos + 85
            if u(pos, 1) == 1 then
                r.aeParam = u(pos + 1 + 10, 17)
                r.aeMsg   = u(pos + 1 + 27, 10)
                pos = pos + 1 + 37
            else
                pos = pos + 1
            end
            if u(pos, 1) == 1 then pos = pos + 1 + 34 else pos = pos + 1 end
            results:append(r)
        end
    end

    local ok, caster, pets = debuff_actor(actor)

    -- Not ours: only listen for debuffs being removed from mobs we track.
    if not ok then
        for _, r in ipairs(results) do
            if MSG_OFF[r.msg] then debuff_clear(r.tid, r.value, 'removed') end
        end
        return
    end

    local rm   = AshitaCore:GetResourceManager()
    local now  = os.time()
    local spellName = nil
    -- What put the debuff on (for hiding): name and menu group.
    local srcKey, srcGroup = DEBUFF_OTHER, 'Other'
    if cat == 4 then
        local sp = rm:GetSpellById(param)
        if sp == nil or is_trust(param, sp) then return end
        spellName = sp.Name[1]
        srcKey, srcGroup = spellName, spell_group(sp)
    elseif cat == 3 and DB_WS[param] then
        srcKey, srcGroup = DB_WS[param].n, 'Weapon Skills'
    elseif cat == 3 and DB_BASH[param] then
        srcKey, srcGroup = DB_BASH[param], 'Abilities'
    elseif cat == 6 then
        local ab = rm:GetAbilityById(param + 512)
        if DB_JA[param] then
            srcKey, srcGroup = DB_JA[param].n, 'Abilities'
        elseif ab ~= nil and ab.Name[1] ~= nil and ab.Name[1] ~= '' then
            srcKey, srcGroup = ab.Name[1], 'Abilities'
        end
    elseif cat == 13 and param == PACT_NIGHTMARE then
        srcKey, srcGroup = 'Nightmare', 'Pets'
    elseif cat == 13 and DB_PACTS[param] then
        srcKey, srcGroup = DB_PACTS[param].n, 'Pets'
    elseif cat == 11 and DB_PETS[param] then
        srcKey, srcGroup = DB_PETS[param].n, 'Pets'
    end

    local touched = {}   -- debuffs set by this action (to spot AoE)

    -- One result on one target.
    local function one(r)
        if r.tid == actor or is_player(r.tid) or pets[r.tid] then return end

        local function active(fx)
            local mob = M.mobs[r.tid]
            local d = mob and mob.fx[fx]
            return d ~= nil and d.exp >= now
        end
        local function set(fx, secs, label, key, group)
            if fx == nil or fx <= 0 then return end
            local mob = M.mobs[r.tid]
            if mob == nil then
                local n, idx = mob_info(r.tid)
                mob = { name = n, index = idx, fx = T{} }
                M.mobs[r.tid] = mob
            end
            label = label or effect_name(fx)
            local rec = { label = label, exp = now + secs, dur = secs, caster = caster,
                          key = key or srcKey, group = group or srcGroup }
            mob.fx[fx] = rec
            touched[#touched + 1] = { mob = r.tid, fx = fx, rec = rec }
            dlog(label .. ' on ' .. mob.name .. ': ' .. mmss(secs))
        end
        local function set_all(d, label)
            if d.fxs ~= nil then
                for _, fx in ipairs(d.fxs) do set(fx, d[1], nil) end
            else
                set(d.fx, d[1] or 180, label)
            end
        end

        local msg = r.msg
        if cat == 13 and param == PACT_NIGHTMARE then
            set(FX_SLEEP, 60, nil)
        elseif cat == 11 and DB_PETS[param] then
            if not MSG_PET[msg] then return end
            local d = DB_PETS[param]
            -- A damage hit doesn't refresh a debuff that's still on.
            if msg == 185 and active(d.fx) then return end
            set_all(d, nil)
        elseif cat == 3 and (msg == 185 or msg == 277) then
            local d = DB_WS[param]
            if d ~= nil then set_all(d, nil) end
        elseif cat == 4 and param >= 515 and param <= 753 and DB_SPELLS[param] then
            -- Blue magic: lands with a damage message (or 236).
            if not (MSG_SPELL_DMG[msg] or msg == 236) then return end
            local d = DB_SPELLS[param]
            if d.fx ~= nil and active(d.fx) then return end
            set_all(d, d.fx ~= nil and spellName or nil)
        elseif cat == 4 and MSG_SPELL_DMG[msg] then
            -- Dia / Bio / Helix land with a damage message.
            -- Dia and Bio don't stack: a new one only lands if neither is on.
            local d = DB_SPELLS[param]
            if d == nil then return end
            if DIA[param] or BIO[param] then
                if not active(FX_DIA) and not active(FX_BIO) then
                    set(DIA[param] and FX_DIA or FX_BIO, d[1], spellName)
                end
            elseif d.fx == FX_HELIX then
                set(FX_HELIX, d[1], spellName)
            end
        elseif cat == 3 and DB_BASH[param] then
            if not active(FX_STUN) then set(FX_STUN, 6, nil) end
        elseif cat == 6 and DB_JA[param] then
            if msg == 127 then set(DB_JA[param].fx, DB_JA[param][1], nil) end
        elseif cat == 13 and DB_PACTS[param] then
            if not MSG_PACT[msg] then return end
            local d = DB_PACTS[param]
            if d.fx ~= nil and active(d.fx) then return end
            set_all(d, nil)
        elseif MSG_ON[msg] then
            -- Any other "is afflicted with ..." result. The effect is in the result.
            local d = nil
            if cat == 4 then d = DB_SPELLS[param] elseif cat == 13 then d = DB_PACTS[param] end
            if d ~= nil then
                for _, fx in ipairs(d.clears or {}) do debuff_clear(r.tid, fx, 'replaced') end
                set(d.fx or r.value, d[1], spellName)
            else
                -- Unknown debuff: 5 minutes (same as kazenoeye).
                set(r.value, 300, spellName)
            end
        elseif MSG_OFF[msg] then
            debuff_clear(r.tid, r.value, 'removed')
        elseif r.aeMsg ~= nil and MSG_PROC[r.aeMsg] then
            set(r.aeParam, DB_PROCS[r.aeParam] or 30, nil, DEBUFF_PROCS, 'Other')
        end
    end

    for _, r in ipairs(results) do one(r) end

    -- AoE: the same debuff landing on 2 or more mobs in one action is
    -- marked so the box shows it as one row for the spell, not per mob.
    local mobsPer = {}
    for _, t in ipairs(touched) do
        local k = t.rec.label .. '|' .. t.fx
        mobsPer[k] = mobsPer[k] or {}
        mobsPer[k][t.mob] = true
    end
    for _, t in ipairs(touched) do
        local n = 0
        for _ in pairs(mobsPer[t.rec.label .. '|' .. t.fx]) do n = n + 1 end
        t.rec.aoe = n >= 2 or nil
    end
end

-- Packet 0x029: "wears off" and "defeated" messages.
-- Little-endian number of n bytes at offset off (0-based) in the packet.
local function le(d, off, n)
    local v = 0
    for i = n, 1, -1 do v = v * 256 + d:byte(off + i) end
    return v
end

function M.handle_message(e)
    local d = e.data
    if #d < 0x1A then return end
    local target = le(d, 0x08, 4)
    local p1     = le(d, 0x0C, 4)
    local p2     = le(d, 0x10, 4)
    local m      = bit.band(le(d, 0x18, 2), 0x7FFF)
    local mob    = M.mobs[target]
    if mob == nil then return end

    if MSG_DEATH[m] then
        dlog(mob.name .. ' defeated: debuffs cleared')
        M.mobs[target] = nil
    elseif m == 321 then
        debuff_clear(target, p2, 'wore off')
    elseif MSG_OFF[m] then
        if p1 == FX_SLEEP then
            -- Sleep, Sleep II and Lullaby all wake up together.
            debuff_clear(target, FX_SLEEP, 'wore off')
            debuff_clear(target, FX_LULLABY, 'wore off')
            debuff_clear(target, FX_SLEEP2, 'wore off')
        else
            debuff_clear(target, p1, 'wore off')
        end
    end
end

-- Clears everything on zoning; drops mobs that despawned or died, and
-- debuffs a few seconds after they run out.
function M.prune(now)
    local mm = AshitaCore:GetMemoryManager()
    local okZ, zone = pcall(function () return mm:GetParty():GetMemberZone(0) end)
    if okZ and zone ~= M.zone then
        M.zone = zone
        M.mobs = T{}
        return
    end
    local ent = mm:GetEntity()
    for id, mob in pairs(M.mobs) do
        local gone = false
        if mob.index ~= nil then
            gone = ent:GetServerId(mob.index) ~= id or ent:GetHPPercent(mob.index) == 0
        end
        if not gone then
            for fx, d in pairs(mob.fx) do
                if now > d.exp + DEBUFF_KEEP then mob.fx[fx] = nil end
            end
            gone = next(mob.fx) == nil
        end
        if gone then M.mobs[id] = nil end
    end
end

-- Used by personalbuffs.lua (menu lists and hiding).
M.SPELLS, M.WS, M.BASH, M.JA, M.PACTS, M.PETS = DB_SPELLS, DB_WS, DB_BASH, DB_JA, DB_PACTS, DB_PETS
M.AUTOMATON, M.GROUPS, M.PROCS, M.OTHER = DB_AUTOMATON, DEBUFF_GROUPS, DEBUFF_PROCS, DEBUFF_OTHER

return M
