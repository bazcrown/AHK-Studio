URLDownloadToVar(url){
	http:=ComObjCreate("WinHttp.WinHttpRequest.5.1")
	if proxy:=settings.ssn("//proxy").text
		http.setProxy(2,proxy)
	http.Open("GET",url),http.Send()
	return http.ResponseText
}