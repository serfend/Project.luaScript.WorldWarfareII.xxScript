Building = {
	nowState=0
}--初始化
 
function Building:new (o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end


function Building:find()
	return findColor({18, 323, 77, 374}, 
		"0|0|0x9c7143,22|16|0xddddd7,48|39|0x805d37",
		95, 0, 0, 0)
end
function  Building:Enter()
	x,y=self.find()
	if x>-1 then
		tap(x,y)
		self.nowState=1
		tap(1,1)
		return true
	else
		return false
	end
end
function Building:EnterCityList()

end