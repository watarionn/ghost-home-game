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
- `docs/STAGE_1_CORE_PROTOTYPE_V02_SPEC.md` - v0.2仕様
- `docs/STAGE_1_V02_VERIFICATION.md` - v0.2の検証結果とPlaytest 002確認事項
- `docs/STAGE_1_CORE_PROTOTYPE_V03_SPEC.md` - 現在の実験ビルドv0.3の正本
- `docs/CODEX_STAGE_1_V03_IMPLEMENTATION.md` - v0.3実装・報告ガイド
- `docs/STAGE_1_V03_VERIFICATION.md` - v0.3の検証結果とPlaytest 003確認事項
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

## Stage 1 Prototype v0.3 の起動

1. **Godot 4.7.2 stable（通常版 / GDScript）** で、このリポジトリ直下の `project.godot` をインポートします。
2. **F6ではなくF5（プロジェクト実行）** で `scenes/main.tscn` を起動します。
3. 180秒以内に住人のFearを100にするとWIN、時間切れでLOSEです。

Windows向けの1280×800の2D仮画面です。外部アセット・Plugin・追加パッケージは不要です。
日本語表示にはWindowsのシステムフォント（Yu Gothic UI / Meiryo）を利用します。
終了時の計測ログ（既存16項目＋Action別の慣れ回復総量・最大同一生活行動streak）はGodotエディターの「出力」パネルで確認できます。

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
- LIGHTはテレビを見始めて最初の3秒、SOUNDは寝入りばなの最初の4秒、SHADOWはWALK中に中央の通路（部屋内X=500〜640）を通る間がOpportunityです。
- Opportunity成功はTiming倍率1.75、認識されたタイミング外は0.50。どちらもAdaptationは通常どおり増え、Missでは増えません。
- 反応中は直前の生活StateをEffectiveStateとして判定し、Opportunityは無効です。睡眠へのSOUND直後にSHADOWを使ってもMissになります。
- 通常Stateの経過時間は反応中に停止し、復帰後に続きます。Opportunityの時計を0に戻すことはありません。時間窓は `[0, 3)` / `[0, 4)`、通路のX境界は両端を含みます。
- テレビ開始時のリモコン・向き直り・画面の明るさ変化、あくびから横になって落ち着く動き、中央の開いたドアを手がかりに観察できます。正解の事前表示はDebugのみです。
- 結果は「大成功！」「効いたが弱い…」「気づかなかった…」と短い理由で表示します。GOODは大きな恐怖加算・強い驚き・短いPulse、MISTIMEDは小さい加算・弱い驚き、MISSには恐怖加算や驚きがありません。
- 生活抽選の基礎重みはTV / 水場 / 睡眠 = 0.40 / 0.30 / 0.30。同じ非WALK行動が直前にあればその候補を0.35倍、直近2回連続なら0.15倍し、再正規化します。同じ行動を禁止する処理ではありません。
- 慣れはActionごとに、最後に認識されてから20秒後より1.0/秒で回復します。GOOD / MISTIMEDは使ったActionだけ待機時間をリセットし、MISSと他Actionの使用はリセットしません。Pause・結果中は回復も止まります。
- WALK中は散歩スペースを移動し、WALK終了時の抽選後は活動位置へ即時移動します。経路探索はありません。
- `MAX_FEAR_GAIN` / `AVERAGE_FEAR_GAIN` は丸めた計算上のFearGainを集計します。平均の分母にはMissを含む発動回数を使い、Cooldown等で拒否された入力は含めません。
- **Checkpoint 1は未通過、人間のPlaytest 003待ち**です。v0.3自動比較ではOpportunityを狙う方針が平均36.990秒、機械的Cooldown順操作が118.435秒で、両方20/20勝利でした。自動比較で楽しさや学びやすさの合格は判定しません。詳細は `docs/STAGE_1_V03_VERIFICATION.md`、過去結果はv0.1 / v0.2の検証報告を参照してください。

### ローカル検証（CI不要）

リポジトリ直下で、`godot` を手元のGodot 4.7.2コンソール版実行ファイルに置き換えて実行してください。

```powershell
godot --headless --path . --editor --import --quit
godot --headless --path . --script tests/acceptance.gd
godot --headless --path . --script tests/acceptance_v02.gd
godot --headless --path . --script tests/acceptance_v03.gd
godot --path . --script tests/visual_smoke.gd
godot --headless --path . --script tests/realtime_timeout.gd
godot --headless --path . --script tests/policy_probe.gd
godot --headless --path . --script tests/flow_probe.gd
```

- `acceptance.gd`: 状態別計算、Miss、慣れ、AI、Pause、入力、終了、連続プレイを検証。
- `acceptance_v02.gd`: 時間・位置境界、GOOD TIMING / Mistimed、EffectiveState、反応連打、Opportunityの停止・復帰を検証。
- `acceptance_v03.gd`: 重み式・再抽選の可能性・回復の境界/速度/独立性/停止・Feedback・追加Debug/ログを検証。
- `visual_smoke.gd`: OpenGLで実描画し、マウス操作を検証。35枚の画面を `test-output/v03_*.png` に保存。
- `realtime_timeout.gd`: 約180秒待って、実際の `_process` による時間切れを検証。
- `policy_probe.gd`: seed 0〜19で `cooldown_order` / `opportunity_aware` / `light_only` を比較。集計・各試行・整合性確認を `test-output/policy_probe_v03.json` に保存。Core Fun合否は自動判定しません。
- `flow_probe.gd`: seed 903で各10,000活動の基礎抽選/anti-streak分布と、Action別回復の制御例を `test-output/flow_probe_v03.json` に保存。

生成キャッシュ・`test-output/` はGit管理対象外です。レビュー用に選んだJSONと画面3枚だけ `docs/evidence/` に保存しています。GitHub ActionsやCI/CDは使用しません。
