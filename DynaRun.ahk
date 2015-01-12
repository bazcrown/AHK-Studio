DynaRun(Script,debug=0){
	static exec
	exec.terminate()
	if script
		shell:=ComObjCreate("WScript.Shell"),exec:=shell.Exec("AutoHotkey.exe *"),exec.StdIn.Write(script),exec.StdIn.Close()
	return exec.ProcessID
}