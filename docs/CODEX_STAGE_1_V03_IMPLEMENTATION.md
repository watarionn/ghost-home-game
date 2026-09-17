# Codex Implementation Guide — Stage 1 v0.3

## Source of Truth

`docs/STAGE_1_CORE_PROTOTYPE_V03_SPEC.md`

実装前に以下を読むこと。

1. `docs/STAGE_1_CORE_PROTOTYPE_SPEC.md`
2. `docs/STAGE_1_CORE_PROTOTYPE_V02_SPEC.md`
3. `docs/PLAYTEST_LOG.md`
4. `docs/STAGE_1_V02_VERIFICATION.md`
5. `docs/STAGE_1_CORE_PROTOTYPE_V03_SPEC.md`
6. Issue #9
7. PR #2のレビュー・コメント

## Goal

v0.2で成立し始めた「観察してOpportunityを狙う」ゲーム性を維持しながら、以下を改善する。

- Opportunityを生活演出から理解できること
- GOOD / MISTIMED / MISSを結果Feedbackから理解できること
- Resident AIの同一生活行動streakを抑えること
- 使っていない怪奇現象のAdaptationが時間で少し回復すること

## Constraints

- Godot 4.7.2 stable / GDScript
- 既存 `feature/stage1-core-prototype-v01` と PR #2 を継続使用
- mainへ直接コミットしない
- 新しい怪奇現象・住人・部屋・成長要素を追加しない
- Opportunityを事前に正解ボタンとして表示しない
- GitHub Actionsを使用しない
- 従量課金が発生する可能性のあるCI/CDを使用しない

## Implementation Priority

1. v0.3 specをテスト可能な定数へ整理
2. Resident anti-streak history / weighted selection
3. per-action Adaptation recovery timer
4. Opportunity cue改善
5. GOOD / MISTIMED / MISS feedback差別化
6. Debug / logging追加
7. 回帰テスト
8. v0.3追加テスト
9. visual smoke
10. policy / flow probe
11. verification document更新
12. PR #2本文更新

## Important Behavior

### Anti-Streak

- Base weightsは変えない
- 直前と同じ非WALK活動候補は `×0.35`
- 直近2回が同じ場合、その候補は `×0.15`
- 再正規化して抽選
- 同じ行動を禁止しない

### Adaptation Recovery

Actionごとに独立。

- 最後の認識成功から20秒後に回復開始
- 1.0 Adaptation / 秒
- GOOD / MISTIMEDで該当Actionの待機をreset
- MISSではresetしない
- 他Actionの使用はresetしない
- Pause / game result中は進めない

### Feedback

通常UIでは内部倍率より結果カテゴリを優先する。

GOOD:

`大成功！ / 恐怖 +XX`

MISTIMED:

`効いたが弱い… / 恐怖 +XX`

MISS:

`気づかなかった…`

可能なら短い文脈理由も表示する。

## Verification

既存v0.1/v0.2 Acceptanceを壊さないこと。

v0.3 spec Section 12の境界テストを追加すること。

特に以下を明示検証する。

- repeat weight calculation
- 3連続が禁止ではなく低確率で残ること
- recovery 19.999 / 20.000秒境界
- recovery rate
- other-action independence
- Miss does not reset recovery
- Pause freezes recovery
- GOOD / MISTIMED / MISS visual/text category separation

## Automated Probe

自動比較は人間のCheckpoint判定に使わない。

ただし以下は設計反例検出として記録する。

- activity streak distribution
- max same non-WALK activity streak
- per-action total recovered adaptation
- cooldown spam
- opportunity-aware policy

## Completion Report

PR #2へ以下を報告する。

1. 実装内容
2. 変更ファイル
3. 既存Acceptance結果
4. v0.3追加Acceptance結果
5. activity streak probe
6. adaptation recovery probe
7. Policy Probe
8. visual feedback確認
9. 既知の問題
10. Playtest 003で確認すべき点

Checkpoint 1をCodex側でPASSにしないこと。人間のPlaytest 003後に判断する。
