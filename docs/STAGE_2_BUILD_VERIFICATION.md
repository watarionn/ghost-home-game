# Stage 2 Playtest Build Verification

Date: 2026-09-21
Branch: `feature/stage2-external-playtest`

## Implemented

- Added `export_presets.cfg` with a Windows Desktop release preset.
- Added custom feature `stage2_playtest`.
- The playtest feature hides the visible `F1 : Debug` hint only.
- The existing F1 debug control remains available and starts OFF.
- Added `playtest/PLAYTEST_README.txt`.
- Added `tools/build_stage2_playtest.cmd`.
- Added `build/` and generated `*.import` files to `.gitignore`.
- Stage 1 v0.3 gameplay values and feedback text were not changed.

## Local validation

Godot:
`4.7.2.stable.official.ed1daf0bf`

Acceptance:
- `acceptance.gd`: 358 checks, 0 failures
- `acceptance_v02.gd`: 297 checks, 0 failures
- `acceptance_v03.gd`: 193 checks, 0 failures
- Total: 848 checks, 0 failures

Tester README hidden-rule audit: PASS.
## Export validation

Official Godot 4.7.2 stable export templates were downloaded from the
`godotengine/godot-builds` 4.7.2-stable release.

Archive:
`Godot_v4.7.2-stable_export_templates.tpz`

Verified before extraction:
- size: 1,281,349,702 bytes
- SHA-256: `f298490b8d44d934be425a5a65a51bf15f422428b229a06a6e11d9ffea248011`
- size match: PASS
- hash match: PASS

Only the Windows x86_64 templates and `version.txt` were installed under:
`%APPDATA%\Godot\export_templates\4.7.2.stable\`

Direct export command:
`godot --headless --path . --export-release "Windows Desktop" "build/stage2-playtest/GhostHomePlaytest.exe"`

Local helper usage:
`set GODOT_EXE=C:\path\to\Godot_v4.7.2-stable_win64_console.exe`
`tools\build_stage2_playtest.cmd`

Helper result after template installation: exit code 0.

## Package result

Generated:
- `build/stage2-playtest/GhostHomePlaytest.exe`
- `build/stage2-playtest/GhostHomePlaytest.pck`
- `build/stage2-playtest/PLAYTEST_README.txt`

Package hashes:
- EXE: `fd6e3ae8bf8bfb54c624b5bcc557e0455af5c8385a4200b1b54de9c16b53e7b0`
- PCK: `e19837169064b12e59497bda859a38b557e6bf2844c9f0566344c01a6eae3401`
- README: `b1f64d1e325d1e1930fad55043e161f421babfd1e55d14402cb6651f5334f57b`

The packaged README hash matches the repository source/template.

Final export scope audit:
- preset uses selected-scene export for `res://scenes/main.tscn`
- runtime dependencies are included automatically by Godot
- export log contains no `res://tests/`, `res://docs/`, `res://playtest/`, or `res://tools/`
- final PCK size: 27,400 bytes
- no generated build artifacts or `*.import` files are tracked by Git

A final PR audit also corrected a missing newline between
`binary_format/architecture` and `codesign/enable` in the export preset.

## Clean-folder launch smoke test

The three package files were copied to a repository-external temporary folder
and the exported EXE was launched from there.

Observed:
- process stayed running after startup
- `Responding=True`
- window title: `Ghost Home — Core Prototype v0.3`
- no TCP connections owned by the game process during the smoke check
- the process closed cleanly via `CloseMainWindow`; force termination was not needed

This confirms the package can launch without the Godot editor or repository
files present in the launch folder.

No GitHub Actions, cloud builds, external plugins, or metered CI/CD were used.
