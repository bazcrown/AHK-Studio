Find_Replace(){
	static
	infopos:=positions.ssn("//*[@file='" current(3).file "']"),last:=ssn(infopos,"@findreplace").text,ea:=settings.ea("//findreplace"),newwin:=new windowtracker(30),value:=[]
	for a,b in ea
		value[a]:=b?"Checked":""
	newwin.Add(["Text,,Find","Edit,w200 vfind","Text,,Replace","Edit,w200 vreplace","Checkbox,vregex " value.regex ",Regex","Checkbox,vcs " value.cs ",Case Sensitive","Checkbox,vgreed " value.greed ",Greed","Checkbox,vml " value.ml ",Multi-Line","Button,gfrfind Default,Find","Button,x+5 gfrreplace,Replace","Button,x+5 gfrall,Replace All"]),newwin.Show("Find & Replace")
	ControlSetText,Edit1,%last%,% hwnd([30])
	ControlSend,Edit1,^a,% hwnd([30])
	return
	30GuiClose:
	30GuiEscape:
	info:=newwin[],fr:=settings.Add({path:"findreplace"})
	for a,b in {regex:info.regex,cs:info.cs,greed:info.greed,ml:info.ml}
		fr.SetAttribute(a,b)
	fr:=positions.ssn("//*[@file='" current(3).file "']"),fr.SetAttribute("findreplace",info.find)
	hwnd({rem:30})
	return
	frfind:
	info:=newwin[],sc:=csc(),stop:=current(3).file,looped:=0,current:=current(),pos:=sc.2008,pre:="O",find:="",find:=info.regex?info.find:"\Q" RegExReplace(info.find, "\\E", "\E\\E\Q") "\E",pre.=info.greed?"":"U",pre.=info.cs?"":"i",pre.=info.ml?"":"m`n",find:=pre ")" find ""
	frrestart:
	if !info.find
		return m("Enter search text")
	list:=sn(current,"following-sibling::*|self::*")
	while,current:=list.Item[A_Index-1],ea:=xml.ea(current){
		text:=update({get:ea.file})
		if pos:=RegExMatch(text,find,found,pos){
			tv(files.ssn("//file[@file='" ea.file "']/@tv").text)
			Sleep,200
			np:=StrPut(SubStr(text,1,pos-1),"utf-8")-1,sc.2160(np,np+StrPut(found.0,"utf-8")-1)
			return
		}
		if(ea.file=stop&&(A_Index>1||looped=1))
			return m("No Matches Found")
		pos:=1
	}current:=current(1).firstchild,looped:=1
	goto frrestart
	return
	frreplace:
	info:=newwin[]
	csc().2170(0,[info.replace])
	goto frfind
	return
	frall:
	info:=newwin[],sc:=csc(),stop:=current(3).file,looped:=0,current:=current(),pos:=sc.2008,pre:="O",find:="",find:=info.regex?info.find:"\Q" RegExReplace(info.find, "\\E", "\E\\E\Q") "\E",pre.=info.greed?"":"U",pre.=info.cs?"":"i",pre.=info.ml?"":"m`n",find:=pre ")" find ""
	list:=sn(current(1),"*"),All:=update("get").1,replace:=info.replace
	while,ll:=list.Item[A_Index-1]{
		text:=All[ssn(ll,"@file").text]
		if(RegExMatch(text,find)){
			rep:=RegExReplace(text,find,replace),ea:=xml.ea(ll)
			if(ea.sc){
				tv(ea.tv)
				Sleep,200
				sc.2181(0,[rep])
			}else
				update({file:ea.file,text:rep})
		}
	}
	return
}