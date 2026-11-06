# PersonalBuffs

An Ashita v4 addon for HorizonXI that shows how much time is left on the buffs **you** cast — on yourself and on others — the debuffs you put on mobs, plus your own ability and spell recasts.

- **Author:** Renavi
- **Version:** 1.3.0
- **Ashita:** v4 (HorizonXI launcher)

> Code written with Claude (AI) at my direction. I tested it in game and maintain it.

> Also in this repo: [PersonalHud](../personalhud), a small HP / MP / TP / XP bar with the same themes.

> [!WARNING]
> **Not currently approved on HorizonXI.** It has been sent to HorizonXI staff for review.
> Do not use it on HorizonXI until it shows on the approved addon list. Using unapproved addons can get your account banned.

## What it shows

**Buff box**
- One row per buff you cast (spells, songs, rolls, job abilities), lowest timer first.
- Click a row to see each person who has it and their own timer.
- Times shown with `~` are estimates. Times without `~` were read from your own buff list.
- Optional: your party members' casts, marked like `Haste (Name)`. **Off by default.** Buffs they can only put on themselves (Stoneskin, Utsusemi, spikes...) are skipped.

**Recast box**
- Your own ability and spell recasts, read from your client. Shows "Ready" for 5 seconds when one comes off cooldown.

**Debuff box**
- Debuffs you put on mobs, one section per mob. Your target is listed first. Click a mob's name to fold its debuffs away.
- AoE debuffs (landing on 2 or more mobs at once, like Sleepga or Horde Lullaby) show as one row per spell at the top: `Horde Lullaby (4)` with the lowest timer. Click it to see each mob.
- Covers spells (Dia / Bio, Helix, blue magic...), weapon skills, Shield Bash / Weapon Bash, Light Shot, blood pacts, jug pet and automaton moves, and weapon procs.
- A debuff ends early when the game says it wore off or the mob dies. Cleared when you zone.
- Times are base times (no gear). On by default; turn off with `/pb debuffs`.
- Hide single debuffs or whole groups in the Debuffs tab, same as buffs (hidden by the spell, weapon skill, ability or pet move that puts it on).
- Party members' debuffs show only when party tracking is on, with who landed it: `Slow II (Aria)`.

**Settings window (`/pb`)**
- Per-job checkboxes to hide buffs, debuffs or recasts.
- Presets: save what is hidden under a name and load it any time (any character).
- Party tab: main on/off switch, plus a checkbox and gear boxes for each person in your party right now (e.g. tick **Dilation Ring** for a RDM so their Haste / Refresh get +30s). Their choices are kept for when they rejoin.
- Theme tab: themes in groups (Default, Glass, Nations, Dark, Simple, Expansions, FFXIV), each with sub-themes. Each theme sets colors and a style: timer bars, box headers, borders (none / thin / thick / double), side stripe, lines between groups, spacing, text size and corner roundness. Tweak any of it, then **Save look** to keep it as your own theme (Custom group). Also background opacity and exact box positions.
- Option to hide the boxes while the full chat log is open (timers keep running).
- Click-through option: mouse clicks go through the boxes to the game (`/pb lock`). Boxes can't be dragged while it's on; use the typed X / Y.
- Profiles: save every setting under a name and load it on another character.
- Test mode: fake buffs, debuffs and recasts so you can place the boxes without casting.

## How buff times are worked out

1. **Real time** – if the buff also landed on you, the time is read from your own status timers for a few seconds after it lands, and the longest is kept (this already counts your gear).
2. **Saved time** – the real time from an earlier cast of the same buff with the same gear setup.
3. **Estimate** – base time from `durations.lua` (from LandSandBoat) plus known gear bonuses. Shown with `~`.

Times on other people are always based on your own casts or your saved/estimated times. The addon cannot see other players' real buff timers.

## What it does NOT do

- Does **not** send packets, use commands, cast, or take any action for you. No automation of any kind.
- Does **not** change any game memory. It only reads.
- Does **not** track alliance members or strangers — party only, and only if you turn it on.
- Does **not** track Trusts.
- Does **not** connect to the internet or any outside service.
- Only writes files in its own Ashita config folder (`config\addons\personalbuffs\`): settings, saved profiles and presets.

## What it reads (for reviewers)

| Source | Used for |
|---|---|
| Incoming action packet `0x028` (read only) | Seeing which buffs you (or party members, if on) cast and who they landed on; debuffs landing on mobs |
| Incoming message packet `0x029` (read only) | Debuffs wearing off and mobs being defeated (Debuff box) |
| Your own buff list and status timers | Real time left on buffs that are on you |
| Vana'diel clock (memory pattern in `FFXiMain.dll`) | Turning your status timers into seconds |
| Your recast timers | Recast box |
| Your equipped items | Gear duration bonuses (e.g. instrument, Dilation Ring) |
| Party list | Names, checking a caster is in your party, your zone (Debuff box clears on zoning) |
| Entity list | Mob names, your / your party's pets, mob gone or defeated (Debuff box) |
| Your current target | Listing your target first in the Debuff box |
| Open game menu name (memory pattern in `FFXiMain.dll`, same one HXUI uses) | Hiding the boxes while the full chat log is open (optional) |
| Ashita resource manager | Spell / ability / item names |

## Install

1. Download the latest release zip (or **Code → Download ZIP**).
2. Inside the zip, copy the `personalbuffs` folder into `HorizonXI\Game\addons\` so you have `addons\personalbuffs\personalbuffs.lua`.
   Copy the inner `personalbuffs` folder, not the outer `renavi-addons-main` one.
3. In game: `/addon load personalbuffs`
4. To load it every time, add `/addon load personalbuffs` to your `scripts\default.txt`.

## Commands

| Command | What it does |
|---|---|
| `/pb` or `/pb config` | Open / close the settings window |
| `/pb test` | Test mode on / off (fake buffs, debuffs and recasts) |
| `/pb party` | Party buff tracking on / off |
| `/pb debuffs` | Debuff box on / off |
| `/pb lock` | Click-through on / off (mouse goes through the boxes) |
| `/pb clear` | Clear all current timers |
| `/pb hide <buff>` / `/pb show <buff>` | Hide / show a buff |
| `/pb hide recast <name>` / `/pb show recast <name>` | Hide / show a recast |
| `/pb hide debuff <name>` / `/pb show debuff <name>` | Hide / show a debuff |
| `/pb preset save <name>` / `load <name>` / `delete <name>` / `list` | Save what is hidden and load it again |
| `/pb list` | List what is hidden |
| `/pb theme` / `/pb theme <name>` | List themes / pick a theme (your saved ones work too) |
| `/pb profile save <name>` / `load <name>` / `delete <name>` / `list` | Save all settings and load them on another character |
| `/pb debug` | Chat lines when a buff or debuff starts and leaves the list (for bug reports) |

Drag the boxes to move them. Their spots are saved. With click-through on, use the typed X / Y in the Theme tab instead.

## Files

- `personalbuffs.lua` – the addon.
- `debuffs.lua` – Debuff box tracking (debuffs on mobs).
- `durations.lua` – base buff times by spell ID (from LandSandBoat).
- `jobdata.lua` – which job gets each spell / ability at level 75 (from LandSandBoat `spell_list.sql` / `abilities.sql`).

## Known limits

- If a buff is removed early (dispel, death, overwritten by someone else), its timer on other people keeps running until it ends.
- Times on other people are estimates unless the same buff also landed on you.
- Gear on other players cannot be seen. Tick their gear in the Party tab so their estimates include it.
- Debuff times are base times. Gear, merits and resists aren't counted, so a debuff can end before its timer (then the wear-off message clears it).

## Credits

- Buff durations and job spell lists: [LandSandBoat](https://github.com/LandSandBoat/server) (GPL-3.0).
- Built for [Ashita v4](https://github.com/AshitaXI/Ashita-v4beta).

## License

GPL-3.0. See [`LICENSE`](../LICENSE).
