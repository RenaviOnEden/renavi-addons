# PersonalBuffs

An Ashita v4 addon for HorizonXI that shows how much time is left on the buffs **you** cast — on yourself and on others — plus your own ability and spell recasts.

- **Author:** Renavi
- **Version:** 1.1.3
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

**Settings window (`/pb`)**
- Per-job checkboxes to hide buffs or recasts.
- Party tab: main on/off switch, a checkbox per person, and gear boxes per person (e.g. tick **Dilation Ring** for a RDM so their Haste / Refresh get +30s).
- Theme tab: themes in groups (Default, Glass, Nations, Dark, Simple, Expansions, FFXIV), each with sub-themes. Each theme sets colors and a style: timer bars, box headers, borders (none / thin / thick / double), side stripe, lines between groups, spacing, text size and corner roundness. Tweak any of it, then **Save look** to keep it as your own theme (Custom group). Also background opacity and exact box positions.
- Option to hide the boxes while the full chat log is open (timers keep running).
- Profiles: save every setting under a name and load it on another character.
- Test mode: fake rows so you can place the windows without casting.

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
- Only writes files in its own Ashita config folder (`config\addons\personalbuffs\`): settings and saved profiles.

## What it reads (for reviewers)

| Source | Used for |
|---|---|
| Incoming action packet `0x028` (read only) | Seeing which buffs you (or party members, if on) cast and who they landed on |
| Your own buff list and status timers | Real time left on buffs that are on you |
| Vana'diel clock (memory pattern in `FFXiMain.dll`) | Turning your status timers into seconds |
| Your recast timers | Recast box |
| Your equipped items | Gear duration bonuses (e.g. instrument, Dilation Ring) |
| Party list | Names, and checking a caster is in your party |
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
| `/pb test` | Test mode on / off (fake buffs and recasts) |
| `/pb party` | Party buff tracking on / off |
| `/pb clear` | Clear all current timers |
| `/pb hide <buff>` / `/pb show <buff>` | Hide / show a buff |
| `/pb hide recast <name>` / `/pb show recast <name>` | Hide / show a recast |
| `/pb list` | List what is hidden |
| `/pb theme` / `/pb theme <name>` | List themes / pick a theme (your saved ones work too) |
| `/pb profile save <name>` / `load <name>` / `delete <name>` / `list` | Save all settings and load them on another character |
| `/pb debug` | Chat lines when a buff starts and leaves the list (for bug reports) |

Drag the boxes to move them. Their spots are saved.

## Files

- `personalbuffs.lua` – the addon.
- `durations.lua` – base buff times by spell ID (from LandSandBoat).
- `jobdata.lua` – which job gets each spell / ability at level 75 (from LandSandBoat `spell_list.sql` / `abilities.sql`).

## Known limits

- If a buff is removed early (dispel, death, overwritten by someone else), its timer on other people keeps running until it ends.
- Times on other people are estimates unless the same buff also landed on you.
- Gear on other players cannot be seen. Tick their gear in the Party tab so their estimates include it.

## Credits

- Buff durations and job spell lists: [LandSandBoat](https://github.com/LandSandBoat/server) (GPL-3.0).
- Built for [Ashita v4](https://github.com/AshitaXI/Ashita-v4beta).

## License

GPL-3.0. See [`LICENSE`](../LICENSE).
