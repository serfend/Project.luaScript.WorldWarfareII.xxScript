require "Building.Building"
require "Building.CityBuilding"
City = {
	nowState=0,
	ID="",
	res={
		iron=resInfo,
		rubbert=resInfo,
		petroleum=resInfo,
		people=resInfo
	},
	pos={
		x=0,y=0
	},
	IsMainCity=0,--是否是主城
	CityProperty="CityOther"
}--初始化

function City:new (o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

function City:Init()
	
end

function City:Run()
	sysLog(self.CityProperty.."Run()")
	self:ShowAllBuildingQueue()
	if Setting.Building[self.CityProperty.."Setting"].EnableAutoDevelop==false then
		ShowInfo.RunningInfo("城市建设被禁用")
		return false
	end
	self:RunBuilding("City")--城市
	while true do
		local nextX,nextY=City:FindNextAero()
		ShowInfo.RunningInfo("寻找下个区域")
		if nextX>0 then
			tap(nextX,nextY)
			if nextY>800 then
				swip(20,800,20,600)
				mSleep(200)
			end
			self:RunBuilding("Field")--野地
		else
			break
		end
	end
	ShowInfo.RunningInfo("城市处理完成")
end

function City:FindNextAero()
	x, y = findColor({442, 77, 531, 1074}, 
	"0|0|0xa39380,-476|4|0x42332a,0|-71|0x8d6828,-479|-60|0x3e332a,-13|-45|0x8a6223,14|-7|0xa39380",
	90, 0, 0, 0)
		return x,y
end
function City:RunBuilding(id)
	sleepWithCheckLoading(200)
	if not City:CheckBuildingQueue(id) then return true end
	ShowInfo.RunningInfo(id.."开始建筑")
	for i=1,7 do
		self:BuildBuildingInRank(i,id)
	end
end

function City:CheckBuildingQueue(id)
	City:CheckImmediateBuilding()
	if self:GetBuildingQueueFreeNum()<1 then
		ShowInfo.RunningInfo(id.."无空闲队列")
		sleepWithCheckLoading(800)
		return false
	end
	return true
end

function City:ShowAllBuildingQueue()
	for index=4,5 do
		for i,building in ipairs(Setting.Building.City) do
			if building[index]==true then
				sysLog(building[1].."可建筑"..building[2])
			else
				sysLog(building[1].."禁止"..building[2])
			end
		end
		for i,building in ipairs(Setting.Building.Field) do
			if building[index]==true then
				sysLog(building[1].."可建筑"..building[2])
			else
				sysLog(building[1].."禁止"..building[2])
			end	
		end
		sysLog("------------")
	end
end
function City:BuildBuildingInRank(rank,CityOrField)
	sysLog("优先级建筑:"..rank.."状态"..self.IsMainCity)
	for i,building in ipairs(Setting.Building[CityOrField]) do 
		if math.abs(building[3-self.IsMainCity])==rank and building[5-self.IsMainCity]==true then
			if building[1]~="none" then
				local points=City:FindBuilding(building[1])
				if #points>0 then
					for i,buildingPos in ipairs(points) do
						local buildingX=buildingPos.x
						sysLog("x"..buildingX)
						if buildingX>1650 then
							swip(1650,647,1850,647)
							mSleep(500)
							buildingX=buildingX-200
						end
						tap(buildingX,650)
						local tmpBuilding=CityBuilding:new()

						tmpBuilding.Status=City:GetBuildingStatus(buildingX)
						sysLog(tmpBuilding.Status)
						if tmpBuilding.Status=="可升级" then
							ShowInfo.RunningInfo("处理建筑"..rank..building[1])
							if not City:UpLevel() then
								City:Rebuild()
							end
						end
					end
				else
					ShowInfo.RunningInfo("建筑"..building[1].."获取坐标失败")
				end															
			end

		else
			ShowInfo.RunningInfo("建筑"..building[1].."被禁用"..building[3-self.IsMainCity])
		end
	end
end
function City:UpLevel()
		x, y = findColor({925, 848, 1839, 1009}, 
	"0|0|0x35442c,55|-26|0x658953,82|14|0x5c764d,58|-1|0x85867d,-11|54|0x2e4423,0|38|0x757f68,32|-8|0xd1cfc8",
	90, 0, 0, 0)--升级
	if x > -1 then
		tap(x,y)
	else
				x, y = findColor({925, 848, 1839, 1009}, 
		"0|0|0x6b7475,-1|26|0x42565f,-3|49|0x4f585a,-27|42|0x8e9a9f,-26|69|0x5d6365,-60|54|0x4e5a5f,-54|34|0x667276",
		95, 0, 0, 0)--重建
		if x > -1 then
			tap(x,y)
		else
			ShowInfo.RunningInfo("获取升级/建筑按钮失败")
			return false
		end
	end
	sysLog(x..","..y)
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
function City:Rebuild()
	x, y = findColor({925, 848, 1839, 1009}, 
				"0|0|0x182411,22|27|0xb4b1a3,47|42|0x838279,62|53|0xd5d3cd,13|67|0x182212,0|32|0x26381d",
				95, 0, 0, 0)
		if x>-1 then
			tap(x,y)
			sleepWithCheckLoading(200)
			tap(1260,680)
			return true
		else
			ShowInfo.RunningInfo("获取重建按钮失败")
		end
end
function City:GetBuildingStatus(buildingX)
	for status,statuInfo in pairs(BuildingStatusList) do
		x, y = findColor({buildingX-150, 542, buildingX+150, 636}, 
			statuInfo,
			90, 0, 0, 0)
		if x>-1 then
			return status
		end
	end
	return "未知状态"
end
function City:GetBuildingQueueFreeNum()
	point = findColors({1121, 196, 1710, 403}, 
	{
		{x=0,y=0,color=0x18d80e},
		{x=14,y=1,color=0x18d80e},
		{x=12,y=-14,color=0x18d80e},
		{x=-4,y=-14,color=0x18d80e},
		{x=4,y=-17,color=0x18d80e},
		{x=4,y=9,color=0x18d80e},
		{x=-3,y=12,color=0x18d80e},
		{x=13,y=12,color=0x18d80e},
		{x=-11,y=14,color=0x365d20}
	},
	95, 0, 0, 0)
	
	return #point 
end
function City:FindBuilding(BuildingName,findNextPage)
	findNextPage=findNextPage or true
	ShowInfo.RunningInfo("寻找建筑"..BuildingName)
	local beenFindingForOnce=false
	local firstTimeSearch=false
	while true do
		local atButtom=false
		atButtom= self:CheckOnButtom()

		if not firstTimeSearch then
			mSleep(1000)
		end
		firstTimeSearch=false
		points = findColors({549,484,1917,773}, 
		BuildingInfoList[BuildingName] ,
		90, 0, 0, 0)
		sysLog(BuildingName.."找到"..#points.."个点")
		if #points > 0 then
			points= exceptPosTableByNewtonDistance(points,50)
			sysLog(BuildingName.."处理后剩余"..#points.."个点")
			return points
		else
			if atButtom==true then
				if beenFindingForOnce==true or (not findNextPage) then
					return {}
				else
					beenFindingForOnce=true
					City:RollToBegin()
				end
			else
				self:NextPage()
			end
			
		end
	end
end
function City:CheckImmediateBuilding()
	local flag=false
	x, y = findColor({1325, 279, 1882, 400}, 
	"0|0|0xfafafa,-3|6|0xfbfbfb,2|14|0xf1f0ef,14|14|0xf1f0ef,17|6|0xfbfbfb,18|24|0xf5f4f3,30|25|0xf4f3f3,34|9|0xf9f8f8,45|2|0xfbfbfb,50|17|0xfbfbfa",
	95, 0, 0, 0)
	if x > -1 then
		tap(x,y+70)
		ShowInfo.RunningInfo("立即完成免费建筑")
		sleepWithCheckLoading(200)
		tap(961,800)
		sleepWithCheckLoading(1200)
		flag=true
		flag=flag or self:CheckImmediateBuilding()
	end
	return flag
end
function City:GetAeraAllValidBuilding()
	local All
	local tmpBuilding=City:GetPageValidBuilding()
	if #tmpBuilding==0 then
		return false
	else
	
	end
end
function City:GetPageValidBuilding()
	
end
function City:GetBuildingInfo()--CanLevelUp,NowLevel
	
end

function City:RollToBegin()
	--ShowInfo.RunningInfo("回到顶部")
	local times=0
	while not City:CheckOnTop() do
		City:LastPage()
		times=times+1
		if times>5 then
			return
		end
	end
	mSleep(2000)
end
function City:NextPage()
	swip(1700,650,570,650,10)
end
function City:LastPage()
	swip(570,650,1700,650,10)
end
function City:CheckOnTop()
	x, y = findColor({548, 485, 637, 535}, 
	"0|0|0x373e4a,0|13|0x373e4a,0|24|0x373e4a",
	90, 0, 0, 0)
	if x > -1 then
		return false
	else
		--ShowInfo.RunningInfo("到达顶部")
		return true
	end
end
function City:CheckOnButtom()
	x, y = findColor({1860, 489, 1919, 542}, 
	"0|0|0x373e4a,0|13|0x373e4a,0|24|0x373e4a",
	90, 0, 0, 0)
	if x > -1 then
		return false
	else
		--ShowInfo.RunningInfo("到达底部")
		return true
	end
end