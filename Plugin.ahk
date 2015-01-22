Plugin(fn){
	static notify:=[]
	if !IsObject(fn)
		return notify.Insert(clean(fn) "_notify")
	for a,b in notify
		%b%(fn)
}