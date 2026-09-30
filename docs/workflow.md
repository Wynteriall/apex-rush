# Apex Rush — Workflow

How to run, test and verify work in this project. Follow this before declaring any task complete.

## Godot binary

```powershell
$godot = "$env:USERPROFILE\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe"
```

> `Downloads\Godot_v4.7.2-stable_win64.exe` is a **folder**, not the executable — the binary lives inside it.
> Use the `_console.exe` variant when running from a terminal, otherwise Godot's output is not captured.

## The four verification checks

Run all four after any structural change (move / rename / delete) and before committing:

```powershell
# 1. reference integrity - every res:// path resolves, .import sidecars intact
powershell -ExecutionPolicy Bypass -File tools/check_references.ps1
#    must print "OK - all references resolve" and exit 0

# 2. headless import - must exit 0 with 0 ERROR / WARNING / invalid UID
& $godot --headless --path . --import

# 3. per-scene sweep - every scene loads with no errors
Get-ChildItem -Recurse -File -Filter '*.tscn' | Where-Object { $_.FullName -notmatch '\\\.godot\\' } |
  ForEach-Object { $rel = $_.FullName.Replace((Get-Location).Path + '\','').Replace('\','/')
    & $godot --headless --path . "$rel" --quit-after 90 }

# 4. runtime boot - main scene runs 180 frames with no script errors
& $godot --headless --path . --quit-after 180
```

Expected baseline on a clean checkout: `122 res:// paths checked | missing: 0`, 13 scenes, 0 errors.
(The count fell from 127 to 122 when five superseded `.import` sidecars were deleted — each one contributed a
`source_file` path. A count *lower* than 122 means a reference disappeared; a count above 122 is normal if you
added references.)

> `loading_scene.tscn` prints `WARNING: N ObjectDB instances were leaked at exit`. This is **pre-existing**
> (a pending `create_timer` interrupted by the forced shutdown) and reproduced identically on the
> unrefactored baseline — not a regression. See `backlog.md`.

## Gotchas (learned the hard way)

- **`git grep` lies while moves/renames are unstaged** — it searches tracked paths, so newly moved files are
  invisible and the old paths appear to still exist. Use `Get-ChildItem` + `Select-String` on the working tree.
- **PowerShell `-ne` / `-eq` are case-insensitive.** A case-only rename (`Shield_ICON.png` →
  `shield_icon.png`) gets silently skipped. Compare with
  `[string]::Equals($a, $b, [System.StringComparison]::Ordinal)`.
- **Godot may reassign a UID** when a rewritten `.import` sidecar is re-imported, and scenes then log
  `ext_resource, invalid UID: ... using text path instead`. Fix: restore the original `uid="uid://..."`
  in the sidecar from `git show HEAD:<old path>`, delete the regenerable `.godot/uid_cache.bin`, re-import.
- **UIDs are the safety net.** `project.godot` (main scene + autoload) and every `.tscn` reference by UID, so
  carrying `.uid` / `.import` sidecars through moves keeps references valid — proven in the 2026-09 refactor.
- When scripting file edits, write UTF-8 **without BOM**:
  `[IO.File]::WriteAllText($path, $text, (New-Object System.Text.UTF8Encoding($false)))`.

## Branches & commits

- Branch per workstream: `refactor/...`, `feature/...`, `fix/...`.
- One logical change per commit, conventional prefixes: `docs:`, `chore:`, `refactor:`, `feat:`, `fix:`.
- Commit only once the four checks pass; state in the commit body what was verified.
- Never commit a large move/rename together with behaviour changes — refactor first, then feature.
