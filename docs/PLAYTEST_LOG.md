# Playtest Log

Stage 1 Core Prototype以降のテストプレイ記録。

目的は「勝てるか」ではなく、Core Funが成立しているかを観察すること。

## Playtest 001 — First Human Playtest

Date: 2026-09-16

Build / Commit: PR #2 / `feature/stage1-core-prototype-v01` / `cb0ac15b4f7462226dd687a0c0f1a69e2a1be6de`

Tester: Project owner

### Qualitative Result

- 住人を見ていたくなるか: **とてもYES**
- 「今だ！」が発生するか: **あんまりない**
- ボタン連打したくなってしまうか: **少しYES**
- 待っている時間が退屈か: **少しYES**
- 怪奇現象が効いた時に気持ちいいか: **YES**

### Interpretation

#### Strong signals

- Residentを眺めること自体には強い魅力がある。
- 怪奇現象が成功した際のフィードバックには快感がある。
- 「自律生活する住人を観察し、幽霊として介入する」という土台は維持する価値が高い。

#### Weak signals

- 観察が「押す瞬間の判断」に十分つながっていない。
- 現状では明確なチャンスの瞬間が少なく、「今だ！」という感覚が弱い。
- Independent Cooldownにより、最適な瞬間を待つよりボタンを使いたくなる圧力が少し強い。
- 状態継続時間が長く、判断イベントの間隔がやや空くため、待ち時間を少し退屈に感じる。

### Core Fun Assessment

**Checkpoint 1: NOT PASS YET**

ただしCore Concept自体を否定する結果ではない。

現在の課題は「住人を見ることが楽しいか」ではなく、

> 観察した情報が、次の怪奇現象をいつ使うかという判断へ十分変換されていないこと。

そのため次ビルドでは、ゲームの土台を増やすより「判断密度」と「タイミング価値」を調整する。

### Hypothesis for Next Build

1. 行動開始直後などに短い **Opportunity Window** を設けると、「今だ！」が発生しやすくなる。
2. 状況に合っていない怪奇現象の効果を弱くすると、Cooldown順の機械的操作より観察が有利になる。
3. Residentの通常State継続時間を短くすると、観察の楽しさを保ったまま待ち時間を減らせる。
4. 怪奇現象成功直後の連続発動に短い共通Lockoutを設けると、連打より一手ごとの判断を促せる可能性がある。

### Proposed Direction for v0.2

優先順位:

1. Opportunity Windowの最小実験
2. 非適正タイミングの効果低下
3. State Duration短縮
4. 必要な場合のみ短いGlobal Action Lockoutを追加

一度に大きく変更せず、各変更が「今だ！」と待ち時間へどう影響したかを比較する。

---

## Record Template

### Playtest

Date:

Build / Commit:

Tester:

Result:

- WIN / LOSE
- Clear time or remaining time:
- Final Fear:

Action usage:

- LIGHT uses:
- SOUND uses:
- SHADOW uses:

Misses:

- LIGHT misses:
- SOUND misses:
- SHADOW misses:

Final Adaptation:

- LIGHT:
- SOUND:
- SHADOW:

### Core Fun Questions

1. 住人を見て「今だ」と思う瞬間があったか。
2. 強いタイミングまで怪奇現象を温存したくなったか。
3. 慣れによって別の怪奇現象へ切り替えたくなったか。
4. 失敗時に「次はこうしよう」と思えたか。
5. Cooldown終了順に押すだけになっていなかったか。
6. 3ボタンを順番に押すだけで攻略できなかったか。
7. 待ち時間が退屈ではなかったか。
8. Residentの現在行動を画面だけで理解できたか。

### What Felt Good

- 

### What Felt Bad

- 

### Unexpected Behavior

- 

### Hypothesis for Next Build

- 

### Parameter Changes Proposed

- 

---

## Stage 1 Population Note

完成版の住人数は現時点で固定しない。

Stage 1のコアが成立した後、1人 → 2人 → 3人… と段階的に増やし、「楽しく忙しい」から「ただ忙しい」へ変わる境界を探す。

現時点では最大10人程度を安全側の仮説とするが、テスト結果を優先する。
