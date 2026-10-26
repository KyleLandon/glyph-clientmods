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
    minecraft   = "26.3"
    loader      = "fabric"
    server      = "play.glyphmc.net"
    mods        = @($mods)
}

# WriteAllText without BOM: Windows PowerShell's UTF8 adds a BOM, which
# breaks Invoke-RestMethod's JSON parsing on player machines.
$manifestPath = Join-Path $PSScriptRoot "manifest.json"
$json = $manifest | ConvertTo-Json -Depth 5
[System.IO.File]::WriteAllText($manifestPath, $json, [System.Text.UTF8Encoding]::new($false))
Write-Output "Wrote manifest.json with $($mods.Count) mod(s), packVersion $($manifest.packVersion)"
