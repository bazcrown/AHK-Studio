run(){
	if !current(1).xml
		return
	sc:=csc(),save(),main:=files.ssn("//*[@sc='" sc.2357 "'].."),file:=ssn(main,"@file").text
	if (file=A_ScriptFullPath)
		exit(1)
	SplitPath,file,,dir
	run:=FileExist(dir "\AutoHotkey.exe")?Chr(34) dir "\AutoHotkey.exe" Chr(34) " " Chr(34) file Chr(34):Chr(34) file Chr(34)
	Run,%run%,%dir%
	if (file=A_ScriptFullPath)
		ExitApp
}