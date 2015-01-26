open(filelist="",show=""){
	static root,top
	if !filelist{
		FileSelectFile,filename,,% ProjectFolder(),,*.ahk
		if ErrorLevel
			return
		if ff:=files.ssn("//main[@file='" filename "']"){
			Gui,1:Default
			tv:=ssn(ff.firstchild,"@tv").text
			TV_Modify(tv,"Select Vis Focus")
			return
		}
		fff:=FileOpen(filename,"RW")
		file1:=file:=fff.read(fff.length)
		gosub,addfile
		Gui,1:TreeView,SysTreeView321
		TV_Modify(root,"Select Vis Focus")
		filelist:=files.sn("//main[@file='" filename "']/*")
		while,filename:=filelist.item[A_Index-1]
			code_explorer.scan(filename)
		code_explorer.Refresh_Code_Explorer()
	}else{
		for a,b in StrSplit(filelist,"`n"){
			if files.ssn("//main[@file='" b "']")
				continue
			fff:=FileOpen(b,"RW")
			file1:=file:=fff.read(fff.length)
			filename:=b
			gosub,addfile
			filelist:=files.sn("//main[@file='" filename "']/*")
			while,fn:=filelist.item[A_Index-1]
				code_explorer.scan(fn)
			if (show=1)
				tv(root)
		}
	}
	return root
	addfile:
	Gui,1:Default
	SplitPath,filename,fn,dir
	top:=files.add({path:"main",att:{file:filename},dup:1})
	v.filelist[filename]:=1
	pos:=1
	Gui,1:TreeView,SysTreeView321
	root:=TV_Add(fn)
	StringReplace,file,file,`r`n,`n,All
	StringReplace,file,file,`r,`n,All
	file1:=file,encoding:=ffff.pos=3?"UTF-8":ffff.pos=2?"UTF-16":"CP0"
	new:=files.under({under:top,node:"file",att:{file:filename,tv:root,filename:fn,encoding:encoding}})
	FileGetTime,time,%filename%
	new.SetAttribute("time",time)
	for a,b in strsplit(file1,"`n"){
		if InStr(b,"#include"){
			skip:=InStr(b,";*")?1:0
			b:=RegExReplace(b,"\/","\")
			while,(d:=substr(b,instr(b," ",0,1,a_index)+1))&&instr(b," ",0,1,a_index){
				if (skip){
					StringReplace,d,d,`;*,,All
					d:=Trim(d)
				}
				if (FileExist(dir "\" d)="D"){
					incdir:=d
					Continue
				}
				iii:=incdir?incdir "\":""
				if !newfn:=FileExist(dir "\" iii d)?dir "\" iii d:""
					newfn:=FileExist(dir "\" d)?dir "\" d:FileExist(d)?d:""
				SplitPath,newfn,ff
				if (ff=".."){
					newfn:=""
					Break
				}
				if (newfn)
					Break
			}
		}
		newfn:=Trim(newfn)
		if (newfn)
			StringReplace,file1,file1,%b%,,All
		if !newfn
			continue
		if ssn(top,"file[@file='" newfn "']")
			continue
		SplitPath,newfn,fn
		child:=TV_Add(fn,root,"Sort")
		top:=files.ssn("//main[@file='" filename "']")
		ffff:=FileOpen(newfn,"RW"),encoding:=ffff.pos=3?"UTF-8":ffff.pos=2?"UTF-16":"CP0"
		new:=files.under({under:top,node:"file",att:{file:newfn,include:b,tv:child,filename:fn,skip:skip,encoding:encoding}})
		FileGetTime,time,%newfn%
		new.SetAttribute("time",time)
		v.filelist[newfn]:=1
		text:=ffff.read(ffff.length)
		StringReplace,text,text,`r`n,`n,All
		update({file:newfn,text:text,load:1})
	}
	update({file:filename,text:Trim(file,"`r`n"),load:1})
	ff:=files.sn("//file")
	if !settings.ssn("//open/file[text()='" filename "']")
		settings.add({path:"open/file",text:filename,dup:1})
	Gui,1:Default
	TV_Modify(TV_GetChild(0),"Select Focus Vis")
	return
}