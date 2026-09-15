# Ghost Home Game

幽霊になって怪奇現象を使い分け、住人を家から追い出す箱庭シミュレーションゲームです。

## Project Status

現在は **Stage 1: Core Prototype** を進行中です。

標準工程:

Stage 0 Project Definition
→ Stage 1 Core Prototype
→ Checkpoint 1 Core Fun Gate
→ Stage 2 External Playtest
→ Checkpoint 2 Player Understanding Gate
→ Stage 3 Vertical Slice
→ Checkpoint 3 Production Feasibility Gate
→ Stage 4 Scope Lock
→ Stage 5 Production
→ Stage 6 Alpha
→ Checkpoint 4 Feature Complete Gate
→ Stage 7 Beta / QA
→ Checkpoint 5 Release Readiness Gate
→ Stage 8 Release
→ Stage 9 Postmortem

## Current Technical Direction

- Engine: Godot 4.7.2 stable
- Language: GDScript
- Target: Windows Desktop
- Rendering: 2D
- Stage 1では仮素材のみを使用

## Core Concept

小さな家で暮らす住人を観察し、性格・生活・場所・時間に合わせて怪奇現象を仕掛け、恐怖と慣れを管理しながら退去させ、最終的に家を伝説の心霊スポットへ育てるゲームを目指します。

Stage 1では、まず以下のCore Funだけを検証します。

> 住人の生活を観察し、「今だ」と思った瞬間に適切な怪奇現象を仕掛けることが面白いか。

## Documents

- `docs/STAGE_0_PROJECT_DEFINITION.md` - ゲーム全体の核
- `docs/STAGE_1_CORE_PROTOTYPE_SPEC.md` - Core Prototype v0.1仕様
- `docs/CODEX_STAGE_1_IMPLEMENTATION.md` - Codex向け実装指示
- `docs/PLAYTEST_LOG.md` - テストプレイ記録

## Development Workflow

1. ChatGPT側でゲーム設計・仕様を整理
2. GitHubの `docs/` を正式仕様として更新
3. Codexがfeature branchで実装
4. Pull Requestを作成
5. 仕様照合・コードレビュー
6. テストプレイ
7. 必要なら修正
8. 合格後に `main` へマージ

`main` は常にレビュー済みの安定版として扱います。

## Important

GitHub Actionsなど、従量課金が発生する可能性のある処理は使用しません。

このプロジェクトでは、コード量や見た目より先に **Core Funが成立しているか** を検証します。
