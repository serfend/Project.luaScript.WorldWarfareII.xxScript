Command = {
	nowState=0,
}--初始化

function Command:new (o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

function Command:SelectTroop(index)
	
end
function Command:SortTroops()

end
function Command:ReturnToNormalScale()
	tap(415,277)--按下提示按钮以返回
end
--	if TroopList:Enter() then
--		if TroopList:FoldTroop() then
--			TroopList:ExtractTroop(0)
--			TroopList:Sort()
--		end
--		TroopList:FoldTroop()
--		TroopList:ExtractTroop(2)
--	end