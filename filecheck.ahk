filecheck(){
	commandsdate:=20150103,menusdate:=20150126,scilexerdate:=20150126161703
	RegRead,proxy,HKEY_CURRENT_USER,Software\Microsoft\Windows\CurrentVersion\Internet Settings,ProxyServer
	if proxy
		settings.Add({path:"proxy",text:proxy})
	if !settings.ssn("//autoadd")
		for a,b in {60:62,123:125,34:34,39:39,91:93,40:41}
			settings.add({path:"autoadd/key",att:{trigger:a,add:b},dup:1})
	if !settings.ssn("//fonts").xml
		defaultfont()
	if (menus.ssn("//date").text!=menusdate){
		SplashTextOn,300,100,Downloading Menus XML,Please Wait...
		temp:=new xml("temp"),temp.xml.loadxml(URLDownloadToVar("http://files.maestrith.com/AHK-Studio/menus.xml"))
		if menus.sn("//*").length=1
			menus.xml.loadxml(temp[])
		else{
			menu:=temp.sn("//*")
			while,mm:=menu.item[A_Index-1]{
				ea:=xml.ea(mm)
				if !ea.clean
					Continue
				if !menus.ssn("//*[@clean='" ea.clean "']"){
					parent:=menus.ssn("//*[@clean='" ssn(mm.ParentNode,"@clean").text "']")
					menus.under({under:parent,node:"menu",att:ea})
				}
			}
		}
		SplashTextOff
		menus.add({path:"date",text:menusdate})
		menus.save(1)
	}
	if !FileExist(A_ScriptDir "\lib")
		FileCreateDir,%A_ScriptDir%\lib
	FileGetTime,time,scilexer.dll,M
	if (scilexerdate>time)
		FileDelete,scilexer.dll
	FileInstall,scilexer.dll,scilexer.dll
	FileInstall,lib\commands.xml,lib\commands.xml
	if !(FileExist("lib\commands.xml")&&FileExist("scilexer.dll"))
		SplashTextOn,,40,Downloading Required Files,Please Wait...
	if (commands.ssn("//Date").text!=commandsdate){
		FileDelete,lib\commands.xml
		updatedate:=1
	}
	if !FileExist("lib\commands.xml")
		FileAppend,% URLDownloadToVar("http://files.maestrith.com/AHK-Studio/commands.xml"),lib\commands.xml
	if !FileExist("scilexer.dll")
		URLDownloadToFile,http://files.maestrith.com/AHK-Studio/SciLexer.dll,SciLexer.dll
	if !FileExist("AHKStudio.ico")
		urldownloadtofile,http://files.maestrith.com/AHK-Studio/AHKStudio.ico,AHKStudio.ico
	SplashTextOff
	if !settings.ssn("//options")
		settings.Add({path:"options",att:{}})
	commands:=new xml("commands","lib\commands.xml")
	if updatedate
		commands.Add({path:"Version/Date",text:commandsdate}),commands.save(1)
	SysGet,Border,33
	SysGet,Caption,4
	v.Border:=Border,v.Caption:=Caption
}