# Stage 1 Core Prototype v0.1 Specification

## Purpose

Core Prototype v0.1は完成品を作るためのものではない。

検証する仮説:

> 住人の生活を観察し、「今だ」と思った瞬間に適切な怪奇現象を仕掛けることが面白い。さらに、同じ怪奇現象への「慣れ」によって次の一手を考えることが面白い。

この仮説を検証できない機能は原則追加しない。

## Scope

### Implement

- 1部屋
- 住人1人
- 住人AI
- 怪奇現象3種
- Fear
- Adaptation
- Cooldown
- 180秒Timer
- WIN / LOSE
- Feedback
- Debug表示
- Restart

### Do Not Implement Yet

- 住人の性格差
- 複数住人
- 複数部屋
- 幽霊力 / MP
- 経験値
- 幽霊レベル
- スキルツリー
- 心霊度
- お金
- アイテム
- ストーリー
- 家の成長
- 家具配置
- 怪奇コンボ
- 住人同士の交流
- 除霊師
- 高度な住人AI

## Screen Layout

### Top: Game Status

- Fear gauge
- Fear value `0 / 100`
- Remaining time
- Pause button

### Center: Room View

画面の大部分を使う。

表示:

- Resident
- TV
- Water area
- Bed
- Walking area

住人が現在何をしているかを画面だけで判別できること。

### Bottom: Ghost Actions

3ボタンを常時表示。

- LIGHT / 照明OFF / keyboard `1`
- SOUND / 怪音 / keyboard `2`
- SHADOW / 人影 / keyboard `3`

各ボタンにCooldownと対応Adaptationを表示する。

## Resident AI

State Machine:

- `WALK`
- `WATCH_TV`
- `DRINK_WATER`
- `SLEEP`
- `SURPRISED`
- `ALERT`

通常遷移:

```text
WALK
↓
次行動抽選
├ WATCH_TV
├ DRINK_WATER
└ SLEEP
↓
WALK
```

Walk終了時抽選:

- WATCH_TV 40%
- DRINK_WATER 30%
- SLEEP 30%

State Duration:

- WALK: 4〜7秒
- WATCH_TV: 12〜20秒
- DRINK_WATER: 5〜8秒
- SLEEP: 20〜30秒
- SURPRISED: 約1.5秒
- ALERT: 約3秒

SURPRISED / ALERT はv0.1では数値補正を持たない。

## Ghost Actions

### LIGHT

- Display name: 照明OFF
- BaseFear: 8
- Cooldown: 8秒
- AdaptationGain: 20

State multiplier:

- WATCH_TV: 1.6
- WALK: 1.2
- DRINK_WATER: 1.0
- SLEEP: 0.0

### SOUND

- Display name: 怪音
- BaseFear: 12
- Cooldown: 10秒
- AdaptationGain: 22

State multiplier:

- WATCH_TV: 0.7
- WALK: 1.0
- DRINK_WATER: 1.2
- SLEEP: 1.7

### SHADOW

- Display name: 人影
- BaseFear: 18
- Cooldown: 15秒
- AdaptationGain: 30

State multiplier:

- WATCH_TV: 1.0
- WALK: 1.5
- DRINK_WATER: 1.3
- SLEEP: 0.0

## Fear Calculation

Fear range:

`0〜100`

Initial:

`0`

Formula:

```text
FearGain = BaseFear × StateMultiplier × AdaptationMultiplier
```

Adaptation multiplier:

```text
max(0.2, 1.0 - Adaptation / 100.0)
```

FearGainは整数へ丸める。

例:

SOUND / SLEEP / Adaptation 0

```text
12 × 1.7 × 1.0 = 20.4 → 20
```

## Adaptation

各怪奇現象ごとに独立管理。

- LightAdaptation
- SoundAdaptation
- ShadowAdaptation

Range:

`0〜80`

Initial:

`0`

StateMultiplierが0の場合は住人が認識しなかったものとする。

その場合:

- FearGain = 0
- AdaptationGain = 0
- Cooldownは発生
- Feedback: `気づかなかった…`

v0.1では時間経過でAdaptationは減らない。

## Cooldown

- LIGHT: 8秒
- SOUND: 10秒
- SHADOW: 15秒

怪奇現象ごとに独立。
Cooldown中はボタン操作不可。

## Fear Stages

- 0〜24: 平常
- 25〜49: 少し不安
- 50〜74: 警戒
- 75〜99: かなり怯えている
- 100: 限界

Prototypeではテキスト・アイコン・簡易表情等で判別できればよい。

## Game Flow

Start:

- Fear = 0
- All Adaptation = 0
- Timer = 180 seconds
- All Cooldown = 0

Fear >= 100:

- Game stops
- `こんな家住めるか！`
- WIN

Timer <= 0:

- Game stops
- `なんだ、気のせいか`
- LOSE

## Pause

Pause中は以下を停止:

- GameTimer
- Resident AI
- Cooldown
- Feedback timer
- Ghost action input

Pauseを戦術機能にはしない。

## Feedback

怪奇現象後、住人付近に1〜2秒表示。

Examples:

- `恐怖 +20！`
- `気づかなかった…`
- `慣れてきた…`

プレイヤーが結果の理由を理解できることを重視する。

## Debug Mode

F1でON/OFF。

Display:

- CurrentState
- StateRemainingTime
- Fear
- LightAdaptation
- SoundAdaptation
- ShadowAdaptation
- LightCooldown
- SoundCooldown
- ShadowCooldown
- LastGhostAction
- LastBaseFear
- LastStateMultiplier
- LastAdaptationMultiplier
- LastFearGain

## Playtest Logging

ゲーム終了時、最低限以下をDebug Consoleへ出力。

- RESULT
- PLAY_TIME
- FINAL_FEAR
- LIGHT_USE_COUNT
- SOUND_USE_COUNT
- SHADOW_USE_COUNT
- LIGHT_MISS_COUNT
- SOUND_MISS_COUNT
- SHADOW_MISS_COUNT
- LIGHT_FINAL_ADAPTATION
- SOUND_FINAL_ADAPTATION
- SHADOW_FINAL_ADAPTATION
- MAX_FEAR_GAIN
- AVERAGE_FEAR_GAIN

CSV出力はv0.1では不要。

## Acceptance Criteria

- Godot 4.7.2で開ける
- エラーなしで実行できる
- Residentが自律生活する
- Stateを視覚的に判別できる
- LIGHT / SOUND / SHADOWが発動可能
- StateによってFearGainが変化
- StateMultiplier 0でMiss
- MissでもCooldown発生
- MissではAdaptationが増えない
- 同じActionを使うと効果低下
- Adaptation <= 80
- Fearは0〜100にClamp
- Fear 100でWIN
- 180秒でLOSE
- Pause正常動作
- Restart可能
- F1 Debug Panel動作
- Playtest結果がConsoleへ出る
- 連続プレイ可能

## Core Fun Gate

以下の判断が自然に発生することを重視する。

- 「今だ」
- 「ここまで温存しよう」
- 「これはもう慣れられた」
- 「次は別の手にしよう」

以下になった場合はCore Fun未成立:

- Cooldown終了順に押すだけ
- 3ボタンを順番に押すだけ
- 何も考えず連打しても勝てる

最重要条件:

> 住人を見ることが、次の操作を決めるゲームになっているか。
