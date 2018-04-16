Conscript = {
	nowState=0,
}--初始化

function Conscript:new (o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end
function Conscript:Run()
	Conscript:Enter("军备")
	
	--Form:Exit()
	--Conscript:Enter("军队")
	mSleep(5000)
end


function Conscript:Enter(target)
	local targetBuilding=(target=="军备" and "兵工厂" or "陆军基地")
	local targetButton=(target=="军备" and "生产军备" or "部队列表")
	Building:SelectMainCityBuilding()
	local targrtPoint=City:FindBuilding(targetBuilding)
	if #targrtPoint>0 then
		tap(targrtPoint[1].x,targrtPoint[1].y)
		mSleep(200)
		local buildNewButtonPosX,buildNewButtonPosY=Form:GetBuildingButton(targetButton)
		tap(buildNewButtonPosX,buildNewButtonPosY)
	end
end