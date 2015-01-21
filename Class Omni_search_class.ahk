class omni_search_class{
	static prefix:={"@":"Menu","^":"File",":":"Label","(":"Function","{":"Class","[":"Method","&":"Hotkey","+":"Function","#":"Bookmark",".":"Property","%":"Variable"}
	__New(){
		this.menus()
		return this
	}
	menus(){
		this.menulist:=[]
		list:=menus.sn("//@clean")
		while,mm:=list.item[A_Index-1]{
			clean:=RegExReplace(mm.text,"_"," "),hotkey:=convert_hotkey(menus.ssn("//*[@clean='" mm.text "']/@hotkey").text)
			if IsFunc(mm.text)
				this.menulist.menu[mm.text]:={launch:"func",name:clean,text:mm.text,type:"menu",sort:mm.text,additional1:hotkey,order:"name,additional1"}
			if IsLabel(mm.text)
				this.menulist.menu[mm.text]:={launch:"label",name:clean,text:mm.text,type:"menu",sort:mm.text,additional1:hotkey,order:"name,additional1"}
		}
	}
	search(){
		list:=this.menulist.menu.clone(),fl:=files.sn("//file")
		while,ff:=fl.item[A_Index-1]{
			file:=ssn(ff,"@file").text
			SplitPath,file,fn,dir
			list.Insert({root:ssn(ff.parentnode,"@file").text,filename:file,dir:dir,name:fn,type:"file",order:"name,dir"})
		}
		list.bookmarks:=[],bm:=cexml.sn("//bookmark")
		while,bb:=bm.Item[A_Index-1],ea:=xml.ea(bb)
			list.Insert(ea)
		all:=cexml.sn("//info")
		while,aa:=all.Item[A_Index-1],ea:=xml.ea(aa)
			list.Insert(ea)
		list.fun:=[],fun:=cexml.sn("//info[@type='function']")
		while,ff:=fun.Item[A_Index-1],ea:=xml.ea(ff)
			list.fun[ea.text]:=ea
		return list
	}
}