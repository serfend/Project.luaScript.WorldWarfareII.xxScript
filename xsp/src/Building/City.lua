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
	IsMainCity=false,--是否是主城
	CityProperty="233",
	nowMainBuildingName="主城"
}--初始化

function City:new (o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end
function City:CheckIfMainBuilding()
		local x,y=  findColor({8, self.pos.y-150, 524, self.pos.y+60}, 
	"0|0|0xdde2eb,7|10|0x5c7093,4|13|0x40557d",
	90, 0, 0, 0)--寻找主城标识
	if x>-1 then
		sysLog("城市为主城")
		self.IsMainCity=true
		self.CityProperty="CityMain"
	else
		sysLog("城市为分城")
		self.IsMainCity=false
		self.CityProperty="CityOther"
	end
end
local maxBuildingPriorityRank=7
function City:Run()
	self:CheckIfMainBuilding()
	sysLog("城市建设开始")
	maxBuildingPriorityRank=7
	--self:ShowAllBuildingQueue() --展示所有建筑列表
	if Setting.Building[self.CityProperty.."Setting"].EnableAutoDevelop==false then
		ShowInfo.RunningInfo("城市建设被禁用")
		return true,-1
	end
	self:RunBuilding("City")--城市建设
	self:CheckIfSupplyInsufficient()--判断补给
--	if self.pos.y>800 then
--		mSleep(200)
--		swip(20,800,20,500,10)
--		self.pos.y=self.pos.y-300
--	end
	while true do
		local nextX,nextY=City:FindNextAero()
		ShowInfo.RunningInfo("寻找下个区域")
		if nextX>-1 then
			tap(nextX,nextY)
			if nextY>800 then
				mSleep(300)
				swip(20,800,20,500,10)
				nextY=nextY-300
			end
			self:RunBuilding("Field")--野地
		else
			sysLog("无下一区域")
			break
		end
	end
	ShowInfo.RunningInfo("城市处理完成")
	local ifNext=self:FindNextCity()
	if ifNext>-1 then
		return false,ifNext
	else
		return true,-1
	end
end
function City:FindNextCity()
	local y=Building:FindNowFocus()
	if y<0 or y>980 then
		return -1
	end
	local x,y=findColor({0,y,20,y+200},
	"0|0|0xa39380,5|33|0xa39380,6|63|0xa39380",
	95, 0, 0, 0)
	if y>-1 then
		y=y+50
	end
	return y
end
function City:FindNextAero()
	x, y = findColor({442, 77, 531, 1074}, 
	"0|0|0xa39380,-476|4|0x42332a,0|-71|0x8d6828,-479|-60|0x3e332a,-13|-45|0x8a6223,14|-7|0xa39380",
	90, 0, 0, 0)
		return x,y
end
local lastTimeFindResAero=false
local isDoubleResAero=false
function City:RunBuilding(id)
	sleepWithCheckLoading(500)
	if Setting.Task.EnableActiveCollectEvent then
		self:CollectFieldEvent()
	end
	if self:CheckNeedConcilite() then
		return true
	end
	if not self:CheckBuildingQueue(id) then return true end
	ShowInfo.RunningInfo(id.."开始建筑")
	lastTimeFindResAero=false
	local AllFoundBuilding,validBuilding=self:GetAeraAllValidBuilding(id)
	sysLog("共可建筑:"..validBuilding)
	if validBuilding==0 then
		return false
	end
	for i=1,7 do
		if i>maxBuildingPriorityRank then 
			ShowInfo.RunningInfo("资源优化生效"..i.."取消")
			break
		end
		if self:BuildBuildingInRank(i,id,AllFoundBuilding)==false then
			return true
		end
	end
end
function City:CollectFieldEvent()
	if not GameTask:CheckNeedRefresh() then
		return false
	end
		x, y = findColor({457, 74, 537, 1076}, 
	"0|0|0xfffefe,-9|-10|0xfffefe,-7|-19|0xece6dc,-24|-13|0xe7dfd3,-25|-19|0xf1ede6,-22|-25|0xf0ebe3,-16|-18|0x8b6426,-16|-13|0x8a6325,-21|-18|0x8b6426,-11|-18|0x8b6426,-16|-23|0x8c6627",
	90, 0, 0, 0)
	if x > -1 then
		tap(x,y)
		sleepWithCheckLoading(2000)--等待目标出现
		GameTask:CollectMapEvent()
		Building:Enter()
		Building:SelectNowFocus()
	else
		sysLog("CollectFieldEventFail")
	end
end
function City:CheckBuildingQueue(id)
	self:CheckImmediateBuilding()
	if self:GetBuildingQueueFreeNum()<1 then
		ShowInfo.RunningInfo(id.."无空闲队列")
		sleepWithCheckLoading(100)
		return false
	end
	return true
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
	},
	85, 0, 0, 0)
	point=exceptPosTableByNewtonDistance(point,50)
	return #point 
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
function City:ShowAllBuildingQueue()--调试方法，可不用
	for index=4,5 do
		for i,building in ipairs(Setting.Building.City) do
			if building[index]==true then
				ShowInfo.RunningInfo(building[1].."可建筑"..building[2])
			else
				ShowInfo.RunningInfo(building[1].."禁止"..building[2])
			end
		end
		for i,building in ipairs(Setting.Building.Field) do
			if building[index]==true then
				ShowInfo.RunningInfo(building[1].."可建筑"..building[2])
			else
				ShowInfo.RunningInfo(building[1].."禁止"..building[2])
			end	
		end
		ShowInfo.RunningInfo("------------")
	end
end
function City:BuildBuildingInRank(rank,CityOrField,ValidBuilding)
	ShowInfo.RunningInfo("处理:".. (self.IsMainCity and "主城" or "分城")..(CityOrField=="City" and "城市" or "野地") ..rank.."级建筑")
	printTable(ValidBuilding)
	for i,building in ipairs(Setting.Building[CityOrField]) do 
		if math.abs(building[3-(self.IsMainCity and 1 or 0)])==rank and building[5-(self.IsMainCity and 1 or 0)]==true then
			if building[1]~="none" then
				local canBuild=false
				for j,canBuilding in ipairs(ValidBuilding) do
					if canBuilding.Name==building[1] then
						if canBuilding.Status=="资源不足"  then
							canBuild=false
							if Setting.Building[self.CityProperty.."Setting"].SkipWhenHigherPriorityBuilingIsLackOfRescource then
								ShowInfo.RunningInfo("禁低于"..rank.."的建筑")
								maxBuildingPriorityRank=rank
							end
						else 
							if canBuilding.Status=="可升级" then
								canBuild=true
							else
								canBuild=false
								--ShowInfo.RunningInfo("建筑"..building[1].."("..canBuilding.Status..")被禁用"..building[3-self.IsMainCity])
							end
						end
						break
					end
				end
				if canBuild then 
					ShowInfo.RunningInfo("处理建筑"..rank..building[1])
					local points=City:FindBuilding(building[1])
					if #points>0 then
						for i,buildingPos in ipairs(points) do
							local buildingX=buildingPos.x
							--ShowInfo.RunningInfo("x"..buildingX)
							if buildingX>1650 then
								swip(1850,647,1650,647)
								mSleep(800)
								buildingX=buildingX-200
							end
							tap(buildingX,650)
							mSleep(200)
							if not CityBuilding:UpLevel() then
								CityBuilding:Rebuild()
							end
							if not City:CheckBuildingQueue(CityOrField) then
								return false
							end
						end
					else
						ShowInfo.RunningInfo("建筑"..building[1].."获取坐标失败")
					end	
				end
			end
		else
			--ShowInfo.RunningInfo("建筑"..building[1].."被禁用"..building[3-self.IsMainCity])
		end
	end
	return true
end
function City:FindBuilding(BuildingName,findNextPage)--
	self:CheckImmediateBuilding()
	findNextPage=findNextPage or true
	ShowInfo.RunningInfo("寻找建筑"..BuildingName)
	if BuildingName=="双资源区" or BuildingName=="单资源区" then
		BuildingName="资源区"
	end
	local beenFindingForOnce=false
	local firstTimeSearch=false
	local tryTime=0
	while true do
		tryTime=tryTime+1
		if tryTime>10 then
			return {}
		end
		local atButtom=false
		atButtom= self:CheckOnButtom()
		if atButtom then
			findNextPage=false
			sysLog("findBuildingAtButtom")
		end
		if not firstTimeSearch then
			mSleep(1000)
		end
		firstTimeSearch=false

		points=self:FindBuildingAtCurrentPage(BuildingName)
		ShowInfo.RunningInfo(BuildingName.."找到"..#points.."个点")
		if #points > 0 then
			points= exceptPosTableByNewtonDistance(points,100)
			ShowInfo.RunningInfo(BuildingName.."处理后剩余"..#points.."个点")
			return points
		else
			if atButtom==true then
				if beenFindingForOnce==true or (not findNextPage) then
					return {}
				else
					beenFindingForOnce=true
					self:RollToBegin()
				end
			else
				self:NextPage()
			end
			
		end
	end
end
function City:FindBuildingAtCurrentPage(BuildingName)
	return  findColors({550,480,1919,800}, 
			BuildingInfoList[BuildingName] ,
			90, 0, 0, 0)
end
function City:GetAeraAllValidBuilding(CityOrField)--寻找可用建筑算法可优化（寻找所有绿色和资源不足）
	local AllValidBuilding={}
	local validBuildingNum=0
	local haveNextPage=true
	while true do
		sleepWithCheckLoading(500)
		local tmpBuilding=self:GetPageValidBuilding(CityOrField)
		
		local thisValidBuildingNum=0
		for i,building in ipairs(tmpBuilding) do
		if building.Status=="可升级" or building.Status=="资源不足" then
				if building.Status=="可升级" then 
					thisValidBuildingNum=thisValidBuildingNum+1
				end
				table.insert(AllValidBuilding,building)
			end
		end
		validBuildingNum=validBuildingNum+thisValidBuildingNum
		ShowInfo.RunningInfo("处理中..."..validBuildingNum)
		if thisValidBuildingNum==0 then
			break
		else
			if not haveNextPage then
				break
			end
			haveNextPage=City:NextPage() 
		end
	end
	ShowInfo.RunningInfo("处理完成..."..validBuildingNum)
	self:RollToBegin()
	return AllValidBuilding,validBuildingNum
end
function City:GetPageValidBuilding(CityOrField)
	local PageValidBuilding={}
	self:CheckAllNeedRepair()
	ShowInfo.RunningInfo("获取:".. (self.IsMainCity and "主城" or "分城")..(CityOrField=="City" and "城市" or "野地").."建筑")
	keepScreen(true)
	local AllBuildingCount=#Setting.Building[CityOrField]
	for i,building in ipairs(Setting.Building[CityOrField]) do
		if building[5-(self.IsMainCity and 1 or 0)]==true or true then
			if building[1]~="none" then
				local findBuildingName=""
				if building[1]=="单资源区" or building[1]=="双资源区" then
					findBuildingName="资源区"
				else
					findBuildingName=building[1]
				end
				--sysLog("寻找"..findBuildingName..":"..BuildingInfoList[findBuildingName])
				buildingX,buildingY = findColor({549,612,1919,736}, 
				BuildingInfoList[findBuildingName] ,
				90, 0, 0, 0)
				--ShowInfo.RunningInfo(i.."/"..AllBuildingCount..building[1])
				if buildingX>-1 then
					--sysLog("找到"..findBuildingName)
					local tmpBuilding=CityBuilding:new()
					if findBuildingName=="资源区" then
						if not lastTimeFindResAero then
							isDoubleResAero=City:CheckIfNotDoubleResourceAero()
							lastTimeFindResAero=true
							if isDoubleResAero then
								tmpBuilding.Name="双资源区"
							else
								tmpBuilding.Name="单资源区"
							end
						end
					else
						tmpBuilding.Name=building[1]
					end
					if tmpBuilding.Name~="" then
						tmpBuilding.Status=CityBuilding:GetBuildingStatus(buildingX)
						if BuildingAeroMain[findBuildingName]~=nil then
							self.nowMainBuildingName=findBuildingName
						end
						if tmpBuilding.Status=="可升级" then
							sysLog("发现建筑:"..tmpBuilding.Name.."在"..buildingX)
						else
							sysLog(tmpBuilding.Name.."条件不符合:"..tmpBuilding.Status.."在"..buildingX)
						end
						table.insert(PageValidBuilding,tmpBuilding)
					end
				else
					--sysLog("未找到"..findBuildingName)
				end
				--mSleep(500)
			end
		end
	end
	keepScreen(false)
	return  PageValidBuilding
end
function City:CheckIfNotDoubleResourceAero()--用于判断单资源或双资源
	local point=City:FindBuilding("狙击塔",findNextPage)
	if #point>0 then
		return false
	else
		return true
	end
end
function City:CheckNeedConcilite()
	if Setting.Building[self.CityProperty.."Setting"].EnableAutoConcilite then
		local x, y =Form:GetBuildingButton("安抚")
		if x>-1 then
			ShowInfo.RunningInfo("进行区域安抚")
			tap(x,y)
			sleepWithCheckLoading(500)
		else
			return false
		end
	else
		return false
	end
end
function City:CheckAllNeedRepair()
	if Setting.Building[self.CityProperty.."Setting"].EnableAutoRepair then
		point = findColors({573, 780, 1919, 785}, 
			"0|0|0xb81602,3|0|0x020d13",
			90, 0, 0, 0)
		point=exceptPosTableByNewtonDistance(point,20)
		ShowInfo.RunningInfo("发现需要修理目标"..#point)
		if #point ~= 0 then
			for i,repairTarget in ipairs(point) do
				tap(repairTarget.x,repairTarget.y-50)
				sleepWithCheckLoading(200)
				CityBuilding:CheckRepair()
			end
		end
	end
end
function City:CheckIfSupplyInsufficient()
	
	if Setting.Building[self.CityProperty.."Setting"].EnableAutoProductSupply ==false then
		return false
	end
	sysLog("CheckIfSupplyInsufficient"..self.CityProperty)
	local SupplyPosX={
		食物=520,
		弹药=875,
		燃料=1225,
	}
	local targetBuilding="补给品厂"
	buildingPos=self:FindBuilding(targetBuilding)
	local haveProduct=false
	if #buildingPos>0 then
		tap(buildingPos[1].x,buildingPos[1].y)
		sleepWithCheckLoading(100)
		x,y=Form:GetBuildingButton("生产补给")
		if x>-1 then
			tap(x,y)
			sleepWithCheckLoading(300)
			if CityBuilding:CheckIfSupplyIsProducting() then
				ShowInfo.RunningInfo("补给正在生产中")
				Form:Exit()
				return false
			end
			for index,item in pairs(SupplyPosX) do
				haveProduct=false
				keepScreen(true)
				for y=845,875 do
					r,g,b=getColorRGB(item,y)--补给食品第二位数字
					if r>100 and g>100 and b>100 then
						haveProduct=true
						break
					end
				end
				keepScreen(false)
				if not haveProduct then
					tap(item,742)
					ShowInfo.RunningInfo("生产"..index..",x"..item)
					sleepWithCheckLoading(100)
					if Form:Build() then
						
					end
					
				end
			end
			sleepWithCheckLoading(100)
			Form:Exit()
		end
		
	else
		ShowInfo.RunningInfo("寻找"..targetBuilding.."失败")
	end
	
end
function City:RollToBegin()
	--ShowInfo.RunningInfo("回到顶部")
	local times=0
	while self:LastPage() do
		times=times+1
		if times>5 then
			return
		end
	end
end
function City:NextPage()
	sysLog("下一页")
	if self:CheckOnButtom() then
		return false
	end
	swip(1700,650,570,650)
	return not self:CheckOnButtom()
end
function City:LastPage()
	sysLog("上一页")
	if self:CheckOnTop() then
		return false
	end
	swip(570,650,1700,650)
	return not self:CheckOnTop()
end
function City:CheckOnTop()
	x, y = findColor({570, 485, 590, 535}, 
	"0|0|0x373e4a,0|12|0x373e4a",
	90, 0, 0, 0)
	if x > -1 then
		local point= self:FindBuildingAtCurrentPage(self.nowMainBuildingName)
		if #point>0 then
			return true
		else
			return false
		end
	else
		ShowInfo.RunningInfo("到达顶部")
		return true
	end
end
function City:CheckOnButtom()
	x, y = findColor({1860, 489, 1919, 542}, 
	"0|0|0x373e4a,0|12|0x373e4a",
	90, 0, 0, 0)
	if x > -1 then
		return false
	else
		ShowInfo.RunningInfo("到达底部")
		return true
	end
end
