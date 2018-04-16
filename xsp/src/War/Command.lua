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

--	if TroopList:Enter() then
--		if TroopList:FoldTroop() then
--			TroopList:ExtractTroop(0)
--			TroopList:Sort()
--		end
--		TroopList:FoldTroop()
--		TroopList:ExtractTroop(2)
--	end