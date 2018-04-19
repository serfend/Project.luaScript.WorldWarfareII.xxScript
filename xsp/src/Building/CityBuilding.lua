
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
	local result="资源不足"
	keepScreen(true)
	for i,statuInfo in ipairs(BuildingStatusList) do
		x, y = findColor({buildingX-100, 546, buildingX+100, 582}, 
			statuInfo[2],
			95, 0, 0, 0)
		if x>-1 then
			keepScreen(false)
			result= statuInfo[1]
			break
		end
	end
	keepScreen(false)
	if result=="可升级" then--判断是否是待重建
			x, y = findColor({buildingX-100, 777, buildingX, 783}, 
		"0|0|0x584837,3|0|0x060f15",
		90, 0, 0, 0)
		if x>-1 then
			result="重建"
		end
	end
	return result
end
function CityBuilding:GetBuildingLevelBeginPos(posx)
	local findTime=0
	local posX=posx+80
	while posX<posx+150 do
		posX=posX+1
		r,g,b=getColorRGB(posX,765)
		if r+g+b>=220*3 then--发现白色区域
			findTime=findTime+1
			posX=posX+5
			if findTime==4 then
				break
			end
		end
	end
	if posX>=posx+150 then
		ShowInfo.RunningInfo("获取建筑等级失败")
	end
	return posX+1
end
function CityBuilding:GetBuildingLevel(buildingX)
	keepScreen(true)
	local result=0
	local x=self:GetBuildingLevelBeginPos(buildingX)
	if x>0 then
		local x1,y1,x2,y2=x,738,x+30,770
		showRect(x1,y1,x2,y2,2000)
		local code,cityLevelRaw=ocr:GetNumBold(x1,y1,x2,y2)
		if code~=0 then
			sysLog("等级识别失败"..code)
			result=-1
		else
			result=tonumber(cityLevelRaw)
			if result==nil then
				sysLog("等级识别错误"..code)
				result=0
			end
			if result>40 then
				result=0
			end
			sysLog("x:"..x..",level:"..result..",raw:"..cityLevelRaw)
		end
	else
		sysLog("no Level Found")
		result= 0
	end
	keepScreen(false)
	return result
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