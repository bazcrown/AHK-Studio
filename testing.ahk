testing(){
	search:="T"
	;m(ssn(current(1),"@file").text)
}
/*
	;clean out positions
	file:=positions.sn("//*/@file")
	while,ff:=file.Item[A_Index-1]
		if !FileExist(ff.text)
			ff.ParentNode.RemoveChild(ff)
*/