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
	self:RunBuild()
	self:RunConscript()
end
function Conscript:RunBuild()
	local needManufacture=false
	if Setting.Army.Enable.生产军备==true then
		for i,item in ipairs(Setting.Army.army) do
			if item.Manufacture>0 then
				needManufacture=true
				break
			end
		end
	else
		ShowInfo.RunningInfo("军备生产被禁用")
		return false
	end
	if needManufacture then
		if Conscript:Enter("军备") then
			ShowInfo.RunningInfo("生产军备开始")
			for i,item in ipairs(Setting.Army.army) do
				if item.Manufacture>0 then
					ShowInfo.RunningInfo("生产"..item[1]..",数量"..item.Manufacture)
					local x,y=self:GetArmamentAtPage(item[1])
					if x>-1 then
						tap(x,y)--开始生产
						mSleep(200)
						local maxManufactureNum = Form:GetNowManufactureNum()
						if maxManufactureNum>item.Manufacture then
							Form:Manufacture(item.Manufacture)--可建造数量大于需求则只建造需求
							item.Manufacture=0
						else
							Form:Manufacture()
							item.Manufacture=item.Manufacture-maxManufactureNum
						end
						setStringConfig("Military.Manufacture."..item[1],tostring(item.Manufacture))
						ShowInfo.RunningInfo("还需生产"..item.Manufacture)
					else
						ShowInfo.RunningInfo("未能找到目标军备")
					end
				end
			end
			Form:Exit()
		end
	end
end
function Conscript:RunConscript()
	local needBuild=false
	if Setting.Army.Enable.组建部队==true then
		for i,item in ipairs(Setting.Army.army) do
			if item.Build>0 then
				needBuild=true
				break
			end
		end
	else
		ShowInfo.RunningInfo("组建部队被禁用")
		return false
	end
	sysLog("needBuild"..tostring(needBuild))
	if needBuild then
		if Conscript:Enter("组建") then
			ShowInfo.RunningInfo("组建部队开始")
			sleepWithCheckLoading(500)
			local needPushButton=true
			for i,item in ipairs(Setting.Army.army) do
				if item.Build>0 then
					if needPushButton then
						tap(1900,1050)--组建按钮
						needPushButton=false
					end
					ShowInfo.RunningInfo("生产"..item[1]..",数量"..item.Build)
					local find=self:SelectTargetArms(item[1])
					if find then
						mSleep(200)--开始生产
						local maxManufactureNum = Form:GetNowManufactureNum()
						if maxManufactureNum>item.Build then
							Form:Manufacture(item.Build)--可建造数量大于需求则只建造需求
							item.Build=0
						else
							Form:Manufacture()
							item.Build=item.Build-maxManufactureNum
						end
						setStringConfig("Military.Build."..item[1],tostring(item.Build))
						ShowInfo.RunningInfo("还需生产"..item.Build)
						needPushButton=true
					else
						ShowInfo.RunningInfo("未能找到目标军备")
					end
				end
			end
			tap(1527,167)--用于退出
			ShowInfo.RunningInfo("组建部队结束")
			mSleep(500)
			Form:Exit()
		else
			ShowInfo.RunningInfo("进入组建失败")
		end
	end
end
function Conscript:GetArmamentAtPage(armamentName)
	local tryTime=0
	mSleep(500)
	while true do
		tryTime=tryTime+1
		local x,y=self:FindArmamentAtPage(armamentName)
		if x>-1 then
			return x,y
		end
		if (not self:ManufactureNextPage()) or tryTime>5 then
			return -1
		end
	end
end
function Conscript:FindArmamentAtPage(armamentName)
	--600 900
	mSleep(500)
	local x,y=findColor({285,600,1635,601},ArmyIconList[armamentName][1],90,0,0,0)
	if x>-1 then 
		return x,y
	else
		x,y=findColor({285,900,1635,901},ArmyIconList[armamentName][1],90,0,0,0)
		return x,y
	end
end
function Conscript:SelectTargetArms(targetName)
	local nowRecognize=90
	local nowSelectName=""
	mSleep(500)
	keepScreen(true)
	while true do
		for i,item in ipairs(Setting.Army.army) do
			local color=ArmyIconList[item[1]][2]
			--sysLog(targetName..":"..color)
			local x,y=findColor({945,648,946,649},color,nowRecognize,0,0,0)
			if x>-1 then
				sysLog("找到"..item[1])
				nowSelectName=item[1]
				--mSleep(1000)
				break
			else
				--sysLog("失败:"..item[1])
			end
		end
		if nowSelectName=="" then--只有在找到后才不退出
			nowRecognize=nowRecognize-5
		else
			break
		end
	end
	keepScreen(false)
	if targetName==nowSelectName then
		return true
	else
		--sysLog("n:"..Setting.Army.armyIndex[nowSelectName].."t:"..Setting.Army.armyIndex[targetName])
		if Setting.Army.armyIndex[nowSelectName]<Setting.Army.armyIndex[targetName] then--只有目前选择的军备等级小于目标才有可能有
			if self:HaveNextConscript() then
				tap(1096,363)--下一个军备
				--mSleep(500)
				return self:SelectTargetArms(targetName)
			end
		end
		return false
	end
end
function Conscript:HaveNextConscript()
	x, y = findColor({1050, 345, 1085, 355}, 
"0|0|0x6d635d,11|0|0x6d635d,22|0|0x6d635d",
95, 0, 0, 0)
	return x==-1
end
function Conscript:ManufactureLastPage()
	swip(300,600,2300,600)
	local atTop= self:ManufactureCheckOnTop()
	mSleep(200)
	return atTop
end
function Conscript:ManufactureNextPage()
	swip(1500,600,-500,600)
	local atBottom= self:ManufactureCheckOnBottom()
	mSleep(200)
	return atBottom
end
function Conscript:ManufactureCheckOnBottom()
		x, y = findColor({1580, 432, 1617, 435}, 
	"0|0|0x292e31",
	95, 0, 0, 0)
	return x ==-1
end
function Conscript:ManufactureCheckOnTop()
	x, y = findColor({288, 429, 330, 434}, 
	"0|0|0x373e4a",
	95, 0, 0, 0)
	return x==-1
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
		if buildNewButtonPosX>-1 then
			tap(buildNewButtonPosX,buildNewButtonPosY)
			return true
		else
			return false
		end
	end
	return false
end