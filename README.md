# 4d-tips-vp-multiple-exports
複数のView Proスプレッドシートをエクスポートするには

## 概要

[`VP IMPORT DOCUMENT`](https://developer.4d.com/docs/ja/ViewPro/commands/vp-import-document/)と[VP EXPORT DOCUMENT](https://developer.4d.com/docs/ja/ViewPro/commands/vp-export-document/)は，いずれも**非同期**のコマンドです（CSV, XLSX, PDF形式）。非同期なので，**ワーカーまたはフォームの実行コンテキスト**で呼び出す必要があり，コールバック関数で処理を進める必要があります。典型的な4Dコマンドのように逐次処理が完了するわけではないことに留意する必要があります。
