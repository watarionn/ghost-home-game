# Stage 2 Playtest Build Verification

Date: 2026-09-20
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
## Export probe

Godot recognized the `Windows Desktop` preset and reached export validation.
The export then stopped only because the Windows export templates are absent.

Expected template:
`%APPDATA%\Godot\export_templates\4.7.2.stable\windows_release_x86_64.exe`

Direct export command:
`godot --headless --path . --export-release "Windows Desktop" "build/stage2-playtest/GhostHomePlaytest.exe"`

Local helper usage:
`set GODOT_EXE=C:\path\to\Godot_v4.7.2-stable_win64_console.exe`
`tools\build_stage2_playtest.cmd`

Current helper result: exit code 4 with an explicit missing-template blocker.

## Package target

`build/stage2-playtest/GhostHomePlaytest.exe`
`build/stage2-playtest/PLAYTEST_README.txt`

Godot may place additional required runtime files in the same folder.

## Blocker

An actual Windows executable was not produced or launched because the
Godot 4.7.2 Windows export templates are not installed locally.
They were not downloaded or installed automatically.

No GitHub Actions, cloud builds, external plugins, or metered CI/CD were used.
