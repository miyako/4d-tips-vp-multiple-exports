# 4d-tips-vp-multiple-exports
複数のView Proスプレッドシートをエクスポートするには

## 概要

[`VP IMPORT DOCUMENT`](https://developer.4d.com/docs/ja/ViewPro/commands/vp-import-document/)と[`VP EXPORT DOCUMENT`](https://developer.4d.com/docs/ja/ViewPro/commands/vp-export-document/)は，いずれも**非同期**のコマンドです（CSV, XLSX, PDF形式）。非同期なので，**ワーカーまたはフォームの実行コンテキスト**で呼び出す必要があり，**コールバック関数**で処理を進める必要があります。典型的な4Dコマンドのように逐次処理が完了するわけではないことに留意する必要があります。

たとえばフォームメソッドで下記のようなことはできません。

```4d
var $documents : Collection
$documents:=[File("/RESOURCES/1.4vp"); File("/RESOURCES/2.4vp"); File("/RESOURCES/3.4vp")]
$dst:=Folder(fk desktop folder)

For each ($document; $documents)
  VP IMPORT DOCUMENT("area"; $document.platformPath)
  VP EXPORT DOCUMENT("area"; $dst.file($document.name+".pdf"))
End for each 
```

あるいはループ処理でオフスクリーンエリアを作成し，下記のようなコードを実行してもダメです。

```4d
Case of 
  : (FORM Event.code=On VP Ready)
  VP IMPORT DOCUMENT(This.area; ...)
  VP EXPORT DOCUMENT(This.area; ...)
End case 
```

それぞれのコールバック処理でつぎに実行するべきコマンドを呼び出す必要があります。

1. VP Run offscreen area
2. FORM Event.code=On VP Ready→VP IMPORT DOCUMENT
3. formula→VP EXPORT DOCUMENT
4. formula→ACCEPT→1に戻る
