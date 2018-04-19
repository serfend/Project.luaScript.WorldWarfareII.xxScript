Authorization = {
	nowState=0,
}--初始化
function Authorization:new (o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end
function Authorization:Check()
	local bb = require("badboy")
	bb.loadluasocket()
	local http = bb.http
	local response_body = {}
	local post_data = "";  
	local res,code,response_Headers,response_statusText = http.request{  
		url = "http://www.kuaidi100.com/query?type=yuantong&postid=11111111111", 
		method = "GET",  
		headers =   
		{  
			['Content-Type'] = 'application/x-www-form-urlencoded',  
			--['Content-Length'] = #post_data,  
		},  
		--source = ltn12.source.string('data=' .. post_data),  
		sink = ltn12.sink.table(response_body)  
	}  
	sysLog( res..","..code..","..response_statusText)
	printTable(response_Headers)
	printTable(response_body)
	return res
end