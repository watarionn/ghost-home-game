# Stage 1 Core Prototype v0.2 実装・検証報告

Refs #1, #3 / PR #2 / `feature/stage1-core-prototype-v01`

検証日: 2026-09-16。正本は `docs/STAGE_1_CORE_PROTOTYPE_V02_SPEC.md`。
実装前にv0.1仕様、Playtest 001、v0.2仕様、Issue #3、PR #2のレビュー1件・コメント2件（行コメント0件）を確認しました。

## 1. 実装内容

- LIGHT: WATCH_TVの通常State経過時間 `[0, 3)` 秒。
- SOUND: SLEEPの通常State経過時間 `[0, 4)` 秒。
- SHADOW: WALKかつ部屋ローカル座標 `500 <= X <= 640`。Yは判定しません。部屋ノードの画面上のオフセット40pxは判定値に含めません。
- Opportunity成功時はTimingMultiplier **1.75**、認識されたタイミング外は **0.50**。使用前Adaptationの倍率を掛けて最後に整数へ丸めます。
- 認識成功はGOOD TIMING / Mistimedとも通常量のAdaptationを加算。MissはFearGain 0・Adaptation加算0・Cooldown消費です。
- SURPRISED / ALERT中は最初に中断した通常StateをEffectiveStateに使い、OpportunityはNONE。追加の認識成功でも元の生活文脈・残り時間を維持します。
- 通常State時間をWALK 3〜5秒、TV 9〜14秒、水場4〜6秒、睡眠12〜18秒に短縮。抽選40/30/30%、反応1.5秒/3秒、180秒制限、既存の現象数値は維持しました。
- 住人の外形・持ち物・散歩・表情・怪奇現象後の反応を維持し、TV開始時のリモコンを上げる仕草と寝入りのあくびを追加。中央通路は固定の背景表現で示し、人影もこの通路に表示します。
- FeedbackにGOOD TIMING / タイミングが悪いと倍率を発動後だけ表示。通常のActionボタンはOpportunityの有無で変化しません。
- DebugにEffectiveState、StateElapsedTime、CurrentOpportunityAction、IsOpportunityWindow、LastTimingMultiplierを追加。
- 終了ログの既存14項目を残し、Opportunity成功数・Mistimed発動数を追加。新しい怪奇現象・住人・部屋・成長要素・Global Lockoutは追加していません。

## 2. 変更ファイル

| ファイル | 内容 |
| --- | --- |
| `data/balance.gd` | 生活テンポ、時間窓、Zone、Timing倍率を集約 |
| `scripts/resident.gd` | 通常経過時間、EffectiveState、Opportunity、行動開始の仕草 |
| `scripts/ghost_action_manager.gd` | 4要素のFear計算、Miss優先、タイミング集計 |
| `scripts/game_manager.gd` | 共通入力処理から住人文脈を渡し、Feedbackと終了ログを更新 |
| `scripts/room.gd` | 通路、人影位置、生活開始ラベル、Feedbackを邪魔しない家具名配置 |
| `scripts/debug_panel.gd` / `scripts/ui.gd` | Debug追加5項目とv0.2表記 |
| `project.godot` | プロジェクト名をv0.2へ変更 |
| `tests/acceptance.gd` | 既存の検証範囲を維持し、v0.2で改訂された数値期待値とAPIを更新 |
| `tests/acceptance_v02.gd` / `.uid` | v0.2追加検証 |
| `tests/visual_smoke.gd` | 実描画、マウス操作、3種のタイミング別Feedback |
| `tests/policy_probe.gd` | 指定3方針・5指標・各試行記録・集計整合性検証 |
| `README.md` | 起動・操作・検証手順をv0.2へ更新 |
| `docs/STAGE_1_VERIFICATION.md` | v0.1記録であることを明示して保存 |
| `docs/STAGE_1_V02_VERIFICATION.md` | 本報告 |
| `docs/evidence/policy_probe_v02.json` | 今回実行した60試行と集計のスナップショット |

## 3. Acceptance Criteria結果

環境: **Godot 4.7.2.stable.official.ed1daf0bf / Windows / OpenGL 3.3 Compatibility / RTX 5060**。

| v0.1から維持する項目 | 結果 | 根拠 |
| --- | --- | --- |
| Godot 4.7.2で開ける | PASS | 指定版editor import |
| エラーなしで実行できる | PASS | headless・OpenGL実行、各テスト終了コード0 |
| Residentが自律生活する | PASS | WALK移動、生活抽選、生活→WALK、10,000回の40/30/30%分布確認 |
| Stateを視覚的に判別できる | PASS | 6状態、TV/睡眠の開始と定常状態を実描画で確認 |
| LIGHT / SOUND / SHADOWが発動可能 | PASS | 共通処理、実Viewportマウス操作、キー入力 |
| StateによってFearGainが変化 | PASS | 4通常状態×3現象、反応状態の期待値確認 |
| StateMultiplier 0でMiss | PASS | 睡眠中LIGHT/SHADOW、反応中の睡眠文脈も0 |
| MissでもCooldown発生 | PASS | LIGHT 8秒、SHADOW 15秒、連打を拒否 |
| MissではAdaptationが増えない | PASS | 初期0と既存Adaptation40の両方で不変 |
| 同じActionを使うと効果低下 | PASS | SLEEPでGOOD TIMING SOUND 36→28、慣れFeedback |
| Adaptation <= 80 | PASS | 各現象10回反復で上限80、倍率下限0.2、時間減衰なし |
| Fearは0〜100にClamp | PASS | 初期0、Missで0維持、99への加算は100 |
| Fear 100でWIN | PASS | 境界テスト、台詞・入力停止、通常初期値でのPolicy Probe |
| 180秒でLOSE | PASS | 179秒時点で継続、180秒でLOSE、実時間テスト |
| Pause正常動作 | PASS | 全タイマー、移動、通常/反応文脈、Opportunity、入力・集計を停止、盤面遮蔽 |
| Restart可能 | PASS | WIN/LOSEの実マウス操作、追加カウンターと文脈も初期化 |
| F1 Debug Panel動作 | PASS | 実キー入力、既存項目と追加5項目、Pause中非表示 |
| Playtest結果がConsoleへ出る | PASS | 既存14項目＋追加2項目、Miss込み平均、二重出力防止 |
| 連続プレイ可能 | PASS | 3連続LOSE→Restart、実マウスのWIN→Restart→LOSE→Restart |

既存回帰テスト: **355 checks, 0 failures**。v0.1で改訂対象だった倍率・時間の古い数値をそのまま要求するテストにはせず、v0.2正本の期待値へ変更しています。

## 4. v0.2追加検証結果

| v0.2追加Acceptance | 結果 | 根拠 |
| --- | --- | --- |
| 通常State時間がv0.2値 | PASS | 全4状態の上下限を反復検証 |
| LIGHTはWATCH_TV開始後3秒だけ | PASS | 0 / 2.999 / 3.000 / 3.001秒、復帰後も累積経過で終了 |
| SOUNDはSLEEP開始後4秒だけ | PASS | 0 / 3.999 / 4.000 / 4.001秒、反応後も時計をリセットしない |
| SHADOWはWALK中の指定Zone | PASS | X=499.999 / 500 / 570 / 640 / 640.001、複数Y、実移動で進入・退出 |
| 成功時TimingMultiplier 1.75 | PASS | LIGHT 22 / SOUND 36 / SHADOW 47（Adaptation 0） |
| タイミング外成功は0.50 | PASS | 同じ通常StateでLIGHT 6 / SOUND 10 / SHADOW 14 |
| MistimedでもAdaptation増加 | PASS | LIGHT +20 / SOUND +22 / SHADOW +30、GOOD TIMINGと同量 |
| MissではAdaptation不変 | PASS | 睡眠・反応中睡眠、非ゼロAdaptationからも不変 |
| 反応中EffectiveStateは直前生活 | PASS | 4通常文脈×2反応State×3現象、追加反応でも文脈維持 |
| 反応中はOpportunity無効 | PASS | 通常なら有効な時間・位置でもNONE、認識成功は0.50 |
| SLEEP→SOUND→SURPRISED→SHADOWはMiss | PASS | 実キーを5回入力、Fear不変、Miss1回、Adaptation 0、Cooldown15秒 |
| Debug追加項目 | PASS | 文字列の値確認と実描画、現在の窓と直前の倍率を区別 |
| 通常UIが事前に正解表示しない | PASS | 窓進入でボタン文字列不変、ボタンにOpportunity連動処理なし、実描画確認 |
| Policy Probe結果出力 | PASS | 3方針×20seed、5指標、60試行、計数整合性エラー0 |

追加テスト: **297 checks, 0 failures**。既存と合計 **652 checks, 0 failures**。

Issue #3の追加確認も実施しました: 各現象のGOOD TIMING、同条件でのMistimedとの差、認識時の慣れ、Miss時の慣れ不変、睡眠反応中のSHADOW連打、機械操作と観察操作の比較、自動比較と人間のCore Fun評価の分離。

### 実行・描画確認

- `visual_smoke.gd`: **21 screenshots, viewport mouse tests, 0 failures**。通常6状態、開始/定常2状態、3現象×GOOD/Mistimed、Debug、Miss、Pause、WIN、LOSE、Restartを確認。画像は `test-output/v02_*.png` に生成されます。
- `realtime_timeout.gd`: **result=LOSE / simulation=180.000 / wall=179.943 / PASS=true**。実際の `_process` で初期状態から約180秒実行。
- `git diff --cached --check` による差分検査。GitHub Actions・従量課金CI/CDは不使用。

## 5. Policy Probe比較

seed **0〜19**を各方針に同じ条件で設定し、実ゲームシーンを **0.1秒刻み** で進めました。数値・経路・初期Fearを方針別に変えていません。認識された反応が生活を中断するため、プレイ途中の生活履歴は方針ごとに分岐します。

| 方針 | WIN率 | 平均終了時間 | 平均最終Fear | 平均Opportunity成功数 | 平均Mistimed発動数 |
| --- | --- | --- | --- | --- | --- |
| `cooldown_order` | 100%（20/20） | 127.015秒 | 100.0 | 1.30 | 33.80 |
| `opportunity_aware` | 100%（20/20） | 36.625秒 | 100.0 | 3.15 | 0.00 |
| `light_only` | 0%（0/20） | 180.000秒 | 39.0 | 2.50 | 17.15 |

- `cooldown_order`: Cooldownが空き次第LIGHT→SOUND→SHADOWを試します。同一時点の後続入力には、その直前の入力が起こした反応文脈を使います。
- `opportunity_aware`: LIGHTはTV開始3秒、SOUNDは睡眠開始4秒、SHADOWはWALKのZoneだけ。反応中は待ちます。
- `light_only`: LIGHTだけCooldownが空き次第使います。
- Mistimedは「認識されたがタイミング外」。MissとCooldownで拒否された入力は含めません。各試行で `全発動数 = Opportunity成功数 + Mistimed数 + Miss数` を確認しました。
- 集計の根拠は [policy_probe_v02.json](evidence/policy_probe_v02.json) に60試行ごと残しています。再実行は `test-output/policy_probe_v02.json` に出力し、記録を自動で上書きしません。

v0.1の `cooldown_order` 平均30.435秒からは遅くなり、v0.2内では観察方針が平均90.390秒早く終わりました。観察方針のv0.1 `observe` とv0.2 `opportunity_aware` は別ルールなので、同一Policyの比較とは扱いません。

**設計目標は一部未達です。** 「観察しなくても最速」は今回の比較では解消しましたが、機械操作20/20勝利は残っています。勝率を合わせる追加チューニングはしていません。

## 6. 既知の問題・実装上の境界

- 機械的操作でも全試行で勝てます。観察の利益は今回、勝率差より所要時間と発動効率の差に現れました。
- Policyは内部の正確なState・時刻・座標を読み、100ms以内に操作できます。人間の見間違い・反応時間・注意配分・退屈さは評価していません。
- 通常生活の経過時間は反応中に停止し、復帰後に残りの窓が続きます。反応のたびに窓を最初から再生成しません。DebugのStateElapsedTimeは表示中Stateの経過時間で、反応中は反応時計です。通常文脈の経過時間は `normal_elapsed_time()` から取得できます。
- Miss時のLastTimingMultiplier `0.0` は「Timing適用なし」を示すDebug用の値です。0.50のMistimedとして集計しません。
- WALK終了時に活動位置へ即時移動するv0.1の仮構成を維持しています。Zoneを通る頻度は乱数による歩行経路に依存します。
- 通路・行動開始の仕草を手がかりとして実装しましたが、初見で時間窓を学べるかは未検証です。通常ボタンの明るさの変化はマウスhoverだけで、Opportunityの正解表示ではありません。
- クリーンPCでの配布、エクスポート、外部プレイテストは未実施。Windowsシステムフォント・仮図形を使用しています。

## 7. Game Design Observations

- **住人を見続けたい長所**: 外形・生活・持ち物・反応は保持し、開始の仕草と通路という観察材料を足しました。Playtest 001の「とてもYES」を維持できたと断言するにはPlaytest 002が必要です。
- **効いたときの気持ちよさ**: GOOD TIMINGでは同条件のMistimedより大きなFearGain（22対6、36対10、47対14）が表示されます。既存の驚き・恐怖段階・Feedbackも残しています。主観評価は未実施です。
- **今だ・温存**: 自動方針は窓を狙うほうが速く、狙う利益は確認できました。一方、窓を覚えるまでの学習と待ち時間の感触は自動比較からは分かりません。
- **慣れと無駄打ち**: Mistimedでも同量の慣れが進み、機械操作は平均33.8回のMistimedを消費しました。ただし、それでも勝てる反例は残ります。
- **生活テンポ**: 通常行動時間は仕様どおり短縮しました。反応時間は4.5秒のままなので、発動頻度によって見かけのテンポは変わります。

**Core Fun Gate / Checkpoint 1: NOT PASS YET。** 自動結果は設計上の反例と比較材料です。Stage 2へ進めず、人間のPlaytest 002で判断します。

## 8. 人間のPlaytest 002で確認すべき点

最初はF1をOFFにして数回プレイし、必要なら後からDebugで理由を確認してください。各回の結果画面とConsoleログを記録し、Playtest 001と同じ5軸を比較します。以下は確認票であり、実施済みの結果ではありません。

1. **住人を見ていたくなるか** — 「とてもYES」を維持できるか。
2. **「今だ！」が発生するか** — TV開始、寝入り、通路で押す瞬間を選べるか。
3. **ボタンを連打したくなるか** — Cooldownが終わっても次の窓まで待てるか。
4. **待ち時間が退屈か** — 高速化と反応の4.5秒がどう感じられるか。
5. **怪奇現象が効くと気持ちいいか** — 「YES」を維持・向上できるか。
6. **Opportunityを生活観察から理解できるか** — 正解ボタン表示なしで3種類の手がかりを学べるか。特に通路の範囲が自然に読めるか。
7. **タイミング外をもったいないと感じるか** — 小さい成果でも慣れは増えたと理解できるか。
8. **次の窓を待つことが期待になるか** — 時計待ちや作業感に変わっていないか。
9. **Feedbackで理由が分かるか** — GOOD TIMING / Mistimed / Missを区別し、反応中は睡眠文脈が続くことを納得できるか。

最重要: **住人を見ることが「どれを使うか」だけでなく「いつ使うか」を決めるゲームになったか。**

## ローカル起動・再検証

Godot 4.7.2 stableで `project.godot` をインポートし、F5で実行します。`1`=LIGHT、`2`=SOUND、`3`=SHADOW、`F1`=Debug、画面のPause/再開/Restartを使用できます。

以下の `godot` は手元のGodot 4.7.2コンソール版パスに置換します。CIは不要です。

```powershell
godot --headless --path . --editor --import --quit
godot --headless --path . --script tests/acceptance.gd
godot --headless --path . --script tests/acceptance_v02.gd
godot --path . --script tests/visual_smoke.gd
godot --headless --path . --script tests/realtime_timeout.gd
godot --headless --path . --script tests/policy_probe.gd
```
