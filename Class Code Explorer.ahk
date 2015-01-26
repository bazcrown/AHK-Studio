class code_explorer{
	static explore:=[],TreeView:=[],sort:=[],function:="Om`n)^\s*((\w|[^\x00-\x7F])+)\((.*)?\)[\s+;.*\s+]?[\s*]?{",label:="Om`n)^\s*((\w|[^\x00-\x7F])+):[\s+;]",functions:=[],bookmarks:=[],variables:=[],varlist:=[]
	scan(node){
		explore:=[],bits:=[],method:=[]
		filename:=ssn(node,"@file").text,parentfile:=ssn(node.ParentNode,"@file").text
		if !main:=cexml.ssn("//main[@file='" parentfile "']")
			main:=cexml.Add({path:"main",att:{file:parentfile},dup:1})
		if !cce:=ssn(main,"file[@file='" filename "']")
			cce:=cexml.under({under:main,node:"file",att:{file:filename}})
		else
			cce.ParentNode.RemoveChild(cce),cce:=cexml.under({under:main,node:"file",att:{file:filename}})
		for a,b in ["class","file","function","hotkey","label","menu","method","property","variable"]
			explore[b]:=[]
		skip:=ssn(node,"@skip").text?1:0,code:=update({get:filename}),pos:=1
		if pos:=InStr(code,"/*"){
			while,pos:=RegExMatch(code,"UOms`n)^(\/\*.*\*\/)",found,pos){
				rep:=RegExReplace(found.1,"(:|\(|\))","_"),pos:=found.Pos(1)+1,rp:=found.1
				StringReplace,code,code,%rp%,%rep%,All
			}
		}
		if !v.options.Disable_Variable_List{
			pos:=1,this.variables[parentfile,filename]:=[]
			while,pos:=RegExMatch(code,"Osm`n)(\w*)(\s*)?:=",var,pos){
				if var.len(1)
					this.variables[parentfile,filename,var.1]:=1,pos:=var.Pos(1)+var.len(1)
				else
					pos+=1
			}
		}
		for type,find in {hotkey:"Om`n)^\s*([#|!|^|\+|~|\$|&|<|>|*]*?\w+)::",label:this.label}{
			pos:=1
			while,pos:=RegExMatch(code,find,fun,pos){
				np:=StrPut(SubStr(code,1,fun.Pos(1)),"utf-8")-1-(StrPut(SubStr(fun.1,1,1),"utf-8")-1)
				cexml.under({under:cce,node:"info",att:{type:type,file:filename,pos:np,text:fun.1,root:parentfile,upper:upper(fun.1),order:"text,type,file"}})
				pos:=fun.pos(1)+1
			}
		}
		lastpos:=pos:=1
		Loop
		{
			test:=[]
			for type,find in {class:"Om`ni)^[\s*]?(class[\s*](\w|[^\x00-\x7F])+)",function:this.function}{
				if pos:=RegExMatch(code,find,fun,pos){
					if (type="function"&&fun.1="if")
						Continue
					np:=StrPut(SubStr(code,1,fun.Pos(1)),"utf-8")-1-(StrPut(SubStr(fun.1,1,1),"utf-8")-1)
					if pos
						test[pos]:={type:type,file:filename,pos:np,text:fun.1,root:parentfile,cpos:pos,args:fun.3}
					pos:=fun.pos(1)+1
				}
				pos:=lastpos
			}
			min:=test[test.MinIndex()]
			if (min.type="class"){
				cl:=SubStr(code,min.cpos),left:="",foundone:="",count:=0
				for a,b in StrSplit(cl,"`n"){
					line:=RegExReplace(RegExReplace(b,"(\s+" Chr(59) ".*)\n"),"U)(" Chr(34) ".*" Chr(34) ")")
					RegExReplace(line,"{","",open),count+=open
					if (open&&foundone="")
						foundone:=1
					RegExReplace(line,"}","",close),count-=close
					if (count=0&&foundone)
						break
					left.=b "`n"
				}
				pos:=lastpos:=min.cpos+StrLen(left),parent:=cexml.under({under:cce,node:"info",att:{type:"class",file:filename,pos:min.pos,text:SubStr(min.text,7),upper:upper(SubStr(min.text,7)),root:min.root,order:"text,type,root"}})
				npos:=1
				while,npos:=RegExMatch(left,this.function,method,npos){
					np:=StrPut(SubStr(left,1,method.Pos(1)),"utf-8")-1-(StrPut(SubStr(method.1,1,1),"utf-8")-1)
					cexml.under({under:parent,node:"info",att:{file:filename,pos:np+min.pos,text:method.1,upper:upper(method.1),args:method.value(3),class:min.text,root:min.root,type:"method",order:"text,type,file,args"}})
					npos:=method.Pos(1)+1
				}
				npos:=1
				while,npos:=RegExMatch(left,"Om`n)^\s*((\w|[^\x00-\x7F])+)\[(.*)?\][\s+;.*\s+]?[\s*]?{",Property,npos){
					np:=StrPut(SubStr(left,1,Property.Pos(1)),"utf-8")-1-(StrPut(SubStr(Property.1,1,1),"utf-8")-1)
					cexml.under({under:parent,node:"info",att:{file:filename,pos:np+min.pos,text:Property.1,upper:upper(property.1),args:Property.value(3),class:min.text,root:min.root,type:"Property",order:"text,type,file,args"}})
					npos:=Property.Pos(1)+1
				}
				continue
			}else if(min.type="function"&&min.text!="if")
				min.order:="text,type,file,args",explore.function.Insert(min),min.upper:=upper(min.text),cexml.under({under:cce,node:"info",att:min})
			if !(test.MinIndex())
				break
			lastpos:=pos:=test.MinIndex()+StrLen(min.text)
		}
		ubp(csc(),filename)
		pos:=fun.Pos(1)+len,this.explore[parentfile,filename]:=explore,this.skip[filename]:=skip
		bm:=bookmarks.sn("//file[@file='" filename "']/mark")
		code_explorer.bookmarks.Remove(filename)
		code_explorer.bookmarks[filename]:=[]
		while,bb:=bm.item[A_Index-1]
			ea:=bookmarks.ea(bb),cexml.under({under:main,node:"bookmark",att:{type:"bookmark",text:ea.name,line:ea.line,file:filename,order:"text,type,file",root:parentfile}})
	}
	remove(filename){
		this.explore.remove(ssn(filename,"@file").text)
		list:=sn(filename,"@file")
		while,ll:=list.item[A_Index-1]
			this.explore.Remove(ll.text)
	}
	populate(){
		code_explorer.Refresh_Code_Explorer()
		Gui,1:TreeView,SysTreeView321
	}
	Refresh_Code_Explorer(){
		if v.options.Hide_Code_Explorer
			return
		Gui,1:TreeView,SysTreeView322
		GuiControl,1:-Redraw,SysTreeView322
		code_explorer.scan(current()),TV_Delete(),code_explorer.treeview:=new xml("TreeView"),bookmark:=[]
		;this.TreeView.filename:=[],this.TreeView.type:=[],this.TreeView.class:=[],this.TreeView.obj:=[]
		SplashTextOff
		Gui,1:TreeView,SysTreeView322
		fz:=cexml.sn("//main")
		while,fn:=fz.Item[A_Index-1]{
			;redo this
			file:=ssn(fn,"@file").text
			SplitPath,file,name
			top:=TV_Add(name)
			if(Label:=sn(fn,"//*[@type='label']")).length{
				ltv:=TV_Add("Labels",top,"Vis")
				while,ll:=Label.Item[A_Index-1]{
					ea:=xml.ea(ll),ea.tv:=TV_Add(ssn(ll,"@text").text,ltv,"Sort")
					code_explorer.treeview.Add({path:"tv",att:ea,dup:1})
				}
			}if(hotkey:=sn(fn,"//*[@type='hotkey']")).length{
				ltv:=TV_Add("Hotkeys",top,"Vis")
				while,ll:=hotkey.Item[A_Index-1]{
					ea:=xml.ea(ll),ea.tv:=TV_Add(ssn(ll,"@text").text,ltv,"Sort")
					code_explorer.treeview.Add({path:"tv",att:ea,dup:1})
				}
			}if(Function:=sn(fn,"//*[@type='function']")).length{
				ltv:=TV_Add("Functions",top,"Vis")
				while,ll:=Function.Item[A_Index-1]{
					ea:=xml.ea(ll),ea.tv:=TV_Add(ssn(ll,"@text").text,ltv,"Sort")
					code_explorer.treeview.Add({path:"tv",att:ea,dup:1})
				}
			}if(class:=sn(fn,"//*[@type='class']")).length{
				ltv:=TV_Add("Class",top,"Vis")
				while,ll:=class.Item[A_Index-1]{
					ea:=xml.ea(ll),ea.tv:=TV_Add(ssn(ll,"@text").text,ltv,"Sort")
					code_explorer.treeview.Add({path:"tv",att:ea,dup:1})
					under:=sn(ll,"*")
					while,uu:=under.Item[A_Index-1]{
						uea:=xml.ea(uu),uea.tv:=TV_Add(ssn(uu,"@text").text,ea.tv,"Sort")
						code_explorer.treeview.Add({path:"tv",att:uea,dup:1})
					}
				}
			}
			if(bookmark:=cexml.sn("//bookmark")).length{
				ltv:=TV_Add("Bookmarks",0,"Vis")
				while,ll:=bookmark.Item[A_Index-1]{
					ea:=xml.ea(ll),ea.tv:=TV_Add(ea.text,ltv,"Sort")
					code_explorer.treeview.Add({path:"tv",att:ea,dup:1})
				}
			}
		}
		GuiControl,1:+Redraw,SysTreeView322
		return
		GuiContextMenu:
		ControlGetFocus,Focus,% hwnd([1])
		if (Focus="SysTreeView322"){
			GuiControl,+g,SysTreeView322
			code_explorer.Refresh_Code_Explorer()
			GuiControl,+gcej,SysTreeView322
		}
		if (Focus="SysTreeView321")
			new()
		return
	}
	cej(){
		cej:
		if (A_GuiEvent="S"&&A_GuiEvent!="RightClick"){
			list:=""
			if found:=code_explorer.TreeView.ssn("//*[@tv='" A_EventInfo "']"){
				ea:=xml.ea(found),TV(files.ssn("//main[@file='" ea.root "']/file[@file='" ea.file "']/@tv").text)
				Sleep,200
				if (ea.type="bookmark"){
					csc().2024(ea.line)
					ControlFocus,,% "ahk_id" csc().sc
				}
				else
					csc().2160(ea.pos,ea.pos+StrPut(ea.text,"Utf-8")-1+_:=ea.type="class"?+6:+0),v.sc.2169,v.sc.2400
			}
			return
		}
		return
	}
}