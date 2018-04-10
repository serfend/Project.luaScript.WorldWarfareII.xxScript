
CityBuilding = {
	nowState=0,
	Name="",
	Level=0,
	Status="无",
	CityProperty="CityOther",
}--初始化

function CityBuilding:new (o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

function CityBuilding:SynInfo()
	
end

function CityBuilding:UpLevel()
		x, y = Form:GetBuildingButton("升级")
	if x > -1 then
		tap(x,y)
		ShowInfo.RunningInfo("升级"..x..","..y)
	else
		x, y = Form:GetBuildingButton("建造")
		if x > -1 then
			tap(x,y)
			ShowInfo.RunningInfo("建造"..x..","..y)
		else
			return false
		end
	end
	
	local tryTime=0
	while not Form:Submit() do
		mSleep(100)
		tryTime=tryTime+1
		if tryTime>10 then
			ShowInfo.RunningInfo("提交建筑失败")
			return false
		end

	end
end
function CityBuilding:Rebuild()
	x, y =Form:GetBuildingButton("重建")
	if x>-1 then
		tap(x,y)
		sleepWithCheckLoading(200)
		tap(1260,680)--确定按钮
		return true
	else
		return false
	end
end
function CityBuilding:GetBuildingStatus(buildingX)
	keepScreen(true)
	for i,statuInfo in ipairs(BuildingStatusList) do
		--sysLog("x"..buildingX)
		x, y = findColor({buildingX-100, 546, buildingX+100, 582}, 
			statuInfo[2],
			95, 0, 0, 0)
		if x>-1 then
			keepScreen(false)
			return statuInfo[1]
		end
	end
	keepScreen(false)
	return "资源不足"
end
function CityBuilding:CheckRepair()
	x, y =Form:GetBuildingButton("修理")
	if x>-1 then
		ShowInfo.RunningInfo("修理建筑")
		tap(x,y)
	end
end
function CityBuilding:CheckIfSupplyIsProducting()
	x, y = findColor({1297, 145, 1397, 236}, 
		"0|0|0x993333,36|-37|0x993333,0|-36|0x993333,41|0|0x993333",
		95, 0, 0, 0)
	if x>-1 then
		return true
	else
		return false
	end
end