# Rhythm Mile (リズムマイル)

## プロジェクト概要

リズムマイルは、ランニングと BPM に基づいた音楽プレイリストを組み合わせた革新的なモバイルアプリケーションです。ランナーのペースに合わせて最適な音楽を提供することで、より楽しく効果的な運動体験を実現します。

## 対応プラットフォーム

### フェーズ 1（優先実装）

- Android
  - minSdkVersion: 24 (Android 7.0)
  - targetSdkVersion: 最新
  - Material Design 3 対応
  - Android 特有の最適化（バッテリー消費、バックグラウンド処理）

### フェーズ 2（将来対応）

- iOS
  - iOS 14 以降
  - Human Interface Guidelines 準拠
- Web（PWA）
  - モバイルブラウザ最適化
  - オフライン機能制限あり

## 主な機能要件

### 1. ランニング機能

- GPS によるランニング距離、ペース、ルートの記録
- リアルタイムの運動データ表示（距離、時間、ペース、消費カロリー）
- ランニング履歴の保存と確認
- カスタマイズ可能なランニング目標設定

### 2. ルート作成・ナビゲーション機能

- 現在地からの最適ルート作成
  - 目標距離に応じたルート提案
  - 勾配を考慮したルート生成
  - 難易度別ルートオプション（初心者、中級者、上級者向け）
- カスタムルート作成
  - 経由地点の指定
  - 希望する勾配レベルの設定
  - 往復/周回コースの選択
- リアルタイムナビゲーション
  - ターンバイターン案内
  - 進捗状況の表示
  - 予想到着時間の計算

### 3. ランニングプレイリスト機能

- Spotify API との連携
  - ユーザーの Spotify アカウント連携
  - プレイリストの自動生成と保存
- BPM ベースの楽曲選択
  - 目標ペースに合わせた BPM 設定
  - ウォームアップ/クールダウン用の可変 BPM
  - インターバルトレーニング向け BPM パターン作成
- カスタマイズオプション
  - 好みのジャンル選択
  - お気に入りアーティスト優先
  - 再生時間のカスタマイズ
- スマートプレイリスト機能
  - ランニング中のペース変化に応じた楽曲切り替え
  - 勾配に応じた BPM 調整
  - モチベーション維持のための盛り上がり曲の配置

### 4. ゲーミフィケーション要素

- レベルアップシステム
- 実績解除機能
- ランキングシステム
- カスタマイズ可能なアバター

### 5. 健康管理機能

- 運動記録の統計と分析
- 目標達成の進捗管理
- 健康アドバイスの提供
- 他の健康アプリとの連携

## 技術要件

### フロントエンド

- Flutter/Dart
- アニメーションと UI/UX の最適化
- オフライン対応
- プラットフォーム固有の実装
  - Android 優先実装
    - Android Activity Lifecycle 対応
    - Android 位置情報サービス最適化
    - Android 通知システム
    - Android Wear OS 連携（オプション）
  - プラットフォーム間のコード共有率 80%以上

### バックエンド

- Firebase
  - Authentication
  - Cloud Firestore
  - Cloud Storage
  - Cloud Functions
- Google Maps Platform
  - Directions API
  - Elevation API
  - Maps SDK for Flutter
- Spotify Web API
  - 楽曲メタデータ取得
  - プレイリスト操作
  - 再生制御
- RESTful API

### デバイス連携

- GPS
- 加速度センサー
- Spotify SDK
- ヘルスケア API

## セキュリティ要件

- ユーザー認証
- データ暗号化
- プライバシー保護
- GDPR 対応

## 品質要件

- ユニットテスト
- UI テスト
- パフォーマンステスト
- セキュリティテスト

## 開発フェーズ

### フェーズ 1: 基本機能実装（Android 優先）

- [ ] プロジェクトセットアップ
  - [ ] Android 開発環境構築
  - [ ] CI/CD 環境構築（GitHub Actions）
  - [ ] Firebase 設定
- [ ] 基本的な UI/UX デザイン
  - [ ] Material Design 3 ガイドライン適用
  - [ ] Android ネイティブコンポーネント最適化
- [ ] ランニング機能の実装
  - [ ] Android 位置情報サービス実装
  - [ ] バックグラウンド処理最適化
- [ ] ルート作成機能の基本実装

### フェーズ 2: 拡張機能実装

- [ ] Spotify 連携機能の実装
  - [ ] Android Spotify SDK 統合
  - [ ] バックグラウンド再生最適化
- [ ] BPM ベースのプレイリスト生成機能の実装
- [ ] 詳細なルートナビゲーション機能の実装
- [ ] 健康管理機能の実装
  - [ ] Google Fit 連携

### フェーズ 3: 最適化とテスト

- [ ] パフォーマンス最適化
  - [ ] Android デバイス別最適化
  - [ ] バッテリー消費最適化
- [ ] セキュリティ強化
- [ ] テスト実施
  - [ ] Android 固有の単体テスト
  - [ ] UI/UX テスト（Android 優先）
- [ ] バグ修正

## 環境構築

```bash
# 必要な環境
- Flutter 3.x
- Dart 3.x
- Firebase CLI
- Android Studio
  - Android SDK
  - Android Emulator
  - Flutter/Dart プラグイン
- Google Maps API Key
- Spotify Developer Account

# 推奨開発環境
- CPU: 最新のIntel Core i5/i7またはAMD Ryzen 5/7以上
- RAM: 16GB以上
- ストレージ: SSD 256GB以上
- OS: macOS Ventura以上 または Windows 11
```

## ライセンス

MIT License
