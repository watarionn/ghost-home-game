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

### Additional Playtest Observations

#### Resident behavior streaks can force adaptation

実プレイ中に、`WALK → DRINK_WATER → WALK → DRINK_WATER` のように同じ非WALK行動が何度も連続して選ばれるケースが発生した。

現行AIはWALK終了ごとに40/30/30%で独立抽選するため、同一行動の連続は確率上自然に発生する。しかし、特定行動が続くと、その行動に適した怪奇現象を繰り返し使う状況へプレイヤーが押し込まれ、プレイヤーの判断というよりAI乱数によってAdaptationが強制的に進む感覚が生じる。

これは「同じ手を使った結果、住人が慣れた」という納得感と異なる。

v0.3候補として、非WALK行動の完全禁止ではなく、直近履歴に応じて同じ行動の抽選Weightを下げる **anti-streak weighting** を検討する。

目的:

- 生活のランダム感は残す
- 同じ行動だけが長く続く極端な偏りを減らす
- プレイヤーに異なるOpportunityが巡ってくる余地を増やす

#### Adaptation recovery may create a useful longer-term rhythm

怪奇現象を長時間使わなかった場合、その現象へのAdaptationが少しずつ減少する仕組みも候補。

ただし「何もしないで待つほど有利」にすると、既存の待ち時間問題を悪化させる可能性がある。

そのため候補としては、全怪奇現象を止めるGlobal Calm Recoveryより、**各怪奇現象ごとに、その現象を一定時間認識させなければその現象のAdaptationが緩やかに減る方式**を優先する。

これにより、LIGHTを休ませている間にSOUND / SHADOWを使うなど、行動を止めずにローテーションする戦略が生まれる可能性がある。

初期実験候補:

- 各現象について最後に住人へ認識された時刻を保持
- その現象を20秒間認識させなければ回復開始
- 回復速度は `1 Adaptation / 秒` 程度から検証
- Missは「認識されていない」ため回復待機時間をリセットしない
- Adaptation下限は0

この数値は正式決定ではなく、v0.3設計時の実験候補とする。

### Core Fun Assessment

**Checkpoint 1: NOT PASS YET**

理由は、Core Mechanic自体の方向性よりも **legibility / feedback clarity** にある。

v0.2では自動Policy Probe上、Opportunity AwareがCooldown Spamより大幅に有利になり、人間プレイでも連打欲求が減少した。よって「観察に報酬を与える」ルール変更自体は機能している可能性が高い。

一方、プレイヤーがOpportunityを自然に読み取れず、結果FeedbackからGOOD / Mistimed / Missを理解できないため、現在はゲーム内部のルールとプレイヤーの認知が噛み合っていない。

加えて、Residentの行動抽選偏りによって特定Opportunityが連続し、Adaptationがプレイヤーの意図より乱数に支配されるケースが確認された。

現段階の主課題:

> 正解を直接表示せずに、住人の生活演出と結果Feedbackだけで「何がチャンスで、なぜ今の一手が成功・失敗したか」を理解できるようにしつつ、住人AIの偶然の偏りでプレイヤーの選択肢が長時間固定されないようにすること。

### Hypothesis for Next Build

v0.3では大規模な新要素を増やさず、主に情報設計とプレイリズムを改善する。

1. Opportunityの前兆・開始演出を生活アニメーション側で明確化する。
2. GOOD / Mistimed / Missで、文字だけでなくサイズ・動き・一時的な画面反応を明確に変える。
3. Feedbackを「結果」と「理由」に分け、短時間でも読み取れる順序にする。
4. 初回プレイ中に説明文を常時出すのではなく、最初の数回だけ住人の自然な仕草や短い補助表現で学べるようにする。
5. 待ち時間には新しい操作を増やさず、住人の次の行動を予感できる小さな予兆を追加する。
6. 直近の行動履歴を使ったanti-streak weightingで、同一生活行動の極端な連続を抑える。
7. 怪奇現象ごとのAdaptation recoveryを小さく実験し、ローテーションに意味を持たせる。

### Proposed Direction for v0.3

**テーマ: Readability / Learnability + Flow Stability Pass**

優先順位:

- Opportunity cueの強化
- GOOD / Mistimed / Miss feedbackの明確な差別化
- 「いつ押すか」を学べる非言語的な導線
- Resident行動のanti-streak weighting
- 怪奇現象ごとの緩やかなAdaptation recovery
- 待ち時間中の期待感を少し高める生活予兆

v0.3実装後、Playtest 003で同じ9項目に加え、「AIの行動偏りで同じ怪奇現象を強制された感覚があったか」「休ませた怪奇現象が再び使えるようになる感覚が自然だったか」を確認する。

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
