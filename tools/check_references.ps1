# Apex Rush - reference integrity checker
#
# Verifies that every res:// path referenced from scenes, scripts, resources,
# .import sidecars and project.godot actually exists on disk. Run this after any
# file move/rename/delete in the project.
#
# Usage:  powershell -ExecutionPolicy Bypass -File tools/check_references.ps1
# Exit code 0 = clean, 1 = problems found.

$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
Set-Location $root
$skip = '\\(\.godot|\.git|docs|tools)\\'

$files = Get-ChildItem -Recurse -File | Where-Object {
  $_.FullName -notmatch $skip -and
  ($_.Extension -in '.tscn','.gd','.tres','.import' -or $_.Name -eq 'project.godot')
}

# --- 1. every res:// reference must resolve ---
$rx = [regex]'res://([^"\r\n]+)'
$checked = 0; $missing = 0
foreach ($f in $files) {
  $text = [IO.File]::ReadAllText($f.FullName)
  foreach ($m in $rx.Matches($text)) {
    $p = $m.Groups[1].Value.Trim().TrimEnd(')')
    if ($p -match '^\.godot/') { continue }   # regenerated import cache
    $checked++
    if (-not (Test-Path -LiteralPath $p)) {
      Write-Host "MISSING -> $p   (referenced from $($f.Name))" -ForegroundColor Red
      $missing++
    }
  }
}
Write-Host "res:// paths checked: $checked | missing: $missing"

# --- 2. each .import sidecar must point at its own existing source file ---
$bad = 0
foreach ($imp in ($files | Where-Object { $_.Extension -eq '.import' })) {
  $text = [IO.File]::ReadAllText($imp.FullName)
  $m = [regex]::Match($text, 'source_file="res://([^"]+)"')
  if (-not $m.Success) { Write-Host "NO source_file: $($imp.Name)" -ForegroundColor Red; $bad++; continue }
  $src = $m.Groups[1].Value
  $srcLeaf = Split-Path $src -Leaf
  $impLeaf = $imp.Name.Substring(0, $imp.Name.Length - 7)   # strip ".import"
  if (-not (Test-Path -LiteralPath $src)) {
    Write-Host "IMPORT BROKEN: $($imp.Name) -> $src" -ForegroundColor Red; $bad++
  } elseif (-not [string]::Equals($srcLeaf, $impLeaf, [System.StringComparison]::Ordinal)) {
    Write-Host "IMPORT NAME MISMATCH: $($imp.Name) -> $src" -ForegroundColor Red; $bad++
  }
}
Write-Host "import sidecar problems: $bad"

if ($missing -or $bad) { Write-Host 'FAILED' -ForegroundColor Red; exit 1 }
Write-Host 'OK - all references resolve' -ForegroundColor Green
