# SmartCTF 4K

SmartCTF rewards the things that help a CTF team win: capturing flags, assisting carriers, covering teammates and saving your own flag. It also gives players a more detailed scoreboard and keeps server records between matches.

4K is built for **Unreal Tournament 99 with patch 469f**. It supports ordinary two-team CTF and compatible four-team CTF games. The familiar SmartCTF look is still there, with a layout that adapts to the player's resolution.

For release notes and bugfix details, see [Version history](VERSION_HISTORY.md).

## What's new in 4K

Compared with 4J:

- **F3 switches interfaces.** Players can switch F1 and F2 between SmartCTF and the game’s original scoreboard and server information. SmartCTF is selected at the start of each map.
- **More player statistics on F1.** Deaths and Seals are back in the rotating display. Headshots, shield belts and damage amps appear beside the name once their count is above zero. Damage dealt is labelled `Dmg.`.
- **More room for four-team games.** The tighter layout makes room for four players per team before paging at the tested resolutions. Available space still depends on the client’s display.
- **Most Deaths on F2.** The record table now has 17 categories, with up to nine rows per page so it fits on two pages when there is enough vertical space.
- **Better carrier labels.** Friendly flag carriers and their locations appear beneath the side team scores. Long names and locations are shortened to fit.
- **Player recovery.** Players who disconnect and return during the same map can recover their score and statistics.
- **Server welcome screen.** Add a logo, four caption lines and an intro sound. Position and sizing follow LogoSplashV3’s familiar format.
- **Smoother Christmas snow.** Santa and presents are included whenever the Christmas scoreboard is active.
- **Correct spree audio recipients.** The player earning a spree hears the configured announcement; everyone else hears the stock spree notification. Personal spree and multikill sounds respect the client’s announcer volume.
- **Native network message delivery.** Spree and multikill events use UT's normal localized-message route. Early events wait briefly for the client HUD and profiles instead of being discarded during initialization.
- **A clearer server startup log** and a grouped INI with three configuration sections.

Records are now saved in **`SmartCTF_Records.ini`**

## Installation

1. Stop the server and back up your current configuration and records.
2. Copy `SmartCTF_4K.u`, `SmartCTF_4K.int` and `SmartCTF_4K.ini` from `Dist/System` into the server’s `System` folder. Keep your own settings if you are updating an existing installation.
3. Add the following entries to the existing `[Engine.GameEngine]` section in the server configuration:

   ```ini
   ServerPackages=SmartCTF_4K
   ServerActors=SmartCTF_4K.SmartCTFServerActor
   ```

4. Restart the server. No additional SmartCTF entry in the mutator list is needed with this setup.

The ServerActor setup is the recommended installation method for servers. `SmartCTFServerActor` checks for a CTF game, creates SmartCTF if it is not already present, and registers it in the game's mutator chain. Do not use `ServerActors=SmartCTF_4K.SmartCTF` directly: that starts the actor without adding it to the normal mutator chain.

Alternatively, you can enable `SmartCTF_4K.SmartCTF` through the mutator list. That is also a supported installation method; omit the SmartCTF `ServerActors` entry when using it. Keep `ServerPackages=SmartCTF_4K` with either method.

Use only one SmartCTF version at a time. Four-team games also need a compatible CTF4 package and map; SmartCTF does not add bases to a two-team map.

If your server already has **`SmartCTF_4K_Records.ini`**, rename it to **`SmartCTF_Records.ini`** while the server is stopped. Leave its contents and section names unchanged. If the new filename already exists, keep a backup of both files rather than overwriting one.

Custom texture and sound packages must also be available to clients through your normal download setup. Add them to `ServerPackages` where needed.

## Playing with SmartCTF

| Key | Action |
|---|---|
| F1 | Scoreboard |
| F2 | Server information and records |
| F3 | Switch SmartCTF and default F1/F2 interfaces |

`bDoKeybind=True` adds the F3 command without discarding another action already bound to that key. Set it to False if you want players to manage their own bindings. This does not undo a binding already installed. `bExtraMsg` controls the short usage hint shown on joining; switching interfaces does not display an extra confirmation message.

The console command `mutate smartctf toggle` works without the F3 binding. The older `stats`, `showstats` and `forcestats` forms are aliases for the same toggle, for example `mutate smartctf stats`.

Admins can use `mutate smartctf apply` to validate the settings already loaded in memory. It **does not reload an edited INI**. Restart the server after changing the file. This command is also available in standalone games.

### F1: player statistics

Frags and points remain visible beside each player. The smaller statistics alternate between these two sets:

| Display | Left column | Right column |
|---|---|---|
| First set | Caps, Grabs, Assists | Covers, DefKills, FlagKls |
| Second set | Caps, Grabs, Returns | Deaths, Seals, Dmg. |

With `bShowDamage=False`, the last slot shows FlagKls instead of Dmg. Damage is still counted for records. `PageSeconds` controls the rotation and any additional player pages.

`HS`, `SB` and `AMP` show headshots, shield-belt pickups and damage-amplifier pickups when greater than zero. `TM` is time in minutes; `EFF` is the kill efficiency percentage. Their positions stay aligned instead of following the length of each name.

Faces keep their proportions even when a skin uses a larger texture. A green flag replaces the face while the player carries a flag. Country flags appear below the face when the IP-to-Country service has a result. Only actual spectators belong in the spectator list; players waiting for the match to start stay with their teams.

Numbers are right-aligned, and statistic bars leave room for at least five digits. Bar colors range from white to green, with the highest value shown in green. The footer uses the client’s local clock and includes the original author credits.

### F2: server information

F2 combines contact information, the message of the day, game and server totals, and the record table. Record names come first, followed by a fixed number column with room for seven digits, then the player, map and date. Pages turn automatically.

## Configuration

`SmartCTF_4K.ini` has three sections:

```ini
[SmartCTF_4K.SmartCTF]
[SmartCTF_4K.SmartCTFMultiConfig]
[SmartCTF_4K.SmartCTFSpreeConfig]
```

The comment headings and blank lines within the main section are just there to make it easier to read. Array settings use square brackets, such as `Texts[0]`. Times below are in seconds and distances are in Unreal world units.

### Main settings

The following groups follow the supplied INI. These are the shipped defaults.

### General

| Setting | Default | What it does |
|---|---|---|
| `bEnabled` | `True` | Enables SmartCTF. If false, the mutator removes itself. It also refuses non-CTF game types. |
| `bDoKeybind` | `True` | Adds the F3 interface-toggle command on the client, retaining other existing F3 actions. False leaves bindings alone; it does not remove a previously installed binding. |
| `bExtraMsg` | `True` | Shows the joining player a short F3/manual-command hint. |

### Scoreboard and Records

| Setting | Default | What it does |
|---|---|---|
| `bDrawFaces` | `True` | Displays player face textures on F1. When disabled or unavailable, the fallback face is used. The carrier icon takes precedence. |
| `bShowCountryFlags` | `True` | Enables player country flags through the external IP-to-Country integration. |
| `CountryFlagsPackage` | `"CountryFlags32e"` | Texture package containing the country flags. This does not configure or install the country resolver. |
| `bShowSpectators` | `True` | Displays actual spectators in the scoreboard footer. |
| `bShowCarrierLocation` | `True` | Shows friendly flag-carrier location information on the HUD. |
| `bShowDamage` | `True` | Allows damage dealt to appear in the rotating F1 statistics. It does not disable damage collection or the F2 damage record when false. |
| `bShowRecords` | `True` | Displays the F2 record table. Record collection/saving remains independent of this display switch. |
| `bRecordsPerHour` | `False` | False selects match-total records; true selects normalized hourly records. Selects both the displayed and updated bank. |
| `PageSeconds` | `7` | Automatic page/statistic rotation interval on F1/F2. Clamped to 3–60 seconds. |

### Scoring and Bonuses

| Setting | Default | What it does |
|---|---|---|
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
| `bSpawnkillDetection` | `True` | Detects kills during the tracked spawn-protection period for notices and an optional penalty. This does not make newly spawned players invulnerable. |
| `SpawnProtectionSeconds` | `2` | Time limit after spawning used by spawnkill detection, while the tracked protection flag is still active. |
| `bCountWarmup` | `False` | False excludes the game's PendingMatch state from SmartCTF counting. True permits counting before match start; ended games remain excluded. |
| `SpawnKillPenalty` | `0` | Points deducted for a detected spawnkill when bSmartScoring is true. Zero keeps detection without deducting points. |

### Messages and Sounds

| Setting | Default | What it does |
|---|---|---|
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

### Player Recovery

| Setting | Default | What it does |
|---|---|---|
| `bRestorePlayerStats` | `True` | Restores a returning player’s statistics within the same map. See Player recovery below. |

### Christmas

| Setting | Default | What it does |
|---|---|---|
| `bXmasSB` | `True` | Shows snow, Santa and presents on F1/F2 during the configured Christmas period. |
| `bXmasStart` | `"01.12."` | Inclusive start date in `dd.mm.` format. Despite the name, this is a string, not a boolean. |
| `bXmasEnd` | `"06.01."` | Inclusive end date in `dd.mm.` format. A range crossing New Year is supported; invalid dates disable the overlay. |

### Flag Textures and Team Symbols

| Setting | Default | What it does |
|---|---|---|
| `RedFlag` | `""` | Optional texture object path for the red team's actual flag and visible FlagBase skin. Empty uses the original. |
| `BlueFlag` | `""` | Equivalent flag-skin override for the blue team. |
| `GreenFlag` | `""` | Equivalent flag-skin override for the green team. |
| `YellowFlag` | `""` | Equivalent flag-skin override for the yellow/gold team. |
| `RedTeamHud` | `""` | Optional texture object path for the red team symbol in the F1 header. |
| `BlueTeamHud` | `""` | Equivalent F1 team-symbol override for blue. |
| `GreenTeamHud` | `""` | Equivalent F1 team-symbol override for green. |
| `YellowTeamHud` | `""` | Equivalent F1 team-symbol override for yellow/gold. |

### Server Splash Logo and Intro

| Setting | Default | What it does |
|---|---|---|
| `LogoTexture` | `""` | Server splash image as `Package.Texture`. Leave empty for no image. |
| `LogoDrawDelay` | `2` | Wait before showing the logo/captions, in seconds (0–120). |
| `LogoFadeInTime` | `1` | Fade-in duration in seconds (0–120); zero skips fading in. |
| `LogoDrawTime` | `10` | Fully visible hold time in seconds, between fade-in and fade-out. Clamped to 0–120. |
| `LogoFadeOutTime` | `1` | Fade-out duration in seconds (0–120); zero hides immediately after the hold. |
| `CaptionLineOne` | `""` | First centered line beneath the logo. |
| `CaptionLineTwo` | `""` | Second caption line. |
| `CaptionLineThree` | `""` | Third caption line. |
| `CaptionLineFour` | `""` | Fourth caption line. |
| `IntroSound` | `"SmartCTF_4K.Start"` | Joining sound as `Package.Sound`. The supplied Start sound is included in the mod; an empty value disables it. |
| `IntroSoundDelay` | `2` | Independent wait before the sound plays once, in seconds (0–120). |
| `bLogoTranslucent` | `True` | Translucent image during the hold phase; False draws it normally. |
| `Position` | `"left:15px,top:30%"` | LogoSplashV3 horizontal,vertical anchor; center or left/right/top/bottom offsets in px or %. |
| `Size` | `"byself:1"` | LogoSplashV3 sizing: byscreenx, byscreeny or byself. See examples above. |

### Cover, Seal and Close Save messages

`CoverMsgType`, `CoverSpreeMsgType`, `SealMsgType` and `SavedMsgType` accept these values:

| Value | Result |
|---|---|
| `0` | No message |
| `1` | Personal text message |
| `2` | Broadcast text message |
| `3` | Broadcast localized HUD message in the original SmartCTF style |

These settings change the messages, not the points awarded. Long Range, Close Save, Cover, Seal and Spawnkill notices keep their established SmartCTF wording and appearance.

### How scoring works

SmartCTF adds its bonuses to the game mode’s own scoring. Turning `bSmartScoring` off stops those extra bonuses and the spawnkill penalty, but statistics continue to be collected.

Defense and Seal use named map areas, following the older SmartCTF behavior. The checks look for RED, BLUE, GREEN, GOLD or YELLOW in the player location, falling back to the zone name. Letter case does not matter. Maps without those area names do not use a distance-based substitute.

Defense requires an enemy victim in the killer’s own area, the killer’s flag at home, and no flag carried by the victim’s team. If the killer’s team has a carrier, that carrier must be in the home area or be the killer. Defense itself adds no bonus points.

Seal requires a friendly carrier and the victim to be in the killer’s home area. The killer must not be carrying a flag, and the victim’s team must not have a carrier. Seal is checked independently of Cover. Teamkills and kills on enemy carriers do not also count as Defense or Seal.

A Close Save is a return near an enemy base, provided the bases are far enough apart. It awards `CloseSaveBonus` instead of `ReturnBonus`. The message and Nice Catch sound also require that enemy base’s flag to be home, so a return can earn the bonus without playing the notice.

For admins coming from 4H: captures and assists use fixed bonuses. Carry-time-based capture splits, separate return bonuses by map area, and extra capture-time Cover/Seal payouts are not included. Close Save requires a base separation greater than twice `CloseSaveRadius`.

### Flag textures and country flags

To change the red flag’s skin, for example:

```ini
RedFlag="Flags_uK.FlagRed"
```

Use an Unreal object path, not a loose image filename. This changes the actual flag and visible flag-base skin; it does not replace the model. The skin also applies while the flag is carried or dropped. The four `TeamHud` settings change only the symbols in the F1 team headers. Empty or invalid paths fall back to the original appearance, and failed loads are logged.

Country flags need a separate IP-to-Country ServerActor and a flag texture package. The resolver must expose the expected `IpToCountry` tag and `GetItemName` interface. With the supplied default, make `CountryFlags32e` available to clients, usually with `ServerPackages=CountryFlags32e`.

SmartCTF does not include a GeoIP database. Bots, local players and unresolved addresses have no country flag. Only the country code is sent to clients.

### The Christmas display

`bXmasSB=True` enables the Christmas display during `bXmasStart`–`bXmasEnd`, using the **server’s calendar**. Both dates are included, and December-to-January ranges work across New Year.

Snow, Santa and presents are all part of the display on F1 and F2. There is no separate image switch. On December 24, 25 and 31 and January 1, the snow becomes multicolored, as in the original effect. Team colors and world flags stay unchanged.

### Rejoining after a disconnect

With `bRestorePlayerStats=True`, a player who reconnects during the same map can recover their F1/F2 statistics. Recovery matches the player name, ignoring letter case, and IP address, ignoring the connection port. A different name or address will not match, and an active player’s entry cannot be claimed.

Restored values include score, deaths, frags, flag actions, headshots, damage, pickups, carrier time and Best Spree. Time spent disconnected is excluded from participation time. Current killing, Cover, Seal and spawnkill streaks reset, as does the multikill timer. Health, weapons, position and flag possession are not restored.

The server holds up to 256 entries for the current map. They are cleared on map change or restart, and recovery stops at match end. A player who leaves and does not return is not submitted to the record table through their stored recovery entry.

### Server logo, captions and intro sound

The default placement puts the logo 15 pixels from the left edge and 30% down the screen, at its original size. Here is a complete example:

```ini
LogoTexture="MyServerTextures.Logo"
LogoDrawDelay=2
LogoFadeInTime=1
LogoDrawTime=10
LogoFadeOutTime=1
CaptionLineOne="Welcome to our server"
CaptionLineTwo="SmartCTF 4K"
CaptionLineThree="Play fair and have fun"
CaptionLineFour="Enjoy your stay!"
IntroSound="SmartCTF_4K.Start"
IntroSoundDelay=2
bLogoTranslucent=True
Position="left:15px,top:30%"
Size="byself:1"
```

The presentation runs once per client map, rather than on every respawn. It waits, fades in, stays visible for `LogoDrawTime`, then fades out. The intro sound has its own delay and also works without a logo. Set `IntroSound=""` to disable it. The supplied Start and Holyshit sounds are embedded in the mod package; clients do not need loose WAV files.

Position and size follow LogoSplashV3:

| Example | Placement or size |
|---|---|
| `Position="left:15px,top:30%"` | 15 pixels from the left, 30% from the top |
| `Position="left:2%,center"` | 2% from the left, vertically centered |
| `Position="right:20px,bottom:30px"` | Insets from the right and bottom edges |
| `Position="center,top:10%"` | Horizontally centered, 10% from the top |
| `Size="byself:1"` | Original texture dimensions |
| `Size="byself:0.5"` | Half the original dimensions |
| `Size="byscreenx:25%"` | 25% of the screen width |
| `Size="byscreeny:20%"` | 20% of the screen height |

The image keeps its aspect ratio. Size values such as `byscreenx:0.25` also work. Oversized logos are fitted to the screen.

Captions use the original LogoSplashV3 layout: the small HUD font, each line centered under the image, with fixed offsets of 10, 20, 30 and 40 pixels. Empty slots keep their spacing. Keep captions short enough for your intended logo position; they are not automatically shortened or moved away from the screen edge. Captions can be shown without an image.

Translucent drawing makes a black logo background disappear. With `bLogoTranslucent=False`, the image is drawn normally while fully visible; fading still uses translucent drawing. F1/F2 may cover the splash while open.

## Multikill and spree messages

Edit `[SmartCTF_4K.SmartCTFMultiConfig]` for multikills and `[SmartCTF_4K.SmartCTFSpreeConfig]` for killing sprees. Both sections use the settings below.

| Setting | Multi default | Spree default | Meaning |
|---|---|---|---|
| `bEnabled` | `True` | `True` | Enables this configurable message profile. It does not stop kill/statistic counting. |
| `bAnimateColor` | `True` | `True` | Enables color changes while the HUD message is visible. False uses BaseColor. |
| `BaseColor` | `(R=255,G=90,B=60)` | `(R=255,G=200,B=60)` | Fixed text color when animation is off; one endpoint when two-color animation is on. Each RGB channel is 0–255. |
| `SecondColor` | `(R=60,G=100,B=255)` | `(R=255,G=100,B=40)` | Other endpoint for the smooth two-color animation. Not used by rainbow mode. |
| `Duration` | `4` | `4` | HUD message lifetime in seconds; rounded to a whole number and limited to 1–15. |
| `ColorSpeed` | `3` | `3` | Color-animation speed multiplier, limited to 0.1–10. Higher values animate faster. |
| `bRainbow` | `False` | `True` | Uses a cycling RGB color effect instead of BaseColor/SecondColor blending. Requires bAnimateColor=True. |

Use `Texts[index]` for the message and `SoundNames[index]` for its sound. Text and sound at the same index belong to the same event. A blank sound path means silence; blank text suppresses the event's configured message and sound.

Sounds require Unreal sound object paths, such as `Announcer.doublekill` or `SmartCTF_4K.Holyshit`, not WAV filenames. External sound packages must be installed and available to clients. Personal spree and multikill sounds follow the player’s announcer-volume setting, including sounds from custom packages. Setting that volume to zero mutes them. There is no separate SmartCTF volume setting, and message position and font follow the regular HUD.

Supported text tokens:

| Token | Meaning |
|---|---|
| `{player}` | Player earning the event, or the killer who ends another player's spree. |
| `{victim}` | Victim for a multikill or ended-spree event; empty when no victim is supplied. |
| `{count}` | Multikill chain length, current spree length, or length of the spree that ended. |
| `{weapon}` | Supported by the formatter, but current Multi/Spree callers supply an empty weapon string. |

### Multikill entries

Only indices **0–5** are supported. The message goes to the killer. Each kill must follow the previous qualifying kill within MultiKillWindow; death resets the chain.

| Text and sound entries | Trigger | Default text | Default sound |
|---|---|---|---|
| `Texts[0]`, `SoundNames[0]` | 2 kills | `DOUBLE KILL!` | `Announcer.doublekill` |
| `Texts[1]`, `SoundNames[1]` | 3 kills | `TRIPLE KILL!` | `Announcer.triplekill` |
| `Texts[2]`, `SoundNames[2]` | 4 kills | `MULTI KILL!` | `Announcer.multikill` |
| `Texts[3]`, `SoundNames[3]` | 5 kills | `MEGA KILL!` | `Announcer.megakill` |
| `Texts[4]`, `SoundNames[4]` | 6 kills | `ULTRA KILL!` | `Announcer.ultrakill` |
| `Texts[5]`, `SoundNames[5]` | 7 or more kills | `MONSTER KILL! ({count})` | `Announcer.monsterkill` |

### Spree entries

Only indices **0–8** are supported. Spree notices are broadcast. Qualifying enemy kills increase the spree; death resets it.

| Text and sound entries | Trigger | Default text | Default sound |
|---|---|---|---|
| `Texts[0]`, `SoundNames[0]` | 5 kills | `{player} is on a killing spree! ({count})` | `Announcer.killingspree` |
| `Texts[1]`, `SoundNames[1]` | 10 kills | `{player} is on a rampage! ({count})` | `Announcer.rampage` |
| `Texts[2]`, `SoundNames[2]` | 15 kills | `{player} is dominating! ({count})` | `Announcer.dominating` |
| `Texts[3]`, `SoundNames[3]` | 20 kills | `{player} is unstoppable! ({count})` | `Announcer.unstoppable` |
| `Texts[4]`, `SoundNames[4]` | 25 kills | `{player} is GODLIKE! ({count})` | `Announcer.godlike` |
| `Texts[5]`, `SoundNames[5]` | 30 kills | `This is just too easy for {player}! ({count})` | `Botpack.SpreeSound` |
| `Texts[6]`, `SoundNames[6]` | 35 kills, then every additional 5 | `{player} is Brutalizing the Competition! ({count})` | `SmartCTF_4K.Holyshit` |
| `Texts[7]`, `SoundNames[7]` | Another player ends a spree of at least 5 | `{player} ended the spree of {victim}! ({count})` | `Botpack.SpreeSound` |
| `Texts[8]`, `SoundNames[8]` | Suicide/environmental end of a spree of at least 5 | `{player} ended their own spree! ({count})` | `Announcer.failed` |

### Who hears the sounds?

Multikill messages and sounds go to the killer. For spree stages 0–6, the player earning the spree hears the configured sound; everyone else hears `Botpack.SpreeSound`, following the stock 469f behavior.

Spree sound 7 goes only to the player whose spree was ended. Sound 8 goes only to the player who ended their own spree. Stock UT is silent for these endings; set both entries to `""` if you prefer that behavior. Spree text is still broadcast.

Capture, Assist, Nice Catch and lead-change announcements are played on the receiving client, following the original SmartCTF approach. The joining sound is separate from the personal spree/multikill announcer path.

## Records

The server writes **`SmartCTF_Records.ini`** once at confirmed match end. There is no minimum participation time and no periodic record save during the match. An interrupted match does not commit its pending records.

The file contains two separate record sets:

| Section | Contents |
|---|---|
| `[SmartCTF_4K.SmartCTFEndStats]` | Match totals |
| `[SmartCTF_4K.SmartCTFHourlyStats]` | Hourly rates |

`bRecordsPerHour` chooses which set is displayed and updated. The other set may contain empty entries; that is normal. Changing the setting does not convert existing records.

Hourly rates are calculated from the player’s active participation time and stored as whole numbers. Best Spree always remains the actual spree length. Since there is no minimum time requirement, short appearances can produce high hourly rates.

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
| `MostDeaths` | Most deaths; displayed in F2 as Most Deaths. Uses the normal match/hourly bank selection. |

Each entry keeps the familiar format:

```ini
MostPoints=(Count=162,PlayerName="Player",MapName="Facing Worlds",RecordDate="19.10.2026 20:15:00")
```

The date uses the server clock in `dd.mm.yyyy HH:MM:SS` format. A new value must beat the existing record; a tie does not replace its holder. `bInitialized` is an internal migration marker and should be left alone. Back up this file when updating the mod.

Legacy array records can be imported into the matching set when present under the current class section. Arbitrary 4H record files are not automatically converted.

## Credits

SmartCTF has passed through several hands over the years. Thanks to everyone who kept it going:

- v4: {PiN}Kev — 2004/01
- v4A: {DnF2}SiNiSTeR — 2004/12
- v4B/C: {DnF2}SiNiSTeR — 2005/03
- v4D: [es]Rush — 2006/01
- v4D++: adminthis — 2008/10
- v4E: adminthis, The_Cowboy & Sp0ngeb0b — 2009/12
- v4G: vanitysan aka [s§s]HanNibaL — 2025/02
- v4H: vanitysan aka [s§s]HanNibaL — 2025/08
- v4I: vanitysan aka [s§s]HanNibaL — 2026/05
- v4J: vanitysan aka [s§s]HanNibaL — 2026/10
- v4K: vanitysan aka [s§s]HanNibaL — 2026/10

The splash layout follows SplashLogoSA by PJMODOS and LogoSplashV3 by [es]Rush. The Christmas snow effect comes from Defrost/CTT, with the original SmartCTF port by Sp0ngeb0b.

Project: [github.com/vanitysan/SmartCTF](https://github.com/vanitysan/SmartCTF)  
Contact: vanitysan on Discord @ OldUnreal.
