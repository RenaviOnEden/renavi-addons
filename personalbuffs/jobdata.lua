-- Which jobs get each spell / ability (level 75 cap + merit spells).
-- Built from LandSandBoat spell_list.sql and abilities.sql.
return {
    spells = {
        [1] = { jobs = { [3]=1, [5]=3, [7]=5, [20]=5 }, buff = false }, -- cure
        [2] = { jobs = { [3]=11, [5]=14, [7]=17, [20]=17 }, buff = false }, -- cure_ii
        [3] = { jobs = { [3]=21, [5]=26, [7]=30, [20]=30 }, buff = false }, -- cure_iii
        [4] = { jobs = { [3]=41, [5]=48, [7]=55, [20]=55 }, buff = false }, -- cure_iv
        [5] = { jobs = { [3]=61 }, buff = false }, -- cure_v
        [7] = { jobs = { [3]=16 }, buff = false }, -- curaga
        [8] = { jobs = { [3]=31 }, buff = false }, -- curaga_ii
        [9] = { jobs = { [3]=51 }, buff = false }, -- curaga_iii
        [10] = { jobs = { [3]=71 }, buff = false }, -- curaga_iv
        [12] = { jobs = { [3]=25, [5]=38, [7]=50, [20]=35 }, buff = false }, -- raise
        [13] = { jobs = { [3]=56, [20]=70 }, buff = false }, -- raise_ii
        [14] = { jobs = { [3]=6, [20]=10 }, buff = false }, -- poisona
        [15] = { jobs = { [3]=9, [20]=12 }, buff = false }, -- paralyna
        [16] = { jobs = { [3]=14, [20]=17 }, buff = false }, -- blindna
        [17] = { jobs = { [3]=19, [20]=22 }, buff = false }, -- silena
        [18] = { jobs = { [3]=39, [20]=50 }, buff = false }, -- stona
        [19] = { jobs = { [3]=34, [20]=46 }, buff = false }, -- viruna
        [20] = { jobs = { [3]=29, [20]=32 }, buff = false }, -- cursna
        [21] = { jobs = { [3]=50, [7]=55 }, buff = false }, -- holy
        [23] = { jobs = { [3]=3, [5]=1 }, buff = false }, -- dia
        [24] = { jobs = { [3]=36, [5]=31 }, buff = false }, -- dia_ii
        [25] = { jobs = { [5]=75 }, buff = false }, -- dia_iii
        [28] = { jobs = { [3]=5, [7]=7 }, buff = false }, -- banish
        [29] = { jobs = { [3]=30, [7]=34 }, buff = false }, -- banish_ii
        [30] = { jobs = { [3]=65 }, buff = false }, -- banish_iii
        [33] = { jobs = { [3]=18, [5]=15 }, buff = false }, -- diaga
        [34] = { jobs = { [3]=18, [5]=15 }, buff = false }, -- diaga_ii
        [38] = { jobs = { [3]=15, [7]=30 }, buff = false }, -- banishga
        [39] = { jobs = { [3]=40 }, buff = false }, -- banishga_ii
        [43] = { jobs = { [3]=7, [5]=7, [7]=10, [20]=10, [22]=20 }, buff = true }, -- protect
        [44] = { jobs = { [3]=27, [5]=27, [7]=30, [20]=30, [22]=40 }, buff = true }, -- protect_ii
        [45] = { jobs = { [3]=47, [5]=47, [7]=50, [20]=50, [22]=60 }, buff = true }, -- protect_iii
        [46] = { jobs = { [3]=63, [5]=63, [7]=70, [20]=66 }, buff = true }, -- protect_iv
        [48] = { jobs = { [3]=17, [5]=17, [7]=20, [20]=20, [22]=10 }, buff = true }, -- shell
        [49] = { jobs = { [3]=37, [5]=37, [7]=40, [20]=40, [22]=30 }, buff = true }, -- shell_ii
        [50] = { jobs = { [3]=57, [5]=57, [7]=60, [20]=60, [22]=50 }, buff = true }, -- shell_iii
        [51] = { jobs = { [3]=68, [5]=68, [20]=71, [22]=70 }, buff = true }, -- shell_iv
        [53] = { jobs = { [3]=19, [5]=23, [20]=29, [22]=35 }, buff = true }, -- blink
        [54] = { jobs = { [3]=28, [5]=34, [20]=44, [22]=55 }, buff = true }, -- stoneskin
        [55] = { jobs = { [3]=10, [5]=12, [20]=13, [22]=15 }, buff = true }, -- aquaveil
        [56] = { jobs = { [3]=13, [5]=13 }, buff = false }, -- slow
        [57] = { jobs = { [3]=40, [5]=48 }, buff = true }, -- haste
        [58] = { jobs = { [3]=4, [5]=6 }, buff = false }, -- paralyze
        [59] = { jobs = { [3]=15, [5]=18 }, buff = false }, -- silence
        [60] = { jobs = { [5]=17, [22]=16 }, buff = true }, -- barfire
        [61] = { jobs = { [5]=21, [22]=20 }, buff = true }, -- barblizzard
        [62] = { jobs = { [5]=13, [22]=12 }, buff = true }, -- baraero
        [63] = { jobs = { [5]=5, [22]=4 }, buff = true }, -- barstone
        [64] = { jobs = { [5]=25, [22]=24 }, buff = true }, -- barthunder
        [65] = { jobs = { [5]=9, [22]=8 }, buff = true }, -- barwater
        [66] = { jobs = { [3]=17 }, buff = true }, -- barfira
        [67] = { jobs = { [3]=21 }, buff = true }, -- barblizzara
        [68] = { jobs = { [3]=13 }, buff = true }, -- baraera
        [69] = { jobs = { [3]=5 }, buff = true }, -- barstonra
        [70] = { jobs = { [3]=25 }, buff = true }, -- barthundra
        [71] = { jobs = { [3]=9 }, buff = true }, -- barwatera
        [72] = { jobs = { [5]=7, [22]=6 }, buff = true }, -- barsleep
        [73] = { jobs = { [5]=10, [22]=9 }, buff = true }, -- barpoison
        [74] = { jobs = { [5]=12, [22]=11 }, buff = true }, -- barparalyze
        [75] = { jobs = { [5]=18, [22]=17 }, buff = true }, -- barblind
        [76] = { jobs = { [5]=23, [22]=22 }, buff = true }, -- barsilence
        [77] = { jobs = { [5]=43, [22]=42 }, buff = true }, -- barpetrify
        [78] = { jobs = { [5]=39, [22]=38 }, buff = true }, -- barvirus
        [79] = { jobs = { [5]=75 }, buff = false }, -- slow_ii
        [80] = { jobs = { [5]=75 }, buff = false }, -- paralyze_ii
        [81] = { jobs = { [3]=53 }, buff = false }, -- recall-jugner
        [82] = { jobs = { [3]=53 }, buff = false }, -- recall-pashh
        [83] = { jobs = { [3]=53 }, buff = false }, -- recall-meriph
        [86] = { jobs = { [3]=7 }, buff = true }, -- barsleepra
        [87] = { jobs = { [3]=10 }, buff = true }, -- barpoisonra
        [88] = { jobs = { [3]=12 }, buff = true }, -- barparalyzra
        [89] = { jobs = { [3]=18 }, buff = true }, -- barblindra
        [90] = { jobs = { [3]=23 }, buff = true }, -- barsilencera
        [91] = { jobs = { [3]=43 }, buff = true }, -- barpetra
        [92] = { jobs = { [3]=39 }, buff = true }, -- barvira
        [93] = { jobs = { [3]=40 }, buff = false }, -- cura
        [94] = { jobs = { [3]=65 }, buff = false }, -- sacrifice
        [95] = { jobs = { [3]=61 }, buff = false }, -- esuna
        [96] = { jobs = { [3]=55 }, buff = true }, -- auspice
        [97] = { jobs = { [7]=61 }, buff = true }, -- reprisal
        [98] = { jobs = { [3]=48 }, buff = false }, -- repose
        [99] = { jobs = { [20]=41 }, buff = true }, -- sandstorm
        [100] = { jobs = { [5]=24 }, buff = true }, -- enfire
        [101] = { jobs = { [5]=22 }, buff = true }, -- enblizzard
        [102] = { jobs = { [5]=20 }, buff = true }, -- enaero
        [103] = { jobs = { [5]=18 }, buff = true }, -- enstone
        [104] = { jobs = { [5]=16 }, buff = true }, -- enthunder
        [105] = { jobs = { [5]=27 }, buff = true }, -- enwater
        [106] = { jobs = { [5]=33, [22]=68 }, buff = true }, -- phalanx
        [107] = { jobs = { [5]=75 }, buff = true }, -- phalanx_ii
        [108] = { jobs = { [3]=21, [5]=21, [20]=18, [22]=23 }, buff = true }, -- regen
        [109] = { jobs = { [5]=41, [22]=62 }, buff = true }, -- refresh
        [110] = { jobs = { [3]=44, [20]=37, [22]=48 }, buff = true }, -- regen_ii
        [111] = { jobs = { [3]=66, [20]=59, [22]=70 }, buff = true }, -- regen_iii
        [112] = { jobs = { [3]=45, [7]=37, [22]=45 }, buff = false }, -- flash
        [113] = { jobs = { [20]=42 }, buff = true }, -- rainstorm
        [114] = { jobs = { [20]=43 }, buff = true }, -- windstorm
        [115] = { jobs = { [20]=44 }, buff = true }, -- firestorm
        [116] = { jobs = { [20]=45 }, buff = true }, -- hailstorm
        [117] = { jobs = { [20]=46 }, buff = true }, -- thunderstorm
        [118] = { jobs = { [20]=47 }, buff = true }, -- voidstorm
        [119] = { jobs = { [20]=48 }, buff = true }, -- aurorastorm
        [120] = { jobs = { [3]=38 }, buff = false }, -- teleport-yhoat
        [121] = { jobs = { [3]=38 }, buff = false }, -- teleport-altep
        [122] = { jobs = { [3]=36 }, buff = false }, -- teleport-holla
        [123] = { jobs = { [3]=36 }, buff = false }, -- teleport-dem
        [124] = { jobs = { [3]=36 }, buff = false }, -- teleport-mea
        [125] = { jobs = { [3]=7 }, buff = true }, -- protectra
        [126] = { jobs = { [3]=27 }, buff = true }, -- protectra_ii
        [127] = { jobs = { [3]=47 }, buff = true }, -- protectra_iii
        [128] = { jobs = { [3]=63 }, buff = true }, -- protectra_iv
        [129] = { jobs = { [3]=75 }, buff = true }, -- protectra_v
        [130] = { jobs = { [3]=17 }, buff = true }, -- shellra
        [131] = { jobs = { [3]=37 }, buff = true }, -- shellra_ii
        [132] = { jobs = { [3]=57 }, buff = true }, -- shellra_iii
        [133] = { jobs = { [3]=68 }, buff = true }, -- shellra_iv
        [134] = { jobs = { [3]=75 }, buff = true }, -- shellra_v
        [135] = { jobs = { [3]=25, [20]=35 }, buff = true }, -- reraise
        [136] = { jobs = { [3]=25, [5]=25, [20]=25 }, buff = true }, -- invisible
        [137] = { jobs = { [3]=20, [5]=20, [20]=20 }, buff = true }, -- sneak
        [138] = { jobs = { [3]=15, [5]=15, [20]=15 }, buff = true }, -- deodorize
        [139] = { jobs = { [3]=42 }, buff = false }, -- teleport-vahzl
        [140] = { jobs = { [3]=70 }, buff = false }, -- raise_iii
        [141] = { jobs = { [3]=56, [20]=70 }, buff = true }, -- reraise_ii
        [142] = { jobs = { [3]=70 }, buff = true }, -- reraise_iii
        [143] = { jobs = { [3]=32, [20]=39 }, buff = false }, -- erase
        [144] = { jobs = { [4]=13, [5]=19, [8]=23, [20]=16, [21]=19 }, buff = false }, -- fire
        [145] = { jobs = { [4]=38, [5]=50, [8]=60, [20]=42, [21]=46 }, buff = false }, -- fire_ii
        [146] = { jobs = { [4]=62, [5]=71, [20]=63, [21]=67 }, buff = false }, -- fire_iii
        [147] = { jobs = { [4]=73, [20]=73 }, buff = false }, -- fire_iv
        [149] = { jobs = { [4]=17, [5]=24, [8]=29, [20]=20, [21]=24 }, buff = false }, -- blizzard
        [150] = { jobs = { [4]=42, [5]=55, [8]=66, [20]=46, [21]=50 }, buff = false }, -- blizzard_ii
        [151] = { jobs = { [4]=64, [5]=73, [20]=66, [21]=70 }, buff = false }, -- blizzard_iii
        [152] = { jobs = { [4]=74, [20]=74 }, buff = false }, -- blizzard_iv
        [154] = { jobs = { [4]=9, [5]=14, [8]=17, [20]=12, [21]=14 }, buff = false }, -- aero
        [155] = { jobs = { [4]=34, [5]=45, [8]=54, [20]=38, [21]=42 }, buff = false }, -- aero_ii
        [156] = { jobs = { [4]=59, [5]=69, [20]=60, [21]=64 }, buff = false }, -- aero_iii
        [157] = { jobs = { [4]=72, [20]=72 }, buff = false }, -- aero_iv
        [159] = { jobs = { [4]=1, [5]=4, [8]=5, [20]=4, [21]=4 }, buff = false }, -- stone
        [160] = { jobs = { [4]=26, [5]=35, [8]=42, [20]=30, [21]=34 }, buff = false }, -- stone_ii
        [161] = { jobs = { [4]=51, [5]=65, [20]=54, [21]=58 }, buff = false }, -- stone_iii
        [162] = { jobs = { [4]=68, [20]=70 }, buff = false }, -- stone_iv
        [164] = { jobs = { [4]=21, [5]=29, [8]=35, [20]=24, [21]=29 }, buff = false }, -- thunder
        [165] = { jobs = { [4]=46, [5]=60, [8]=72, [20]=51, [21]=54 }, buff = false }, -- thunder_ii
        [166] = { jobs = { [4]=66, [5]=75, [20]=69, [21]=73 }, buff = false }, -- thunder_iii
        [167] = { jobs = { [4]=75, [20]=75 }, buff = false }, -- thunder_iv
        [169] = { jobs = { [4]=5, [5]=9, [8]=11, [20]=8, [21]=9 }, buff = false }, -- water
        [170] = { jobs = { [4]=30, [5]=40, [8]=48, [20]=34, [21]=38 }, buff = false }, -- water_ii
        [171] = { jobs = { [4]=55, [5]=67, [20]=57, [21]=61 }, buff = false }, -- water_iii
        [172] = { jobs = { [4]=70, [20]=71 }, buff = false }, -- water_iv
        [174] = { jobs = { [4]=28 }, buff = false }, -- firaga
        [175] = { jobs = { [4]=53 }, buff = false }, -- firaga_ii
        [176] = { jobs = { [4]=69 }, buff = false }, -- firaga_iii
        [179] = { jobs = { [4]=32 }, buff = false }, -- blizzaga
        [180] = { jobs = { [4]=57 }, buff = false }, -- blizzaga_ii
        [181] = { jobs = { [4]=71 }, buff = false }, -- blizzaga_iii
        [184] = { jobs = { [4]=23 }, buff = false }, -- aeroga
        [185] = { jobs = { [4]=48 }, buff = false }, -- aeroga_ii
        [186] = { jobs = { [4]=67 }, buff = false }, -- aeroga_iii
        [189] = { jobs = { [4]=15 }, buff = false }, -- stonega
        [190] = { jobs = { [4]=40 }, buff = false }, -- stonega_ii
        [191] = { jobs = { [4]=63 }, buff = false }, -- stonega_iii
        [194] = { jobs = { [4]=36 }, buff = false }, -- thundaga
        [195] = { jobs = { [4]=61 }, buff = false }, -- thundaga_ii
        [196] = { jobs = { [4]=73 }, buff = false }, -- thundaga_iii
        [199] = { jobs = { [4]=19 }, buff = false }, -- waterga
        [200] = { jobs = { [4]=44 }, buff = false }, -- waterga_ii
        [201] = { jobs = { [4]=65 }, buff = false }, -- waterga_iii
        [204] = { jobs = { [4]=60 }, buff = false }, -- flare
        [205] = { jobs = { [4]=75 }, buff = false }, -- flare_ii
        [206] = { jobs = { [4]=50 }, buff = false }, -- freeze
        [207] = { jobs = { [4]=75 }, buff = false }, -- freeze_ii
        [208] = { jobs = { [4]=52 }, buff = false }, -- tornado
        [209] = { jobs = { [4]=75 }, buff = false }, -- tornado_ii
        [210] = { jobs = { [4]=54 }, buff = false }, -- quake
        [211] = { jobs = { [4]=75 }, buff = false }, -- quake_ii
        [212] = { jobs = { [4]=56 }, buff = false }, -- burst
        [213] = { jobs = { [4]=75 }, buff = false }, -- burst_ii
        [214] = { jobs = { [4]=58 }, buff = false }, -- flood
        [215] = { jobs = { [4]=75 }, buff = false }, -- flood_ii
        [216] = { jobs = { [5]=21 }, buff = false }, -- gravity
        [220] = { jobs = { [4]=3, [5]=5, [8]=6 }, buff = false }, -- poison
        [221] = { jobs = { [4]=43, [5]=46, [8]=46 }, buff = false }, -- poison_ii
        [225] = { jobs = { [4]=24, [8]=26 }, buff = false }, -- poisonga
        [226] = { jobs = { [4]=64, [8]=66 }, buff = false }, -- poisonga_ii
        [230] = { jobs = { [4]=10, [5]=10, [8]=15 }, buff = false }, -- bio
        [231] = { jobs = { [4]=35, [5]=36, [8]=40 }, buff = false }, -- bio_ii
        [232] = { jobs = { [5]=75 }, buff = false }, -- bio_iii
        [235] = { jobs = { [4]=24 }, buff = false }, -- burn
        [236] = { jobs = { [4]=22 }, buff = false }, -- frost
        [237] = { jobs = { [4]=20 }, buff = false }, -- choke
        [238] = { jobs = { [4]=18 }, buff = false }, -- rasp
        [239] = { jobs = { [4]=16 }, buff = false }, -- shock
        [240] = { jobs = { [4]=27 }, buff = false }, -- drown
        [241] = { jobs = { [4]=55 }, buff = false }, -- retrace
        [242] = { jobs = { [8]=61 }, buff = false }, -- absorb-acc
        [245] = { jobs = { [4]=12, [8]=10, [20]=21, [21]=15 }, buff = false }, -- drain
        [246] = { jobs = { [8]=62 }, buff = false }, -- drain_ii
        [247] = { jobs = { [4]=25, [8]=20, [20]=36, [21]=30 }, buff = false }, -- aspir
        [249] = { jobs = { [4]=10, [5]=20, [20]=30, [22]=45 }, buff = true }, -- blaze_spikes
        [250] = { jobs = { [4]=20, [5]=40, [20]=50, [22]=65 }, buff = true }, -- ice_spikes
        [251] = { jobs = { [4]=30, [5]=60, [20]=70 }, buff = true }, -- shock_spikes
        [252] = { jobs = { [4]=45, [8]=37 }, buff = false }, -- stun
        [253] = { jobs = { [4]=20, [5]=25, [8]=30, [20]=30, [21]=35 }, buff = false }, -- sleep
        [254] = { jobs = { [4]=4, [5]=8 }, buff = false }, -- blind
        [258] = { jobs = { [4]=7, [5]=11, [8]=20 }, buff = false }, -- bind
        [259] = { jobs = { [4]=41, [5]=46, [8]=56, [20]=65, [21]=70 }, buff = false }, -- sleep_ii
        [260] = { jobs = { [5]=32, [20]=32 }, buff = false }, -- dispel
        [261] = { jobs = { [4]=17 }, buff = false }, -- warp
        [262] = { jobs = { [4]=40 }, buff = false }, -- warp_ii
        [263] = { jobs = { [4]=29 }, buff = false }, -- escape
        [264] = { jobs = { [4]=25, [8]=32 }, buff = false }, -- tractor
        [266] = { jobs = { [8]=43 }, buff = false }, -- absorb-str
        [267] = { jobs = { [8]=41 }, buff = false }, -- absorb-dex
        [268] = { jobs = { [8]=35 }, buff = false }, -- absorb-vit
        [269] = { jobs = { [8]=37 }, buff = false }, -- absorb-agi
        [270] = { jobs = { [8]=39 }, buff = false }, -- absorb-int
        [271] = { jobs = { [8]=31 }, buff = false }, -- absorb-mnd
        [272] = { jobs = { [8]=33 }, buff = false }, -- absorb-chr
        [273] = { jobs = { [4]=31 }, buff = false }, -- sleepga
        [274] = { jobs = { [4]=56 }, buff = false }, -- sleepga_ii
        [275] = { jobs = { [8]=45 }, buff = false }, -- absorb-tp
        [276] = { jobs = { [5]=75 }, buff = false }, -- blind_ii
        [277] = { jobs = { [8]=71 }, buff = true }, -- dread_spikes
        [278] = { jobs = { [20]=18 }, buff = false }, -- geohelix
        [279] = { jobs = { [20]=20 }, buff = false }, -- hydrohelix
        [280] = { jobs = { [20]=22 }, buff = false }, -- anemohelix
        [281] = { jobs = { [20]=24 }, buff = false }, -- pyrohelix
        [282] = { jobs = { [20]=26 }, buff = false }, -- cryohelix
        [283] = { jobs = { [20]=28 }, buff = false }, -- ionohelix
        [284] = { jobs = { [20]=30 }, buff = false }, -- noctohelix
        [285] = { jobs = { [20]=32 }, buff = false }, -- luminohelix
        [287] = { jobs = { [20]=46 }, buff = true }, -- klimaform
        [288] = { jobs = { [15]=1 }, buff = false }, -- fire_spirit
        [289] = { jobs = { [15]=1 }, buff = false }, -- ice_spirit
        [290] = { jobs = { [15]=1 }, buff = false }, -- air_spirit
        [291] = { jobs = { [15]=1 }, buff = false }, -- earth_spirit
        [292] = { jobs = { [15]=1 }, buff = false }, -- thunder_spirit
        [293] = { jobs = { [15]=1 }, buff = false }, -- water_spirit
        [294] = { jobs = { [15]=1 }, buff = false }, -- light_spirit
        [295] = { jobs = { [15]=1 }, buff = false }, -- dark_spirit
        [296] = { jobs = { [15]=1 }, buff = false }, -- carbuncle
        [297] = { jobs = { [15]=1 }, buff = false }, -- fenrir
        [298] = { jobs = { [15]=1 }, buff = false }, -- ifrit
        [299] = { jobs = { [15]=1 }, buff = false }, -- titan
        [300] = { jobs = { [15]=1 }, buff = false }, -- leviathan
        [301] = { jobs = { [15]=1 }, buff = false }, -- garuda
        [302] = { jobs = { [15]=1 }, buff = false }, -- shiva
        [303] = { jobs = { [15]=1 }, buff = false }, -- ramuh
        [304] = { jobs = { [15]=1 }, buff = false }, -- diabolos
        [305] = { jobs = { [15]=75 }, buff = false }, -- odin
        [306] = { jobs = { [15]=75 }, buff = false }, -- alexander
        [310] = { jobs = { [7]=85 }, buff = true }, -- enlight
        [312] = { jobs = { [5]=58 }, buff = true }, -- enfire_ii
        [313] = { jobs = { [5]=56 }, buff = true }, -- enblizzard_ii
        [314] = { jobs = { [5]=54 }, buff = true }, -- enaero_ii
        [315] = { jobs = { [5]=52 }, buff = true }, -- enstone_ii
        [316] = { jobs = { [5]=50 }, buff = true }, -- enthunder_ii
        [317] = { jobs = { [5]=60 }, buff = true }, -- enwater_ii
        [318] = { jobs = { [13]=25 }, buff = true }, -- monomi_ichi
        [320] = { jobs = { [13]=15 }, buff = false }, -- katon_ichi
        [321] = { jobs = { [13]=40 }, buff = false }, -- katon_ni
        [322] = { jobs = { [13]=75 }, buff = false }, -- katon_san
        [323] = { jobs = { [13]=15 }, buff = false }, -- hyoton_ichi
        [324] = { jobs = { [13]=40 }, buff = false }, -- hyoton_ni
        [325] = { jobs = { [13]=75 }, buff = false }, -- hyoton_san
        [326] = { jobs = { [13]=15 }, buff = false }, -- huton_ichi
        [327] = { jobs = { [13]=40 }, buff = false }, -- huton_ni
        [328] = { jobs = { [13]=75 }, buff = false }, -- huton_san
        [329] = { jobs = { [13]=15 }, buff = false }, -- doton_ichi
        [330] = { jobs = { [13]=40 }, buff = false }, -- doton_ni
        [331] = { jobs = { [13]=75 }, buff = false }, -- doton_san
        [332] = { jobs = { [13]=15 }, buff = false }, -- raiton_ichi
        [333] = { jobs = { [13]=40 }, buff = false }, -- raiton_ni
        [334] = { jobs = { [13]=75 }, buff = false }, -- raiton_san
        [335] = { jobs = { [13]=15 }, buff = false }, -- suiton_ichi
        [336] = { jobs = { [13]=40 }, buff = false }, -- suiton_ni
        [337] = { jobs = { [13]=75 }, buff = false }, -- suiton_san
        [338] = { jobs = { [13]=12 }, buff = true }, -- utsusemi_ichi
        [339] = { jobs = { [13]=37 }, buff = true }, -- utsusemi_ni
        [341] = { jobs = { [13]=30 }, buff = false }, -- jubaku_ichi
        [344] = { jobs = { [13]=23 }, buff = false }, -- hojo_ichi
        [345] = { jobs = { [13]=48 }, buff = false }, -- hojo_ni
        [347] = { jobs = { [13]=19 }, buff = false }, -- kurayami_ichi
        [348] = { jobs = { [13]=44 }, buff = false }, -- kurayami_ni
        [350] = { jobs = { [13]=27 }, buff = false }, -- dokumori_ichi
        [353] = { jobs = { [13]=9 }, buff = true }, -- tonko_ichi
        [354] = { jobs = { [13]=34 }, buff = true }, -- tonko_ni
        [355] = { jobs = { [15]=1 }, buff = false }, -- siren
        [368] = { jobs = { [10]=7 }, buff = false }, -- foe_requiem
        [369] = { jobs = { [10]=17 }, buff = false }, -- foe_requiem_ii
        [370] = { jobs = { [10]=37 }, buff = false }, -- foe_requiem_iii
        [371] = { jobs = { [10]=47 }, buff = false }, -- foe_requiem_iv
        [372] = { jobs = { [10]=57 }, buff = false }, -- foe_requiem_v
        [373] = { jobs = { [10]=67 }, buff = false }, -- foe_requiem_vi
        [376] = { jobs = { [10]=27 }, buff = false }, -- horde_lullaby
        [378] = { jobs = { [10]=5 }, buff = true }, -- armys_paeon
        [379] = { jobs = { [10]=15 }, buff = true }, -- armys_paeon_ii
        [380] = { jobs = { [10]=35 }, buff = true }, -- armys_paeon_iii
        [381] = { jobs = { [10]=45 }, buff = true }, -- armys_paeon_iv
        [382] = { jobs = { [10]=65 }, buff = true }, -- armys_paeon_v
        [386] = { jobs = { [10]=25 }, buff = true }, -- mages_ballad
        [387] = { jobs = { [10]=55 }, buff = true }, -- mages_ballad_ii
        [389] = { jobs = { [10]=1 }, buff = true }, -- knights_minne
        [390] = { jobs = { [10]=21 }, buff = true }, -- knights_minne_ii
        [391] = { jobs = { [10]=41 }, buff = true }, -- knights_minne_iii
        [392] = { jobs = { [10]=61 }, buff = true }, -- knights_minne_iv
        [394] = { jobs = { [10]=3 }, buff = true }, -- valor_minuet
        [395] = { jobs = { [10]=23 }, buff = true }, -- valor_minuet_ii
        [396] = { jobs = { [10]=43 }, buff = true }, -- valor_minuet_iii
        [397] = { jobs = { [10]=63 }, buff = true }, -- valor_minuet_iv
        [399] = { jobs = { [10]=11 }, buff = true }, -- sword_madrigal
        [400] = { jobs = { [10]=51 }, buff = true }, -- blade_madrigal
        [401] = { jobs = { [10]=31 }, buff = true }, -- hunters_prelude
        [402] = { jobs = { [10]=71 }, buff = true }, -- archers_prelude
        [403] = { jobs = { [10]=13 }, buff = true }, -- sheepfoe_mambo
        [404] = { jobs = { [10]=53 }, buff = true }, -- dragonfoe_mambo
        [405] = { jobs = { [10]=33 }, buff = true }, -- fowl_aubade
        [406] = { jobs = { [10]=9 }, buff = true }, -- herb_pastoral
        [408] = { jobs = { [10]=56 }, buff = true }, -- shining_fantasia
        [409] = { jobs = { [10]=19 }, buff = true }, -- scops_operetta
        [410] = { jobs = { [10]=69 }, buff = true }, -- puppets_operetta
        [412] = { jobs = { [10]=54 }, buff = true }, -- gold_capriccio
        [414] = { jobs = { [10]=73 }, buff = true }, -- warding_round
        [415] = { jobs = { [10]=49 }, buff = true }, -- goblin_gavotte
        [419] = { jobs = { [10]=29 }, buff = true }, -- advancing_march
        [420] = { jobs = { [10]=60 }, buff = true }, -- victory_march
        [421] = { jobs = { [10]=39 }, buff = false }, -- battlefield_elegy
        [422] = { jobs = { [10]=59 }, buff = false }, -- carnage_elegy
        [424] = { jobs = { [10]=34 }, buff = true }, -- sinewy_etude
        [425] = { jobs = { [10]=32 }, buff = true }, -- dextrous_etude
        [426] = { jobs = { [10]=30 }, buff = true }, -- vivacious_etude
        [427] = { jobs = { [10]=28 }, buff = true }, -- quick_etude
        [428] = { jobs = { [10]=26 }, buff = true }, -- learned_etude
        [429] = { jobs = { [10]=24 }, buff = true }, -- spirited_etude
        [430] = { jobs = { [10]=22 }, buff = true }, -- enchanting_etude
        [431] = { jobs = { [10]=74 }, buff = true }, -- herculean_etude
        [432] = { jobs = { [10]=72 }, buff = true }, -- uncanny_etude
        [433] = { jobs = { [10]=70 }, buff = true }, -- vital_etude
        [434] = { jobs = { [10]=68 }, buff = true }, -- swift_etude
        [435] = { jobs = { [10]=66 }, buff = true }, -- sage_etude
        [436] = { jobs = { [10]=64 }, buff = true }, -- logical_etude
        [437] = { jobs = { [10]=62 }, buff = true }, -- bewitching_etude
        [438] = { jobs = { [10]=44 }, buff = true }, -- fire_carol
        [439] = { jobs = { [10]=46 }, buff = true }, -- ice_carol
        [440] = { jobs = { [10]=42 }, buff = true }, -- wind_carol
        [441] = { jobs = { [10]=38 }, buff = true }, -- earth_carol
        [442] = { jobs = { [10]=48 }, buff = true }, -- lightning_carol
        [443] = { jobs = { [10]=40 }, buff = true }, -- water_carol
        [444] = { jobs = { [10]=36 }, buff = true }, -- light_carol
        [445] = { jobs = { [10]=50 }, buff = true }, -- dark_carol
        [454] = { jobs = { [10]=20 }, buff = false }, -- fire_threnody
        [455] = { jobs = { [10]=22 }, buff = false }, -- ice_threnody
        [456] = { jobs = { [10]=18 }, buff = false }, -- wind_threnody
        [457] = { jobs = { [10]=14 }, buff = false }, -- earth_threnody
        [458] = { jobs = { [10]=24 }, buff = false }, -- lightning_threnody
        [459] = { jobs = { [10]=16 }, buff = false }, -- water_threnody
        [460] = { jobs = { [10]=10 }, buff = false }, -- light_threnody
        [461] = { jobs = { [10]=12 }, buff = false }, -- dark_threnody
        [462] = { jobs = { [10]=33 }, buff = false }, -- magic_finale
        [463] = { jobs = { [10]=16 }, buff = false }, -- foe_lullaby
        [464] = { jobs = { [10]=71 }, buff = true }, -- goddesss_hymnus
        [465] = { jobs = { [10]=73 }, buff = true }, -- chocobo_mazurka
        [466] = { jobs = { [10]=75 }, buff = false }, -- maidens_virelai
        [467] = { jobs = { [10]=37 }, buff = true }, -- raptor_mazurka
        [468] = { jobs = { [10]=75 }, buff = true }, -- foe_sirvente
        [469] = { jobs = { [10]=75 }, buff = true }, -- adventurers_dirge
        [513] = { jobs = { [16]=42 }, buff = false }, -- venom_shell
        [515] = { jobs = { [16]=61 }, buff = false }, -- maelstrom
        [517] = { jobs = { [16]=8 }, buff = true }, -- metallic_body
        [519] = { jobs = { [16]=26 }, buff = false }, -- screwdriver
        [521] = { jobs = { [16]=42 }, buff = false }, -- mp_drainkiss
        [522] = { jobs = { [16]=34 }, buff = false }, -- death_ray
        [524] = { jobs = { [16]=1 }, buff = false }, -- sandspin
        [527] = { jobs = { [16]=34 }, buff = false }, -- smite_of_rage
        [529] = { jobs = { [16]=18 }, buff = false }, -- bludgeon
        [530] = { jobs = { [16]=48 }, buff = true }, -- refueling
        [531] = { jobs = { [16]=50 }, buff = false }, -- ice_break
        [532] = { jobs = { [16]=44 }, buff = false }, -- blitzstrahl
        [533] = { jobs = { [16]=50 }, buff = false }, -- self-destruct
        [534] = { jobs = { [16]=40 }, buff = false }, -- mysterious_light
        [535] = { jobs = { [16]=52 }, buff = false }, -- cold_wave
        [536] = { jobs = { [16]=22 }, buff = false }, -- poison_breath
        [537] = { jobs = { [16]=44 }, buff = false }, -- stinking_gas
        [538] = { jobs = { [16]=62 }, buff = true }, -- memento_mori
        [539] = { jobs = { [16]=40 }, buff = false }, -- terror_touch
        [540] = { jobs = { [16]=63 }, buff = false }, -- spinal_cleave
        [541] = { jobs = { [16]=48 }, buff = false }, -- blood_saber
        [542] = { jobs = { [16]=36 }, buff = false }, -- digest
        [543] = { jobs = { [16]=44 }, buff = false }, -- mandibular_bite
        [544] = { jobs = { [16]=18 }, buff = false }, -- cursed_sphere
        [545] = { jobs = { [16]=48 }, buff = false }, -- sickle_slash
        [547] = { jobs = { [16]=8 }, buff = true }, -- cocoon
        [548] = { jobs = { [16]=52 }, buff = false }, -- filamented_hold
        [549] = { jobs = { [16]=1 }, buff = false }, -- pollen
        [551] = { jobs = { [16]=4 }, buff = false }, -- power_attack
        [554] = { jobs = { [16]=60 }, buff = false }, -- death_scissors
        [555] = { jobs = { [16]=46 }, buff = false }, -- magnetite_cloud
        [557] = { jobs = { [16]=61 }, buff = false }, -- eyes_on_me
        [560] = { jobs = { [16]=63 }, buff = false }, -- frenetic_rip
        [561] = { jobs = { [16]=50 }, buff = false }, -- frightful_roar
        [563] = { jobs = { [16]=54 }, buff = false }, -- hecatomb_wave
        [564] = { jobs = { [16]=62 }, buff = false }, -- body_slam
        [565] = { jobs = { [16]=54 }, buff = false }, -- radiant_breath
        [567] = { jobs = { [16]=16 }, buff = false }, -- helldive
        [569] = { jobs = { [16]=38 }, buff = false }, -- jet_stream
        [570] = { jobs = { [16]=20 }, buff = false }, -- blood_drain
        [572] = { jobs = { [16]=32 }, buff = false }, -- sound_blast
        [573] = { jobs = { [16]=64 }, buff = false }, -- feather_tickle
        [574] = { jobs = { [16]=56 }, buff = true }, -- feather_barrier
        [575] = { jobs = { [16]=48 }, buff = false }, -- jettatura
        [576] = { jobs = { [16]=64 }, buff = false }, -- yawn
        [577] = { jobs = { [16]=1 }, buff = false }, -- foot_kick
        [578] = { jobs = { [16]=30 }, buff = false }, -- wild_carrot
        [579] = { jobs = { [16]=64 }, buff = false }, -- voracious_trunk
        [581] = { jobs = { [16]=16 }, buff = false }, -- healing_breeze
        [582] = { jobs = { [16]=32 }, buff = false }, -- chaotic_eye
        [584] = { jobs = { [16]=16 }, buff = false }, -- sheep_song
        [585] = { jobs = { [16]=73 }, buff = false }, -- ram_charge
        [587] = { jobs = { [16]=20 }, buff = false }, -- claw_cyclone
        [588] = { jobs = { [16]=71 }, buff = false }, -- lowing
        [589] = { jobs = { [16]=60 }, buff = false }, -- dimensional_death
        [591] = { jobs = { [16]=71 }, buff = false }, -- heat_breath
        [592] = { jobs = { [16]=38 }, buff = false }, -- blank_gaze
        [593] = { jobs = { [16]=58 }, buff = false }, -- magic_fruit
        [594] = { jobs = { [16]=38 }, buff = false }, -- uppercut
        [595] = { jobs = { [16]=62 }, buff = false }, -- 1000_needles
        [596] = { jobs = { [16]=36 }, buff = false }, -- pinecone_bomb
        [597] = { jobs = { [16]=4 }, buff = false }, -- sprout_smack
        [598] = { jobs = { [16]=24 }, buff = false }, -- soporific
        [599] = { jobs = { [16]=8 }, buff = false }, -- queasyshroom
        [603] = { jobs = { [16]=4 }, buff = false }, -- wild_oats
        [604] = { jobs = { [16]=61 }, buff = false }, -- bad_breath
        [605] = { jobs = { [16]=46 }, buff = false }, -- geist_wall
        [606] = { jobs = { [16]=46 }, buff = false }, -- awful_eye
        [608] = { jobs = { [16]=66 }, buff = false }, -- frost_breath
        [610] = { jobs = { [16]=65 }, buff = false }, -- infrasonics
        [611] = { jobs = { [16]=72 }, buff = false }, -- disseverment
        [612] = { jobs = { [16]=74 }, buff = false }, -- actinic_burst
        [613] = { jobs = { [16]=74 }, buff = true }, -- reactor_cool
        [614] = { jobs = { [16]=72 }, buff = true }, -- saline_coat
        [615] = { jobs = { [16]=75 }, buff = true }, -- plasma_charge
        [616] = { jobs = { [16]=73 }, buff = false }, -- temporal_shift
        [617] = { jobs = { [16]=75 }, buff = false }, -- vertical_cleave
        [618] = { jobs = { [16]=18 }, buff = false }, -- blastbomb
        [620] = { jobs = { [16]=12 }, buff = false }, -- battle_dance
        [621] = { jobs = { [16]=66 }, buff = false }, -- sandspray
        [622] = { jobs = { [16]=30 }, buff = false }, -- grand_slam
        [623] = { jobs = { [16]=12 }, buff = false }, -- head_butt
        [626] = { jobs = { [16]=28 }, buff = false }, -- bomb_toss
        [628] = { jobs = { [16]=63 }, buff = false }, -- frypan
        [629] = { jobs = { [16]=58 }, buff = false }, -- flying_hip_press
        [631] = { jobs = { [16]=63 }, buff = false }, -- hydro_shot
        [632] = { jobs = { [16]=67 }, buff = true }, -- diamondhide
        [633] = { jobs = { [16]=67 }, buff = false }, -- enervation
        [634] = { jobs = { [16]=58 }, buff = false }, -- light_of_penance
        [636] = { jobs = { [16]=68 }, buff = true }, -- warm-up
        [637] = { jobs = { [16]=68 }, buff = false }, -- firespit
        [638] = { jobs = { [16]=12 }, buff = false }, -- feather_storm
        [640] = { jobs = { [16]=69 }, buff = false }, -- tail_slap
        [641] = { jobs = { [16]=69 }, buff = false }, -- hysteric_barrage
        [642] = { jobs = { [16]=70 }, buff = true }, -- amplification
        [643] = { jobs = { [16]=70 }, buff = false }, -- cannonball
        [644] = { jobs = { [16]=73 }, buff = false }, -- mind_blast
        [645] = { jobs = { [16]=75 }, buff = false }, -- exuviation
        [646] = { jobs = { [16]=74 }, buff = false }, -- magic_hammer
        [647] = { jobs = { [16]=65 }, buff = true }, -- zephyr_mantle
        [648] = { jobs = { [16]=69 }, buff = false }, -- regurgitation
        [650] = { jobs = { [16]=61 }, buff = false }, -- seedspray
        [651] = { jobs = { [16]=66 }, buff = false }, -- corrosive_ooze
        [652] = { jobs = { [16]=60 }, buff = false }, -- spiral_spin
        [653] = { jobs = { [16]=70 }, buff = false }, -- asuran_claws
        [654] = { jobs = { [16]=72 }, buff = false }, -- sub-zero_smash
        [655] = { jobs = { [16]=71 }, buff = true }, -- triumphant_roar
        [896] = { jobs = { [1]=1, [2]=1, [3]=1, [4]=1, [5]=1, [6]=1, [7]=1, [8]=1, [9]=1, [10]=1, [11]=1, [12]=1, [13]=1, [14]=1, [15]=1, [16]=1, [17]=1, [18]=1, [19]=1, [20]=1, [21]=1, [22]=1 }, buff = true }, -- shantotto
        [897] = { jobs = { [1]=1, [2]=1, [3]=1, [4]=1, [5]=1, [6]=1, [7]=1, [8]=1, [9]=1, [10]=1, [11]=1, [12]=1, [13]=1, [14]=1, [15]=1, [16]=1, [17]=1, [18]=1, [19]=1, [20]=1, [21]=1, [22]=1 }, buff = true }, -- naji
        [898] = { jobs = { [1]=1, [2]=1, [3]=1, [4]=1, [5]=1, [6]=1, [7]=1, [8]=1, [9]=1, [10]=1, [11]=1, [12]=1, [13]=1, [14]=1, [15]=1, [16]=1, [17]=1, [18]=1, [19]=1, [20]=1, [21]=1, [22]=1 }, buff = true }, -- kupipi
        [899] = { jobs = { [1]=1, [2]=1, [3]=1, [4]=1, [5]=1, [6]=1, [7]=1, [8]=1, [9]=1, [10]=1, [11]=1, [12]=1, [13]=1, [14]=1, [15]=1, [16]=1, [17]=1, [18]=1, [19]=1, [20]=1, [21]=1, [22]=1 }, buff = true }, -- excenmille
        [900] = { jobs = { [1]=1, [2]=1, [3]=1, [4]=1, [5]=1, [6]=1, [7]=1, [8]=1, [9]=1, [10]=1, [11]=1, [12]=1, [13]=1, [14]=1, [15]=1, [16]=1, [17]=1, [18]=1, [19]=1, [20]=1, [21]=1, [22]=1 }, buff = true }, -- ayame
        [901] = { jobs = { [1]=1, [2]=1, [3]=1, [4]=1, [5]=1, [6]=1, [7]=1, [8]=1, [9]=1, [10]=1, [11]=1, [12]=1, [13]=1, [14]=1, [15]=1, [16]=1, [17]=1, [18]=1, [19]=1, [20]=1, [21]=1, [22]=1 }, buff = true }, -- nanaa_mihgo
        [902] = { jobs = { [1]=1, [2]=1, [3]=1, [4]=1, [5]=1, [6]=1, [7]=1, [8]=1, [9]=1, [10]=1, [11]=1, [12]=1, [13]=1, [14]=1, [15]=1, [16]=1, [17]=1, [18]=1, [19]=1, [20]=1, [21]=1, [22]=1 }, buff = true }, -- curilla
        [903] = { jobs = { [1]=1, [2]=1, [3]=1, [4]=1, [5]=1, [6]=1, [7]=1, [8]=1, [9]=1, [10]=1, [11]=1, [12]=1, [13]=1, [14]=1, [15]=1, [16]=1, [17]=1, [18]=1, [19]=1, [20]=1, [21]=1, [22]=1 }, buff = true }, -- volker
        [904] = { jobs = { [1]=1, [2]=1, [3]=1, [4]=1, [5]=1, [6]=1, [7]=1, [8]=1, [9]=1, [10]=1, [11]=1, [12]=1, [13]=1, [14]=1, [15]=1, [16]=1, [17]=1, [18]=1, [19]=1, [20]=1, [21]=1, [22]=1 }, buff = true }, -- ajido-marujido
        [905] = { jobs = { [1]=1, [2]=1, [3]=1, [4]=1, [5]=1, [6]=1, [7]=1, [8]=1, [9]=1, [10]=1, [11]=1, [12]=1, [13]=1, [14]=1, [15]=1, [16]=1, [17]=1, [18]=1, [19]=1, [20]=1, [21]=1, [22]=1 }, buff = true }, -- trion
        [906] = { jobs = { [1]=1, [2]=1, [3]=1, [4]=1, [5]=1, [6]=1, [7]=1, [8]=1, [9]=1, [10]=1, [11]=1, [12]=1, [13]=1, [14]=1, [15]=1, [16]=1, [17]=1, [18]=1, [19]=1, [20]=1, [21]=1, [22]=1 }, buff = true }, -- zeid
        [907] = { jobs = { [1]=1, [2]=1, [3]=1, [4]=1, [5]=1, [6]=1, [7]=1, [8]=1, [9]=1, [10]=1, [11]=1, [12]=1, [13]=1, [14]=1, [15]=1, [16]=1, [17]=1, [18]=1, [19]=1, [20]=1, [21]=1, [22]=1 }, buff = true }, -- lion
        [908] = { jobs = { [1]=1, [2]=1, [3]=1, [4]=1, [5]=1, [6]=1, [7]=1, [8]=1, [9]=1, [10]=1, [11]=1, [12]=1, [13]=1, [14]=1, [15]=1, [16]=1, [17]=1, [18]=1, [19]=1, [20]=1, [21]=1, [22]=1 }, buff = true }, -- tenzen
        [909] = { jobs = { [1]=1, [2]=1, [3]=1, [4]=1, [5]=1, [6]=1, [7]=1, [8]=1, [9]=1, [10]=1, [11]=1, [12]=1, [13]=1, [14]=1, [15]=1, [16]=1, [17]=1, [18]=1, [19]=1, [20]=1, [21]=1, [22]=1 }, buff = true }, -- mihli_aliapoh
        [910] = { jobs = { [1]=1, [2]=1, [3]=1, [4]=1, [5]=1, [6]=1, [7]=1, [8]=1, [9]=1, [10]=1, [11]=1, [12]=1, [13]=1, [14]=1, [15]=1, [16]=1, [17]=1, [18]=1, [19]=1, [20]=1, [21]=1, [22]=1 }, buff = true }, -- valaineral
        [911] = { jobs = { [1]=1, [2]=1, [3]=1, [4]=1, [5]=1, [6]=1, [7]=1, [8]=1, [9]=1, [10]=1, [11]=1, [12]=1, [13]=1, [14]=1, [15]=1, [16]=1, [17]=1, [18]=1, [19]=1, [20]=1, [21]=1, [22]=1 }, buff = true }, -- joachim
        [912] = { jobs = { [1]=1, [2]=1, [3]=1, [4]=1, [5]=1, [6]=1, [7]=1, [8]=1, [9]=1, [10]=1, [11]=1, [12]=1, [13]=1, [14]=1, [15]=1, [16]=1, [17]=1, [18]=1, [19]=1, [20]=1, [21]=1, [22]=1 }, buff = true }, -- naja_salaheem
        [913] = { jobs = { [1]=1, [2]=1, [3]=1, [4]=1, [5]=1, [6]=1, [7]=1, [8]=1, [9]=1, [10]=1, [11]=1, [12]=1, [13]=1, [14]=1, [15]=1, [16]=1, [17]=1, [18]=1, [19]=1, [20]=1, [21]=1, [22]=1 }, buff = true }, -- prishe
        [914] = { jobs = { [1]=1, [2]=1, [3]=1, [4]=1, [5]=1, [6]=1, [7]=1, [8]=1, [9]=1, [10]=1, [11]=1, [12]=1, [13]=1, [14]=1, [15]=1, [16]=1, [17]=1, [18]=1, [19]=1, [20]=1, [21]=1, [22]=1 }, buff = true }, -- ulmia
        [915] = { jobs = { [1]=1, [2]=1, [3]=1, [4]=1, [5]=1, [6]=1, [7]=1, [8]=1, [9]=1, [10]=1, [11]=1, [12]=1, [13]=1, [14]=1, [15]=1, [16]=1, [17]=1, [18]=1, [19]=1, [20]=1, [21]=1, [22]=1 }, buff = true }, -- shikaree_z
        [916] = { jobs = { [1]=1, [2]=1, [3]=1, [4]=1, [5]=1, [6]=1, [7]=1, [8]=1, [9]=1, [10]=1, [11]=1, [12]=1, [13]=1, [14]=1, [15]=1, [16]=1, [17]=1, [18]=1, [19]=1, [20]=1, [21]=1, [22]=1 }, buff = true }, -- cherukiki
        [917] = { jobs = { [1]=1, [2]=1, [3]=1, [4]=1, [5]=1, [6]=1, [7]=1, [8]=1, [9]=1, [10]=1, [11]=1, [12]=1, [13]=1, [14]=1, [15]=1, [16]=1, [17]=1, [18]=1, [19]=1, [20]=1, [21]=1, [22]=1 }, buff = true }, -- iron_eater
        [918] = { jobs = { [1]=1, [2]=1, [3]=1, [4]=1, [5]=1, [6]=1, [7]=1, [8]=1, [9]=1, [10]=1, [11]=1, [12]=1, [13]=1, [14]=1, [15]=1, [16]=1, [17]=1, [18]=1, [19]=1, [20]=1, [21]=1, [22]=1 }, buff = true }, -- gessho
        [919] = { jobs = { [1]=1, [2]=1, [3]=1, [4]=1, [5]=1, [6]=1, [7]=1, [8]=1, [9]=1, [10]=1, [11]=1, [12]=1, [13]=1, [14]=1, [15]=1, [16]=1, [17]=1, [18]=1, [19]=1, [20]=1, [21]=1, [22]=1 }, buff = true }, -- gadalar
        [920] = { jobs = { [1]=1, [2]=1, [3]=1, [4]=1, [5]=1, [6]=1, [7]=1, [8]=1, [9]=1, [10]=1, [11]=1, [12]=1, [13]=1, [14]=1, [15]=1, [16]=1, [17]=1, [18]=1, [19]=1, [20]=1, [21]=1, [22]=1 }, buff = true }, -- rainemard
        [921] = { jobs = { [1]=1, [2]=1, [3]=1, [4]=1, [5]=1, [6]=1, [7]=1, [8]=1, [9]=1, [10]=1, [11]=1, [12]=1, [13]=1, [14]=1, [15]=1, [16]=1, [17]=1, [18]=1, [19]=1, [20]=1, [21]=1, [22]=1 }, buff = true }, -- ingrid
        [922] = { jobs = { [1]=1, [2]=1, [3]=1, [4]=1, [5]=1, [6]=1, [7]=1, [8]=1, [9]=1, [10]=1, [11]=1, [12]=1, [13]=1, [14]=1, [15]=1, [16]=1, [17]=1, [18]=1, [19]=1, [20]=1, [21]=1, [22]=1 }, buff = true }, -- lehko_habhoka
        [923] = { jobs = { [1]=1, [2]=1, [3]=1, [4]=1, [5]=1, [6]=1, [7]=1, [8]=1, [9]=1, [10]=1, [11]=1, [12]=1, [13]=1, [14]=1, [15]=1, [16]=1, [17]=1, [18]=1, [19]=1, [20]=1, [21]=1, [22]=1 }, buff = true }, -- nashmeira
        [924] = { jobs = { [1]=1, [2]=1, [3]=1, [4]=1, [5]=1, [6]=1, [7]=1, [8]=1, [9]=1, [10]=1, [11]=1, [12]=1, [13]=1, [14]=1, [15]=1, [16]=1, [17]=1, [18]=1, [19]=1, [20]=1, [21]=1, [22]=1 }, buff = true }, -- zazarg
        [925] = { jobs = { [1]=1, [2]=1, [3]=1, [4]=1, [5]=1, [6]=1, [7]=1, [8]=1, [9]=1, [10]=1, [11]=1, [12]=1, [13]=1, [14]=1, [15]=1, [16]=1, [17]=1, [18]=1, [19]=1, [20]=1, [21]=1, [22]=1 }, buff = true }, -- ovjang
        [926] = { jobs = { [1]=1, [2]=1, [3]=1, [4]=1, [5]=1, [6]=1, [7]=1, [8]=1, [9]=1, [10]=1, [11]=1, [12]=1, [13]=1, [14]=1, [15]=1, [16]=1, [17]=1, [18]=1, [19]=1, [20]=1, [21]=1, [22]=1 }, buff = true }, -- mnejing
        [927] = { jobs = { [1]=1, [2]=1, [3]=1, [4]=1, [5]=1, [6]=1, [7]=1, [8]=1, [9]=1, [10]=1, [11]=1, [12]=1, [13]=1, [14]=1, [15]=1, [16]=1, [17]=1, [18]=1, [19]=1, [20]=1, [21]=1, [22]=1 }, buff = true }, -- sakura
        [928] = { jobs = { [1]=1, [2]=1, [3]=1, [4]=1, [5]=1, [6]=1, [7]=1, [8]=1, [9]=1, [10]=1, [11]=1, [12]=1, [13]=1, [14]=1, [15]=1, [16]=1, [17]=1, [18]=1, [19]=1, [20]=1, [21]=1, [22]=1 }, buff = true }, -- luzaf
        [929] = { jobs = { [1]=1, [2]=1, [3]=1, [4]=1, [5]=1, [6]=1, [7]=1, [8]=1, [9]=1, [10]=1, [11]=1, [12]=1, [13]=1, [14]=1, [15]=1, [16]=1, [17]=1, [18]=1, [19]=1, [20]=1, [21]=1, [22]=1 }, buff = true }, -- najelith
        [930] = { jobs = { [1]=1, [2]=1, [3]=1, [4]=1, [5]=1, [6]=1, [7]=1, [8]=1, [9]=1, [10]=1, [11]=1, [12]=1, [13]=1, [14]=1, [15]=1, [16]=1, [17]=1, [18]=1, [19]=1, [20]=1, [21]=1, [22]=1 }, buff = true }, -- aldo
        [931] = { jobs = { [1]=1, [2]=1, [3]=1, [4]=1, [5]=1, [6]=1, [7]=1, [8]=1, [9]=1, [10]=1, [11]=1, [12]=1, [13]=1, [14]=1, [15]=1, [16]=1, [17]=1, [18]=1, [19]=1, [20]=1, [21]=1, [22]=1 }, buff = true }, -- moogle
        [932] = { jobs = { [1]=1, [2]=1, [3]=1, [4]=1, [5]=1, [6]=1, [7]=1, [8]=1, [9]=1, [10]=1, [11]=1, [12]=1, [13]=1, [14]=1, [15]=1, [16]=1, [17]=1, [18]=1, [19]=1, [20]=1, [21]=1, [22]=1 }, buff = true }, -- fablinix
        [933] = { jobs = { [1]=1, [2]=1, [3]=1, [4]=1, [5]=1, [6]=1, [7]=1, [8]=1, [9]=1, [10]=1, [11]=1, [12]=1, [13]=1, [14]=1, [15]=1, [16]=1, [17]=1, [18]=1, [19]=1, [20]=1, [21]=1, [22]=1 }, buff = true }, -- maat
        [934] = { jobs = { [1]=1, [2]=1, [3]=1, [4]=1, [5]=1, [6]=1, [7]=1, [8]=1, [9]=1, [10]=1, [11]=1, [12]=1, [13]=1, [14]=1, [15]=1, [16]=1, [17]=1, [18]=1, [19]=1, [20]=1, [21]=1, [22]=1 }, buff = true }, -- d_shantotto
        [935] = { jobs = { [1]=1, [2]=1, [3]=1, [4]=1, [5]=1, [6]=1, [7]=1, [8]=1, [9]=1, [10]=1, [11]=1, [12]=1, [13]=1, [14]=1, [15]=1, [16]=1, [17]=1, [18]=1, [19]=1, [20]=1, [21]=1, [22]=1 }, buff = true }, -- star_sibyl
        [936] = { jobs = { [1]=1, [2]=1, [3]=1, [4]=1, [5]=1, [6]=1, [7]=1, [8]=1, [9]=1, [10]=1, [11]=1, [12]=1, [13]=1, [14]=1, [15]=1, [16]=1, [17]=1, [18]=1, [19]=1, [20]=1, [21]=1, [22]=1 }, buff = true }, -- karaha-baruha
        [937] = { jobs = { [1]=1, [2]=1, [3]=1, [4]=1, [5]=1, [6]=1, [7]=1, [8]=1, [9]=1, [10]=1, [11]=1, [12]=1, [13]=1, [14]=1, [15]=1, [16]=1, [17]=1, [18]=1, [19]=1, [20]=1, [21]=1, [22]=1 }, buff = true }, -- cid
        [938] = { jobs = { [1]=1, [2]=1, [3]=1, [4]=1, [5]=1, [6]=1, [7]=1, [8]=1, [9]=1, [10]=1, [11]=1, [12]=1, [13]=1, [14]=1, [15]=1, [16]=1, [17]=1, [18]=1, [19]=1, [20]=1, [21]=1, [22]=1 }, buff = true }, -- gilgamesh
        [939] = { jobs = { [1]=1, [2]=1, [3]=1, [4]=1, [5]=1, [6]=1, [7]=1, [8]=1, [9]=1, [10]=1, [11]=1, [12]=1, [13]=1, [14]=1, [15]=1, [16]=1, [17]=1, [18]=1, [19]=1, [20]=1, [21]=1, [22]=1 }, buff = true }, -- areuhat
        [940] = { jobs = { [1]=1, [2]=1, [3]=1, [4]=1, [5]=1, [6]=1, [7]=1, [8]=1, [9]=1, [10]=1, [11]=1, [12]=1, [13]=1, [14]=1, [15]=1, [16]=1, [17]=1, [18]=1, [19]=1, [20]=1, [21]=1, [22]=1 }, buff = true }, -- semih_lafihna
        [941] = { jobs = { [1]=1, [2]=1, [3]=1, [4]=1, [5]=1, [6]=1, [7]=1, [8]=1, [9]=1, [10]=1, [11]=1, [12]=1, [13]=1, [14]=1, [15]=1, [16]=1, [17]=1, [18]=1, [19]=1, [20]=1, [21]=1, [22]=1 }, buff = true }, -- elivira
        [942] = { jobs = { [1]=1, [2]=1, [3]=1, [4]=1, [5]=1, [6]=1, [7]=1, [8]=1, [9]=1, [10]=1, [11]=1, [12]=1, [13]=1, [14]=1, [15]=1, [16]=1, [17]=1, [18]=1, [19]=1, [20]=1, [21]=1, [22]=1 }, buff = true }, -- noillurie
        [943] = { jobs = { [1]=1, [2]=1, [3]=1, [4]=1, [5]=1, [6]=1, [7]=1, [8]=1, [9]=1, [10]=1, [11]=1, [12]=1, [13]=1, [14]=1, [15]=1, [16]=1, [17]=1, [18]=1, [19]=1, [20]=1, [21]=1, [22]=1 }, buff = true }, -- lhu_mhakaracca
        [944] = { jobs = { [1]=1, [2]=1, [3]=1, [4]=1, [5]=1, [6]=1, [7]=1, [8]=1, [9]=1, [10]=1, [11]=1, [12]=1, [13]=1, [14]=1, [15]=1, [16]=1, [17]=1, [18]=1, [19]=1, [20]=1, [21]=1, [22]=1 }, buff = true }, -- ferreous_coffin
        [945] = { jobs = { [1]=1, [2]=1, [3]=1, [4]=1, [5]=1, [6]=1, [7]=1, [8]=1, [9]=1, [10]=1, [11]=1, [12]=1, [13]=1, [14]=1, [15]=1, [16]=1, [17]=1, [18]=1, [19]=1, [20]=1, [21]=1, [22]=1 }, buff = true }, -- lilisette
        [946] = { jobs = { [1]=1, [2]=1, [3]=1, [4]=1, [5]=1, [6]=1, [7]=1, [8]=1, [9]=1, [10]=1, [11]=1, [12]=1, [13]=1, [14]=1, [15]=1, [16]=1, [17]=1, [18]=1, [19]=1, [20]=1, [21]=1, [22]=1 }, buff = true }, -- mumor
        [947] = { jobs = { [1]=1, [2]=1, [3]=1, [4]=1, [5]=1, [6]=1, [7]=1, [8]=1, [9]=1, [10]=1, [11]=1, [12]=1, [13]=1, [14]=1, [15]=1, [16]=1, [17]=1, [18]=1, [19]=1, [20]=1, [21]=1, [22]=1 }, buff = true }, -- uka_totlihn
        [948] = { jobs = { [1]=1, [2]=1, [3]=1, [4]=1, [5]=1, [6]=1, [7]=1, [8]=1, [9]=1, [10]=1, [11]=1, [12]=1, [13]=1, [14]=1, [15]=1, [16]=1, [17]=1, [18]=1, [19]=1, [20]=1, [21]=1, [22]=1 }, buff = true }, -- klara
        [949] = { jobs = { [1]=1, [2]=1, [3]=1, [4]=1, [5]=1, [6]=1, [7]=1, [8]=1, [9]=1, [10]=1, [11]=1, [12]=1, [13]=1, [14]=1, [15]=1, [16]=1, [17]=1, [18]=1, [19]=1, [20]=1, [21]=1, [22]=1 }, buff = true }, -- romaa_mihgo
        [950] = { jobs = { [1]=1, [2]=1, [3]=1, [4]=1, [5]=1, [6]=1, [7]=1, [8]=1, [9]=1, [10]=1, [11]=1, [12]=1, [13]=1, [14]=1, [15]=1, [16]=1, [17]=1, [18]=1, [19]=1, [20]=1, [21]=1, [22]=1 }, buff = true }, -- kuyin_hathdenna
        [951] = { jobs = { [1]=1, [2]=1, [3]=1, [4]=1, [5]=1, [6]=1, [7]=1, [8]=1, [9]=1, [10]=1, [11]=1, [12]=1, [13]=1, [14]=1, [15]=1, [16]=1, [17]=1, [18]=1, [19]=1, [20]=1, [21]=1, [22]=1 }, buff = true }, -- rahal
        [952] = { jobs = { [1]=1, [2]=1, [3]=1, [4]=1, [5]=1, [6]=1, [7]=1, [8]=1, [9]=1, [10]=1, [11]=1, [12]=1, [13]=1, [14]=1, [15]=1, [16]=1, [17]=1, [18]=1, [19]=1, [20]=1, [21]=1, [22]=1 }, buff = true }, -- koru-moru
        [953] = { jobs = { [1]=1, [2]=1, [3]=1, [4]=1, [5]=1, [6]=1, [7]=1, [8]=1, [9]=1, [10]=1, [11]=1, [12]=1, [13]=1, [14]=1, [15]=1, [16]=1, [17]=1, [18]=1, [19]=1, [20]=1, [21]=1, [22]=1 }, buff = true }, -- pieuje_uc
        [954] = { jobs = { [1]=1, [2]=1, [3]=1, [4]=1, [5]=1, [6]=1, [7]=1, [8]=1, [9]=1, [10]=1, [11]=1, [12]=1, [13]=1, [14]=1, [15]=1, [16]=1, [17]=1, [18]=1, [19]=1, [20]=1, [21]=1, [22]=1 }, buff = true }, -- i_shield_uc
        [955] = { jobs = { [1]=1, [2]=1, [3]=1, [4]=1, [5]=1, [6]=1, [7]=1, [8]=1, [9]=1, [10]=1, [11]=1, [12]=1, [13]=1, [14]=1, [15]=1, [16]=1, [17]=1, [18]=1, [19]=1, [20]=1, [21]=1, [22]=1 }, buff = true }, -- apururu_uc
        [956] = { jobs = { [1]=1, [2]=1, [3]=1, [4]=1, [5]=1, [6]=1, [7]=1, [8]=1, [9]=1, [10]=1, [11]=1, [12]=1, [13]=1, [14]=1, [15]=1, [16]=1, [17]=1, [18]=1, [19]=1, [20]=1, [21]=1, [22]=1 }, buff = true }, -- jakoh_uc
        [957] = { jobs = { [1]=1, [2]=1, [3]=1, [4]=1, [5]=1, [6]=1, [7]=1, [8]=1, [9]=1, [10]=1, [11]=1, [12]=1, [13]=1, [14]=1, [15]=1, [16]=1, [17]=1, [18]=1, [19]=1, [20]=1, [21]=1, [22]=1 }, buff = true }, -- flaviria_uc
        [958] = { jobs = { [1]=1, [2]=1, [3]=1, [4]=1, [5]=1, [6]=1, [7]=1, [8]=1, [9]=1, [10]=1, [11]=1, [12]=1, [13]=1, [14]=1, [15]=1, [16]=1, [17]=1, [18]=1, [19]=1, [20]=1, [21]=1, [22]=1 }, buff = true }, -- babban
        [959] = { jobs = { [1]=1, [2]=1, [3]=1, [4]=1, [5]=1, [6]=1, [7]=1, [8]=1, [9]=1, [10]=1, [11]=1, [12]=1, [13]=1, [14]=1, [15]=1, [16]=1, [17]=1, [18]=1, [19]=1, [20]=1, [21]=1, [22]=1 }, buff = true }, -- abenzio
        [960] = { jobs = { [1]=1, [2]=1, [3]=1, [4]=1, [5]=1, [6]=1, [7]=1, [8]=1, [9]=1, [10]=1, [11]=1, [12]=1, [13]=1, [14]=1, [15]=1, [16]=1, [17]=1, [18]=1, [19]=1, [20]=1, [21]=1, [22]=1 }, buff = true }, -- rughadjeen
        [961] = { jobs = { [1]=1, [2]=1, [3]=1, [4]=1, [5]=1, [6]=1, [7]=1, [8]=1, [9]=1, [10]=1, [11]=1, [12]=1, [13]=1, [14]=1, [15]=1, [16]=1, [17]=1, [18]=1, [19]=1, [20]=1, [21]=1, [22]=1 }, buff = true }, -- kukki-chebukki
        [962] = { jobs = { [1]=1, [2]=1, [3]=1, [4]=1, [5]=1, [6]=1, [7]=1, [8]=1, [9]=1, [10]=1, [11]=1, [12]=1, [13]=1, [14]=1, [15]=1, [16]=1, [17]=1, [18]=1, [19]=1, [20]=1, [21]=1, [22]=1 }, buff = true }, -- margret
        [963] = { jobs = { [1]=1, [2]=1, [3]=1, [4]=1, [5]=1, [6]=1, [7]=1, [8]=1, [9]=1, [10]=1, [11]=1, [12]=1, [13]=1, [14]=1, [15]=1, [16]=1, [17]=1, [18]=1, [19]=1, [20]=1, [21]=1, [22]=1 }, buff = true }, -- chacharoon
        [964] = { jobs = { [1]=1, [2]=1, [3]=1, [4]=1, [5]=1, [6]=1, [7]=1, [8]=1, [9]=1, [10]=1, [11]=1, [12]=1, [13]=1, [14]=1, [15]=1, [16]=1, [17]=1, [18]=1, [19]=1, [20]=1, [21]=1, [22]=1 }, buff = true }, -- lhe_lhangavo
        [965] = { jobs = { [1]=1, [2]=1, [3]=1, [4]=1, [5]=1, [6]=1, [7]=1, [8]=1, [9]=1, [10]=1, [11]=1, [12]=1, [13]=1, [14]=1, [15]=1, [16]=1, [17]=1, [18]=1, [19]=1, [20]=1, [21]=1, [22]=1 }, buff = true }, -- arciela
        [966] = { jobs = { [1]=1, [2]=1, [3]=1, [4]=1, [5]=1, [6]=1, [7]=1, [8]=1, [9]=1, [10]=1, [11]=1, [12]=1, [13]=1, [14]=1, [15]=1, [16]=1, [17]=1, [18]=1, [19]=1, [20]=1, [21]=1, [22]=1 }, buff = true }, -- mayakov
        [967] = { jobs = { [1]=1, [2]=1, [3]=1, [4]=1, [5]=1, [6]=1, [7]=1, [8]=1, [9]=1, [10]=1, [11]=1, [12]=1, [13]=1, [14]=1, [15]=1, [16]=1, [17]=1, [18]=1, [19]=1, [20]=1, [21]=1, [22]=1 }, buff = true }, -- qultada
        [968] = { jobs = { [1]=1, [2]=1, [3]=1, [4]=1, [5]=1, [6]=1, [7]=1, [8]=1, [9]=1, [10]=1, [11]=1, [12]=1, [13]=1, [14]=1, [15]=1, [16]=1, [17]=1, [18]=1, [19]=1, [20]=1, [21]=1, [22]=1 }, buff = true }, -- adelheid
        [969] = { jobs = { [1]=1, [2]=1, [3]=1, [4]=1, [5]=1, [6]=1, [7]=1, [8]=1, [9]=1, [10]=1, [11]=1, [12]=1, [13]=1, [14]=1, [15]=1, [16]=1, [17]=1, [18]=1, [19]=1, [20]=1, [21]=1, [22]=1 }, buff = true }, -- amchuchu
        [970] = { jobs = { [1]=1, [2]=1, [3]=1, [4]=1, [5]=1, [6]=1, [7]=1, [8]=1, [9]=1, [10]=1, [11]=1, [12]=1, [13]=1, [14]=1, [15]=1, [16]=1, [17]=1, [18]=1, [19]=1, [20]=1, [21]=1, [22]=1 }, buff = true }, -- brygid
        [971] = { jobs = { [1]=1, [2]=1, [3]=1, [4]=1, [5]=1, [6]=1, [7]=1, [8]=1, [9]=1, [10]=1, [11]=1, [12]=1, [13]=1, [14]=1, [15]=1, [16]=1, [17]=1, [18]=1, [19]=1, [20]=1, [21]=1, [22]=1 }, buff = true }, -- mildaurion
        [972] = { jobs = { [1]=1, [2]=1, [3]=1, [4]=1, [5]=1, [6]=1, [7]=1, [8]=1, [9]=1, [10]=1, [11]=1, [12]=1, [13]=1, [14]=1, [15]=1, [16]=1, [17]=1, [18]=1, [19]=1, [20]=1, [21]=1, [22]=1 }, buff = true }, -- halver
        [973] = { jobs = { [1]=1, [2]=1, [3]=1, [4]=1, [5]=1, [6]=1, [7]=1, [8]=1, [9]=1, [10]=1, [11]=1, [12]=1, [13]=1, [14]=1, [15]=1, [16]=1, [17]=1, [18]=1, [19]=1, [20]=1, [21]=1, [22]=1 }, buff = true }, -- rongelouts
        [974] = { jobs = { [1]=1, [2]=1, [3]=1, [4]=1, [5]=1, [6]=1, [7]=1, [8]=1, [9]=1, [10]=1, [11]=1, [12]=1, [13]=1, [14]=1, [15]=1, [16]=1, [17]=1, [18]=1, [19]=1, [20]=1, [21]=1, [22]=1 }, buff = true }, -- leonoyne
        [975] = { jobs = { [1]=1, [2]=1, [3]=1, [4]=1, [5]=1, [6]=1, [7]=1, [8]=1, [9]=1, [10]=1, [11]=1, [12]=1, [13]=1, [14]=1, [15]=1, [16]=1, [17]=1, [18]=1, [19]=1, [20]=1, [21]=1, [22]=1 }, buff = true }, -- maximilian
        [976] = { jobs = { [1]=1, [2]=1, [3]=1, [4]=1, [5]=1, [6]=1, [7]=1, [8]=1, [9]=1, [10]=1, [11]=1, [12]=1, [13]=1, [14]=1, [15]=1, [16]=1, [17]=1, [18]=1, [19]=1, [20]=1, [21]=1, [22]=1 }, buff = true }, -- kayeel-payeel
        [977] = { jobs = { [1]=1, [2]=1, [3]=1, [4]=1, [5]=1, [6]=1, [7]=1, [8]=1, [9]=1, [10]=1, [11]=1, [12]=1, [13]=1, [14]=1, [15]=1, [16]=1, [17]=1, [18]=1, [19]=1, [20]=1, [21]=1, [22]=1 }, buff = true }, -- robel-akbel
        [978] = { jobs = { [1]=1, [2]=1, [3]=1, [4]=1, [5]=1, [6]=1, [7]=1, [8]=1, [9]=1, [10]=1, [11]=1, [12]=1, [13]=1, [14]=1, [15]=1, [16]=1, [17]=1, [18]=1, [19]=1, [20]=1, [21]=1, [22]=1 }, buff = true }, -- kupofried
        [979] = { jobs = { [1]=1, [2]=1, [3]=1, [4]=1, [5]=1, [6]=1, [7]=1, [8]=1, [9]=1, [10]=1, [11]=1, [12]=1, [13]=1, [14]=1, [15]=1, [16]=1, [17]=1, [18]=1, [19]=1, [20]=1, [21]=1, [22]=1 }, buff = true }, -- selh_teus
        [980] = { jobs = { [1]=1, [2]=1, [3]=1, [4]=1, [5]=1, [6]=1, [7]=1, [8]=1, [9]=1, [10]=1, [11]=1, [12]=1, [13]=1, [14]=1, [15]=1, [16]=1, [17]=1, [18]=1, [19]=1, [20]=1, [21]=1, [22]=1 }, buff = true }, -- yoran-oran_uc
        [981] = { jobs = { [1]=1, [2]=1, [3]=1, [4]=1, [5]=1, [6]=1, [7]=1, [8]=1, [9]=1, [10]=1, [11]=1, [12]=1, [13]=1, [14]=1, [15]=1, [16]=1, [17]=1, [18]=1, [19]=1, [20]=1, [21]=1, [22]=1 }, buff = true }, -- sylvie_uc
        [982] = { jobs = { [1]=1, [2]=1, [3]=1, [4]=1, [5]=1, [6]=1, [7]=1, [8]=1, [9]=1, [10]=1, [11]=1, [12]=1, [13]=1, [14]=1, [15]=1, [16]=1, [17]=1, [18]=1, [19]=1, [20]=1, [21]=1, [22]=1 }, buff = true }, -- abquhbah
        [983] = { jobs = { [1]=1, [2]=1, [3]=1, [4]=1, [5]=1, [6]=1, [7]=1, [8]=1, [9]=1, [10]=1, [11]=1, [12]=1, [13]=1, [14]=1, [15]=1, [16]=1, [17]=1, [18]=1, [19]=1, [20]=1, [21]=1, [22]=1 }, buff = true }, -- balamor
        [984] = { jobs = { [1]=1, [2]=1, [3]=1, [4]=1, [5]=1, [6]=1, [7]=1, [8]=1, [9]=1, [10]=1, [11]=1, [12]=1, [13]=1, [14]=1, [15]=1, [16]=1, [17]=1, [18]=1, [19]=1, [20]=1, [21]=1, [22]=1 }, buff = true }, -- august
        [985] = { jobs = { [1]=1, [2]=1, [3]=1, [4]=1, [5]=1, [6]=1, [7]=1, [8]=1, [9]=1, [10]=1, [11]=1, [12]=1, [13]=1, [14]=1, [15]=1, [16]=1, [17]=1, [18]=1, [19]=1, [20]=1, [21]=1, [22]=1 }, buff = true }, -- rosulatia
        [986] = { jobs = { [1]=1, [2]=1, [3]=1, [4]=1, [5]=1, [6]=1, [7]=1, [8]=1, [9]=1, [10]=1, [11]=1, [12]=1, [13]=1, [14]=1, [15]=1, [16]=1, [17]=1, [18]=1, [19]=1, [20]=1, [21]=1, [22]=1 }, buff = true }, -- teodor
        [987] = { jobs = { [1]=1, [2]=1, [3]=1, [4]=1, [5]=1, [6]=1, [7]=1, [8]=1, [9]=1, [10]=1, [11]=1, [12]=1, [13]=1, [14]=1, [15]=1, [16]=1, [17]=1, [18]=1, [19]=1, [20]=1, [21]=1, [22]=1 }, buff = true }, -- ullegore
        [988] = { jobs = { [1]=1, [2]=1, [3]=1, [4]=1, [5]=1, [6]=1, [7]=1, [8]=1, [9]=1, [10]=1, [11]=1, [12]=1, [13]=1, [14]=1, [15]=1, [16]=1, [17]=1, [18]=1, [19]=1, [20]=1, [21]=1, [22]=1 }, buff = true }, -- makki-chebukki
        [989] = { jobs = { [1]=1, [2]=1, [3]=1, [4]=1, [5]=1, [6]=1, [7]=1, [8]=1, [9]=1, [10]=1, [11]=1, [12]=1, [13]=1, [14]=1, [15]=1, [16]=1, [17]=1, [18]=1, [19]=1, [20]=1, [21]=1, [22]=1 }, buff = true }, -- king_of_hearts
        [990] = { jobs = { [1]=1, [2]=1, [3]=1, [4]=1, [5]=1, [6]=1, [7]=1, [8]=1, [9]=1, [10]=1, [11]=1, [12]=1, [13]=1, [14]=1, [15]=1, [16]=1, [17]=1, [18]=1, [19]=1, [20]=1, [21]=1, [22]=1 }, buff = true }, -- morimar
        [991] = { jobs = { [1]=1, [2]=1, [3]=1, [4]=1, [5]=1, [6]=1, [7]=1, [8]=1, [9]=1, [10]=1, [11]=1, [12]=1, [13]=1, [14]=1, [15]=1, [16]=1, [17]=1, [18]=1, [19]=1, [20]=1, [21]=1, [22]=1 }, buff = true }, -- darrcuiln
        [992] = { jobs = { [1]=1, [2]=1, [3]=1, [4]=1, [5]=1, [6]=1, [7]=1, [8]=1, [9]=1, [10]=1, [11]=1, [12]=1, [13]=1, [14]=1, [15]=1, [16]=1, [17]=1, [18]=1, [19]=1, [20]=1, [21]=1, [22]=1 }, buff = true }, -- aahm
        [993] = { jobs = { [1]=1, [2]=1, [3]=1, [4]=1, [5]=1, [6]=1, [7]=1, [8]=1, [9]=1, [10]=1, [11]=1, [12]=1, [13]=1, [14]=1, [15]=1, [16]=1, [17]=1, [18]=1, [19]=1, [20]=1, [21]=1, [22]=1 }, buff = true }, -- aaev
        [994] = { jobs = { [1]=1, [2]=1, [3]=1, [4]=1, [5]=1, [6]=1, [7]=1, [8]=1, [9]=1, [10]=1, [11]=1, [12]=1, [13]=1, [14]=1, [15]=1, [16]=1, [17]=1, [18]=1, [19]=1, [20]=1, [21]=1, [22]=1 }, buff = true }, -- aamr
        [995] = { jobs = { [1]=1, [2]=1, [3]=1, [4]=1, [5]=1, [6]=1, [7]=1, [8]=1, [9]=1, [10]=1, [11]=1, [12]=1, [13]=1, [14]=1, [15]=1, [16]=1, [17]=1, [18]=1, [19]=1, [20]=1, [21]=1, [22]=1 }, buff = true }, -- aatt
        [996] = { jobs = { [1]=1, [2]=1, [3]=1, [4]=1, [5]=1, [6]=1, [7]=1, [8]=1, [9]=1, [10]=1, [11]=1, [12]=1, [13]=1, [14]=1, [15]=1, [16]=1, [17]=1, [18]=1, [19]=1, [20]=1, [21]=1, [22]=1 }, buff = true }, -- aagk
        [997] = { jobs = { [1]=1, [2]=1, [3]=1, [4]=1, [5]=1, [6]=1, [7]=1, [8]=1, [9]=1, [10]=1, [11]=1, [12]=1, [13]=1, [14]=1, [15]=1, [16]=1, [17]=1, [18]=1, [19]=1, [20]=1, [21]=1, [22]=1 }, buff = true }, -- iroha
        [998] = { jobs = { [1]=1, [2]=1, [3]=1, [4]=1, [5]=1, [6]=1, [7]=1, [8]=1, [9]=1, [10]=1, [11]=1, [12]=1, [13]=1, [14]=1, [15]=1, [16]=1, [17]=1, [18]=1, [19]=1, [20]=1, [21]=1, [22]=1 }, buff = true }, -- ygnas
        [999] = { jobs = { [1]=1, [2]=1, [3]=1, [4]=1, [5]=1, [6]=1, [7]=1, [8]=1, [9]=1, [10]=1, [11]=1, [12]=1, [13]=1, [14]=1, [15]=1, [16]=1, [17]=1, [18]=1, [19]=1, [20]=1, [21]=1, [22]=1 }, buff = true }, -- monberaux
        [1002] = { jobs = { [1]=1, [2]=1, [3]=1, [4]=1, [5]=1, [6]=1, [7]=1, [8]=1, [9]=1, [10]=1, [11]=1, [12]=1, [13]=1, [14]=1, [15]=1, [16]=1, [17]=1, [18]=1, [19]=1, [20]=1, [21]=1, [22]=1 }, buff = true }, -- cornelia
        [1003] = { jobs = { [1]=1, [2]=1, [3]=1, [4]=1, [5]=1, [6]=1, [7]=1, [8]=1, [9]=1, [10]=1, [11]=1, [12]=1, [13]=1, [14]=1, [15]=1, [16]=1, [17]=1, [18]=1, [19]=1, [20]=1, [21]=1, [22]=1 }, buff = true }, -- matsui-p
        [1004] = { jobs = { [1]=1, [2]=1, [3]=1, [4]=1, [5]=1, [6]=1, [7]=1, [8]=1, [9]=1, [10]=1, [11]=1, [12]=1, [13]=1, [14]=1, [15]=1, [16]=1, [17]=1, [18]=1, [19]=1, [20]=1, [21]=1, [22]=1 }, buff = true }, -- excenmille_s
        [1005] = { jobs = { [1]=1, [2]=1, [3]=1, [4]=1, [5]=1, [6]=1, [7]=1, [8]=1, [9]=1, [10]=1, [11]=1, [12]=1, [13]=1, [14]=1, [15]=1, [16]=1, [17]=1, [18]=1, [19]=1, [20]=1, [21]=1, [22]=1 }, buff = true }, -- ayame_uc
        [1006] = { jobs = { [1]=1, [2]=1, [3]=1, [4]=1, [5]=1, [6]=1, [7]=1, [8]=1, [9]=1, [10]=1, [11]=1, [12]=1, [13]=1, [14]=1, [15]=1, [16]=1, [17]=1, [18]=1, [19]=1, [20]=1, [21]=1, [22]=1 }, buff = true }, -- maat_uc
        [1007] = { jobs = { [1]=1, [2]=1, [3]=1, [4]=1, [5]=1, [6]=1, [7]=1, [8]=1, [9]=1, [10]=1, [11]=1, [12]=1, [13]=1, [14]=1, [15]=1, [16]=1, [17]=1, [18]=1, [19]=1, [20]=1, [21]=1, [22]=1 }, buff = true }, -- aldo_uc
        [1008] = { jobs = { [1]=1, [2]=1, [3]=1, [4]=1, [5]=1, [6]=1, [7]=1, [8]=1, [9]=1, [10]=1, [11]=1, [12]=1, [13]=1, [14]=1, [15]=1, [16]=1, [17]=1, [18]=1, [19]=1, [20]=1, [21]=1, [22]=1 }, buff = true }, -- naja_uc
        [1009] = { jobs = { [1]=1, [2]=1, [3]=1, [4]=1, [5]=1, [6]=1, [7]=1, [8]=1, [9]=1, [10]=1, [11]=1, [12]=1, [13]=1, [14]=1, [15]=1, [16]=1, [17]=1, [18]=1, [19]=1, [20]=1, [21]=1, [22]=1 }, buff = true }, -- lion_ii
        [1010] = { jobs = { [1]=1, [2]=1, [3]=1, [4]=1, [5]=1, [6]=1, [7]=1, [8]=1, [9]=1, [10]=1, [11]=1, [12]=1, [13]=1, [14]=1, [15]=1, [16]=1, [17]=1, [18]=1, [19]=1, [20]=1, [21]=1, [22]=1 }, buff = true }, -- zeid_ii
        [1011] = { jobs = { [1]=1, [2]=1, [3]=1, [4]=1, [5]=1, [6]=1, [7]=1, [8]=1, [9]=1, [10]=1, [11]=1, [12]=1, [13]=1, [14]=1, [15]=1, [16]=1, [17]=1, [18]=1, [19]=1, [20]=1, [21]=1, [22]=1 }, buff = true }, -- prishe_ii
        [1012] = { jobs = { [1]=1, [2]=1, [3]=1, [4]=1, [5]=1, [6]=1, [7]=1, [8]=1, [9]=1, [10]=1, [11]=1, [12]=1, [13]=1, [14]=1, [15]=1, [16]=1, [17]=1, [18]=1, [19]=1, [20]=1, [21]=1, [22]=1 }, buff = true }, -- nashmeira_ii
        [1013] = { jobs = { [1]=1, [2]=1, [3]=1, [4]=1, [5]=1, [6]=1, [7]=1, [8]=1, [9]=1, [10]=1, [11]=1, [12]=1, [13]=1, [14]=1, [15]=1, [16]=1, [17]=1, [18]=1, [19]=1, [20]=1, [21]=1, [22]=1 }, buff = true }, -- lilisette_ii
        [1014] = { jobs = { [1]=1, [2]=1, [3]=1, [4]=1, [5]=1, [6]=1, [7]=1, [8]=1, [9]=1, [10]=1, [11]=1, [12]=1, [13]=1, [14]=1, [15]=1, [16]=1, [17]=1, [18]=1, [19]=1, [20]=1, [21]=1, [22]=1 }, buff = true }, -- tenzen_ii
        [1015] = { jobs = { [1]=1, [2]=1, [3]=1, [4]=1, [5]=1, [6]=1, [7]=1, [8]=1, [9]=1, [10]=1, [11]=1, [12]=1, [13]=1, [14]=1, [15]=1, [16]=1, [17]=1, [18]=1, [19]=1, [20]=1, [21]=1, [22]=1 }, buff = true }, -- mumor_ii
        [1016] = { jobs = { [1]=1, [2]=1, [3]=1, [4]=1, [5]=1, [6]=1, [7]=1, [8]=1, [9]=1, [10]=1, [11]=1, [12]=1, [13]=1, [14]=1, [15]=1, [16]=1, [17]=1, [18]=1, [19]=1, [20]=1, [21]=1, [22]=1 }, buff = true }, -- ingrid_ii
        [1017] = { jobs = { [1]=1, [2]=1, [3]=1, [4]=1, [5]=1, [6]=1, [7]=1, [8]=1, [9]=1, [10]=1, [11]=1, [12]=1, [13]=1, [14]=1, [15]=1, [16]=1, [17]=1, [18]=1, [19]=1, [20]=1, [21]=1, [22]=1 }, buff = true }, -- arciela_ii
        [1018] = { jobs = { [1]=1, [2]=1, [3]=1, [4]=1, [5]=1, [6]=1, [7]=1, [8]=1, [9]=1, [10]=1, [11]=1, [12]=1, [13]=1, [14]=1, [15]=1, [16]=1, [17]=1, [18]=1, [19]=1, [20]=1, [21]=1, [22]=1 }, buff = true }, -- iroha_ii
        [1019] = { jobs = { [1]=1, [2]=1, [3]=1, [4]=1, [5]=1, [6]=1, [7]=1, [8]=1, [9]=1, [10]=1, [11]=1, [12]=1, [13]=1, [14]=1, [15]=1, [16]=1, [17]=1, [18]=1, [19]=1, [20]=1, [21]=1, [22]=1 }, buff = true }, -- shantotto_ii
    },
    abilities = {
        [16] = { job = 1, level = 1, buff = true }, -- mighty_strikes
        [17] = { job = 2, level = 1, buff = true }, -- hundred_fists
        [18] = { job = 3, level = 1, buff = false }, -- benediction
        [19] = { job = 4, level = 1, buff = true }, -- manafont
        [20] = { job = 5, level = 1, buff = true }, -- chainspell
        [21] = { job = 6, level = 1, buff = true }, -- perfect_dodge
        [22] = { job = 7, level = 1, buff = true }, -- invincible
        [23] = { job = 8, level = 1, buff = true }, -- blood_weapon
        [24] = { job = 9, level = 1, buff = false }, -- familiar
        [25] = { job = 10, level = 1, buff = true }, -- soul_voice
        [26] = { job = 11, level = 1, buff = false }, -- eagle_eye_shot
        [27] = { job = 12, level = 1, buff = true }, -- meikyo_shisui
        [28] = { job = 13, level = 1, buff = false }, -- mijin_gakure
        [29] = { job = 14, level = 1, buff = true }, -- spirit_surge
        [30] = { job = 15, level = 1, buff = true }, -- astral_flow
        [31] = { job = 1, level = 15, buff = true }, -- berserk
        [32] = { job = 1, level = 35, buff = true }, -- warcry
        [33] = { job = 1, level = 25, buff = true }, -- defender
        [34] = { job = 1, level = 45, buff = true }, -- aggressor
        [35] = { job = 1, level = 5, buff = false }, -- provoke
        [36] = { job = 2, level = 25, buff = true }, -- focus
        [37] = { job = 2, level = 15, buff = true }, -- dodge
        [38] = { job = 2, level = 35, buff = false }, -- chakra
        [39] = { job = 2, level = 5, buff = true }, -- boost
        [40] = { job = 2, level = 45, buff = true }, -- counterstance
        [41] = { job = 6, level = 5, buff = false }, -- steal
        [42] = { job = 6, level = 25, buff = true }, -- flee
        [43] = { job = 6, level = 45, buff = true }, -- hide
        [44] = { job = 6, level = 15, buff = true }, -- sneak_attack
        [45] = { job = 6, level = 35, buff = false }, -- mug
        [46] = { job = 7, level = 15, buff = false }, -- shield_bash
        [47] = { job = 7, level = 5, buff = true }, -- holy_circle
        [48] = { job = 7, level = 30, buff = true }, -- sentinel
        [49] = { job = 8, level = 30, buff = true }, -- souleater
        [50] = { job = 8, level = 5, buff = true }, -- arcane_circle
        [51] = { job = 8, level = 15, buff = true }, -- last_resort
        [52] = { job = 9, level = 1, buff = false }, -- charm
        [53] = { job = 9, level = 10, buff = false }, -- gauge
        [54] = { job = 9, level = 30, buff = false }, -- tame
        [55] = { job = 9, level = 1, buff = false }, -- pet_commands
        [56] = { job = 11, level = 10, buff = false }, -- scavenge
        [57] = { job = 11, level = 40, buff = false }, -- shadowbind
        [58] = { job = 11, level = 20, buff = true }, -- camouflage
        [59] = { job = 11, level = 1, buff = true }, -- sharpshot
        [60] = { job = 11, level = 30, buff = true }, -- barrage
        [61] = { job = 14, level = 1, buff = false }, -- call_wyvern
        [62] = { job = 12, level = 15, buff = true }, -- third_eye
        [63] = { job = 12, level = 30, buff = true }, -- meditate
        [64] = { job = 12, level = 5, buff = true }, -- warding_circle
        [65] = { job = 14, level = 5, buff = true }, -- ancient_circle
        [66] = { job = 14, level = 10, buff = false }, -- jump
        [67] = { job = 14, level = 35, buff = false }, -- high_jump
        [68] = { job = 14, level = 50, buff = false }, -- super_jump
        [69] = { job = 9, level = 1, buff = false }, -- fight
        [70] = { job = 9, level = 10, buff = false }, -- heel
        [71] = { job = 9, level = 35, buff = false }, -- leave
        [72] = { job = 9, level = 25, buff = false }, -- sic
        [73] = { job = 9, level = 15, buff = false }, -- stay
        [74] = { job = 3, level = 15, buff = true }, -- divine_seal
        [75] = { job = 4, level = 15, buff = true }, -- elemental_seal
        [76] = { job = 6, level = 30, buff = true }, -- trick_attack
        [77] = { job = 8, level = 20, buff = false }, -- weapon_bash
        [78] = { job = 9, level = 12, buff = false }, -- reward
        [79] = { job = 7, level = 35, buff = true }, -- cover
        [80] = { job = 14, level = 25, buff = false }, -- spirit_link
        [82] = { job = 2, level = 41, buff = false }, -- chi_blast
        [83] = { job = 5, level = 40, buff = false }, -- convert
        [84] = { job = 6, level = 65, buff = false }, -- accomplice
        [85] = { job = 9, level = 23, buff = false }, -- call_beast
        [86] = { job = 11, level = 51, buff = true }, -- unlimited_shot
        [87] = { job = 14, level = 1, buff = false }, -- dismiss
        [88] = { job = 15, level = 1, buff = false }, -- assault
        [89] = { job = 15, level = 1, buff = false }, -- retreat
        [90] = { job = 15, level = 1, buff = false }, -- release
        [91] = { job = 15, level = 1, buff = false }, -- blood_pact_rage
        [92] = { job = 7, level = 62, buff = true }, -- rampart
        [93] = { job = 16, level = 1, buff = true }, -- azure_lore
        [94] = { job = 16, level = 40, buff = true }, -- chain_affinity
        [95] = { job = 16, level = 25, buff = true }, -- burst_affinity
        [96] = { job = 17, level = 1, buff = false }, -- wild_card
        [97] = { job = 17, level = 5, buff = false }, -- phantom_roll
        [98] = { job = 17, level = 49, buff = true }, -- fighters_roll
        [99] = { job = 17, level = 31, buff = true }, -- monks_roll
        [100] = { job = 17, level = 20, buff = true }, -- healers_roll
        [101] = { job = 17, level = 58, buff = true }, -- wizards_roll
        [102] = { job = 17, level = 46, buff = true }, -- warlocks_roll
        [103] = { job = 17, level = 43, buff = true }, -- rogues_roll
        [104] = { job = 17, level = 55, buff = true }, -- gallants_roll
        [105] = { job = 17, level = 14, buff = true }, -- chaos_roll
        [106] = { job = 17, level = 34, buff = true }, -- beast_roll
        [107] = { job = 17, level = 26, buff = true }, -- choral_roll
        [108] = { job = 17, level = 11, buff = true }, -- hunters_roll
        [109] = { job = 17, level = 37, buff = true }, -- samurai_roll
        [110] = { job = 17, level = 8, buff = true }, -- ninja_roll
        [111] = { job = 17, level = 23, buff = true }, -- drachen_roll
        [112] = { job = 17, level = 40, buff = true }, -- evokers_roll
        [113] = { job = 17, level = 17, buff = true }, -- maguss_roll
        [114] = { job = 17, level = 5, buff = true }, -- corsairs_roll
        [115] = { job = 17, level = 52, buff = true }, -- puppet_roll
        [116] = { job = 17, level = 61, buff = true }, -- dancers_roll
        [117] = { job = 17, level = 64, buff = true }, -- scholars_roll
        [123] = { job = 17, level = 5, buff = false }, -- double-up
        [124] = { job = 17, level = 40, buff = false }, -- quick_draw
        [125] = { job = 17, level = 40, buff = false }, -- fire_shot
        [126] = { job = 17, level = 40, buff = false }, -- ice_shot
        [127] = { job = 17, level = 40, buff = false }, -- wind_shot
        [128] = { job = 17, level = 40, buff = false }, -- earth_shot
        [129] = { job = 17, level = 40, buff = false }, -- thunder_shot
        [130] = { job = 17, level = 40, buff = false }, -- water_shot
        [131] = { job = 17, level = 40, buff = false }, -- light_shot
        [132] = { job = 17, level = 40, buff = false }, -- dark_shot
        [133] = { job = 17, level = 50, buff = false }, -- random_deal
        [135] = { job = 18, level = 1, buff = true }, -- overdrive
        [136] = { job = 18, level = 1, buff = false }, -- activate
        [137] = { job = 18, level = 15, buff = false }, -- repair
        [138] = { job = 18, level = 1, buff = false }, -- deploy
        [139] = { job = 18, level = 1, buff = false }, -- deactivate
        [140] = { job = 18, level = 10, buff = false }, -- retrieve
        [141] = { job = 18, level = 1, buff = true }, -- fire_maneuver
        [142] = { job = 18, level = 1, buff = true }, -- ice_maneuver
        [143] = { job = 18, level = 1, buff = true }, -- wind_maneuver
        [144] = { job = 18, level = 1, buff = true }, -- earth_maneuver
        [145] = { job = 18, level = 1, buff = true }, -- thunder_maneuver
        [146] = { job = 18, level = 1, buff = true }, -- water_maneuver
        [147] = { job = 18, level = 1, buff = true }, -- light_maneuver
        [148] = { job = 18, level = 1, buff = true }, -- dark_maneuver
        [149] = { job = 1, level = 75, buff = true }, -- warriors_charge
        [150] = { job = 1, level = 75, buff = false }, -- tomahawk
        [151] = { job = 2, level = 75, buff = true }, -- mantra
        [152] = { job = 2, level = 75, buff = true }, -- formless_strikes
        [153] = { job = 3, level = 75, buff = false }, -- martyr
        [154] = { job = 3, level = 75, buff = false }, -- devotion
        [155] = { job = 6, level = 75, buff = true }, -- assassins_charge
        [156] = { job = 6, level = 75, buff = true }, -- feint
        [157] = { job = 7, level = 75, buff = true }, -- fealty
        [158] = { job = 7, level = 75, buff = true }, -- chivalry
        [159] = { job = 8, level = 75, buff = true }, -- dark_seal
        [160] = { job = 8, level = 75, buff = true }, -- diabolic_eye
        [161] = { job = 9, level = 75, buff = false }, -- feral_howl
        [162] = { job = 9, level = 75, buff = true }, -- killer_instinct
        [163] = { job = 10, level = 75, buff = true }, -- nightingale
        [164] = { job = 10, level = 75, buff = true }, -- troubadour
        [165] = { job = 11, level = 75, buff = true }, -- stealth_shot
        [166] = { job = 11, level = 75, buff = true }, -- flashy_shot
        [167] = { job = 12, level = 75, buff = false }, -- shikikoyo
        [168] = { job = 12, level = 75, buff = false }, -- blade_bash
        [169] = { job = 14, level = 75, buff = true }, -- deep_breathing
        [170] = { job = 14, level = 75, buff = false }, -- angon
        [171] = { job = 13, level = 75, buff = true }, -- sange
        [172] = { job = 15, level = 1, buff = false }, -- blood_pact_ward
        [173] = { job = 12, level = 25, buff = true }, -- hasso
        [174] = { job = 12, level = 35, buff = true }, -- seigan
        [175] = { job = 16, level = 75, buff = true }, -- convergence
        [176] = { job = 16, level = 75, buff = true }, -- diffusion
        [177] = { job = 17, level = 75, buff = true }, -- snake_eye
        [178] = { job = 17, level = 75, buff = false }, -- fold
        [179] = { job = 18, level = 75, buff = false }, -- role_reversal
        [180] = { job = 18, level = 75, buff = false }, -- ventriloquy
        [181] = { job = 19, level = 1, buff = true }, -- trance
        [182] = { job = 19, level = 5, buff = false }, -- sambas
        [183] = { job = 19, level = 15, buff = false }, -- waltzes
        [184] = { job = 19, level = 5, buff = true }, -- drain_samba
        [185] = { job = 19, level = 35, buff = true }, -- drain_samba_ii
        [186] = { job = 19, level = 65, buff = true }, -- drain_samba_iii
        [187] = { job = 19, level = 25, buff = true }, -- aspir_samba
        [188] = { job = 19, level = 60, buff = true }, -- aspir_samba_ii
        [189] = { job = 19, level = 45, buff = true }, -- haste_samba
        [190] = { job = 19, level = 15, buff = false }, -- curing_waltz
        [191] = { job = 19, level = 30, buff = false }, -- curing_waltz_ii
        [192] = { job = 19, level = 45, buff = false }, -- curing_waltz_iii
        [193] = { job = 19, level = 70, buff = false }, -- curing_waltz_iv
        [194] = { job = 19, level = 35, buff = false }, -- healing_waltz
        [195] = { job = 19, level = 25, buff = false }, -- divine_waltz
        [196] = { job = 19, level = 25, buff = true }, -- spectral_jig
        [197] = { job = 19, level = 55, buff = true }, -- chocobo_jig
        [198] = { job = 19, level = 25, buff = false }, -- jigs
        [199] = { job = 19, level = 20, buff = false }, -- steps
        [200] = { job = 19, level = 20, buff = false }, -- flourishes_i
        [201] = { job = 19, level = 20, buff = false }, -- quickstep
        [202] = { job = 19, level = 30, buff = false }, -- box_step
        [203] = { job = 19, level = 40, buff = false }, -- stutter_step
        [204] = { job = 19, level = 20, buff = false }, -- animated_flourish
        [205] = { job = 19, level = 30, buff = false }, -- desperate_flourish
        [206] = { job = 19, level = 40, buff = false }, -- reverse_flourish
        [207] = { job = 19, level = 45, buff = false }, -- violent_flourish
        [208] = { job = 19, level = 50, buff = true }, -- building_flourish
        [209] = { job = 19, level = 60, buff = false }, -- wild_flourish
        [210] = { job = 20, level = 1, buff = true }, -- tabula_rasa
        [211] = { job = 20, level = 10, buff = true }, -- light_arts
        [212] = { job = 20, level = 10, buff = true }, -- dark_arts
        [213] = { job = 19, level = 40, buff = false }, -- flourishes_ii
        [214] = { job = 20, level = 65, buff = false }, -- modus_veritas
        [215] = { job = 20, level = 10, buff = true }, -- penury
        [216] = { job = 20, level = 25, buff = true }, -- celerity
        [217] = { job = 20, level = 55, buff = true }, -- rapture
        [218] = { job = 20, level = 40, buff = true }, -- accession
        [219] = { job = 20, level = 10, buff = true }, -- parsimony
        [220] = { job = 20, level = 25, buff = true }, -- alacrity
        [221] = { job = 20, level = 55, buff = true }, -- ebullience
        [222] = { job = 20, level = 40, buff = true }, -- manifestation
        [223] = { job = 20, level = 10, buff = false }, -- stratagems
        [224] = { job = 11, level = 45, buff = true }, -- velocity_shot
        [225] = { job = 9, level = 45, buff = false }, -- snarl
        [226] = { job = 1, level = 60, buff = true }, -- retaliation
        [227] = { job = 2, level = 65, buff = true }, -- footwork
        [229] = { job = 10, level = 20, buff = true }, -- pianissimo
        [230] = { job = 12, level = 40, buff = true }, -- sekkanoki
        [232] = { job = 15, level = 50, buff = false }, -- elemental_siphon
        [233] = { job = 20, level = 35, buff = true }, -- sublimation
        [234] = { job = 20, level = 10, buff = true }, -- addendum_white
        [235] = { job = 20, level = 30, buff = true }, -- addendum_black
        [236] = { job = 6, level = 65, buff = false }, -- collaborator
        [237] = { job = 19, level = 75, buff = true }, -- saber_dance
        [238] = { job = 19, level = 75, buff = true }, -- fan_dance
        [239] = { job = 19, level = 75, buff = false }, -- no_foot_rise
        [240] = { job = 20, level = 75, buff = true }, -- altruism
        [241] = { job = 20, level = 75, buff = true }, -- focalization
        [242] = { job = 20, level = 75, buff = true }, -- tranquility
        [243] = { job = 20, level = 75, buff = true }, -- equanimity
        [244] = { job = 20, level = 75, buff = true }, -- enlightenment
        [245] = { job = 3, level = 40, buff = true }, -- afflatus_solace
        [246] = { job = 3, level = 40, buff = true }, -- afflatus_misery
        [247] = { job = 5, level = 50, buff = true }, -- composure
        [248] = { job = 13, level = 40, buff = true }, -- yonin
        [249] = { job = 13, level = 40, buff = true }, -- innin
        [250] = { job = 15, level = 55, buff = true }, -- avatars_favor
        [251] = { job = 9, level = 25, buff = false }, -- ready
        [382] = { job = 23, level = 1, buff = false }, -- relinquish
        [512] = { job = 15, level = 1, buff = false }, -- healing_ruby
        [513] = { job = 15, level = 5, buff = false }, -- poison_nails
        [514] = { job = 15, level = 24, buff = false }, -- shining_ruby
        [515] = { job = 15, level = 44, buff = false }, -- glittering_ruby
        [516] = { job = 15, level = 55, buff = false }, -- meteorite
        [517] = { job = 15, level = 65, buff = false }, -- healing_ruby_ii
        [518] = { job = 15, level = 1, buff = false }, -- searing_light
        [528] = { job = 15, level = 5, buff = false }, -- moonlit_charge
        [529] = { job = 15, level = 10, buff = false }, -- crescent_fang
        [530] = { job = 15, level = 21, buff = false }, -- lunar_cry
        [531] = { job = 15, level = 32, buff = false }, -- lunar_roar
        [532] = { job = 15, level = 43, buff = false }, -- ecliptic_growl
        [533] = { job = 15, level = 54, buff = false }, -- ecliptic_howl
        [534] = { job = 15, level = 65, buff = false }, -- eclipse_bite
        [536] = { job = 15, level = 1, buff = false }, -- howling_moon
        [544] = { job = 15, level = 1, buff = false }, -- punch
        [545] = { job = 15, level = 10, buff = false }, -- fire_ii
        [546] = { job = 15, level = 23, buff = false }, -- burning_strike
        [547] = { job = 15, level = 30, buff = false }, -- double_punch
        [548] = { job = 15, level = 38, buff = false }, -- crimson_howl
        [549] = { job = 15, level = 60, buff = false }, -- fire_iv
        [550] = { job = 15, level = 70, buff = false }, -- flaming_crush
        [551] = { job = 15, level = 75, buff = false }, -- meteor_strike
        [552] = { job = 15, level = 1, buff = false }, -- inferno
        [560] = { job = 15, level = 1, buff = false }, -- rock_throw
        [561] = { job = 15, level = 10, buff = false }, -- stone_ii
        [562] = { job = 15, level = 21, buff = false }, -- rock_buster
        [563] = { job = 15, level = 35, buff = false }, -- megalith_throw
        [564] = { job = 15, level = 46, buff = false }, -- earthen_ward
        [565] = { job = 15, level = 60, buff = false }, -- stone_iv
        [566] = { job = 15, level = 70, buff = false }, -- mountain_buster
        [567] = { job = 15, level = 75, buff = false }, -- geocrush
        [568] = { job = 15, level = 1, buff = false }, -- earthen_fury
        [576] = { job = 15, level = 1, buff = false }, -- barracuda_dive
        [577] = { job = 15, level = 10, buff = false }, -- water_ii
        [578] = { job = 15, level = 26, buff = false }, -- tail_whip
        [579] = { job = 15, level = 47, buff = false }, -- spring_water
        [580] = { job = 15, level = 33, buff = false }, -- slowga
        [581] = { job = 15, level = 60, buff = false }, -- water_iv
        [582] = { job = 15, level = 70, buff = false }, -- spinning_dive
        [583] = { job = 15, level = 75, buff = false }, -- grand_fall
        [584] = { job = 15, level = 1, buff = false }, -- tidal_wave
        [592] = { job = 15, level = 1, buff = false }, -- claw
        [593] = { job = 15, level = 10, buff = false }, -- aero_ii
        [594] = { job = 15, level = 36, buff = false }, -- whispering_wind
        [595] = { job = 15, level = 48, buff = false }, -- hastega
        [596] = { job = 15, level = 25, buff = false }, -- aerial_armor
        [597] = { job = 15, level = 60, buff = false }, -- aero_iv
        [598] = { job = 15, level = 70, buff = false }, -- predator_claws
        [599] = { job = 15, level = 75, buff = false }, -- wind_blade
        [600] = { job = 15, level = 1, buff = false }, -- aerial_blast
        [608] = { job = 15, level = 1, buff = false }, -- axe_kick
        [609] = { job = 15, level = 10, buff = false }, -- blizzard_ii
        [610] = { job = 15, level = 28, buff = false }, -- frost_armor
        [611] = { job = 15, level = 39, buff = false }, -- sleepga
        [612] = { job = 15, level = 50, buff = false }, -- double_slap
        [613] = { job = 15, level = 60, buff = false }, -- blizzard_iv
        [614] = { job = 15, level = 70, buff = false }, -- rush
        [615] = { job = 15, level = 75, buff = false }, -- heavenly_strike
        [616] = { job = 15, level = 1, buff = false }, -- diamond_dust
        [624] = { job = 15, level = 1, buff = false }, -- shock_strike
        [625] = { job = 15, level = 10, buff = false }, -- thunder_ii
        [626] = { job = 15, level = 31, buff = false }, -- rolling_thunder
        [627] = { job = 15, level = 19, buff = false }, -- thunderspark
        [628] = { job = 15, level = 42, buff = false }, -- lightning_armor
        [629] = { job = 15, level = 60, buff = false }, -- thunder_iv
        [630] = { job = 15, level = 70, buff = false }, -- chaotic_strike
        [631] = { job = 15, level = 75, buff = false }, -- thunderstorm
        [632] = { job = 15, level = 1, buff = false }, -- judgment_bolt
        [656] = { job = 15, level = 1, buff = false }, -- camisado
        [657] = { job = 15, level = 20, buff = false }, -- somnolence
        [658] = { job = 15, level = 29, buff = false }, -- nightmare
        [659] = { job = 15, level = 37, buff = false }, -- ultimate_terror
        [660] = { job = 15, level = 49, buff = false }, -- noctoshield
        [661] = { job = 15, level = 56, buff = false }, -- dream_shroud
        [662] = { job = 15, level = 65, buff = false }, -- nether_blast
        [664] = { job = 15, level = 1, buff = false }, -- ruinous_omen
        [668] = { job = 15, level = 75, buff = false }, -- deconstruction
        [669] = { job = 15, level = 75, buff = false }, -- chronoshift
        [671] = { job = 15, level = 75, buff = false }, -- perfect_defense
        [672] = { job = 9, level = 25, buff = false }, -- foot_kick
        [673] = { job = 9, level = 25, buff = false }, -- dust_cloud
        [674] = { job = 9, level = 25, buff = false }, -- whirl_claws
        [675] = { job = 9, level = 25, buff = false }, -- head_butt
        [676] = { job = 9, level = 25, buff = false }, -- dream_flower
        [677] = { job = 9, level = 25, buff = false }, -- wild_oats
        [678] = { job = 9, level = 25, buff = false }, -- leaf_dagger
        [679] = { job = 9, level = 25, buff = false }, -- scream
        [680] = { job = 9, level = 25, buff = false }, -- roar
        [681] = { job = 9, level = 25, buff = false }, -- razor_fang
        [682] = { job = 9, level = 25, buff = false }, -- claw_cyclone
        [683] = { job = 9, level = 25, buff = false }, -- tail_blow
        [684] = { job = 9, level = 25, buff = false }, -- fireball
        [685] = { job = 9, level = 25, buff = false }, -- blockhead
        [686] = { job = 9, level = 25, buff = false }, -- brain_crush
        [687] = { job = 9, level = 25, buff = false }, -- infrasonics
        [688] = { job = 9, level = 25, buff = false }, -- secretion
        [689] = { job = 9, level = 25, buff = false }, -- lamb_chop
        [690] = { job = 9, level = 25, buff = false }, -- rage
        [691] = { job = 9, level = 25, buff = false }, -- sheep_charge
        [692] = { job = 9, level = 25, buff = false }, -- sheep_song
        [693] = { job = 9, level = 25, buff = false }, -- bubble_shower
        [694] = { job = 9, level = 25, buff = false }, -- bubble_curtain
        [695] = { job = 9, level = 25, buff = false }, -- big_scissors
        [696] = { job = 9, level = 25, buff = false }, -- scissor_guard
        [697] = { job = 9, level = 25, buff = false }, -- metallic_body
        [698] = { job = 9, level = 25, buff = false }, -- needleshot
        [699] = { job = 9, level = 25, buff = false }, -- random_needles
        [700] = { job = 9, level = 25, buff = false }, -- frogkick
        [701] = { job = 9, level = 25, buff = false }, -- spore
        [702] = { job = 9, level = 25, buff = false }, -- queasyshroom
        [703] = { job = 9, level = 25, buff = false }, -- numbshroom
        [704] = { job = 9, level = 25, buff = false }, -- shakeshroom
        [705] = { job = 9, level = 25, buff = false }, -- silence_gas
        [706] = { job = 9, level = 25, buff = false }, -- dark_spore
        [707] = { job = 9, level = 25, buff = false }, -- power_attack
        [708] = { job = 9, level = 25, buff = false }, -- hi-freq_field
        [709] = { job = 9, level = 25, buff = false }, -- rhino_attack
        [710] = { job = 9, level = 25, buff = false }, -- rhino_guard
        [711] = { job = 9, level = 25, buff = false }, -- spoil
        [712] = { job = 9, level = 25, buff = false }, -- cursed_sphere
        [713] = { job = 9, level = 25, buff = false }, -- venom
        [714] = { job = 9, level = 25, buff = false }, -- sandblast
        [715] = { job = 9, level = 25, buff = false }, -- sandpit
        [716] = { job = 9, level = 25, buff = false }, -- venom_spray
        [717] = { job = 9, level = 25, buff = false }, -- mandibular_bite
        [718] = { job = 9, level = 25, buff = false }, -- soporific
        [719] = { job = 9, level = 25, buff = false }, -- gloeosuccus
        [720] = { job = 9, level = 25, buff = false }, -- palsy_pollen
        [721] = { job = 9, level = 25, buff = false }, -- geist_wall
        [722] = { job = 9, level = 25, buff = false }, -- numbing_noise
        [723] = { job = 9, level = 25, buff = false }, -- nimble_snap
        [724] = { job = 9, level = 25, buff = false }, -- cyclotail
        [725] = { job = 9, level = 25, buff = false }, -- toxic_spit
        [726] = { job = 9, level = 25, buff = false }, -- double_claw
        [727] = { job = 9, level = 25, buff = false }, -- grapple
        [728] = { job = 9, level = 25, buff = false }, -- spinning_top
        [729] = { job = 9, level = 25, buff = false }, -- filamented_hold
        [730] = { job = 9, level = 25, buff = false }, -- chaotic_eye
        [731] = { job = 9, level = 25, buff = false }, -- blaster
        [732] = { job = 9, level = 25, buff = false }, -- suction
        [733] = { job = 9, level = 25, buff = false }, -- drainkiss
        [734] = { job = 9, level = 25, buff = false }, -- snow_cloud
        [735] = { job = 9, level = 25, buff = false }, -- wild_carrot
        [736] = { job = 9, level = 25, buff = false }, -- sudden_lunge
        [737] = { job = 9, level = 25, buff = false }, -- spiral_spin
        [738] = { job = 9, level = 25, buff = false }, -- noisome_powder
        [740] = { job = 10, level = 25, buff = false }, -- acid_mist
        [741] = { job = 10, level = 25, buff = false }, -- tp_drainkiss
        [743] = { job = 9, level = 26, buff = false }, -- scythe_tail
        [744] = { job = 9, level = 26, buff = false }, -- ripper_fang
        [745] = { job = 9, level = 25, buff = false }, -- chomp_rush
        [746] = { job = 9, level = 26, buff = false }, -- charged_whisker
        [747] = { job = 9, level = 25, buff = false }, -- purulent_ooze
        [748] = { job = 9, level = 25, buff = false }, -- corrosive_ooze
        [749] = { job = 9, level = 25, buff = false }, -- back_heel
        [750] = { job = 9, level = 25, buff = false }, -- jettatura
        [751] = { job = 9, level = 25, buff = false }, -- choke_breath
        [752] = { job = 9, level = 25, buff = false }, -- fantod
        [753] = { job = 9, level = 25, buff = false }, -- tortoise_stomp
        [754] = { job = 9, level = 25, buff = false }, -- harden_shell
        [755] = { job = 9, level = 25, buff = false }, -- aqua_breath
        [756] = { job = 9, level = 25, buff = false }, -- wing_slap
        [757] = { job = 9, level = 25, buff = false }, -- beak_lunge
        [758] = { job = 9, level = 25, buff = false }, -- intimidate
        [759] = { job = 9, level = 25, buff = false }, -- recoil_dive
        [760] = { job = 9, level = 25, buff = false }, -- water_wall
        [761] = { job = 9, level = 25, buff = false }, -- sensilla_blades
        [762] = { job = 9, level = 25, buff = false }, -- tegmina_buffet
        [763] = { job = 9, level = 25, buff = false }, -- molting_plumage
        [764] = { job = 9, level = 25, buff = false }, -- swooping_frenzy
        [765] = { job = 9, level = 25, buff = false }, -- sweeping_gouge
        [766] = { job = 9, level = 25, buff = false }, -- zealous_snort
        [767] = { job = 9, level = 25, buff = false }, -- pentapeck
        [768] = { job = 9, level = 25, buff = false }, -- tickling_tendrils
        [769] = { job = 9, level = 25, buff = false }, -- stink_bomb
        [770] = { job = 9, level = 25, buff = false }, -- nectarous_deluge
        [771] = { job = 9, level = 25, buff = false }, -- nepenthic_plunge
        [772] = { job = 9, level = 25, buff = false }, -- somersault
        [774] = { job = 9, level = 25, buff = false }, -- foul_waters
        [775] = { job = 9, level = 25, buff = false }, -- pestilent_plume
        [776] = { job = 9, level = 25, buff = false }, -- pecking_flurry
        [777] = { job = 9, level = 25, buff = false }, -- sickle_slash
        [778] = { job = 9, level = 25, buff = false }, -- acid_spray
        [779] = { job = 9, level = 25, buff = false }, -- spider_web
        [781] = { job = 9, level = 25, buff = false }, -- infected_leech
        [782] = { job = 9, level = 25, buff = false }, -- gloom_spray
        [786] = { job = 9, level = 25, buff = false }, -- disembowel
        [787] = { job = 9, level = 25, buff = false }, -- extirpating_salvo
        [788] = { job = 9, level = 25, buff = false }, -- venom_shower
        [789] = { job = 9, level = 25, buff = false }, -- mega_scissors
        [790] = { job = 9, level = 25, buff = false }, -- frenzied_rage
        [791] = { job = 9, level = 25, buff = false }, -- rhinowrecker
        [792] = { job = 9, level = 25, buff = false }, -- fluid_toss
        [793] = { job = 9, level = 25, buff = false }, -- fluid_spread
        [794] = { job = 9, level = 25, buff = false }, -- digest
        [795] = { job = 9, level = 25, buff = false }, -- crossthrash
        [796] = { job = 9, level = 25, buff = false }, -- predatory_glare
        [797] = { job = 9, level = 25, buff = false }, -- hoof_volley
        [798] = { job = 9, level = 25, buff = false }, -- nihility_song
    },
}
