# Changelog

## 1.1.6

**New**
- Split HUD: name / jobs, HP, MP, TP and XP each in their own box (Bars tab). The boxes snap and stick to each other; **Re-stack** puts them back in one column. The target bar can stick to any of them. Split mode always keeps the MP box.
- New files: `split.lua` and `snap.lua`.

**Changed**
- Aht Urhgan theme retuned to desert bronze and gold.

## 1.1.5

**Changed**
- Bolder themes: San d'Oria, Bastok, Windurst, High Contrast, Vana'diel, Zilart, Promathia, Aht Urhgan and Goddess were retuned (same as PersonalBuffs 1.4.1).

## 1.1.4

**New**
- Target bar test mode: `/phud test` or the Target tab button shows a fake "Test Mob" when you have no target, so you can place the box. Not saved.

## 1.1.3

**New**
- Brightness slider for debuff letters that aren't on (default 55%).

## 1.1.2

**New**
- Type-in boxes next to every slider.

## 1.1.1

**New**
- The target bar snaps to the HUD: drag it within 20 px of a side and let go. It sticks there and moves with the HUD. Drag it away, press **Unsnap**, or type an X / Y to unstick it.
- The target bar is always the same width as the HUD. Long names are cut with "..." and debuff letters wrap to a second row.

## 1.1.0

**New**
- Target bar in its own box (Target tab, `/phud target`): name and mob ID, HP bar with %, distance, and a row of debuff letters that light up in their element's color. Counts debuffs from anyone, mobs only. Name color shows the type: player, NPC, unclaimed mob, your party's mob, someone else's mob.
- Copy PersonalBuffs' look (Theme tab button, `/phud copy`): a one-time copy of its theme, style and opacity that you can change after.
- Text size can go from 80% to 200% (was up to 130%).
- New files: `target.lua` and `debuffs.lua`.

**Fixes**
- TNL hid whenever its spot touched the name or jobs. It now slides into the free space and only hides when there is no room. The text is always `TNL` (XP) or `TNM` (merits).

## 1.0 – first release
- One box with your name, jobs, HP, MP, TP and XP (LP once your XP is capped).
- XP to next level (or LP to next merit) in the top line; centered % on the HP, MP and XP / LP bars.
- Same themes as PersonalBuffs, plus Expansions and FFXIV themes, style tweaks and saved custom looks.
- Match PersonalBuffs: follows PersonalBuffs' theme.
- Bar options: TP / XP bars on or off, hide MP on jobs with no MP, low HP / MP colors, Classic or Theme bar colors, bar width and height.
- Exact X / Y position, click-through, and hide while the full chat log is open.
- Profiles: save and load all settings by name (`/phud profile`).
