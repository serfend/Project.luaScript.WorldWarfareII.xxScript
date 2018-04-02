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
	return Form:DoAction(Form.findExit,"退出界面")
end
function Form:Submit()
	return Form:DoAction(Form.findSubmit,"提交")
end
function Form:DoAction(fun,id)
	x,y=fun()
	if x>-1 then
		ShowInfo.RunningInfo(id)
		tap(x,y)
		sleepWithCheckLoading(500)
		return true
	else
		return false
	end
end
function Form:findSubmit()
	return findColor({1553, 978, 1916, 1076}, 
"0|0|0xf9b61c,1|38|0xf6ab15,240|43|0xf9b50f,238|-25|0xfec91d,140|45|0xffd201,129|-24|0xfdc81d",
90, 0, 0, 0)

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