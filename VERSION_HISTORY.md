# SmartCTF version history



## 4K — October 2026

### Scoreboard and HUD

- Added F3 switching between SmartCTF and the game’s original F1/F2 interfaces. The original scoreboard class is retained, including compatible CTF4 scoreboards.
- Restored `bDoKeybind` and `bExtraMsg`. The F3 binding keeps existing actions, and the joining hint can be disabled.
- Removed the confirmation messages when switching interfaces.
- Reduced vertical spacing in the four-team layout. At 1920×1080, four players per team fit before paging without reducing the font size.
- Added Most Deaths to F2. Its record is appended after the existing categories, preserving their stored indices.
- Increased F2 capacity to nine record rows per page where screen height allows. The 17 categories then fit on two pages.
- Moved friendly carrier names and locations beneath the side team scores.

### Welcome screen and Christmas display

- Added a server splash image, four caption lines and a joining sound. Logo and sound have separate delays.
- Embedded `start.wav` as `SmartCTF_4K.Start` and made it the default intro sound.
- Replaced the old snow sprites with a smoother texture. Snow movement and size adapt to the client display.
- Removed `bXmasImages`. Snow, Santa and presents now share `bXmasSB` and its existing date range. World flags are unchanged.

### Player recovery

- Added optional recovery for players who reconnect during the same map. Entries match the player’s name and IP address, ignoring letter case and the connection port.
- Recovery restores the statistics used by F1 and F2. Disconnected time is excluded from participation time.
- Current killing, Cover, Seal and spawnkill streaks are reset. Best Spree remains a saved statistic, and the multikill timer starts fresh.
- Health, inventory, position and flag possession are not restored. Recovery entries stay in memory and are cleared on map change or server restart.

### Fixes

- **Spree and Multikill delivery on dedicated servers:** replaced the custom statistics-actor `ClientNotice` RPC with UT's native `ReceiveLocalizedMessage` route. This removes the extra ownership and player-reference checks that could discard messages.
- **Misaligned F1 numbers:** rotating statistic labels could produce different number and bar positions. Both displays now share column widths measured with the active font, including space for at least five digits.
- **Wrong spree announcement:** other players could hear the personal stage announcement. Sound selection now checks the recipient’s player replication identity. The spree owner hears the configured sound; everyone else hears `Botpack.SpreeSound`.
- **Announcer volume:** personal spree and multikill sounds now use the stock 469f client playback path with announcer-volume control enabled. This also applies to custom sound packages.
- **Caption size and alignment:** replaced the custom caption layout with the original small-font positioning. Empty caption slots retain their spacing rather than moving later lines upward.

### Configuration and maintenance

- Grouped the INI with comment headings and blank lines while keeping three configuration sections.
- Renamed the record file to `SmartCTF_Records.ini`. Existing files can be renamed without changing their section names or record entries.
- Removed unused helpers, obsolete options and unused statistic counters.


## 4J — October 2026

4J rebuilt the tested 4H code into a 469f-focused version while retaining the original SmartCTF appearance.

### Features and layout

- Added two- and four-team layouts for the SmartCTF scoreboard and server information.
- Kept the original fonts, team headers and artwork while adapting the layout to client resolution.
- Added aligned TM/EFF fields and a fixed record-number column with room for seven digits.
- Restored the green carrier icon in place of the player face.
- Added configurable flag skins and F1 team symbols for all four teams.
- Added configurable multikill and spree text, colors, color animation and sounds.
- Added named match-total and hourly record sets. The selected set is controlled by `bRecordsPerHour`.
- Consolidated the main settings into the SmartCTF section. Christmas activation uses a server-date range that can cross New Year.

### Fixes and behavior changes

- **Large player textures:** faces now fit within a defined frame while preserving their aspect ratio. Their source resolution no longer determines the displayed size.
- **Opaque artwork:** restored transparent drawing for player faces and the F2 trophy, removing visible background boxes.
- **Flag skin replacement:** applying a skin only to the collectible flag missed the flag shown at home. The override now also updates the visible `FlagBase` skin.
- **Missing spectators:** the footer reads the replicated player list rather than relying on spectator pawns being present on the client.
- **Waiting players listed as spectators:** actual spectators are distinguished from players waiting for match start. Waiting players stay in the team lists.
- **Footer clock and spacing:** switched the displayed clock to local client time and separated it from the map/server line.
- **Client-only announcements:** Capture, Assist, Nice Catch and lead sounds are delivered through a localized message and played on the receiving client.
- **Defense and Seal checks:** restored named map-area detection and extended team-area handling to four bases. Seal is evaluated independently of Cover’s radius check.
- **Record persistence:** records are committed once at confirmed match end. Participation timing no longer relies on UT’s elapsed-time counter continuing to advance, and an overtime end attempt does not prematurely lock out saving.
- Removed the minimum participation-time requirement for records. Capture and assist bonuses are fixed; returns use one normal bonus or the Close Save bonus.

## Earlier releases

The following author and date entries come from the original source header. Detailed release notes are not reconstructed where the available history does not establish the changes.

| Version | Date | Author |
|---|---|---|
| 4I | May 2026 | vanitysan aka [s§s]HanNibaL |
| 4H | August 2025 | vanitysan aka [s§s]HanNibaL |
| 4G | February 2025 | vanitysan aka [s§s]HanNibaL |
| 4E | December 2009 | adminthis, The_Cowboy & Sp0ngeb0b |
| 4D++ | October 2008 | adminthis |
| 4D | January 2006 | [es]Rush |
| 4B/C | March 2005 | {DnF2}SiNiSTeR |
| 4A | December 2004 | {DnF2}SiNiSTeR |
| 4 | January 2004 | {PiN}Kev |

See [README.md](README.md) for the current settings and installation instructions.
