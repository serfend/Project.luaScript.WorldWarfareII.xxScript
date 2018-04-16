TroopList = {
	nowState=0,
}--初始化
--[[
	未分组	士兵、摩托、空军、运输
	分组1	装甲
	分组2	反装甲
	分组3	攻城
	分组4	远程输出
	分组5	
]]

function TroopList:new (o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end


function TroopList:Enter()
	local x,y= self:Find()
	if x>-1 then
		tap(x,y)
		mSleep(300)
		return true
	else
		ShowInfo.RunningInfo("没有找到部队模块")
		return false
	end
end
function TroopList:Find()
	x, y = findColor({21,599,128,706}, 
	"0|0|0xddddd7,0|15|0xd4d4cd,0|30|0xd4d4cc,0|45|0xf5f5f5",
	95, 0, 0, 0)
	return x,y
end
function TroopList:Sort()
	
end
function TroopList:ExtractTroop(index)
	tap(35,41+92*index)
end
function TroopList:FoldTroop()
	x, y = findColor({18, 16, 63, 67}, 
	"0|0|0xb15d30,9|0|0xbe6a37,18|0|0xd18647,0|9|0xbbb7ab,9|9|0xaf6434",
	95, 0, 0, 0)
	if x>-1 then
		tap(x,y)
		mSleep(300)
		return true
	else
		return false
	end
end

function TroopList:AtTop()

end	