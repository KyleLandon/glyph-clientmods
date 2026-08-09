# Glyph client modpack auto-updater.
#
# Put this script in your Minecraft instance folder (the one that contains
# the mods/ folder) and run it — it downloads new and updated Glyph pack
# mods and removes pack mods that were dropped from the pack. Mods YOU
# added yourself are never touched: the updater only manages files it
# installed, tracked in mods/.glyph-pack-state.json.
#
# Recommended: add it as a pre-launch command in your launcher so your mods
# stay in sync with the server automatically (see the README).
#
# Optional: -ModsDir <path> to point somewhere other than <script dir>\mods.

param(
    [string]$ModsDir = (Join-Path $PSScriptRoot "mods")
)

$ErrorActionPreference = "Stop"
$manifestUrl = "https://raw.githubusercontent.com/KyleLandon/glyph-clientmods/main/manifest.json"

if (-not (Test-Path $ModsDir)) {
    New-Item -ItemType Directory $ModsDir | Out-Null
}
$statePath = Join-Path $ModsDir ".glyph-pack-state.json"

Write-Output "Glyph modpack updater — checking $manifestUrl"
try {
    $manifest = Invoke-RestMethod $manifestUrl -TimeoutSec 30
} catch {
    # Never block a game launch because GitHub is unreachable.
    Write-Warning "Could not fetch the pack manifest ($_). Launching with current mods."
    exit 0
}

$managed = @()
if (Test-Path $statePath) {
    try { $managed = @((Get-Content $statePath -Raw | ConvertFrom-Json).files) } catch { }
}

$downloaded = 0
$removed = 0
$keep = @()

foreach ($mod in $manifest.mods) {
    $target = Join-Path $ModsDir $mod.file
    $needed = $true
    if (Test-Path $target) {
        $hash = (Get-FileHash $target -Algorithm SHA256).Hash.ToLowerInvariant()
        $needed = ($hash -ne $mod.sha256)
    }
    if ($needed) {
        Write-Output "  downloading $($mod.file)"
        $temp = "$target.download"
        Invoke-WebRequest $mod.url -OutFile $temp -TimeoutSec 300
        $hash = (Get-FileHash $temp -Algorithm SHA256).Hash.ToLowerInvariant()
        if ($hash -ne $mod.sha256) {
            Remove-Item $temp
            Write-Warning "  checksum mismatch for $($mod.file) — skipped"
            continue
        }
        Move-Item $temp $target -Force
        $downloaded++
    }
    $keep += $mod.file
}

# Remove mods this updater previously installed that left the pack
# (usually old versions replaced by renamed jars).
foreach ($file in $managed) {
    if ($keep -notcontains $file) {
        $stale = Join-Path $ModsDir $file
        if (Test-Path $stale) {
            Write-Output "  removing old pack mod $file"
            Remove-Item $stale
            $removed++
        }
    }
}

@{ packVersion = $manifest.packVersion; files = $keep } |
    ConvertTo-Json | Set-Content $statePath -Encoding UTF8

if ($downloaded -eq 0 -and $removed -eq 0) {
    Write-Output "Up to date (pack $($manifest.packVersion), $($keep.Count) mods)."
} else {
    Write-Output ("Updated to pack $($manifest.packVersion): " +
        "$downloaded downloaded, $removed removed.")
}
