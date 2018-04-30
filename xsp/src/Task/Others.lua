Others={}
function Others:new (o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

function Others:AutoExitActivityForm()--自动退出活动页面
	if not Setting.Task.EnableAutoHandleActivity then
		return false
	end
	x, y = findColor({1563, 92, 1645, 168}, 
		"0|0|0x993434,0|20|0xf4fcff,-1|41|0x993333,-20|20|0x993434,21|16|0x993333",
		95, 0, 0, 0)
	if x > -1 then
		tap(x,y)
		sleepWithCheckLoading(500)
	end
end