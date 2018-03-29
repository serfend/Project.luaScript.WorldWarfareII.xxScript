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
	x,y=findExit()
	if x>-1 then 
		ShowInfo.RunningInfo("返回主界面")
		tap(x,y)
		mSleep(200)
	else
	
	end
end
function findExit()
	return findColor({1172, 0, 1279, 67}, 
"0|0|0x8c2f2f,17|9|0x993333,29|20|0x993434,54|23|0x973636,77|31|0x993333,68|5|0x993333,50|16|0x905151,22|28|0x993333,7|28|0x993333,5|19|0x993333,71|16|0x993333",
95, 0, 0, 0)

end