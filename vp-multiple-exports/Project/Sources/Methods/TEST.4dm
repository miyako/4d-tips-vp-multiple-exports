//%attributes = {}
var $documents : Collection
$documents:=[File:C1566("/RESOURCES/1.4vp"); File:C1566("/RESOURCES/2.4vp"); File:C1566("/RESOURCES/3.4vp")]

var $exporter : cs:C1710.VPExporter
$exporter:=cs:C1710.VPExporter.new($documents)
$statuses:=$exporter.export()

ALERT:C41(JSON Stringify:C1217($statuses; *))