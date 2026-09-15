# Codex Implementation Handoff: Stage 1 Core Prototype v0.1

## Mission

Godot 4.7.2 stable / GDScript で、`docs/STAGE_1_CORE_PROTOTYPE_SPEC.md` に定義された Core Prototype v0.1 を実装する。

目的は完成品を作ることではない。

検証したいものは以下だけ。

> 住人の生活を観察し、適切なタイミングで怪奇現象を発動することが面白いか。

仕様外のゲーム要素を独自判断で追加しないこと。

## Required Reading Before Coding

1. `README.md`
2. `docs/STAGE_0_PROJECT_DEFINITION.md`
3. `docs/STAGE_1_CORE_PROTOTYPE_SPEC.md`
4. このファイル

優先順位は `STAGE_1_CORE_PROTOTYPE_SPEC.md` を最上位とする。

## Technical Conditions

- Engine: Godot 4.7.2 stable
- Language: GDScript
- Target: Windows Desktop
- Rendering: 2D
- External assets: 不要
- Plugins: 使用しない
- GitHub Actions: 使用しない
- 従量課金が発生する可能性のあるCI/CD処理: 使用しない

仮素材はGodot標準ノード、図形、Label等で構成してよい。

## Working Branch

基本作業ブランチ:

`feature/stage1-core-prototype-v01`

`main` へ直接ゲーム実装をコミットしないこと。

完了後はPull Requestを作成する。

## Recommended Project Structure

```text
ghost-home-game/
├ project.godot
├ README.md
├ docs/
├ scenes/
│  ├ main.tscn
│  ├ room.tscn
│  ├ resident.tscn
│  └ ui.tscn
├ scripts/
│  ├ game_manager.gd
│  ├ resident.gd
│  ├ ghost_action.gd
│  ├ ghost_action_manager.gd
│  └ debug_panel.gd
└ data/
   └ ghost_actions.gd
```

これは推奨構造であり、Godot上でより単純かつ明確な構造になるなら軽微な変更は許容する。

ただし不要なManagerや抽象化を増やさないこと。

## Implementation Order

1. Godot project作成
2. Main scene
3. Room仮レイアウト
4. Resident表示
5. Resident State Machine
6. Resident移動
7. Ghost Actionデータ定義
8. 怪奇現象入力
9. Fear
10. Adaptation
11. Cooldown
12. Feedback
13. UI
14. GameTimer
15. WIN / LOSE
16. Pause
17. Restart
18. Debug Panel
19. Playtest Logging
20. READMEの起動・操作情報更新

## Design Constraints

### Resident Observation First

Room Viewを画面の主役にする。

プレイヤーがUIを読むより前に、Residentの現在行動を視覚的に判断できること。

### No Premature Features

以下を追加しない。

- 複数住人
- 複数部屋
- 性格
- 幽霊力 / MP
- 成長システム
- 心霊度
- アイテム
- 怪奇コンボ
- ストーリー
- セーブ
- オンライン
- 高度な演出

### Data-driven Balance Values

以下の調整値はコード各所へ散らさず、可能な限り1か所で変更できる構造にする。

- Game time
- Win Fear
- Resident state durations
- Resident state transition rates
- BaseFear
- Cooldown
- AdaptationGain
- StateMultiplier
- Adaptation max
- Adaptation multiplier minimum
- Surprised duration
- Alert duration

過剰なResource設計や汎用フレームワーク化は不要。

## Input

- `1`: LIGHT
- `2`: SOUND
- `3`: SHADOW
- `F1`: Debug Panel ON/OFF

画面ボタンとKeyboard入力は同一のAction実行処理を利用すること。

## Pause Requirement

Pause中は以下を停止する。

- GameTimer
- Resident AI
- Cooldown
- Feedback timer
- Ghost action input

Pauseを使って盤面を観察してから有利に発動する戦術は成立させない。

## Playtest Logging

ゲーム終了時にGodot Debug Consoleへ以下を出力する。

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

v0.1ではCSV保存不要。

## Verification

PRを作成する前に `docs/STAGE_1_CORE_PROTOTYPE_SPEC.md` の Acceptance Criteria を一項目ずつ確認する。

Godotを実際に起動できる環境がある場合は、実行確認を行う。

実行環境がなく静的確認しかできない項目は、確認済みと偽らず明記すること。

## Pull Request Requirements

PR本文に以下を記載する。

### Implemented

実装した内容。

### Files

主要な作成・変更ファイル。

### How to Run

Godotでの起動方法と操作。

### Acceptance Criteria

各項目を `PASS / NOT VERIFIED / FAIL` で報告。

### Known Issues

残っている問題。

### Game Design Observations

実際に動作確認できた場合、以下を中心に気づきを記載する。

- Residentを見て「今だ」と思えるか
- Actionを温存する理由があるか
- AdaptationでActionを切り替えたくなるか
- Cooldown順に押すだけになっていないか

## Definition of Done

コードが書き終わったことを完了条件にしない。

最低条件は、仕様に沿ったPrototype一式をfeature branchへコミットし、レビュー可能なPull Requestを作成できる状態であること。

このStageで最重要なのは以下。

> 住人を見ることが、次の操作を決めるゲームになっているか。
