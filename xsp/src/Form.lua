Form = {
	nowState=0,
}--初始化
function Form:new (o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

function Form:Exit()
	x,y=Form:findExit()
	if x>-1 then 
		ShowInfo.RunningInfo("退出界面")
		tap(x,y)
		sleepWithCheckLoading(500)
	else
	
	end
end
function Form:findExit()
	return findColor({1764, 0, 1919, 77}, 
"0|0|0x993333,62|-7|0x993333",
95, 0, 0, 0)

end

function Form:CheckLoading(lastX,lastY)
	lastX=lastX or -1
	x, y = findColor({882, 438, 1037, 587}, 
	"0|0|0xfde992,-7|5|0xfae890",
	90, 0, 0, 0)
	if x > -1 then
		if lastX>-1 then
			if x==lastX and y==lastY then
				return  false
			else
				return true
			end
		else
			mSleep(50)--两次判断防误判
			return Form:CheckLoading(x,y)
		end
	else
		return false
	end
end