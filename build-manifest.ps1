# Maintainer tool: regenerates manifest.json from the jars in mods/.
#
# Workflow when the server updates:
#   1. Drop the new/updated jars into mods/ (delete old versions).
#   2. Run this script.
#   3. Commit and push. Players pick up the change next time the updater runs.

$ErrorActionPreference = "Stop"

$repoRawBase = "https://raw.githubusercontent.com/KyleLandon/glyph-clientmods/main"
$modsDir = Join-Path $PSScriptRoot "mods"

$mods = Get-ChildItem $modsDir -Filter *.jar | Sort-Object Name | ForEach-Object {
    [ordered]@{
        file   = $_.Name
        sha256 = (Get-FileHash $_.FullName -Algorithm SHA256).Hash.ToLowerInvariant()
        size   = $_.Length
        url    = "$repoRawBase/mods/" + [uri]::EscapeDataString($_.Name)
    }
}

$manifest = [ordered]@{
    name        = "Glyph Client Modpack"
    packVersion = (Get-Date -Format "yyyy.MM.dd")
    minecraft   = "26.2"
    loader      = "fabric"
    server      = "play.glyphmc.net"
    mods        = @($mods)
}

$manifestPath = Join-Path $PSScriptRoot "manifest.json"
$manifest | ConvertTo-Json -Depth 5 | Set-Content $manifestPath -Encoding UTF8
Write-Output "Wrote manifest.json with $($mods.Count) mod(s), packVersion $($manifest.packVersion)"
