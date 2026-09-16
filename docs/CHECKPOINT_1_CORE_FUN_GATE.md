# Checkpoint 1 — Core Fun Gate

Date: 2026-09-17

Status: **PASS**

Target build: Stage 1 Core Prototype v0.3 / PR #2 / `feature/stage1-core-prototype-v01`

## Decision

Stage 1 Core PrototypeはCheckpoint 1 Core Fun Gateを通過する。

この判定は、実装Acceptanceだけではなく、Project ownerによるHuman Playtest 001〜003の変化を基準に行う。

## Playtest 003 Result

- 住人を見ていたくなるか: **とてもYES**
- 「今だ！」が増えたか: **とてもYES**
- 連打したくなるか: **NO**
- 待ち時間の退屈が減ったか: **YES**
- 怪奇現象が効いた時に気持ちいいか: **YES**
- TV開始・寝入り・ドア通過からOpportunityを理解できたか: **なんとなく**
- タイミング外を「もったいない」と感じるか: **YES**
- 次のOpportunity待ちが期待になるか: **すこしYES**
- GOOD / MISTIMED / MISSが分かるか: **YES**
- 同じ生活行動の不自然な連続感が減ったか: **YES**
- 行動が操作されたランダムに感じるか: **感じない**
- 慣れ回復を見て別の怪奇現象を使おうと思えるか: **YES**
- 回復のためだけに何もしない時間が増えたか: **増えない**
- Feedbackが説明過多・うるさすぎるか: **少し説明過多**

## Why This Passes

Checkpoint 1で確認したい中核は、次のループが人間プレイで成立したかどうか。

`観察 → 待つ → 「今だ」 → 怪奇現象 → 結果を読む → 慣れ/回復を見て次の手を考える`

Playtest 003では以下が同時に成立した。

1. Residentを見ること自体が強く楽しい。
2. 観察から「今だ」というタイミング判断が強く発生した。
3. Cooldown順の連打欲求が消えた。
4. 待ち時間の退屈が改善した。
5. GOOD / MISTIMED / MISSを通常画面から区別できた。
6. タイミング外に損失感があり、次のOpportunityを待つ理由ができた。
7. anti-streakによりAIの偏りによる強制感が改善し、作為的にも感じなかった。
8. Adaptation recoveryにより、別Actionへ切り替えて休ませるローテーション判断が自然に発生した。
9. 回復だけを目的に何もしない待機は増えなかった。

したがって、Stage 1のCore Fun Hypothesisは最低限成立したと判断する。

## Remaining Issues

以下はCheckpoint 1を阻害しないが、次工程で検証・改善する。

### Opportunity Learnability

Opportunityは「なんとなく」理解できる段階であり、初見の外部プレイヤーが説明なしで学べるかは未確認。

これはStage 2 External PlaytestとCheckpoint 2 Player Understanding Gateの主要検証事項とする。

### Feedback Density

GOOD / MISTIMED / MISSの区別は理解できるようになったが、Feedbackは少し説明過多と感じられた。

Stage 2では、意味を失わずに情報量を減らせるか観察する。

### Mechanical Spam Still Can Win

自動Policy ProbeではCooldown順の機械操作も勝利可能。ただし観察方針の方が大幅に効率的で、人間Playtestでは連打欲求はNOになった。

Checkpoint 1では「最適性と人間の自然な行動」を重視し、この点だけを理由にFAILとはしない。

## Next Stage

`Stage 2 External Playtest`

目的:

- 開発経緯を知らない人がゲームを見て理解できるか
- Opportunityを説明なし、または最小説明で学習できるか
- GOOD / MISTIMED / MISSの意味が伝わるか
- Feedback量が適切か
- 住人を見る楽しさと「今だ」が外部プレイヤーでも再現するか

Checkpoint 2では **Player Understanding Gate** を判定する。

## Merge Rule

このPASS判定だけではPR #2を自動でmainへマージしない。

PR #2のレビュー・最終確認後、Project ownerの明示承認でmainへマージし、その後Stage 2へ進む。
