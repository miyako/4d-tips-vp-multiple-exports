property documents : Collection
property target : 4D:C1709.Folder
property area : Text
property statuses : Collection

Class constructor($documents : Collection)
	
	This:C1470.documents:=[]
	
	If ($documents#Null:C1517)
		For each ($document; $documents)
			If (OB Instance of:C1731($document; 4D:C1709.File)) && ($document.exists)
				This:C1470.documents.push($document)
			End if 
		End for each 
	End if 
	
	This:C1470.target:=Folder:C1567(fk desktop folder:K87:19)
	This:C1470.area:="area"
	
	This:C1470.format:=vk pdf format:K89:21
	This:C1470.password:=""
	This:C1470.formula:=Null:C1517
	This:C1470.valuesOnly:=True:C214
	This:C1470.includeFormatInfo:=False:C215
	This:C1470.includeBindingSource:=False:C215
	This:C1470.sheetIndex:=vk workbook:K89:4
	This:C1470.pdfOptions:={}
	This:C1470.csvOptions:={}
	This:C1470.sjsOptions:={}
	This:C1470.autoQuit:=False:C215
	This:C1470.timeout:=20
	
Function get statuses : Collection
	
	return This:C1470._statuses.copy(ck shared:K85:29; This:C1470._signal)
	
Function onExport($area : Text; $path : Text; $this : cs:C1710.VPExporter; $status : Object)
	
	$this._statuses.push({export: $path; status: $status})
	
	If ($status.success)
		ACCEPT:C269
	Else 
		CANCEL:C270
	End if 
	
	If ($this.documents.length#0)
		$this._export()
	Else 
		$this._currentFile:=Null:C1517
		If ($this._signal#Null:C1517) && (OB Instance of:C1731($this._signal; 4D:C1709.Signal))
			Use ($this._signal)
				$this._signal.statuses:=$this.statuses
			End use 
			$this._signal.trigger()
		End if 
		KILL WORKER:C1390
	End if 
	
Function onImport($area : Text; $path : Text; $this : cs:C1710.VPExporter; $status : Object)
	
	$this._statuses.push({import: $path; status: $status})
	
	$this.formula:=$this.onExport
	VP EXPORT DOCUMENT($area; $this.target.file($this._exportName()).platformPath; $this)
	
Function onEvent()
	
	$event:=FORM Event:C1606
	
	Case of 
		: ($event.code=On Load:K2:1)
			
		: ($event.code=On End URL Loading:K2:47)
			
		: ($event.code=On VP Ready:K2:59)
			
			If (This:C1470._currentFile.exists)
				This:C1470.formula:=This:C1470.onImport
				VP IMPORT DOCUMENT(This:C1470.area; This:C1470._currentFile.platformPath; This:C1470)
			End if 
			
		: ($event.code=On VP Range Changed:K2:61)
			
		: ($event.code=On URL Loading Error:K2:48)
			
		: ($event.code=On Unload:K2:2)
			
	End case 
	
Function _exportName() : Text
	
	Case of 
		: (This:C1470._currentFile=Null:C1517)
			return 
		: (This:C1470.format=vk pdf format:K89:21)
			return This:C1470._currentFile.name+".pdf"
		: (This:C1470.format=vk csv format:K89:116)
			return This:C1470._currentFile.name+".csv"
		: (This:C1470.format=vk sjs format:K89:158)
			return This:C1470._currentFile.name+".sjs"
		: (This:C1470.format=vk 4D View Pro format:K89:1)
			return This:C1470._currentFile.name+".4vp"
		Else 
			return This:C1470._currentFile.fullName
	End case 
	
Function _start($this : cs:C1710.VPExporter)
	
	$this._statuses:=[]
	$this._export()
	
Function export() : Collection
	
	This:C1470._signal:=New signal:C1641
	$workerName:=Current method name:C684+"#"+Generate UUID:C1066
	CALL WORKER:C1389($workerName; This:C1470._start; This:C1470)
	This:C1470._signal.wait()
	
	return This:C1470._signal.statuses
	
Function _export() : cs:C1710.VPExporter
	
	This:C1470._currentFile:=This:C1470.documents.shift()
	
	VP Run offscreen area(This:C1470)