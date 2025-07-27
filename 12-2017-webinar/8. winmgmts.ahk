#Include <default_Settings> ;NoIndex ;RAlt::
global vObj:=[] ;Creates obj holder for variables
Browser_Forward::Reload ;RControl::
Browser_Back::
;**************************************
filepath := "C:\Windows\System32\notepad.exe"	;set the target full file path
StringReplace, filepath, filepath, \, \\, All	;double backslashes

objWMIService := ComObjGet("winmgmts:{impersonationLevel=impersonate}!\\" . A_ComputerName . "\root\cimv2") 
WQLQuery = SELECT * FROM CIM_Datafile WHERE Name = '%filepath%'		;CIM_Datafile
colFiles := objWMIService.ExecQuery(WQLQuery)._NewEnum 

While colFiles[objFile] {
	FileProperties := "Access mask:`t`t" . objFile.AccessMask . "`n"
	. "Archive:`t`t`t" . objFile.Archive . "`n"
	. "Compressed:`t`t" . objFile.Compressed . "`n"
	. "Compression method:`t`t" . objFile.CompressionMethod . "`n"
	. "Creation date:`t`t" . objFile.CreationDate . "`n"
	. "Computer system name:`t" . objFile.CSName . "`n"
	. "Drive:`t`t`t" . objFile.Drive . "`n"
	. "8.3 file name:`t`t" . objFile.EightDotThreeFileName . "`n"
	. "Encrypted:`t`t" . objFile.Encrypted . "`n"
	. "Encryption method:`t" . objFile.EncryptionMethod . "`n"
	. "Extension:`t`t`t" . objFile.Extension . "`n"
	. "File Name:`t`t" . objFile.FileName . "`n"
	. "File Size:`t`t`t" . objFile.FileSize . "`n"
	. "File Type:`t`t`t" . objFile.FileType . "`n"
	. "File system name:`t`t" . objFile.FSName . "`n"
	. "Hidden:`t`t`t" . objFile.Hidden . "`n"
	. "Last accessed:`t`t" . objFile.LastAccessed . "`n"
	. "Last modified:`t`t" . objFile.LastModified . "`n"
	. "Manufacturer:`t`t" . objFile.Manufacturer . "`n"
	. "Name:`t`t`t" . objFile.Name . "`n"
	. "Path:`t`t`t" . objFile.Path . "`n"
	. "Readable:`t`t`t" . objFile.Readable . "`n"	
	. "System:`t`t`t" . objFile.System . "`n"
	. "Version:`t`t`t" . objFile.Version . "`n"
	. "Writeable:`t`t`t" . objFile.Writeable 
}
msgbox % FileProperties

folderpath := "C:\Windows\System32"	;set the target full foler path
folderpath := RTrim(folderpath,"\") ;remove a trailing backslash, if present 
StringReplace, folderpath, folderpath, \, \\, All	;double backslashes
objWMIService := ComObjGet("winmgmts:{impersonationLevel=impersonate}!\\" . [color=brown]A_ComputerName . "\root\cimv2") 
WQLQuery = SELECT * FROM Win32_Directory WHERE Name = '%folderpath%'	;Win32_Directory
colFolder := objWMIService.ExecQuery(WQLQuery)._NewEnum 	
While colFolder[objFolder] {
	FolderProperties := "Archive:`t`t`t" . objFolder.Archive . "`n"
	. "Caption:`t`t`t" . objFolder.Caption . "`n"
	. "Compressed:`t`t" . objFolder.Compressed . "`n"
	. "Compression method:`t" . objFolder.CompressionMethod . "`n"
	. "Creation date:`t`t" . objFolder.CreationDate . "`n"
	. "Encrypted:`t`t" . objFolder.Encrypted . "`n"
	. "Encryption method:`t`t" . objFolder.EncryptionMethod . "`n"
	. "Hidden:`t`t`t" . objFolder.Hidden . "`n"
	. "In use count:`t`t" . objFolder.InUseCount . "`n"
	. "Last accessed:`t`t" . objFolder.LastAccessed . "`n"
	. "Last modified:`t`t" . objFolder.LastModified . "`n"
	. "Name:`t`t`t" . objFolder.Name . "`n"
	. "Path:`t`t`t" . objFolder.Path . "`n"
	. "Readable:`t`t`t" . objFolder.Readable . "`n"
	. "System:`t`t`t" . objFolder.System . "`n"
	. "Writeable:`t`t`t" . objFolder.Writeable
}
msgbox % FolderProperties