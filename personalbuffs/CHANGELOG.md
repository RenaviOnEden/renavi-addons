# Changelog

## 1.1.3

**New**
- Profiles: save every setting under a name and load it on another character (Theme tab > Profiles, or `/pb profile save|load|delete|list`).
- `/pb debug`: chat lines when a buff starts (and where its time came from) and when it leaves the list (and why).
- Your own name shows as "You" in the buff list (same as test mode).

**Fixes**
- Buff times read from the wrong buff (e.g. Blade Madrigal showing your food's 20+ minutes). Timers are now matched with the buff icon list, which is in the same order. Songs over 10 minutes are ignored as a safety net.
- Songs (and other buffs) dropping early after a recast. Your buff timer is now read for a few seconds after a buff lands and the longest time is kept.

## 1.1.2
- New themes: Expansions group (Vana'diel, Zilart, Promathia, Aht Urhgan, Goddess) and FFXIV.
- New: option to hide the boxes while the full chat log is open.
- Party tracking skips buffs a party member can only cast on themselves (Stoneskin, Blink, Aquaveil, Utsusemi, Tonko, spikes, enspells, Berserk...).
- Fix: buffs you turn off in the Buffs tab are now hidden when party members cast them too.

## 1.1.1
- Fix: recast box no longer shows a fake "Brazen Rush" next to your 2-hour.

## 1.1

**New**
- Themes: grouped into Default, Glass, Nations, Dark and Simple, each with sub-themes (19 in all). Default is the original look.
- Each theme sets a full style: timer bars, box headers, borders (none / thin / thick / double), side stripe, lines between groups, spacing, text size and corner roundness.
- Tweak any style setting, plus background opacity, in the Theme tab.
- Save your own looks as custom themes (Save look / Update / Delete). `/pb theme <name>` works for them too.
- Box position: type X / Y or nudge with - / +.
- Recast box: "Abilities" and "Spells" labels (can be turned off).
- Party tab: tick gear a party member wears (Dilation Ring) so their Haste / Refresh estimates get the extra time.

**Fixes**
- Berserk, Warcry, Defender, Aggressor, Focus, Dodge and other job ability buffs now show in the buff box.
- Utsusemi now shows its real time (it shows on you under a different icon ID).
- Newer imgui calls are only used when your Ashita build has them, so a missing one can't stop the addon.

## 1.0 – first release
- Buff box: timers for buffs you cast, with per-person dropdown.
- Recast box: your ability and spell recasts.
- Settings window with per-job hide options.
- Optional party buff tracking (off by default).
- Test mode.
