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

## Playtest 002 — Opportunity Window Human Playtest

Date: 2026-09-16

Build / Commit: PR #2 / `feature/stage1-core-prototype-v01` / v0.2 implementation (`0dae06e026fbdb68246fa51120454f4cef8c6431`)

Tester: Project owner

### Qualitative Result

- 住人を見ていたくなるか: **とてもYES**
- 「今だ！」が発生するか: **すこしYES**
- ボタンを連打したくなるか: **あんまりない**
- 待ち時間が退屈か: **すこしYES**
- 怪奇現象が効いた時に気持ちいいか: **YES**
- Opportunityを観察だけで理解できたか: **NO**
- タイミングを外した時に「もったいない」と感じたか: **YES**
- 次のOpportunityを待つのが「待ち作業」ではなく期待になったか: **すこしYES**
- GOOD TIMING / Mistimed / Missの違いをFeedbackから理解できたか: **全然わからない**

### Comparison with Playtest 001

#### Improved

- 「今だ！」は「あんまりない」から「すこしYES」へ改善。
- ボタン連打欲求は「少しYES」から「あんまりない」へ改善。
- タイミングを外した際に「もったいない」という損失感が発生した。
- Opportunityを待つことに少し期待感が生まれた。

#### Maintained Strengths

- 住人を見ていたくなる: **とてもYES**を維持。
- 怪奇現象が効いた時に気持ちいい: **YES**を維持。

#### Remaining Problems

- Opportunity Windowを画面観察だけでは理解できなかった。
- GOOD TIMING / Mistimed / Missの違いをFeedbackからほぼ理解できなかった。
- 待ち時間の退屈さは「すこしYES」のままで、十分には改善していない。
- 「今だ！」は改善したが、まだ強いYESには届いていない。

### Core Fun Assessment

**Checkpoint 1: NOT PASS YET**

理由は、Core Mechanic自体の方向性よりも **legibility / feedback clarity** にある。

v0.2では自動Policy Probe上、Opportunity AwareがCooldown Spamより大幅に有利になり、人間プレイでも連打欲求が減少した。よって「観察に報酬を与える」ルール変更自体は機能している可能性が高い。

一方、プレイヤーがOpportunityを自然に読み取れず、結果FeedbackからGOOD / Mistimed / Missを理解できないため、現在はゲーム内部のルールとプレイヤーの認知が噛み合っていない。

現段階の主課題:

> 正解を直接表示せずに、住人の生活演出と結果Feedbackだけで「何がチャンスで、なぜ今の一手が成功・失敗したか」を理解できるようにすること。

### Hypothesis for Next Build

v0.3では新ルールを増やさず、主に情報設計を改善する。

1. Opportunityの前兆・開始演出を生活アニメーション側で明確化する。
2. GOOD / Mistimed / Missで、文字だけでなくサイズ・動き・一時的な画面反応を明確に変える。
3. Feedbackを「結果」と「理由」に分け、短時間でも読み取れる順序にする。
4. 初回プレイ中に説明文を常時出すのではなく、最初の数回だけ住人の自然な仕草や短い補助表現で学べるようにする。
5. 待ち時間には新しい操作を増やさず、住人の次の行動を予感できる小さな予兆を追加する。

### Proposed Direction for v0.3

**テーマ: Readability / Learnability Pass**

機械的な数値調整は最小限に留め、以下を優先する。

- Opportunity cueの強化
- GOOD / Mistimed / Miss feedbackの明確な差別化
- 「いつ押すか」を学べる非言語的な導線
- 待ち時間中の期待感を少し高める生活予兆

v0.3実装後、Playtest 003で同じ9項目を再評価する。

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
