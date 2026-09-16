# Stage 1 Core Prototype v0.2 Specification

## Status

正式採用。

v0.1の人間プレイテスト（Playtest 001）を受けた改善仕様。

v0.1を置き換えて完成版仕様とするものではなく、Checkpoint 1 Core Fun Gateへ向けた次の実験ビルドとして扱う。

---

## 1. Purpose

v0.1では以下が確認できた。

### Strengths

- 住人を見ていたくなる: とてもYES
- 怪奇現象が効いた時に気持ちいい: YES

### Problems

- 「今だ！」が発生する: あまりない
- ボタンを連打したくなる: 少しYES
- 待っている時間が退屈: 少しYES

また自動Policy Probeでは、Cooldownが空き次第3種を機械的に使う方針でも20/20で勝利し、観察を必要としない攻略が成立した。

v0.2では、v0.1で確認できた「住人を眺める楽しさ」と「怪奇現象が効く気持ちよさ」を維持したまま、次の3点を改善する。

1. 「今だ！」と思う瞬間を増やす
2. 雑な連打の価値を下げる
3. 判断材料が来る頻度を上げ、待ち時間を減らす

---

## 2. Core Fun Hypothesis v0.2

> 住人の行動の中に短いOpportunity Windowを設け、良いタイミングで怪奇現象を使うと大きな成果が得られ、雑な発動では少ない恐怖しか得られない一方で慣れは進むようにすることで、「まだ……今だ！」と住人を観察して待つ楽しさが生まれる。

---

## 3. Scope

v0.1のScopeを維持する。

### Continue

- 1部屋
- 住人1人
- 住人AI
- 怪奇現象3種
- Fear
- Adaptation
- Cooldown
- Timer
- WIN / LOSE
- Feedback
- Debug
- Restart

### Do Not Add Yet

- 住人の性格
- 複数住人
- 複数部屋
- 新しい怪奇現象
- 幽霊力 / MP
- 経験値 / レベル
- 心霊度
- 家の成長
- アイテム
- ストーリー
- 怪奇コンボ専用システム
- 高度なAI

v0.2では新要素を増やすのではなく、既存の「観察 → タイミング → 発動」を濃くする。

---

## 4. Resident Pace

住人の通常State時間を短縮する。

| State | v0.1 | v0.2 |
| --- | --- | --- |
| WALK | 4〜7秒 | 3〜5秒 |
| WATCH_TV | 12〜20秒 | 9〜14秒 |
| DRINK_WATER | 5〜8秒 | 4〜6秒 |
| SLEEP | 20〜30秒 | 12〜18秒 |
| SURPRISED | 1.5秒 | 1.5秒 |
| ALERT | 3秒 | 3秒 |

Walk終了時の抽選確率は変更しない。

- WATCH_TV: 40%
- DRINK_WATER: 30%
- SLEEP: 30%

目的はボタンを増やして暇を埋めることではなく、住人側から次の判断材料が来る頻度を増やすこと。

---

## 5. Opportunity Window

各怪奇現象に、特に強く効く短いOpportunity Windowを1つ設定する。

Opportunity Window中は、通常のStateMultiplierとは別にTimingMultiplierを適用する。

### LIGHT Opportunity

対象State:

`WATCH_TV`

Window:

`WATCH_TV`開始から最初の3.0秒

意味:

住人がテレビを見始めた直後に照明を落とす。

### SOUND Opportunity

対象State:

`SLEEP`

Window:

`SLEEP`開始から最初の4.0秒

意味:

寝入りばなに怪音を発生させる。

### SHADOW Opportunity

対象State:

`WALK`

Window:

住人が部屋中央の「Shadow Chance Zone」を通過している間。

初期Zone:

- X = 500〜640

YはWALK移動範囲内で判定しない。

Room Viewには、この位置が「人影を見せやすい通路・出入口」であることが分かる環境表現を置く。

`CHANCE`などの正解テキストを常時表示しない。

プレイヤーは住人の位置を観察して判断する。

---

## 6. Timing Multiplier

Fear計算へTimingMultiplierを追加する。

```text
FearGain
=
BaseFear
× StateMultiplier
× TimingMultiplier
× AdaptationMultiplier
```

### Opportunity成功時

```text
TimingMultiplier = 1.75
```

### 認識されたがOpportunity外

```text
TimingMultiplier = 0.50
```

### StateMultiplier = 0

従来どおりMiss。

```text
FearGain = 0
AdaptationGain = 0
Cooldown = 発生
```

TimingMultiplierは適用しない。

---

## 7. Adaptation and Mistimed Actions

認識された怪奇現象では、Opportunity成功・失敗に関係なく従来どおりAdaptationが増える。

つまり、タイミングが悪い発動では、

```text
FearGain = 小さい
Adaptation = 通常どおり増える
Cooldown = 発生
```

となる。

これにより雑な連打には「怪奇現象を慣れさせてしまう」という代償を持たせる。

ただし住人が認識していないMissではAdaptationを増やさない。

例:

SLEEP中のLIGHT:

- StateMultiplier = 0
- FearGain = 0
- AdaptationGain = 0
- Cooldown = 8秒

---

## 8. Existing Ghost Action Values

v0.2では、まずBaseFear / Cooldown / AdaptationGain / StateMultiplierは変更しない。

タイミングシステムの効果を単独で評価するためである。

### LIGHT

- BaseFear: 8
- Cooldown: 8秒
- AdaptationGain: 20

StateMultiplier:

- WATCH_TV: 1.6
- WALK: 1.2
- DRINK_WATER: 1.0
- SLEEP: 0.0

### SOUND

- BaseFear: 12
- Cooldown: 10秒
- AdaptationGain: 22

StateMultiplier:

- WATCH_TV: 0.7
- WALK: 1.0
- DRINK_WATER: 1.2
- SLEEP: 1.7

### SHADOW

- BaseFear: 18
- Cooldown: 15秒
- AdaptationGain: 30

StateMultiplier:

- WATCH_TV: 1.0
- WALK: 1.5
- DRINK_WATER: 1.3
- SLEEP: 0.0

---

## 9. Reaction State Context

v0.1ではSURPRISED / ALERTを中立倍率1.0として扱ったため、以下のような連打が成立した。

```text
SLEEP
↓
SOUND
↓
SURPRISED
↓
SHADOWが倍率1.0で命中
```

v0.2ではこれを変更する。

### Effective State

SURPRISED / ALERT中に怪奇現象が発動された場合、StateMultiplier判定には「驚く直前の生活State」を使用する。

例:

```text
SLEEP
↓ SOUND
SURPRISED
↓ SHADOW
```

SHADOWはSLEEPのStateMultiplier `0.0` を使用するためMiss。

### Opportunity during Reaction

SURPRISED / ALERT中はOpportunity Window扱いにしない。

```text
TimingMultiplier = 0.50
```

ただしEffective StateのStateMultiplierが0ならMissを優先する。

この仕様により反応中の追加発動を完全禁止せず、雑な連打の価値だけを抑える。

将来的な怪奇コンボの余地は残す。

---

## 10. Opportunity State Tracking

住人は通常Stateについて以下を追跡できるようにする。

- current normal state
- current state elapsed time
- current state remaining time
- suspended / context state

Opportunity判定は通常Stateと経過時間、または位置から算出する。

反応Stateに入っても、元の生活Contextを保持する。

---

## 11. Feedback

怪奇現象を使用した後に「なぜその結果になったか」を学べることを重視する。

### Opportunity Success

例:

```text
恐怖 +35！
GOOD TIMING ×1.75
```

### Recognized but Mistimed

例:

```text
恐怖 +6
タイミングが悪い ×0.50
```

### Miss

```text
気づかなかった…
```

Adaptationが既にある場合は従来どおり、必要に応じて

`慣れてきた…`

を併記してよい。

事前にGhost Actionボタンを光らせて正解を直接教えるUIは追加しない。

---

## 12. Room Visual Cues

Opportunity WindowはUIの正解表示ではなく、Room View内の生活観察から読めることを優先する。

最低限:

- WATCH_TV開始が視覚的に分かる
- SLEEP開始が視覚的に分かる
- SHADOW用の通路 / 出入口Zoneが背景として分かる

Debug Modeでは検証用にOpportunity状態を明示してよい。

---

## 13. Debug Additions

既存Debugへ以下を追加する。

- EffectiveState
- StateElapsedTime
- CurrentOpportunityAction または `NONE`
- IsOpportunityWindow
- LastTimingMultiplier

これらは通常UIには表示しない。

---

## 14. Game Time

v0.2ではGame Timerを変更しない。

```text
180秒
```

住人テンポとTimingルールの変更だけを先に評価する。

必要ならPlaytest 002後に再検討する。

---

## 15. Automated Policy Probe

v0.1と同じく、人間の楽しさを代替するものではない。

ただし設計上の反例検出として以下を比較する。

### Policy A: Cooldown Spam

Cooldownが空き次第、LIGHT → SOUND → SHADOWを機械的に使用。

### Policy B: Opportunity Aware

- LIGHT: WATCH_TV Opportunityのみ
- SOUND: SLEEP Opportunityのみ
- SHADOW: WALK Shadow Chance Zoneのみ
- SURPRISED / ALERT中は待つ

### Policy C: Single Action

LIGHTのみCooldownが空き次第使用。

記録:

- WIN rate
- 平均終了時間
- 平均最終Fear
- 平均Opportunity成功数
- 平均Mistimed発動数

### Design Target

Implementation Acceptanceとは分離する。

望ましい方向:

- Cooldown Spamがv0.1のような20/20簡単勝利にならない
- Opportunity AwareがCooldown Spamより明確に有利になる
- 「観察しなくても最速」が解消される

特定の勝率数値へ過剰最適化しない。

---

## 16. Human Playtest 002 Questions

v0.2を人間がプレイし、Playtest 001と同じ軸で比較する。

1. 住人を見ていたくなるか
2. 「今だ！」が発生するか
3. ボタンを連打したくなるか
4. 待っている時間が退屈か
5. 怪奇現象が効いた時に気持ちいいか

追加:

6. Opportunity Windowは観察から理解できたか
7. タイミングを外した時に「もったいない」と感じたか
8. 次のOpportunityを待つことが苦痛ではなく期待になったか
9. Feedbackから成功 / 失敗の理由を理解できたか

### Desired Direction

Playtest 001から最低限、以下の方向変化を狙う。

- 住人を見ていたくなる: `とてもYES` を維持
- 「今だ！」: 改善
- 連打したくなる: 減少
- 待ち時間が退屈: 減少
- 効いた時が気持ちいい: `YES` を維持または向上

---

## 17. Implementation Acceptance Criteria v0.2

v0.1のAcceptance Criteriaをすべて維持したうえで、以下を追加する。

- Resident通常State時間がv0.2値になっている
- LIGHT OpportunityがWATCH_TV開始後3秒だけ成立する
- SOUND OpportunityがSLEEP開始後4秒だけ成立する
- SHADOW OpportunityがWALK中の指定Zoneで成立する
- Opportunity成功時にTimingMultiplier 1.75が適用される
- Opportunity外の認識成功ではTimingMultiplier 0.50が適用される
- MistimedでもAdaptationが通常どおり増える
- MissではAdaptationが増えない
- SURPRISED / ALERT中は直前生活StateをEffectiveStateとして使う
- SURPRISED / ALERT中はOpportunity扱いにならない
- SLEEP → SOUND → SURPRISED → SHADOW がMissになる
- DebugでOpportunity / EffectiveState / TimingMultiplierを確認できる
- 通常UIがOpportunityの正解を事前表示しない
- Policy Probeでv0.2比較結果を出力できる

---

## 18. Checkpoint 1 Rule

v0.2の実装完了だけではCheckpoint 1を通過しない。

Checkpoint 1の判断には必ず人間のPlaytest 002を使用する。

最重要確認:

> 住人を見ることが、次の操作だけでなく「いつ操作するか」を決めるゲームになったか。

これが成立しなければ、Stage 2へ進まずStage 1内で再度改善する。
