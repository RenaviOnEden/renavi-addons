# PersonalHud

A small Ashita v4 addon for HorizonXI that shows your name, jobs, HP, MP, TP and XP (or LP once your XP is capped) in one themed box.

- **Author:** Renavi
- **Version:** 1.0
- **Ashita:** v4 (HorizonXI launcher)

> Code written with Claude (AI) at my direction. I tested it in game and maintain it.

> [!WARNING]
> **Not currently approved on HorizonXI.** It has not been sent to HorizonXI staff for review yet.
> Do not use it on HorizonXI until it shows on the approved addon list. Using unapproved addons can get your account banned.

## What it shows

- **Top line:** your name, XP to next level (or LP to next merit), and your jobs.
- **HP / MP bars:** current value and %. Low numbers turn yellow, orange, then red.
- **TP bar:** turns blue at 1000 TP.
- **XP / LP bar:** current points and %.
- The % on each bar is always centered. Letters over the filled part are dark, letters over the empty part are light.

## Settings window (`/phud`)

**Bars tab**
- Show / hide the HUD, the TP bar and the XP / LP bar.
- Hide the MP bar on jobs with no MP.
- Low HP / MP colors on or off.
- Click-through (mouse goes through the HUD).
- Hide while the full chat log is open (on by default).
- Bar colors: **Classic** (built-in colors) or **Theme** (colors from your theme).
- Bar width and height.
- Exact HUD position (X / Y).

**Theme tab**
- The same themes as PersonalBuffs, including Expansions (Vana'diel, Zilart, Promathia, Aht Urhgan, Goddess) and FFXIV.
- Style tweaks: header line, border, spacing, side stripe, text size, corner roundness, background opacity.
- Save your own looks as custom themes.
- **Match PersonalBuffs:** use whatever theme PersonalBuffs is using. Change the theme in `/pb` and the HUD follows within about 2 seconds.

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
| PersonalBuffs' saved settings file (only if Match PersonalBuffs is on) | Copying its theme |
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
| `/phud match` | Match PersonalBuffs on / off |
| `/phud profile save <name>` | Save your settings as a profile |
| `/phud profile load <name>` | Load a profile onto this character |
| `/phud profile delete <name>` | Delete a profile |
| `/phud profile list` | List profiles |
| `/phud menu` | Print the name of the game menu open right now (for checking) |

Drag the HUD to move it. Its spot is saved.

## Files

- `personalhud.lua` – the addon.
- `themes.lua` – the themes (shared look with PersonalBuffs).

## Known limits

- While **Match PersonalBuffs** is on, the HUD can only use themes your copy of PersonalBuffs has (all of them from PersonalBuffs 1.1.3 on).
- The full chat log check looks for a game menu named `fulllog`. If the HUD doesn't hide, open the full log, type `/phud menu` and report the name it prints.

## Credits

- Menu memory pattern as used by HXUI.
- Built for [Ashita v4](https://github.com/AshitaXI/Ashita-v4beta).

## License

GPL-3.0. See [`LICENSE`](../LICENSE).
