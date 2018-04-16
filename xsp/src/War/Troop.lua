Troop = {
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
function Troop:SelectMap()
	touchDown(0,200,10)
	mSleep(1000)
	for i=1,10 do
		touchMove(0,5000*i,5000*i)
	end
	touchUp(0,50000,50000)
end

function Troop:new (o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

