# Stage 2 External Playtest Specification

## Status

Active.

Stage 1 Core Prototype and Checkpoint 1 Core Fun Gate are complete. Stage 2 exists to verify whether a person who did not participate in development can understand and enjoy the core loop without developer coaching.

## Primary Question

> Can a new player understand that they should observe the resident, wait for a good moment, choose the right phenomenon, and react to adaptation without being told the hidden rules?

Stage 2 is not a content expansion phase. Do not add more residents, rooms, phenomena, progression, story, economy, or visual polish unrelated to understanding the current core loop.

## Stage 2 Goal

Validate four things with external players:

1. Core loop comprehension
2. Opportunity readability
3. Feedback comprehension
4. Desire to try again after failure or imperfect play

The build should remain mechanically equivalent to the accepted Stage 1 v0.3 baseline unless a playtest blocker requires a minimal fix.

## Tester Profile

Initial wave: 3 to 5 external testers.

Prefer a mix of:

- someone who plays simulation/management games
- someone who plays games casually
- someone with little or no knowledge of this project

Do not explain hidden multipliers, exact Opportunity windows, AI weights, Adaptation recovery delay, or optimal strategy before play.

## Test Protocol

### Before Play

Give only this minimum instruction:

> You are a ghost. Observe the resident and use three paranormal phenomena to scare them out of the house. Try to figure out when each phenomenon works well.

Allowed control explanation:

- Mouse buttons or on-screen buttons
- `1 / 2 / 3` for the three phenomena
- Pause if necessary

Do not explain:

- TV / sleep / doorway Opportunity rules
- GOOD / MISTIMED thresholds
- exact Fear formula
- exact Adaptation formula
- anti-streak AI
- 20-second Adaptation recovery rule

### First Run

- F1 Debug OFF
- No coaching during play unless the game cannot be operated
- Let the tester finish naturally, WIN or LOSE
- Record observable confusion and spontaneous comments

### Second Run

Only if the tester wants another try.

Do not explain the solution before the second run. See whether the player changes behavior using what they learned from the first run.

## Observation Checklist

Record whether the tester:

- watches the resident before pressing
- notices TV start, sleep onset, and doorway movement
- waits intentionally for a moment
- presses all buttons mechanically
- recognizes GOOD / MISTIMED / MISS
- notices Adaptation and rotates phenomena
- notices Adaptation recovery without being told
- waits doing nothing purely for recovery
- understands why an action failed
- expresses a theory such as "maybe this works better when..."
- changes strategy on a second attempt
- wants to retry after losing

## Post-Play Questions

Ask after the run, not before.

1. What did you think the goal was?
2. What were you paying attention to while the resident moved around?
3. When did you think each of the three phenomena worked best?
4. Could you tell the difference between a strong hit, a weak hit, and a miss?
5. What did you think the Adaptation values meant?
6. Did you notice that an unused phenomenon slowly became effective again?
7. Did you ever feel like you were just waiting with nothing to do?
8. Did you ever feel like pressing buttons at random was good enough?
9. If you failed or made a bad move, did you know what you wanted to try differently next time?
10. Was any feedback too wordy or distracting?
11. What was the most satisfying moment?
12. What was the most confusing moment?

## Required Metrics Per Tester

Record:

- tester ID (anonymous label only)
- prior familiarity with project: yes/no
- run result: WIN/LOSE
- clear time or timeout
- number of runs
- whether they voluntarily retried
- whether they identified at least 2 of 3 Opportunity relationships without explanation
- whether they distinguished GOOD / MISTIMED / MISS
- whether they understood Adaptation concept
- whether they changed strategy after feedback/failure
- qualitative notes

Do not collect unnecessary personal data.

## Stage 2 Success Direction

This stage is exploratory. Do not overfit to a single tester.

Desired pattern across testers:

- Most testers observe before acting rather than button-mash.
- Most testers can infer at least 2 of the 3 Opportunity relationships after one or two runs.
- Most testers can explain the difference between GOOD / MISTIMED / MISS in their own words.
- Players who make a poor move can usually say what they would try differently next time.
- Retry motivation appears without prompting in at least some testers.
- Waiting is not the dominant complaint.

## Checkpoint 2 Player Understanding Gate

Checkpoint 2 is evaluated after the initial external-playtest wave.

The gate asks:

> Can a new player understand the core loop and form useful hypotheses from the game itself, without the developer explaining the hidden rules?

PASS direction:

- Core loop is understood from play.
- Feedback supports learning.
- Failure produces a useful next hypothesis.
- Major confusion is localized and fixable rather than structural.

FAIL / iterate direction:

- Players win or lose without understanding why.
- Players rely on random button presses.
- Opportunity relationships remain opaque after repeated play.
- Feedback is too verbose or too unclear to teach.
- Waiting or inactivity dominates the experience.

Do not proceed to Stage 3 Vertical Slice until Checkpoint 2 is explicitly passed.

## Stage 2 Build Preparation

Before inviting testers, prepare a simple Windows playtest package that can be launched without opening the Godot editor.

Requirements:

- Windows desktop export
- no external installer required if avoidable
- clear executable name
- project runs from a clean extracted folder
- no Debug panel enabled by default
- no developer-only files required at runtime
- no network connection required
- no telemetry or account requirement
- simple `PLAYTEST_README.txt` next to the executable

The exported build must preserve the Stage 1 v0.3 mechanics.

## Current Known Follow-up

Playtest 003 found the normal feedback slightly over-explanatory. Do not preemptively redesign it before external evidence. Stage 2 should determine whether new players need the current amount of explanation or whether it can be shortened safely.
