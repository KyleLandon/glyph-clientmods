<p align="center"><img src="https://raw.githubusercontent.com/KyleLandon/glyph/main/assets/glyph-logo.png" alt="Glyph logo" width="160"></p>

# Glyph Client Modpack

Optional client mods for **play.glyphmc.net** (Minecraft 26.3, Fabric).
None of these are required to join — they add voice chat, maps, performance,
and quality-of-life features that match the server.

## What's included

| Mod | Why |
| --- | --- |
| Simple Voice Chat | Proximity voice on the server |
| Xaero's Minimap + World Map | Maps and waypoints. Move the minimap to the **left** (`Y` → Change Position) so it does not cover the server cash HUD on the right. |
| Sodium, ImmediatelyFast | Performance |
| Iris | Shader support |
| JEI | Recipe lookup |
| Jade | Block/entity tooltips |
| AppleSkin | Food/saturation info |
| Inventory Profiles Next | Inventory sorting |
| ShulkerBoxTooltip | Shulker previews |
| Mod Menu | In-game mod config |
| Fabric API, Fabric Language Kotlin, Cloth Config, Architectury, libIPN | Libraries the above need |

## Install (one time)

1. Install [Fabric Loader](https://fabricmc.net/use/installer/) for
   Minecraft **26.3** (or create a 26.3 Fabric instance in Prism/MultiMC/
   Modrinth App).
2. Download this pack: **Code → Download ZIP** (green button above), or
   [click here](https://github.com/KyleLandon/glyph-clientmods/archive/refs/heads/main.zip).
3. Copy the contents of the zip's `mods/` folder into your instance's
   `mods/` folder, and copy `update-glyph-mods.ps1` next to it (into the
   instance folder, e.g. `.minecraft/`).

## Stay up to date automatically

The server's mods change over time. `update-glyph-mods.ps1` syncs your
mods folder with this repository: it downloads new and updated pack mods
and removes pack mods we retire. **Mods you added yourself are never
touched.**

Run it manually any time:

```powershell
powershell -ExecutionPolicy Bypass -File update-glyph-mods.ps1
```

Or make your launcher run it before every launch so you never think about
it again:

- **Prism / MultiMC**: instance → Edit → Settings → Custom commands →
  Pre-launch command:

  ```
  powershell -ExecutionPolicy Bypass -File "$INST_MC_DIR/update-glyph-mods.ps1"
  ```

- **Vanilla launcher**: no pre-launch hook — just run the script whenever
  the server announces a pack update.

The updater never blocks your game: if GitHub is unreachable it logs a
warning and lets the launch continue with the mods you have.

## For pack maintainers

Drop the new jars into `mods/` (delete replaced versions), run
`build-manifest.ps1`, commit, push. Players get the change on their next
launch.
