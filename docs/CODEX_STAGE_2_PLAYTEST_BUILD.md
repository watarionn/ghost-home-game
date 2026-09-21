# Codex: Stage 2 External Playtest Build Preparation

## Goal

Prepare the accepted Stage 1 v0.3 build for external Windows playtesting without changing the core mechanics.

## Working branch

`feature/stage2-external-playtest`

Do not commit directly to `main`.

## Read first

1. `docs/CHECKPOINT_1_CORE_FUN_GATE.md`
2. `docs/STAGE_1_CORE_PROTOTYPE_V03_SPEC.md`
3. `docs/STAGE_1_V03_VERIFICATION.md`
4. `docs/STAGE_2_EXTERNAL_PLAYTEST_SPEC.md`
5. `docs/EXTERNAL_PLAYTEST_GUIDE.md`
6. `docs/EXTERNAL_PLAYTEST_SURVEY.md`

## Required implementation

### 1. Windows export preset

Add a Godot Windows Desktop export preset suitable for a local playtest build.

Requirements:

- Windows desktop target
- release/playtest build, not developer debug UI
- F1 debug remains available only as the existing hidden developer control; it must not start enabled
- no network dependency
- no installer requirement unless Godot technically requires one
- no external plugins

Do not add GitHub Actions or cloud build automation.

### 2. Playtest package layout

Target local output layout:

```text
build/
  stage2-playtest/
    GhostHomePlaytest.exe
    PLAYTEST_README.txt
```

If Godot produces additional required runtime files, keep them in the same folder.

Do not commit generated executable binaries to the repository unless explicitly requested later.

### 3. PLAYTEST_README.txt

Add a repository source/template for the file that will be placed beside the executable.

The tester-facing text must reveal only:

- the player is a ghost
- observe the resident
- use three paranormal phenomena to scare the resident out
- figure out when they work well
- controls
- how to quit
- request to play once without asking for hints

Do not reveal Opportunity windows, formulas, Adaptation recovery timing, anti-streak logic, or optimal strategy.

### 4. Local build helper

If useful, add a simple local-only build command/script for Windows that invokes Godot export.

Constraints:

- no GitHub Actions
- no metered CI/CD
- no downloading or installing dependencies automatically
- fail clearly if the Godot executable or export templates are missing
- do not silently modify user-level Godot settings

### 5. Build verification

Verify locally where possible:

- project still passes existing acceptance suites
- export preset parses
- export command/path is documented
- generated build launches if export templates are available
- no developer-only instructions appear in tester README
- F1 debug is OFF at launch

If actual export cannot be completed because local export templates are absent, report that precisely instead of changing scope or downloading them automatically.

## Do not change

Do not tune:

- Fear values
- Opportunity windows
- Timing multipliers
- Adaptation values/recovery
- resident activity weights
- state durations
- Feedback wording or amount

The current slightly verbose Feedback is intentionally preserved for Stage 2 evidence.

## Completion report

Update the PR with:

1. files changed
2. export preset details
3. exact local export command
4. package layout
5. validation results
6. whether an actual `.exe` was produced and launched
7. any blocker, especially missing Godot export templates
8. confirmation that GitHub Actions / paid CI were not used
