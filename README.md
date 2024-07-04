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

ALERT(JSON Stringify($statuses; *))
```

あるいはループ処理でオフスクリーンエリアを作成し，下記のようなコードを実行してもダメです。

```4d
Case of 
  : (FORM Event.code=On VP Ready)
  VP IMPORT DOCUMENT(This.area; ...)
  VP EXPORT DOCUMENT(This.area; ...)
End case 
```

それぞれのコールバック処理でつぎに実行するべきコマンドを順番に呼び出す必要があります。

1. VP Run offscreen area
2. FORM Event.code=On VP Ready→VP IMPORT DOCUMENT
3. formula→VP EXPORT DOCUMENT
4. formula→ACCEPT→1に戻る

これを典型的な4Dコマンドのような同期処理で実行するためには，`4D.Signal`でワーカーの処理を待つ必要があります。

## 例題

```4d
var $documents : Collection
$documents:=[File("/RESOURCES/1.4vp"); File("/RESOURCES/2.4vp"); File("/RESOURCES/3.4vp")]

var $exporter : cs.VPExporter
$exporter:=cs.VPExporter.new($documents)
$status:=$exporter.export()
```

## ポイント

内部的にワーカーを起動し，`4D.Signal`で待ち合わせをしています。

```4d
Function export() : Collection
	
	This._signal:=New signal
	$workerName:=Current method name+"#"+Generate UUID
	CALL WORKER($workerName; This._start; This)
	This._signal.wait()
	
	return This._signal.statuses
```

処理するべき`4D.File`をコレクションに収納しておき，`1`個ずつ`.shift()`で取り出して処理しています。

```4d
Function _export() : cs.VPExporter
	
	This._currentFile:=This.documents.shift()
	
	VP Run offscreen area(This)
```

`VP IMPORT DOCUMENT`と`VP EXPORT DOCUMENT`はいずれも`.formula`でコールバック関数を指定するので，直前にメンバー関数を切り替えてからコマンドを実行しています。

```4d
This.formula:=This.onImport
VP IMPORT DOCUMENT(This.area; This._currentFile.platformPath; This)
```

```4d
$this.formula:=$this.onExport
VP EXPORT DOCUMENT($area; $this.target.file($this._exportName()).platformPath; $this)
```
