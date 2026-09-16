# Stage 1 Core Prototype v0.3 実装・検証報告

Refs #1, #3, #9 / PR #2 / `feature/stage1-core-prototype-v01`

検証日: 2026-09-16。正本は `docs/STAGE_1_CORE_PROTOTYPE_V03_SPEC.md`。
実装前に指定の6文書、Issue #9、PR #2のレビュー2件・会話コメント4件・行コメント0件を確認しました。

**Core Fun Gate / Checkpoint 1: NOT PASS YET。人間のPlaytest 003待ちです。**
以下のPASSは実装・自動検証・表示構成の確認であり、楽しさや初見の理解度の合格ではありません。

## 1. 実装内容

- TV開始: リモコンを2.6秒間上げ、0.7秒で向き直る姿勢と視線、起動直後2.6秒のTV画面の明るさ変化を追加。
- 寝入り: あくびから0.65〜1.8秒で横になり、開始4秒まで小さく落ち着く動き。定常睡眠では動きを止めます。
- SHADOW通路: ドア枠・開いた扉・敷居で環境を明確化。既存のX=500〜640判定と人影位置は維持し、Zone色枠やCHANCE表示は設けません。
- 結果は「大成功！」「効いたが弱い…」「気づかなかった…」と文脈理由。GOODは大きい文字、強い驚き、0.35秒の短いPulse。MISTIMEDは小さい文字・弱い驚きでPulseなし。MISSは恐怖加算表示・新しい驚きなし。
- 非WALK行動履歴で同一候補だけ重みを0.35倍、直近2回が同じなら0.15倍へ置換し、合計1へ再正規化。WALKと反応からの復帰は履歴を増やしません。
- Actionごとに最後の認識からの経過時間を保持。20秒より後の時間だけ1.0/秒でAdaptationを回復。小数を保持し、下限0・上限80。GOOD/MISTIMEDだけ該当Actionの待機をリセットします。
- Pause・WIN/LOSEでは回復待機、回復量、生活演出、Feedbackも停止。Restartでは追加履歴・回復量も初期化。
- Debugへ指定9項目、既存16項目の終了ログへAction別回復総量3項目と最大同一活動streakを追加。
- 1部屋・住人1人・3現象を維持。180秒、Fear100、Opportunity窓、1.75/0.50、BaseFear、Cooldown、AdaptationGain、StateMultiplier、生活時間、SURPRISED1.5秒/ALERT3秒は変更していません。

## 2. 変更ファイル

| ファイル | 内容 |
| --- | --- |
| `data/balance.gd` | 重み・回復・生活演出の定数 |
| `scripts/resident.gd` | 非WALK履歴、抽選、streak、生活姿勢・強弱反応 |
| `scripts/ghost_action_manager.gd` | Action別回復と小数Adaptation |
| `scripts/game_manager.gd` | 結果カテゴリ・文脈理由・追加ログ |
| `scripts/room.gd` | 生活演出、ドア、結果パネル、短いPulse |
| `scripts/debug_panel.gd` / `scripts/ui.gd` | 追加Debug9項目、慣れ小数表示、v0.3表記 |
| `project.godot` | プロジェクト名だけv0.3へ更新 |
| `tests/acceptance.gd` / `tests/acceptance_v02.gd` | v0.3で改訂されたルール・文言に期待値を更新 |
| `tests/acceptance_v03.gd` / `.uid` | Section 12と停止・復帰・初期化の追加検証 |
| `tests/flow_probe.gd` / `.uid` | 行動分布と回復timelineの記録 |
| `tests/policy_probe.gd` / `tests/visual_smoke.gd` | 回復/streak計測、生活演出・結果画面の実描画 |
| `README.md` | 起動・操作・ローカル検証・Checkpointの現在状況 |
| `docs/STAGE_1_V02_VERIFICATION.md` | v0.2の過去記録であることを明示 |
| `docs/STAGE_1_V03_VERIFICATION.md` | 本報告 |
| `docs/evidence/policy_probe_v03.json` / `flow_probe_v03.json` | 実行結果のスナップショット |
| `docs/evidence/v03_good.png` / `v03_mistimed.png` / `v03_miss.png` | F1 OFFの結果表示3種 |

仕様書と人間の `PLAYTEST_LOG.md` は変更していません。

## 3. 既存Acceptance結果

環境: **Godot 4.7.2.stable.official.ed1daf0bf / Windows / OpenGL 3.3 Compatibility / RTX 5060**。

| v0.1からのAcceptance | 結果・根拠 |
| --- | --- |
| Godot 4.7.2で開ける | PASS: editor import、GDScript読込 |
| エラーなしで実行 | PASS: headless/OpenGL、各検証終了コード0 |
| Resident自律生活 | PASS: WALK移動、抽選、活動→WALK。基礎分布と履歴補正を別に検証 |
| Stateの視覚判別 | PASS: 6状態と開始/定常の描画を確認 |
| 3現象が発動 | PASS: キー入力・実Viewportマウス操作・共通処理 |
| StateでFearGain変化 | PASS: 4通常状態×3現象、反応文脈を含む |
| StateMultiplier 0でMiss | PASS: 睡眠中LIGHT/SHADOW、反応中も睡眠文脈を保持 |
| MissでもCooldown | PASS: 8秒/15秒、再入力拒否 |
| Missで慣れ加算なし | PASS: 初期0・非ゼロの両方。時間による回復とは独立 |
| 同じActionで効果低下 | PASS: 回復開始前の反復と慣れFeedback |
| Adaptation <= 80 | PASS: 上限80・倍率下限0.2、v0.3回復下限0 |
| Fearを0〜100へClamp | PASS: 初期0・Miss・99からの加算 |
| Fear100でWIN | PASS: 境界、入力停止、Policy通常初期値 |
| 180秒でLOSE | PASS: 境界と実 `_process` 約180秒 |
| Pause正常動作 | PASS: 生活・反応・窓・回復・入力を停止、盤面遮蔽 |
| Restart | PASS: WIN/LOSE後のマウス操作、追加カウンターも初期化 |
| F1 Debug | PASS: 実キー、既存19項目と追加9項目、Pause時非表示 |
| Consoleログ | PASS: 既存16項目を維持、追加4項目、二重出力防止 |
| 連続プレイ | PASS: 3連続LOSE/RestartとマウスWIN→Restart→LOSE→Restart |

| v0.2追加Acceptance | 結果・根拠 |
| --- | --- |
| 生活時間を維持 | PASS: WALK3〜5、TV9〜14、水4〜6、睡眠12〜18秒 |
| LIGHTの3秒窓 | PASS: 0 / 2.999 / 3.000 / 3.001秒 |
| SOUNDの4秒窓 | PASS: 0 / 3.999 / 4.000 / 4.001秒 |
| SHADOWのZone | PASS: X499.999 / 500 / 570 / 640 / 640.001、Y非依存 |
| GOOD倍率1.75 | PASS: 慣れ0でLIGHT22 / SOUND36 / SHADOW47 |
| MISTIMED倍率0.50 | PASS: 同一通常状態で6 / 10 / 14 |
| MISTIMEDでも慣れ加算 | PASS: +20 / +22 / +30、GOODと同量 |
| Missで慣れ不変 | PASS: 発動瞬間に加算なし、回復待機にも影響なし |
| EffectiveState | PASS: 4生活×2反応×3現象、連続反応でも文脈維持 |
| 反応中は窓無効 | PASS: NONE、認識時0.50、復帰後は中断時刻から継続 |
| SLEEP→SOUND→反応→SHADOWはMiss | PASS: 連打時もFear/慣れ加算0、Cooldown15秒 |
| v0.2 Debug追加5項目 | PASS: 値確認・実描画 |
| 正解を事前表示しない | PASS: 窓だけではボタンが変化しない、F1 OFF描画 |
| Policy比較の出力 | PASS: 3方針×20seed、集計整合性エラー0 |

`acceptance.gd`: **358 checks, 0 failures**。`acceptance_v02.gd`: **297 checks, 0 failures**。
旧「慣れは時間で減らない」はv0.3で明示改訂されたため20秒待機/回復へ変更。完全独立40/30/30は履歴が空の基礎分布として維持し、通常抽選の補正は別テスト。旧英語Feedback文字列は指定の日本語カテゴリへ更新しています。

- editor import、各テストのログにSCRIPT ERROR / ERROR / WARNING / FAILなし。
- 実時間試験: **LOSE / simulation=180.000 / wall=179.942 / PASS=true**。
- 実描画: **35 screenshots, viewport mouse tests, 0 failures**。
- Git差分の空白検査を実施。全検証はローカル実行。GitHub Actions・従量課金CI/CD不使用。

## 4. v0.3追加Acceptance結果

`acceptance_v03.gd`: **193 checks, 0 failures**。3スイート合計 **848 checks, 0 failures**。

| Section 12 | 結果・根拠 |
| --- | --- |
| 基礎重み0.40/0.30/0.30 | PASS: 履歴なしで一致 |
| 直前と同じ候補のみ×0.35 | PASS: TV/水/睡眠すべてを対象に式を照合 |
| 2回連続後は同候補のみ×0.15 | PASS: ×0.35との積ではなく置換。3回連続後も検証 |
| 再正規化 | PASS: 各候補の計算式・合計1 |
| 同一行動が禁止されない | PASS: 全候補の正重み、各履歴から実際に同一候補を抽選可能 |
| WALKは履歴対象外 | PASS: WALKを挟んでも履歴維持、反応復帰も追加なし |
| 19.999秒は回復しない | PASS: 全Action、Adaptation60のまま・Recovering=false |
| 20.000秒から回復開始 | PASS: 全Action、Recovering=true、経過回復時間0なので60のまま |
| 1秒で1.0回復 | PASS: 21.000秒で59、21.250秒で58.75 |
| 0未満にならない | PASS: 長時間の回復・回復総量も元の慣れ量を超えない |
| 他Actionの独立性 | PASS: 全Action×GOOD/MISTIMEDで、他2種の待機/慣れは不変 |
| 認識時だけ該当待機をreset | PASS: 全Action×両認識カテゴリ、使用前回復後に慣れを加算 |
| MISSでresetしない | PASS: LIGHT/SHADOW、慣れも加算なし、Cooldown中も回復継続 |
| Pause停止 | PASS: 回復中の100秒Pauseと入力、再開後1.0/秒 |
| 文言が明確に異なる | PASS: 指定3文言・文脈理由、倍率を主表示にしない |
| 数字サイズ/演出強度が異なる | PASS: GOOD30px/MISTIMED20px、反応強度1.0/0.3、GOODのみPulse |
| MISSには恐怖加算表示なし | PASS: 加算ラベル非表示・空文字、新しい驚きなし |
| F1なしでカテゴリ区別可能な構成 | PASS: 通常画面の別文言・文字サイズ・動作、実画面で確認 |

さらに、20秒をまたぐ大きなフレームは閾値後の部分だけ回復すること、0.05秒分割との一致、小数AdaptationがFear倍率に反映されること、WIN/LOSE停止、Restart、追加Debug/ログも検証しました。

## 5. Activity streak probe

[flow_probe_v03.json](evidence/flow_probe_v03.json) に保存。seed **903**、各 **10,000非WALK活動**。同じproduction selectorを使い、比較側だけ抽選前の履歴を空にして基礎重みを適用します。両方で状態時間・WALKの乱数消費も行い、同じseedから開始しています。ゲームの勝率試験とは別の抽選比較です。

| 指標 | 基礎重みのみ | anti-streak |
| --- | ---: | ---: |
| TV / 水 / 睡眠回数 | 3928 / 3012 / 3060 | 3705 / 3147 / 3148 |
| 隣り合う同一活動（9999境界中） | 3301（33.01%） | 1341（13.41%） |
| 最大streak | 10 | 5 |

streak長ごとの連続区間数（例: 3回連続は長さ3の区間1件）:

| 長さ | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| 基礎のみ | 4512 | 1449 | 479 | 183 | 52 | 12 | 9 | 2 | 0 | 1 |
| anti-streak | 7418 | 1147 | 89 | 4 | 1 | 0 | 0 | 0 | 0 | 0 |

連続確率は減り、3回以上も残りました。基礎重みは同じでも長期の実出現率は履歴補正で変わります。この1seedの頻度をAcceptanceの閾値や将来の上限保証には使っていません。

## 6. Adaptation recovery probe

同じ [flow_probe_v03.json](evidence/flow_probe_v03.json) に時系列を保存。回復計算を明示するため **初期Adaptationを各60・最後の認識時刻を0** とした制御例です。実プレイやPolicyの初期値は0のままです。

| 時刻 | イベント | Adaptation LIGHT / SOUND / SHADOW |
| --- | --- | --- |
| 19.999 | 閾値直前 | 60 / 60 / 60 |
| 20.000 | 回復開始、瞬間的な1減少はなし | 60 / 60 / 60 |
| 21.000 | 回復1秒 | 59 / 59 / 59 |
| 21.000 | LIGHTが睡眠中MISS | 59 / 59 / 59（LIGHT待機21秒を維持） |
| 21.000 | SOUND認識 | 59 / 80 / 59（SOUNDだけ待機0） |
| 26.000 | 5秒経過 | 54 / 80 / 54 |
| 26.000 | SHADOW認識 | 54 / 80 / 80（SHADOWだけ待機0） |
| 46.000 | さらに20秒 | 34 / 75 / 80 |

最終回復総量 **LIGHT26 / SOUND6 / SHADOW6**。他Actionへ切り替えている間も休ませたActionの回復が進みます。20.000秒ちょうどは回復可能状態に入る境界で、そこからの経過時間×1.0を積分します。フレーム境界で1.0を先払いしません。

## 7. Policy Probe

[policy_probe_v03.json](evidence/policy_probe_v03.json) に60試行を保存。seed **0〜19**、**0.1秒刻み**、通常の初期値と実ゲームシーンを使用。反応が生活を中断するので、プレイ途中の履歴は方針ごとに分岐します。

| 方針 | WIN率 | 平均終了秒 | 平均最終Fear | 平均GOOD | 平均MISTIMED |
| --- | --- | ---: | ---: | ---: | ---: |
| cooldown_order | 20/20 | 118.435 | 100.0 | 1.15 | 32.15 |
| opportunity_aware | 20/20 | 36.990 | 100.0 | 3.15 | 0.00 |
| light_only | 0/20 | 180.000 | 37.8 | 2.05 | 17.15 |

| 方針 | 平均回復量 LIGHT / SOUND / SHADOW | 全試行中の最大streak |
| --- | --- | ---: |
| cooldown_order | 8.460 / 0.000 / 12.280 | 2 |
| opportunity_aware | 1.680 / 2.905 / 6.960 | 2 |
| light_only | 9.425 / 0.000 / 0.000 | 3 |

- cooldown_order: Cooldownが空き次第LIGHT→SOUND→SHADOW。連続発動の後続は直前の反応文脈を使用。
- opportunity_aware: 正確な内部State・時刻・位置を読み、窓内だけ発動。反応中は待機。
- light_only: LIGHTだけCooldownが空き次第発動。
- `全発動数 = GOOD + MISTIMED + MISS` 等の整合性: **60 games, 0 failures**。拒否された入力は発動数に含めません。

観察方針は平均 **81.445秒早い**一方、機械操作も20/20で勝利します。v0.2の同じ方針（127.015秒 / 36.625秒）に対し、機械操作は8.580秒速まり、観察方針は0.365秒遅くなりました。anti-streakと回復を同時に変更した比較なので、どちらが差の原因かは切り分けていません。今回の勝率に合わせた仕様外の調整はしていません。

### Game Design Observations

- 同一活動の偏りは減る一方、繰り返しは残ります。偶然らしさ・強制的な慣れの感覚が改善したかは人間確認が必要です。
- 休ませたActionの回復は作動しますが、短時間で勝つ観察Policyでは回復総量は小さめです。ローテーション動機や「何もしない方がよい」感覚はこの3方針では証明できません。
- GOODは大きい成果と強い反応、MISTIMEDは小さい成果、MISSは未認識という構成になりました。住人を見たい・効くと気持ちいいという長所を維持できたか、理由表示が学習につながるかはPlaytest 003で判断します。

## 8. Visual feedback確認

OpenGLの実Viewportでマウス操作と35枚の描画を取得し、通常6状態・TV/睡眠の時系列・3現象のGOOD/MISTIMED・MISS・慣れありFeedback・Debug・Pause・WIN/LOSE/Restartを確認しました。生成先は `test-output/v03_*.png`。代表3枚をGit管理しています。

| F1 OFF | 文言 | 恐怖加算 | Resident / 画面 |
| --- | --- | --- | --- |
| [GOOD](evidence/v03_good.png) | 大成功！＋文脈理由 | 30px | 大きい腕・口・跳ね、短いPulse |
| [MISTIMED](evidence/v03_mistimed.png) | 効いたが弱い…＋文脈理由 | 20px | 小さい反応、Pulseなし |
| [MISS](evidence/v03_miss.png) | 気づかなかった…＋睡眠理由 | 非表示 | 睡眠を継続、新しい驚きなし |

TVの明るさ変化/向き直り/リモコン、あくび→横になる→定常睡眠、ドアと人影の関係を確認。3行/慣れあり4行の結果パネルで文字が欠けず、家具名の一部がパネル端で切れない配置へ調整しました。倍率と回復時計・抽選履歴はDebugのみ。通常ボタンに正解を示す表示はありません。

表示構成の検証です。人間が初見で正しく区別・学習できたという評価はまだありません。

## 9. 既知の問題

- 機械操作でも全試行勝利。観察の利益は勝率より時間・発動効率に現れています。
- Policyは内部情報と100ms操作を使います。新しい生活演出の読みやすさや退屈さを測っていません。
- anti-streakは確率補正なので、3連続以上を防ぎきる保証はありません。これは仕様どおりです。
- 回復待機は最後の認識からの経過時間で、20秒を超えても進みます。Recoveringは「20秒以上かつAdaptation>0」。慣れ0ではfalseです。
- 発動中の生活文脈・通常時計は従来どおり停止/復帰します。MISSは既に進行中の反応を取り消さず、新しい反応を開始しません。
- WALK終了時の活動位置への即時移動は従来の仮構成を維持。経路探索はありません。
- Feedbackは毎回理由を表示します。説明量・Pulse・リアクションの好みは未確認。
- Windowsシステムフォントと仮図形を使用。クリーンPC、エクスポート配布、外部プレイテストは未実施。

## 10. Playtest 003で確認すべき点

**F1 OFFで数回プレイ**し、結果画面・Consoleログとともに以下を評価してください。これは未実施の確認票です。Checkpoint 1は人間の判断待ちです。

1. 住人を見ていたくなるか（「とてもYES」を維持）。
2. 「今だ！」が発生するか（Playtest 002より改善）。
3. ボタンを連打したくなるか（あんまりない以下を維持）。
4. 待ち時間の退屈が減ったか。
5. 怪奇現象が効くと気持ちいいか（YES維持以上）。
6. TV開始・寝入り・ドア通過からOpportunityを理解できたか。
7. タイミング外を「もったいない」と感じたか。
8. 次のOpportunityを待つことが期待になったか。
9. GOOD / MISTIMED / MISSを通常画面から理解できたか。
10. 同じ生活行動が不自然に連続する感覚は減ったか。
11. Residentの選択が作為的すぎると感じないか。
12. 回復を見て「別の怪奇現象を使って待とう」と思えたか。
13. 回復のためだけに何もしない時間が増えていないか。
14. Feedbackが説明過多・うるさすぎないか。

### 起動・再検証

Godot 4.7.2 stableで `project.godot` をインポートし、**F5**で開始。`1`/`2`/`3`が3現象、F1がDebugです。以下はローカルだけで実行します（`godot` を手元のコンソール版実行ファイルへ置換）。

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

再実行の生成物は `test-output/` に出し、過去の `docs/evidence/` を自動上書きしません。mainへの直接コミット・マージは行いません。
