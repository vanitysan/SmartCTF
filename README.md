# SmartCTF 4J
<img width="1915" height="1079" alt="Screenshot 2026-10-18 192008" src="https://github.com/user-attachments/assets/42474b2c-e53c-43bd-bedf-633878ed7180" />
<img width="1919" height="1079" alt="Screenshot 2026-10-18 192308" src="https://github.com/user-attachments/assets/fb1dfc8d-a989-4121-976c-2172157db124" />
<img width="1862" height="880" alt="Screenshot 2026-10-18 192116" src="https://github.com/user-attachments/assets/85b063e4-4dcc-42d9-9fdd-873fe11dec5d" />



SmartCTF changes CTF scoring and adds team-oriented statistics, messages and HUD features. This version targets **Unreal Tournament 99, patch 469f**, with two-team CTF and compatible four-team CTF games and maps.

This document describes the current 4J implementation and its differences from older Versions

## Installation

1. Copy `SmartCTF_4J.u`, `SmartCTF_4J.int` and the `SmartCTF_4J.ini` into the game's `System` directory.
2. Add `ServerPackages=SmartCTF_4J` under `[Engine.GameEngine]` in the server's UnrealTournament.ini.
3. Enable the mutator `SmartCTF_4J.SmartCTF`. Do not run another SmartCTF version alongside it.
4. Restart the server. Use F1 for the scoreboard and F2 for server information.

The `.int` file supplies the mutator's menu entry. Four-team play additionally requires a compatible CTF4 game package and map; SmartCTF does not turn an ordinary map into a four-base map.

The main configuration has three sections: `SmartCTF`, `SmartCTFMultiConfig` and `SmartCTFSpreeConfig`. Restart the server after editing it. `mutate smartctf apply` validates already loaded settings; it does not reload the file from disk. Array entries use square brackets, for example `Texts[0]`.

## Changes since 4H

### Scoreboard and server information

- F1 and F2 use SmartCTF's interfaces whenever the mod is active. There is no option to switch back to the stock interfaces.
- The layout retains the original visual style, team headers, fonts, transparent faces and trophy, while adapting to client resolution and two or four teams.
- Player images are fitted proportionally, including skins with larger source textures.
- Player names have a fixed column based on approximately 15 characters. TM and EFF occupy aligned columns; long names are shortened when space is limited.
- Statistic bars reserve room for at least five digits. Their color moves from white toward green according to the player's share of the highest value; the leading value is fully green.
- Only actual spectators appear in the spectator list. Players waiting for match start remain in the team lists.
- F2 has 16 record categories, paginated when necessary. Labels precede a fixed, right-aligned number column sized for seven digits, followed by Who, Where and When.

### Scoring and detection

- Team/base handling supports all four team identities, including multiple friendly flag carriers.
- Defense and Seal retain 4H-style map-area detection. Seal is checked independently of Cover. Areas are identified from `PlayerLocation.LocationName`, falling back to `PlayerZone.ZoneName`, using RED, BLUE, GREEN, GOLD or YELLOW, case-insensitively. Maps without matching area names do not get a radius fallback for these checks.
- Capture and Assist use fixed bonuses. The optional 4H division of points according to flag-carry time, including its minimum capture bonus, is not implemented in 4J.
- Normal returns use one `ReturnBonus`. The separate 4H base/midfield/enemy-base return amounts are replaced by this setting. A qualifying close save uses `CloseSaveBonus` instead.
- Close-save detection checks all enemy bases. The base-to-base distance must exceed twice `CloseSaveRadius`; 4H used a 1.5-times separation check. This is a deliberate description of the current difference, not identical behavior at that boundary.
- Cover and Seal award their configured bonus immediately. 4H's additional capture-time reward for accumulated cover/seal actions is not part of the current implementation.
- SmartCTF bonuses are added to the game mode's own scoring. Turning off SmartCTF scoring still permits statistic collection.

### Messages and audio

- Multikill and killing-spree text, colors, animated colors and sound paths are configurable in their own sections.
- Messages use normal HUD message positions and fonts, with console history, instead of a separate configurable-position overlay.
- Cover, Seal, Long Range, Close Save and Spawnkill notices use the original message behavior and fixed presentation. Capture, Assist, Nice Catch and lead-change audio use client-side localized messages, as in 4H.
- `Sounds/holyshit.wav` is embedded as `SmartCTF_4J.Holyshit`; clients do not need the loose WAV file.

### Records

- Records cover 16 categories instead of the older smaller selection. The former Sacrifice/deaths record is not one of these 16 categories.
- Match totals and hourly rates have separate named record banks, selected by `bRecordsPerHour`.
- There is no minimum participation time. Records are committed once at confirmed match end, not every five seconds during play.
- Entries retain the familiar `Count`, `PlayerName`, `MapName`, `RecordDate` structure. Dates use `dd.mm.yyyy HH:MM:SS` and the server clock.
- Legacy 4J array records can be imported into the matching bank. Automatic conversion of an arbitrary 4H records file is not provided.

### Christmas and configuration

- The original 4H snow effect, 16 snowflake textures, presents and Santa are retained and scaled for the client display. The overlay is used on both F1 and F2.
- A server-date range now controls Christmas automatically, including ranges crossing New Year.
- Main settings are consolidated into `[SmartCTF_4J.SmartCTF]`.
- The current version has no Halloween/Easter overlay, general seasonal switch or seasonal world-flag replacement. Those were earlier 4J experiments, not features of this release.
- UI scale, panel dimensions, standard UI colors, statistic labels and enabled record categories are fixed internally. Old `SmartCTFSettingsConfig`, `SmartCTFCoolConfig` and `SmartCTFDeathConfig` sections are not used by the current configuration.

## Main INI section

Section: `[SmartCTF_4J.SmartCTF]`. The following settings are listed in the same order as the supplied INI. Distances are Unreal world units; times are seconds unless stated otherwise.

| Setting | Default | Meaning |
|---|---|---|
| `bEnabled` | `True` | Enables SmartCTF. If false, the mutator removes itself. It also refuses non-CTF game types. |
| `bDrawFaces` | `True` | Displays player face textures on F1. When disabled or unavailable, the fallback face is used. The carrier icon takes precedence. |
| `bShowCountryFlags` | `True` | Enables player country flags through the external IP-to-Country integration. |
| `CountryFlagsPackage` | `"CountryFlags32e"` | Texture package containing the country flags. This does not configure or install the country resolver. |
| `bShowSpectators` | `True` | Displays actual spectators in the scoreboard footer. |
| `bShowCarrierLocation` | `True` | Shows friendly flag-carrier location information on the HUD. |
| `bShowDamage` | `True` | Allows damage dealt to appear in the rotating F1 statistics. It does not disable damage collection or the F2 damage record when false. |
| `bShowRecords` | `True` | Displays the F2 record table. Record collection/saving remains independent of this display switch. |
| `bRecordsPerHour` | `False` | False selects match-total records; true selects normalized hourly records. Selects both the displayed and updated bank. |
| `bSmartScoring` | `True` | Applies SmartCTF's additional bonuses and spawnkill penalty. False leaves the underlying game scoring and statistic collection active. |
| `CapBonus` | `15` | Additional points for capturing an enemy flag. |
| `AssistBonus` | `7` | Additional points for each eligible friendly contributor who carried that flag during its current run, excluding the final capturer. |
| `GrabBonus` | `0` | Additional points for taking an enemy flag from its base. Picking up a dropped flag is not a new base grab. |
| `FlagKillBonus` | `3` | Additional points for killing an enemy flag carrier. |
| `CoverBonus` | `2` | Additional points for a qualifying kill while covering a friendly carrier. |
| `SealBonus` | `3` | Additional points for a qualifying base-sealing kill. |
| `ReturnBonus` | `2` | Additional points for a normal own-flag return. |
| `CloseSaveBonus` | `10` | Replaces ReturnBonus for a return qualifying as a close save; the two bonuses are not added together. |
| `CoverRadius` | `768` | Maximum distance from a friendly carrier to either the killer or victim for Cover. The killer must not be a carrier; enemy-carrier kills follow the FlagKill branch instead. |
| `CloseSaveRadius` | `900` | The returned flag must be nearer than this distance to an enemy base, and the two bases must be farther apart than twice this distance. |
| `MultiKillWindow` | `3` | Maximum gap between consecutive qualifying kills to continue a multikill chain. |
| `bSpawnkillDetection` | `True` | Detects kills during the victim's tracked spawn-protection period and enables the associated statistic, notice and optional penalty. Does not itself make newly spawned players invulnerable. |
| `SpawnProtectionSeconds` | `2` | Time limit after spawning used by spawnkill detection, while the tracked protection flag is still active. |
| `bCountWarmup` | `False` | False excludes the game's PendingMatch state from SmartCTF counting. True permits counting before match start; ended games remain excluded. |
| `SpawnKillPenalty` | `0` | Points deducted for a detected spawnkill when bSmartScoring is true. Zero keeps detection without deducting points. |
| `bPlayCaptureSound` | `True` | Enables the client-side capture announcement. Lead-change audio may take priority for that capture. |
| `bPlayAssistSound` | `True` | Enables the assist announcement for eligible contributors, subject to lead-announcement priority. |
| `bPlaySavedSound` | `True` | Enables Nice Catch audio for a close-save notice. That notice also requires the relevant enemy flag to be home. |
| `bPlayLeadSound` | `True` | Enables taken-lead/lost-lead announcements when a capture changes the unique leading team. |
| `bShowLongRangeMsg` | `True` | Enables the original Long Range and Uber Long Range notices for eligible kills over 1536 and 3072 units. Sniper/headshot, telefrag, Redeemer and SuperShockRifle cases are excluded. |
| `bShowSpawnKillerGlobalMsg` | `True` | Enables the global spawnkiller notice after more than two actions in the tracked spawnkill spree. Requires spawnkill detection. |
| `CoverMsgType` | `2` | Delivery mode for ordinary Cover notices; see the mode table below. |
| `CoverSpreeMsgType` | `3` | Delivery mode for special third/fourth Cover-spree notices. |
| `SealMsgType` | `3` | Delivery mode for the Seal-spree notice, triggered at the second Seal. |
| `SavedMsgType` | `3` | Delivery mode for Close Save notices. Does not control the separate sound switch. |
| `bXmasSB` | `True` | Enables the Christmas overlay on F1/F2 when the server date is in the configured range. |
| `bXmasImages` | `True` | Adds presents at bottom left and Santa at bottom right while the Christmas overlay is active. False keeps the snow without those images. |
| `bXmasStart` | `"01.12."` | Inclusive start date in `dd.mm.` format. Despite the name, this is a string, not a boolean. |
| `bXmasEnd` | `"06.01."` | Inclusive end date in `dd.mm.` format. A range crossing New Year is supported; invalid dates disable the overlay. |
| `PageSeconds` | `7` | Automatic page/statistic rotation interval on F1/F2. Clamped to 3–60 seconds. |
| `RedFlag` | `""` | Optional texture object path for the red team's actual flag and visible FlagBase skin. Empty uses the original. |
| `BlueFlag` | `""` | Equivalent flag-skin override for the blue team. |
| `GreenFlag` | `""` | Equivalent flag-skin override for the green team. |
| `YellowFlag` | `""` | Equivalent flag-skin override for the yellow/gold team. |
| `RedTeamHud` | `""` | Optional texture object path for the red team symbol in the F1 header. |
| `BlueTeamHud` | `""` | Equivalent F1 team-symbol override for blue. |
| `GreenTeamHud` | `""` | Equivalent F1 team-symbol override for green. |
| `YellowTeamHud` | `""` | Equivalent F1 team-symbol override for yellow/gold. |

### Notice delivery modes

Applies to CoverMsgType, CoverSpreeMsgType, SealMsgType and SavedMsgType:

| Value | Delivery |
|---|---|
| `0` | No notice. |
| `1` | Personal text message to the player who earned it. |
| `2` | Broadcast text message. |
| `3` | Broadcast localized HUD message using the original SmartCTF presentation. |

These controls affect notices, not scoring. Use values 0–3.

### Defense, Seal and Close Save details

Defense requires the enemy victim to be in the killer's own named team area, the killer's own flag to be home, and the victim's team not to be carrying a flag. If the killer's team has a carrier, the killer must itself be carrying a flag or a friendly carrier must be in the own team area. Defense alone awards no extra points.

Seal requires a friendly carrier and the enemy victim to be in the killer's own named area. The killer must not carry a flag, and the victim's team must not carry a flag. It is independent of Cover's distance check. Teamkills and flag-carrier kills do not additionally become Defense/Seal kills.

A close-save bonus depends on return location and base separation. The Close Save message and Nice Catch sound additionally require an enemy flag at the qualifying base to be home. A bonus can therefore be awarded without that message/sound.

### Custom texture packages and country flags

Example: `RedFlag="Flags_uK.FlagRed"`. Use a complete Unreal object path, not a filesystem path or loose PNG. Place the package in the appropriate game directory and distribute it to clients, for example with `ServerPackages=Flags_uK`. Several teams may use the same texture.

The flag overrides change skins, not meshes or gameplay. The override can remain visible on the flag while carried or dropped. TeamHud settings only change the F1 symbols. Invalid texture paths are logged and fall back to the original presentation.

Country flags require a separately configured IP-to-Country ServerActor exposing the expected `IpToCountry` tag/GetItemName interface, plus the selected flag texture package. For the default package, add `ServerPackages=CountryFlags32e`. SmartCTF includes no GeoIP database. Only actual network clients are queried; bots, local players and unknown results do not receive an invented flag. Only the country code is replicated, not the player's IP address.

### Christmas behavior

The server calendar determines activation; the footer clock remains local to each client. There are 100 snow particles using the 16 original textures. As in the original effect, snow becomes multicolored on December 24, 25 and 31 and January 1. Team/text colors and flag skins are unaffected. The snow effect originates from Defrost/CTT, with the original SmartCTF port by Sp0ngeb0b.

## Multikill and spree INI sections

Sections: `[SmartCTF_4J.SmartCTFMultiConfig]` and `[SmartCTF_4J.SmartCTFSpreeConfig]`.

### Shared settings

| Setting | Multi default | Spree default | Meaning |
|---|---|---|---|
| `bEnabled` | `True` | `True` | Enables this configurable message profile. It does not stop kill/statistic counting. |
| `bAnimateColor` | `True` | `True` | Enables color changes while the HUD message is visible. False uses BaseColor. |
| `BaseColor` | `(R=255,G=90,B=60)` | `(R=255,G=200,B=60)` | Fixed text color when animation is off; one endpoint when two-color animation is on. Each RGB channel is 0–255. |
| `SecondColor` | `(R=60,G=100,B=255)` | `(R=255,G=100,B=40)` | Other endpoint for the smooth two-color animation. Not used by rainbow mode. |
| `Duration` | `4` | `4` | HUD message lifetime in seconds; rounded to a whole number and limited to 1–15. |
| `ColorSpeed` | `3` | `3` | Color-animation speed multiplier, limited to 0.1–10. Higher values animate faster. |
| `bRainbow` | `False` | `True` | Uses a cycling RGB color effect instead of BaseColor/SecondColor blending. Requires bAnimateColor=True. |

Both sections use `Texts[index]` for the message and `SoundNames[index]` for its sound. Text and sound at the same index belong to the same event. A blank sound path means silence; blank text suppresses the event's configured message and sound.

Sounds require Unreal sound object paths, such as `Announcer.doublekill` or `SmartCTF_4J.Holyshit`, not WAV filenames. External sound packages must be installed and available to clients. HUD position, font/size and sound volume are fixed; there are no PositionY, TextScale, SoundVolume, SoundName, bConsole or bOverlay settings.

Supported text tokens:

| Token | Meaning |
|---|---|
| `{player}` | Player earning the event, or the killer who ends another player's spree. |
| `{victim}` | Victim for a multikill or ended-spree event; empty when no victim is supplied. |
| `{count}` | Multikill chain length, current spree length, or length of the spree that ended. |
| `{weapon}` | Supported by the formatter, but current Multi/Spree callers supply an empty weapon string. |

### Every multikill entry

Only indices **0–5** are supported. The message goes to the killer. Each kill must follow the previous qualifying kill within MultiKillWindow; death resets the chain. These names are the configured 4J labels.

| Text and sound entries | Trigger | Default text | Default sound |
|---|---|---|---|
| `Texts[0]`, `SoundNames[0]` | 2 kills | `DOUBLE KILL!` | `Announcer.doublekill` |
| `Texts[1]`, `SoundNames[1]` | 3 kills | `TRIPLE KILL!` | `Announcer.triplekill` |
| `Texts[2]`, `SoundNames[2]` | 4 kills | `MULTI KILL!` | `Announcer.multikill` |
| `Texts[3]`, `SoundNames[3]` | 5 kills | `MEGA KILL!` | `Announcer.megakill` |
| `Texts[4]`, `SoundNames[4]` | 6 kills | `ULTRA KILL!` | `Announcer.ultrakill` |
| `Texts[5]`, `SoundNames[5]` | 7 or more kills | `MONSTER KILL! ({count})` | `Announcer.monsterkill` |

### Every spree entry

Only indices **0–8** are supported. Spree notices are broadcast. Qualifying enemy kills increase the spree; death resets it.

| Text and sound entries | Trigger | Default text | Default sound |
|---|---|---|---|
| `Texts[0]`, `SoundNames[0]` | 5 kills | `{player} is on a killing spree! ({count})` | `Announcer.killingspree` |
| `Texts[1]`, `SoundNames[1]` | 10 kills | `{player} is on a rampage! ({count})` | `Announcer.rampage` |
| `Texts[2]`, `SoundNames[2]` | 15 kills | `{player} is dominating! ({count})` | `Announcer.dominating` |
| `Texts[3]`, `SoundNames[3]` | 20 kills | `{player} is unstoppable! ({count})` | `Announcer.unstoppable` |
| `Texts[4]`, `SoundNames[4]` | 25 kills | `{player} is GODLIKE! ({count})` | `Announcer.godlike` |
| `Texts[5]`, `SoundNames[5]` | 30 kills | `This is just too easy for {player}! ({count})` | `Botpack.SpreeSound` |
| `Texts[6]`, `SoundNames[6]` | 35 kills, then every additional 5 | `{player} is Brutalizing the Competition! ({count})` | `SmartCTF_4J.Holyshit` |
| `Texts[7]`, `SoundNames[7]` | Another player ends a spree of at least 5 | `{player} ended the spree of {victim}! ({count})` | `Botpack.SpreeSound` |
| `Texts[8]`, `SoundNames[8]` | Suicide/environmental end of a spree of at least 5 | `{player} ended their own spree! ({count})` | `Announcer.failed` |

## Record storage

Records are stored separately in `SmartCTF_4J_Records.ini`:

- `[SmartCTF_4J.SmartCTFEndStats]`: match-total records.
- `[SmartCTF_4J.SmartCTFHourlyStats]`: hourly records.

Only the selected bank is updated. An unused bank can contain initialized but empty entries; this does not mean saving has failed. Switching bRecordsPerHour does not convert old totals into hourly values.

Hourly values use `value * 3600 / active participation seconds` and are stored as integers. BestSpree is always the actual run length, not an hourly rate. There is no minimum participation threshold, so a short participation can produce a high hourly rate.

| Record key | Statistic |
|---|---|
| `MostPoints` | Player score, including the game mode's points and SmartCTF bonuses. |
| `MostFrags` | Qualifying enemy kills. |
| `MostCaps` | Flag captures. |
| `MostAssists` | Capture assists. |
| `MostGrabs` | Enemy flags taken from base. |
| `MostReturns` | Own-flag returns. |
| `MostFlagKills` | Enemy flag-carrier kills. |
| `MostCovers` | Cover actions. |
| `MostSeals` | Seal actions. |
| `MostDefenseKills` | Defense kills. |
| `MostHeadShots` | Headshot kills. |
| `MostDamage` | Recorded enemy damage dealt. |
| `MostCarrierSeconds` | Flag-carrying time in seconds. |
| `MostShieldBelts` | Shield-belt pickups. |
| `MostDamageAmps` | Damage-amplifier pickups. |
| `BestSpree` | Longest killing spree. |

Example format:

```ini
MostPoints=(Count=162,PlayerName="Player",MapName="Facing Worlds",RecordDate="18.10.2026 05:41:39")
```

`Count` is the best value, `PlayerName` identifies its holder, `MapName` is the map title, and `RecordDate` is its server timestamp. `bInitialized` is an internal migration marker, not a gameplay switch. A new record must strictly exceed the stored value; equal or zero values do not create a new holder. Saving occurs at confirmed match end, so an interrupted match does not commit its pending records. Preserve this file when installing updates.

## Credits

- v4: {PiN}Kev — 2004/01
- v4A: {DnF2}SiNiSTeR — 2004/12
- v4B/C: {DnF2}SiNiSTeR — 2005/03
- v4D: [es]Rush — 2006/01
- v4D++: adminthis — 2008/10
- v4E: adminthis, The_Cowboy & Sp0ngeb0b — 2009/12
- v4G: vanitysan aka HanNibaL — 2025/02
- v4H: vanitysan aka HanNibaL — 2025/08
- v4I: vanitysan aka HanNibaL — 2026/05
- v4J: vanitysan aka HanNibaL — 2026/10

Contact: vanitysan on Discord @ OldUnreal.
