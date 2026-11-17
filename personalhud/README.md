# PersonalHud

A small Ashita v4 addon for HorizonXI that shows your name, jobs, HP, MP, TP and XP (or LP once your XP is capped) in one themed box, plus an optional target bar.

- **Author:** Renavi
- **Version:** 1.1.6
- **Ashita:** v4 (HorizonXI launcher)

> Code written with Claude (AI) at my direction. I tested it in game and maintain it.

> [!WARNING]
> **Not currently approved on HorizonXI.** It has not been sent to HorizonXI staff for review yet.
> Do not use it on HorizonXI until it shows on the approved addon list. Using unapproved addons can get your account banned.

## What it shows

- **Top line:** your name, `TNL` (XP to next level) or `TNM` (LP to next merit), and your jobs.
- **HP / MP bars:** current value and %. Low numbers turn yellow, orange, then red.
- **TP bar:** turns blue at 1000 TP.
- **XP / LP bar:** current points and %.
- The % on each bar is always centered. Letters over the filled part are dark, letters over the empty part are light.

**Target bar (its own box)**
- Target's name with its mob ID like `(1A3)`, HP bar with %, and distance.
- Name color shows the type: player, NPC, unclaimed mob, your party's mob, someone else's mob.
- A row of debuff letters. A letter lights up in its element's color while that debuff is on the mob. Counts debuffs from anyone; only mobs are tracked.
- Always the same width as the HUD. Drag it near a side of the HUD and let go to snap it there; it then moves with the HUD.

## Settings window (`/phud`)

**Bars tab**
- Show / hide the HUD, the TP bar and the XP / LP bar.
- **Split HUD:** name / jobs, HP, MP, TP and XP each in their own box. They snap and stick to each other; **Re-stack** puts them back in one column.
- Hide the MP bar on jobs with no MP (not in split mode).
- Low HP / MP colors on or off.
- Click-through (mouse goes through the HUD).
- Hide while the full chat log is open (on by default).
- Bar colors: **Classic** (built-in colors) or **Theme** (colors from your theme).
- Bar width and height. Every slider also has a type-in box.
- Exact HUD position (X / Y).

**Target tab**
- Target bar on / off, and which parts show (distance, mob ID, name colors, debuff letters).
- HP bar length, distance text size, and how bright the letters that aren't on are.
- Snap to the HUD on / off, **Unsnap**, and exact position.
- Test button: shows a fake "Test Mob" when you have no target.

**Theme tab**
- The same themes as PersonalBuffs, including Expansions (Vana'diel, Zilart, Promathia, Aht Urhgan, Goddess) and FFXIV.
- Style tweaks: header line, border, spacing, side stripe, text size, corner roundness, background opacity.
- Save your own looks as custom themes.
- **Match PersonalBuffs:** use whatever theme PersonalBuffs is using. Change the theme in `/pb` and the HUD follows within about 2 seconds.
- **Copy PersonalBuffs' look:** a one-time copy of its theme, style and opacity. Matching turns off so you can change it after.

**Profiles tab**
- Save every HUD setting under a name and load it on another character.
- Tip: use the same name as your PersonalBuffs profile.

## What it does NOT do

- Does **not** send packets, use commands, or take any action for you. No automation of any kind.
- Does **not** change any game memory. It only reads.
- Does **not** connect to the internet or any outside service.

## What it reads (for reviewers)

| Source | Used for |
|---|---|
| Party list (your own slot) | HP, MP, TP and name |
| Your player data | Jobs, levels, max HP / MP, XP, LP |
| Open game menu name (memory pattern in `FFXiMain.dll`, same one HXUI uses) | Hiding while the full chat log is open |
| Your current target and the entity list | Target bar: name, HP %, distance, mob ID, type and claim |
| Incoming action packet `0x028` (read only, only while debuff letters are on) | Debuffs landing on mobs (target bar letters) |
| Incoming message packet `0x029` (read only, only while debuff letters are on) | Debuffs wearing off and mobs being defeated |
| Mouse position over its own boxes | Dragging and snapping boxes |
| PersonalBuffs' saved settings file (only for Match / Copy PersonalBuffs) | Copying its theme |
| Ashita resource manager | Job names |

It writes only its own settings and profile files in `config\addons\personalhud\`.

## Install

1. Download the latest release zip (or **Code → Download ZIP**).
2. Inside the zip, copy the `personalhud` folder into `HorizonXI\Game\addons\` so you have `addons\personalhud\personalhud.lua`.
   Copy the inner `personalhud` folder, not the outer `renavi-addons-main` one.
3. In game: `/addon load personalhud`
4. To load it every time, add `/addon load personalhud` to your `scripts\default.txt`.

## Commands

| Command | What it does |
|---|---|
| `/phud` or `/phud config` | Open / close the settings window |
| `/phud toggle` / `/phud show` / `/phud hide` | Show or hide the HUD |
| `/phud theme` / `/phud theme <name>` | List themes / pick a theme (your saved ones work too) |
| `/phud target` | Target bar on / off |
| `/phud test` | Target bar test mode on / off (fake "Test Mob") |
| `/phud match` | Match PersonalBuffs on / off |
| `/phud copy` | Copy PersonalBuffs' look once |
| `/phud profile save <name>` | Save your settings as a profile |
| `/phud profile load <name>` | Load a profile onto this character |
| `/phud profile delete <name>` | Delete a profile |
| `/phud profile list` | List profiles |
| `/phud menu` | Print the name of the game menu open right now (for checking) |

Drag the HUD to move it. Its spot is saved.

## Files

- `personalhud.lua` – the addon.
- `themes.lua` – the themes (shared look with PersonalBuffs).
- `target.lua` – the target bar.
- `debuffs.lua` – debuff tracking for the target bar's letters (same tracker as PersonalBuffs).
- `split.lua` – split HUD boxes.
- `snap.lua` – snap math for the target bar and split boxes.

## Known limits

- While **Match PersonalBuffs** is on, the HUD can only use themes your copy of PersonalBuffs has (all of them from PersonalBuffs 1.1.3 on).
- Debuff letters use base times (no gear, merits or resists), so a letter can stay lit a little after the debuff is gone, until the wear-off message clears it.
- The full chat log check looks for a game menu named `fulllog`. If the HUD doesn't hide, open the full log, type `/phud menu` and report the name it prints.

## Credits

- Menu memory pattern as used by HXUI.
- Built for [Ashita v4](https://github.com/AshitaXI/Ashita-v4beta).

## License

GPL-3.0. See [`LICENSE`](../LICENSE).
