# Stage 1 v0.1 検証結果

この文書は `cb0ac15` 時点の過去記録です。現在のv0.2実装の検証結果・再現手順は [STAGE_1_V02_VERIFICATION.md](STAGE_1_V02_VERIFICATION.md) を参照してください。

## 対象と環境

- 対象: Issue #1 / `feature/stage1-core-prototype-v01`
- 正本: `docs/STAGE_1_CORE_PROTOTYPE_SPEC.md`。指定4文書を実装前に確認。
- エンジン: `4.7.2.stable.official.ed1daf0bf`（公式Windowsコンソール版）
- 環境: Windows / OpenGL 3.3 Compatibility / NVIDIA GeForce RTX 5060
- 検証はローカル実行のみ。GitHub Actions・従量課金CI/CD・外部アセット・Pluginなし。

## Acceptance Criteria

PASSは以下のローカル検証範囲での結果です。クリーンPCへの配布検証や人間のCore Fun評価を意味しません。

| 項目 | 結果 | 確認内容 |
| --- | --- | --- |
| Godot 4.7.2で開ける | PASS | 指定版で `--editor --import --quit` 成功 |
| エラーなしで実行できる | PASS | 実シーンのheadless / OpenGL実行、テスト終了コード0 |
| Residentが自律生活する | PASS | WALK移動、生活への抽選、生活→WALK、指定時間範囲、40/30/30%の分布を検証 |
| Stateを視覚的に判別できる | PASS | 6状態の実描画を画像で確認。場所・コップ・リモコン・目・口・Zzz・警戒弧・状態ラベル |
| LIGHT / SOUND / SHADOWが発動可能 | PASS | 実Viewportへのマウス入力、キー入力、共通発動処理 |
| StateによってFearGainが変化 | PASS | 通常4状態×3種の期待値を照合。SOUND/SLEEPは20 |
| StateMultiplier 0でMiss | PASS | SLEEPへのLIGHT/SHADOWはFearGain 0、睡眠継続とMiss Feedback |
| MissでもCooldown発生 | PASS | LIGHT 8秒 / SHADOW 15秒、再発動拒否 |
| MissではAdaptationが増えない | PASS | SLEEP Miss時の値・カウンターを確認 |
| 同じActionを使うと効果低下 | PASS | SLEEP/SOUNDが20→16。計算は使用前のAdaptationを参照 |
| Adaptation <= 80 | PASS | 各種10回反復で80、倍率下限0.2、時間で減衰しない |
| Fearは0〜100にClamp | PASS | 初期0 / Missで0維持 / Fear99から27加算して100 |
| Fear 100でWIN | PASS | 終了処理・台詞・入力停止。通常パラメーターの自動操作でもWIN |
| 180秒でLOSE | PASS | 179秒では継続、180秒でLOSE。実時間 `_process` 検証も実施 |
| Pause正常動作 | PASS | Timer/AI/位置/Cooldown/Feedback/入力を凍結。盤面・数値詳細遮蔽、再開時予約発動なし |
| Restart可能 | PASS | WIN/LOSE画面で実マウス操作。Fear/時間/Adaptation/Cooldown/統計/Feedback/Debugを初期化 |
| F1 Debug Panel動作 | PASS | 実入力経由の表示切替と14項目、Pause中非表示、住人を避ける配置 |
| Playtest結果がConsoleへ出る | PASS | 指定14項目・ゼロ回平均・Missを含む平均・最大値・二重出力防止 |
| 連続プレイ可能 | PASS | 3連続180秒LOSE/Restartに加え、マウス経由WIN→Restart→LOSE→Restart |

## 再現方法と証拠

READMEの「ローカル検証」の5コマンドを使用します。

- `tests/acceptance.gd`: **355 checks, 0 failures**。
- `tests/visual_smoke.gd`: **12 screenshots、実Viewportマウス入力、0 failures**。
- 実描画した6状態、Miss、Feedback/Debug、Pause、WIN、LOSE、Restart画面を目視確認。生成画像はローカルの `test-output/` に保存され、Git管理対象外です。
- WINの境界テストではFearを99または90に設定して到達直前を再現しています。自然な初期値からの到達は下記のpolicy probeで別途確認しています。
- AI抽選分布はseed固定の10,000回。通常のゲーム進行はランダムです。
- `tests/realtime_timeout.gd`: 初期状態から手を加えず `_process` で実行。`result=LOSE simulation=180.000 wall=179.886 PASS=true` とConsole出力14項目を確認しました（ゲーム時間180秒、実測約179.9秒）。

## 実装上の判断と制約

- 反応は認識成功時のみ。SURPRISED 1.5秒→ALERT 3秒→中断した生活・残り時間へ復帰します。反応中に追加で驚かせた場合も最初の復帰先を保持します。
- SURPRISED / ALERTの「数値補正を持たない」を中立倍率1.0と解釈しています。直前の通常状態の倍率は引き継ぎません。この解釈はレビュー対象として明記します。
- WALK終了時に次行動を抽選し、活動位置へ即時に移します。WALK中の移動は連続しますが、家具までの経路探索は実装していません。
- 怪音は波形の簡易図形でフィードバックします。音声アセットは使用しません。
- Feedbackは1.8秒、Pauseでは凍結。ゲーム終了時はシミュレーション全体が停止します。
- 部屋はGodotの図形とLabelで構成し、日本語はWindowsのシステムフォントを使用します。

## Game Design Observations

### Core Fun Gate: FAIL（現行数値・現行の反応状態解釈）

`tests/policy_probe.gd` で、seed 0〜19、各20プレイ、0.1秒刻みで実ゲームシーンを進めました。数値改変や追加ルールは使っていません。平均時間はWIN/LOSEまでのゲーム内秒数です。

| 操作方針 | WIN | 平均時間 | 平均最終Fear |
| --- | --- | --- | --- |
| Cooldownが空き次第LIGHT→SOUND→SHADOWを試す | 20 / 20 | 30.435秒 | 100.0 |
| TVにLIGHT、水場・WALKにSHADOW、SLEEPにSOUND、反応中は待つ | 20 / 20 | 75.430秒 | 100.0 |
| LIGHTだけCooldownが空き次第使う | 0 / 20 | 180.000秒 | 63.4 |

- **「今だ」**: 状態ごとの得手不得手は数値・表示で確認できます。特に眠っている時はSOUNDが20、LIGHT/SHADOWはMissです。ただし観察せず勝てる反例があり、現状では観察を勝利の必要条件にできていません。
- **温存**: 個別の強いタイミングは存在しますが、単純操作より待つ戦略が有利になることは今回の試行で確認できませんでした。比較した観察方針は最適方針ではありません。
- **慣れによる切り替え**: 同じ現象の弱体化とLIGHT単独での敗北は確認できました。一方、機械的に3種を使うだけでも十分です。
- **Cooldown順操作**: 20 seedすべてで勝利したため、正本の「何も考えず連打しても勝てる」未成立条件に該当します。
- 連続発動では先の入力がSURPRISEDへ切り替えるため、後の入力は中立倍率1.0になります。睡眠中のSOUND直後にSHADOWが命中することもあります。反応状態の扱いは次の設計レビューで確認すべき点です。
- **人間が楽しめるかの評価: NOT VERIFIED**。自動操作と画面確認であり、外部プレイテストを行ったとは扱いません。

仕様の数値・Scopeは変更せず、この結果をレビュー材料として残します。Checkpoint 1の合格やStage 2への進行は宣言しません。
