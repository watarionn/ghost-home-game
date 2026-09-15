# Ghost Home Game

幽霊になって怪奇現象を使い分け、住人を家から追い出す箱庭シミュレーションゲームです。

## Project Status

現在は **Stage 1: Core Prototype** を進行中です。

標準工程:

Stage 0 Project Definition
→ Stage 1 Core Prototype
→ Checkpoint 1 Core Fun Gate
→ Stage 2 External Playtest
→ Checkpoint 2 Player Understanding Gate
→ Stage 3 Vertical Slice
→ Checkpoint 3 Production Feasibility Gate
→ Stage 4 Scope Lock
→ Stage 5 Production
→ Stage 6 Alpha
→ Checkpoint 4 Feature Complete Gate
→ Stage 7 Beta / QA
→ Checkpoint 5 Release Readiness Gate
→ Stage 8 Release
→ Stage 9 Postmortem

## Current Technical Direction

- Engine: Godot 4.7.2 stable
- Language: GDScript
- Target: Windows Desktop
- Rendering: 2D
- Stage 1では仮素材のみを使用

## Core Concept

小さな家で暮らす住人を観察し、性格・生活・場所・時間に合わせて怪奇現象を仕掛け、恐怖と慣れを管理しながら退去させ、最終的に家を伝説の心霊スポットへ育てるゲームを目指します。

Stage 1では、まず以下のCore Funだけを検証します。

> 住人の生活を観察し、「今だ」と思った瞬間に適切な怪奇現象を仕掛けることが面白いか。

## Documents

- `docs/STAGE_0_PROJECT_DEFINITION.md` - ゲーム全体の核
- `docs/STAGE_1_CORE_PROTOTYPE_SPEC.md` - Core Prototype v0.1仕様
- `docs/CODEX_STAGE_1_IMPLEMENTATION.md` - Codex向け実装指示
- `docs/PLAYTEST_LOG.md` - テストプレイ記録

## Development Workflow

1. ChatGPT側でゲーム設計・仕様を整理
2. GitHubの `docs/` を正式仕様として更新
3. Codexがfeature branchで実装
4. Pull Requestを作成
5. 仕様照合・コードレビュー
6. テストプレイ
7. 必要なら修正
8. 合格後に `main` へマージ

`main` は常にレビュー済みの安定版として扱います。

## Important

GitHub Actionsなど、従量課金が発生する可能性のある処理は使用しません。

このプロジェクトでは、コード量や見た目より先に **Core Funが成立しているか** を検証します。

## Stage 1 Prototype の起動

1. **Godot 4.7.2 stable（通常版 / GDScript）** で、このリポジトリ直下の `project.godot` をインポートします。
2. **F6ではなくF5（プロジェクト実行）** で `scenes/main.tscn` を起動します。
3. 180秒以内に住人のFearを100にするとWIN、時間切れでLOSEです。

Windows向けの1280×800の2D仮画面です。外部アセット・Plugin・追加パッケージは不要です。
日本語表示にはWindowsのシステムフォント（Yu Gothic UI / Meiryo）を利用します。
終了時の14項目の計測ログはGodotエディターの「出力」パネルで確認できます。

| 操作 | 内容 |
| --- | --- |
| `1` / LIGHTボタン | 照明OFF |
| `2` / SOUNDボタン | 怪音 |
| `3` / SHADOWボタン | 人影 |
| `F1` | Debug Panelの表示切り替え |
| 一時停止 / 再開ボタン | すべてのゲーム内時間と怪奇現象入力を停止 / 再開 |
| 結果画面のRestart | 全数値を初期化して再プレイ |

Pause中は部屋・数値詳細を覆い、怪奇現象の予約入力は受け付けません。
調整値は `data/balance.gd` に集約しています。正本の仕様書の値を使用しています。

### 実装上の補足

- 認識された怪奇現象で `SURPRISED`（1.5秒）→ `ALERT`（3秒）→中断した生活状態・残り時間へ戻ります。Missでは反応状態へ移りません。
- `SURPRISED` / `ALERT` の「数値補正を持たない」は中立倍率 `1.0` として実装しています。反応中に別の現象を受けても、復帰先は最初に中断した生活です。
- WALK中は散歩スペースを移動し、WALK終了時の抽選後は活動位置へ即時移動します。経路探索はありません。
- `MAX_FEAR_GAIN` / `AVERAGE_FEAR_GAIN` は丸めた計算上のFearGainを集計します。平均の分母にはMissを含む発動回数を使い、Cooldown等で拒否された入力は含めません。
- 数値上の機能検証と、面白さの判定は別です。現在の自動操作では単純なCooldown順操作でも勝てるため、**Core Fun Gateは未達**です。詳細は `docs/STAGE_1_VERIFICATION.md` を参照してください。

### ローカル検証（CI不要）

リポジトリ直下で、`godot` を手元のGodot 4.7.2コンソール版実行ファイルに置き換えて実行してください。

```powershell
godot --headless --path . --editor --import --quit
godot --headless --path . --script tests/acceptance.gd
godot --path . --script tests/visual_smoke.gd
godot --headless --path . --script tests/realtime_timeout.gd
godot --headless --path . --script tests/policy_probe.gd
```

- `acceptance.gd`: 状態別計算、Miss、慣れ、AI、Pause、入力、終了、連続プレイを検証。
- `visual_smoke.gd`: OpenGLで実描画し、マウス操作を検証。12枚の画面を `test-output/` に保存。
- `realtime_timeout.gd`: 約180秒待って、実際の `_process` による時間切れを検証。
- `policy_probe.gd`: seed 0〜19で3種類の操作方針を比較。結果を `test-output/policy_probe.json` に保存。

生成キャッシュ・検証画像はGit管理対象外です。GitHub ActionsやCI/CDは使用しません。
