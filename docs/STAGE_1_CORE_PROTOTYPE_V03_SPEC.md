# Stage 1 Core Prototype v0.3 Specification

## Status

正式採用。

Playtest 002の結果と追加観察を受けたStage 1内の改善実験。

Checkpoint 1はまだ未通過。v0.3実装後の人間Playtest 003で判定する。

---

## 1. Purpose

Playtest 002では、v0.2によって以下が改善した。

- 住人を見ていたくなる: とてもYESを維持
- 「今だ！」: あまりない → すこしYES
- ボタン連打欲求: 少しYES → あんまりない
- タイミング外の「もったいない」: YES
- Opportunity待ち: すこし期待になる
- 怪奇現象が効いた時の気持ちよさ: YESを維持

一方で以下が未達だった。

- Opportunityを観察だけで理解できない
- GOOD TIMING / Mistimed / Missの違いがFeedbackから分からない
- 待ち時間はまだ少し退屈
- Residentのランダム行動が偏ると、同じ怪奇現象を何度も使わされAdaptationが半ば強制的に進む

v0.3では新しい怪奇現象や成長要素を追加せず、次の2テーマを改善する。

1. Readability / Learnability
2. Flow Stability

---

## 2. Core Hypothesis v0.3

> Opportunityの前兆と結果Feedbackを生活演出から理解できるようにし、Residentの行動偏りを抑え、使わなかった怪奇現象への慣れが徐々に薄れるようにすることで、プレイヤーが「何が起きたか」を理解しながら次のOpportunityを期待して待てるようになる。

---

## 3. Scope

v0.2のScopeを維持する。

### Continue

- 1部屋
- 住人1人
- 3怪奇現象
- Fear
- Adaptation
- Cooldown
- Opportunity Window
- TimingMultiplier
- EffectiveState
- 180秒Timer
- WIN / LOSE
- Pause / Restart
- Debug
- Playtest logging

### Do Not Add Yet

- 新しい怪奇現象
- 複数住人
- 複数部屋
- 性格差
- 幽霊力 / MP
- アイテム
- ストーリー
- 家の成長
- 怪奇コンボ専用システム
- チュートリアル画面
- 常時「今押せ」と教える正解UI

---

## 4. Opportunity Readability

Opportunityの正解をボタン側に表示しない。

代わりにRoom ViewとResidentの生活演出を強化する。

### LIGHT / WATCH_TV

Opportunity:

`WATCH_TV`開始から3.0秒。

v0.3 cue:

- TVへ移動した直後、Residentがリモコンを上げる
- TV画面が起動直後だけ2〜3秒ほど明滅または明るさ変化する
- ResidentがTVへ向き直る動作を明確にする

目的:

「テレビをつけた直後」という出来事を画面だけで認識できること。

`CHANCE`などの文字は出さない。

### SOUND / SLEEP

Opportunity:

`SLEEP`開始から4.0秒。

v0.3 cue:

- ベッドへ入る前後のあくび・横になる動作を明確にする
- 寝入り直後だけ身体または布団に小さな落ち着きアニメーションを入れる
- 定常睡眠との差を見た目で判別できること

目的:

「寝た瞬間 / 寝入りばな」を画面だけで認識できること。

### SHADOW / WALK

Opportunity:

WALK中、Shadow Chance Zone `X=500〜640`。

v0.3 cue:

- 通路 / 出入口 / ドア枠など、Residentが横切る意味のある場所として背景を明確化
- 人影が現れる位置と通路の関係が視覚的に自然であること
- Zoneそのものを色枠やCHANCE表示で可視化しない

目的:

「ここを通った時に何か見せると怖そう」と環境から推測できること。

---

## 5. Outcome Feedback Redesign

結果は、数値だけでなく見た目・動き・文言で区別する。

### GOOD TIMING

最低限:

- Residentの驚きリアクションを最も強くする
- Fear表示を大きくする
- 短い画面Pulseまたは軽いShakeを許可
- Feedback:

```text
大成功！
恐怖 +XX
```

必要ならその下に短い理由を表示する。

例:

```text
テレビをつけた直後だった！
```

### MISTIMED

最低限:

- Residentは反応するがGOODより弱い
- Fear表示をGOODより小さくする
- 画面Pulse / Shakeは原則なし
- Feedback:

```text
効いたが弱い…
恐怖 +XX
```

必要なら短い理由を表示する。

例:

```text
タイミングが遅かった
```

### MISS

最低限:

- Residentは驚きリアクションをしない
- Fear数値は表示しない
- Feedback:

```text
気づかなかった…
```

可能なら文脈理由を1行表示する。

例:

```text
眠っていて人影が見えない
```

### Rule

`GOOD TIMING ×1.75` や `×0.50` の倍率そのものは通常UIで主役にしない。

倍率はDebugでは表示してよい。

通常プレイヤーには「結果」と「理由」を先に伝える。

---

## 6. Learnability Hints

常時チュートリアルや正解ボタン表示は追加しない。

ただし最初の学習を助けるため、怪奇現象ごとに結果理由を短い自然文で表示してよい。

例:

- LIGHT GOOD: `テレビをつけた直後は暗闇に驚きやすい！`
- LIGHT MISTIMED: `テレビに慣れて落ち着いている…`
- SOUND GOOD: `寝入りばなに音が響いた！`
- SOUND MISTIMED: `眠りが安定している…`
- SHADOW GOOD: `通路を横切った瞬間に見えた！`
- SHADOW MISTIMED: `人影を見せる位置が悪かった…`
- SHADOW MISS during sleep: `眠っていて人影が見えない`

Prototypeでは毎回表示してもよい。

Playtest 003で説明過多と感じた場合、初回のみ表示へ変更する。

---

## 7. Resident Anti-Streak Weighting

v0.2の通常行動抽選は完全独立だったため、同じ生活行動が連続することがある。

v0.3では直近の非WALK生活行動を記録し、同じ行動の連続確率を下げる。

Base weights:

- WATCH_TV: 0.40
- DRINK_WATER: 0.30
- SLEEP: 0.30

### Repeat Penalty

次候補が直前の非WALK行動と同じ場合:

```text
weight × 0.35
```

直近2回の非WALK行動が同じで、次候補も同じ場合:

```text
weight × 0.15
```

その後、全候補のweightを再正規化して抽選する。

### Important

- 同じ行動を完全禁止しない
- 生活の偶然性は残す
- 3連続以上をかなり起こりにくくする
- WALKは履歴判定対象外

目的:

Resident AIの偏りによって、プレイヤーが同じ怪奇現象を半ば強制的に使わされる状況を減らす。

---

## 8. Adaptation Recovery

怪奇現象ごとのAdaptationに時間回復を追加する。

### Recovery Start

その怪奇現象がResidentに最後に認識されてから:

```text
20.0秒
```

経過したら回復開始。

### Recovery Rate

```text
1.0 Adaptation / 秒
```

### Range

```text
0〜80
```

0未満にはならない。

### Per Action

LIGHT / SOUND / SHADOWそれぞれ独立して回復タイマーを持つ。

例:

LIGHT Adaptation = 60

LIGHTを20秒間Residentに認識させなかった場合:

```text
60 → 59 → 58 → 57 ...
```

その間にSOUND / SHADOWを使ってもLIGHTの回復待機時間はリセットしない。

### Recognized Action

GOODまたはMISTIMEDとしてResidentに認識された場合:

- 対応Actionの回復待機時間を0へ戻す
- Adaptationを従来どおり増やす

### Miss

Residentが認識していないMissでは:

- Adaptationは増えない
- 回復待機時間もリセットしない
- Cooldownは従来どおり発生

### Pause / Result

Pause中、WIN / LOSE後は回復時間も停止する。

### Design Intent

「何もしないこと」自体を最適解にするためではない。

狙いは、

```text
LIGHTが慣れられた
↓
SOUND / SHADOWへ切り替える
↓
しばらくLIGHTを休ませる
↓
LIGHTが少し戻る
```

という怪奇現象ローテーションを自然に作ること。

---

## 9. Existing Values

以下はv0.2から変更しない。

- Game Time: 180秒
- Fear Goal: 100
- Opportunity Window時間 / Zone
- GOOD TimingMultiplier: 1.75
- MISTIMED TimingMultiplier: 0.50
- BaseFear
- Cooldown
- AdaptationGain
- StateMultiplier
- Resident State Duration
- SURPRISED 1.5秒
- ALERT 3秒

v0.3ではReadability / Flow変更の効果を分離して評価する。

---

## 10. Debug Additions

既存Debugへ追加:

- LastNonWalkActivity
- PreviousNonWalkActivity
- CurrentActivityWeights
- LightRecoveryWait
- SoundRecoveryWait
- ShadowRecoveryWait
- LightRecovering
- SoundRecovering
- ShadowRecovering

通常UIには表示しない。

---

## 11. Logging Additions

既存ログを維持したうえで、可能なら以下を追加する。

- LIGHT_RECOVERED_TOTAL
- SOUND_RECOVERED_TOTAL
- SHADOW_RECOVERED_TOTAL
- MAX_SAME_ACTIVITY_STREAK

Prototypeの分析用であり、通常UIには不要。

---

## 12. Automated Verification

### Anti-Streak

以下を確認する。

- Base weight自体は0.40 / 0.30 / 0.30のまま
- 直前と同じ候補だけ0.35倍される
- 2回連続後は同候補だけ0.15倍される
- 重みが再正規化される
- 同じ生活行動は完全禁止されない
- WALKは履歴に含まれない

長期ランダム試験は補助資料として実施してよいが、特定乱数の勝率だけでAcceptanceを決めない。

### Adaptation Recovery

以下を境界検証する。

- 19.999秒では回復しない
- 20.000秒から回復開始
- 1秒で1.0回復
- 0未満にならない
- 他Action使用では回復待機をリセットしない
- GOOD / MISTIMED認識時だけ対応Actionの回復待機をリセット
- Missではリセットしない
- Pause中は停止

### Feedback

GOOD / MISTIMED / MISSについて:

- 文言が明確に異なる
- Fear数値表示サイズまたは演出強度が異なる
- MISSではFear加算表示をしない
- Debugを見なくても結果カテゴリを区別できる構成である

---

## 13. Human Playtest 003

F1 OFFで開始する。

Playtest 002と同じ9項目を再評価する。

1. 住人を見ていたくなるか
2. 「今だ！」が発生するか
3. ボタンを連打したくなるか
4. 待ち時間が退屈か
5. 怪奇現象が効いた時に気持ちいいか
6. Opportunityを観察だけで理解できたか
7. タイミング外を「もったいない」と感じたか
8. 次のOpportunity待ちが期待になったか
9. GOOD / MISTIMED / MISSをFeedbackから理解できたか

追加確認:

10. 同じ生活行動が不自然に連続する感覚は減ったか
11. Residentの行動が作為的すぎると感じないか
12. Adaptationが回復することで「別の怪奇現象を使って待とう」と思えたか
13. Adaptation回復のためだけに何もしない時間が増えていないか
14. Feedbackが説明過多・うるさすぎないか

---

## 14. Desired Direction

最低限:

- 住人を見ていたくなる: とてもYES維持
- 「今だ！」: Playtest 002より改善
- 連打欲求: あんまりない以下を維持
- 待ち時間の退屈: 減少
- 効いた時の気持ちよさ: YES維持以上
- Opportunity理解: NOから明確に改善
- Feedback理解: 「全然わからない」から大幅改善
- AI偏りによる強制Adaptation感: 減少
- Adaptation Recoveryが新たな待ち最適化を生まない

---

## 15. Checkpoint 1 Rule

v0.3の実装テストがすべてPASSしてもCheckpoint 1は自動通過しない。

必ずPlaytest 003で判断する。

最重要確認:

> 住人を観察すると「何を」「いつ」使えばよいか自然に分かり、その結果も直感的に理解できるか。

加えて:

> Resident AIとAdaptationが、プレイヤーの選択肢を奪うのではなく、次の一手を考える理由になっているか。
