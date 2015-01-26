Jump_To_First_Available(){
	Jump_To_Specific("")	
}
Jump_To_Function(){
	Jump_To_Specific("function")
}
Jump_To_Label(){
	Jump_To_Specific("label")
}
Jump_To_Class(){
	Jump_To_Specific("class")
}
Jump_To_Method(){
	Jump_To_Specific("method")
}
Jump_To_Include(){
	Jump_To_Specific("include")
}
Jump_To_Specific(search:=""){
	sc:=csc(),cpos:=sc.2008,word:=sc.textrange(sc.2266(cpos,1),sc.2267(cpos,1))
	StringUpper,word,word
	search:=search?"[@type='" search "'][@upper='" word "']":"[@upper='" word "']"
	if found:=cexml.ssn("//*" search){
		ea:=xml.ea(found),TV(files.ssn("//main[@file='" ea.root "']/file[@file='" ea.file "']/@tv").text)
		Sleep,200
		csc().2160(ea.pos,ea.pos+StrPut(ea.text,"Utf-8")-1+_:=ea.type="class"?+6:+0),v.sc.2169,v.sc.2400
	}else if(InStr(text:=sc.textrange(sc.2128(line:=sc.2166(sc.2008)),sc.2136(line)),Chr(35) "include"))
		inc:=SubStr(text,InStr(text," ",0,1,1)+1),main:=files.ssn("//main[@file='" ssn(current(1),"@file").text "']"),tv(ssn(main,"file[@file='" inc "']|file[@filename='" inc "']/@tv").text)
}