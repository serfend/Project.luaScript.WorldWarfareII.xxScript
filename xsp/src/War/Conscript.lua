Conscript = {
	nowState=0,
	needMerge=2,nextTimeNeedMerge=0
}--初始化

function Conscript:new (o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end
function Conscript:Run()
	ShowInfo.RunningInfo("军事生产开始")
	local success=false
	success=self:RunBuild()
	if Setting.Army.Enable.AutoMerge==false then
		ShowInfo.RunningInfo("自动合并部队被禁用")
	else
		success=success and self:RunConscript()
	end
	
	return success
end
function Conscript:ClearAll(id)--Build Manufacture
	if dialogRet("确定要清空"..id.."吗","确定","取消","",0)==0 then
		for i,item in ipairs(Setting.Army.army) do
			setStringConfig("Military.".. id .."."..item[1],"0")
			item[id]=0
		end
		dialog("已清空"..id,5)
	end
end

function Conscript:GetQueueNum(x1,y1,x2,y2)
	local code,result=ocr:GetNum(x1,y1,x2,y2)
	result=string:getNumOnly(result)
	sysLog("Conscript:GetQueueNum:"..result)
	if result=="" then
		dialog("获取队列失败",5)
		return -1,-1
	end
		local nowQueue=0
		local maxQueue=0
	local checkIfNumber=string.find(result,"/") or 0
	if checkIfNumber<=0 then
		local checkIfNumOutOfRange=tonumber(result)
		maxQueue= math.mod (checkIfNumOutOfRange,100)
		nowQueue=math.floor(checkIfNumOutOfRange / 100)
	else
		local tmp=split(result,"/")
		if #tmp>1 then
			tmp[2]=replace(tmp[2]," ","")
			maxQueue=tonumber(GetLastValue(tmp[2]))
			nowQueue=tonumber(GetLastValue(tmp[1]))
		end
	end
	sysLog("Conscript:GetQueueNum:"..nowQueue.."/"..maxQueue)
	return nowQueue,maxQueue
end
function Conscript:GetConscriptQueueNum()
	return self:GetQueueNum(282,90,358,119)
end
function Conscript:GetBuildQueueNum()
	return self:GetQueueNum(398,97,480,133)
end
function Conscript:CheckBuildRunning()
	local nowQueue,maxQueue= self:GetBuildQueueNum()
	return nowQueue<maxQueue
end
function Conscript:CheckConscriptRunning()
	local nowQueue,maxQueue= self:GetConscriptQueueNum()
	return nowQueue<maxQueue
end
function Conscript:CheckBuildStatus(exitForm)
	exitForm=exitForm or true
	x, y = findColor({1480, 149, 1545, 225}, 
	"0|0|0x983535,15|0|0xf4fcff",
	90, 0, 0, 0)
	if x > -1 then
		tap(x,y)
		ShowInfo.RunningInfo("关闭军备界面")
		mSleep(200)
		Form:Exit(true)
	end
end
function Conscript:CheckConscriptStatus(exitForm)
	exitForm=exitForm or true
	mSleep(200)
	x, y = findColor({1480, 149, 1545, 225}, 
	"0|0|0x983535,15|0|0xf4fcff",
	90, 0, 0, 0)
	if x > -1 then
		tap(x,y)
		ShowInfo.RunningInfo("关闭组建界面")
		mSleep(200)
		Form:Exit(true)
	end
end
function Conscript:Reset()
	Conscript:CheckConscriptStatus(true)
	Conscript:CheckBuildStatus(true)
end
function Conscript:RunBuild()
	local needManufacture=0
	self:CheckBuildStatus()
	if Setting.Army.Enable.生产军备==true then
		for i,item in ipairs(Setting.Army.army) do
			if item.Manufacture==nil then
				ShowInfo.RunningInfo("错误的设置"..item[1])
				toast("错误的设置"..item[1])
			elseif item.Manufacture>0 then
				needManufacture=item[2]
				break
			end
		end
	else
		ShowInfo.RunningInfo("军备生产被禁用")
		return true
	end
	if needManufacture>0 then
		if Conscript:Enter("军备",needManufacture) then
			if not self:DoManufacture(needManufacture) then
				Conscript:CheckBuildStatus()
			end
			Form:Exit()
		end
	end
	return true
end
function Conscript:DoManufacture(ManufactureIndex)--陆军 空军 海军
	ShowInfo.RunningInfo("生产军备开始")
	keepScreen(false)
	sleepWithCheckLoading(1000)
	local nowQueue,maxQueue=self:GetBuildQueueNum()
	for i,item in ipairs(Setting.Army.army) do
		if item.Manufacture>0 then
			if nowQueue>=2 then
				ShowInfo.RunningInfo("军备正在生产中，取消")
				return true
			else
				if ManufactureIndex==item[2] then--判断军队类型
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
						nowQueue=nowQueue+1
					else
						ShowInfo.RunningInfo("未能找到目标军备")
						return false
					end
				end
			end
		end
	end
end
function Conscript:RunConscript()
	local needBuild=0
	if self.nextTimeNeedMerge>0 then 
		self.nextTimeNeedMerge=0
		self.needMerge=self.nextTimeNeedMerge
	end
	Conscript:CheckConscriptStatus(false)
	if Setting.Army.Enable.组建部队==true then
		for i,item in ipairs(Setting.Army.army) do
			if item.Build>0 then
				needBuild=item[2]
				break
			end
		end
	else
		ShowInfo.RunningInfo("组建部队被禁用")
	end
	if needBuild>0 or self.needMerge>0 then
		local selectBuilding=(self.needMerge>0 and self.needMerge or needBuild)
		if Conscript:Enter("组建",selectBuilding) then
			if needBuild>0 then
				if not self:DoConscript(needBuild) then
					Conscript:CheckConscriptStatus(false)
				else
					mSleep(500)
				end
			end
			if self.needMerge>0 then
				self:DoMerge(self.needMerge)
			end
			Form:Exit(true)
		else
			ShowInfo.RunningInfo("进入组建失败")
		end
	end
	return true
end
local armyTypeCollection={}
function Conscript:DoMerge(armyIndex)
	self.needMerge=0
	ShowInfo.RunningInfo("尝试合并部队")
	mSleep(500)
	armyTypeCollection={}
	self:DoMergeOnce("步兵",armyIndex)
	printTable(armyTypeCollection)
	for k,v in pairs(armyTypeCollection) do
		if k~="步兵" then
			--if v>1 then 
				--sysLog("检查"..k..","..v)
				self:DoMergeOnce(k) 
			--end
		end
	end
	ShowInfo.RunningInfo("尝试合并部队结束")
end
function Conscript:CollectArmyType(armyIndex)
	keepScreen(true)
	for i,item in ipairs(Setting.Army.army) do
		if item[2]==armyIndex then
			x,y=self:FindArmyAtPage(item[1])
			--sysLog("finding"..item[1])
			if x>-1 then
				ShowInfo.RunningInfo(string.format("发现%d:%s",i,item[1]))
				armyTypeCollection[item[1]]=armyTypeCollection[item[1]] or 0
				armyTypeCollection[item[1]]=armyTypeCollection[item[1]]+1
			else
				--ShowInfo.RunningInfo(string.format("寻找%d:%s",i,item[1]))
			end
		end
	end
	keepScreen(false)
end
function Conscript:FindArmyAtPage(targetArmyName,beginX)
	beginX=beginX or 139
	return findColor({beginX,567,1790,567},ArmyIconList[targetArmyName][3],85,0,0,0)
end
function Conscript:DoMergeOnce(targetArmyName,collectArmyType)
	local sumNum=0
	local findNextTime=true
	collectArmyType=collectArmyType or 0
	ShowInfo.RunningInfo("尝试合并"..targetArmyName)
	while true do 
		local thisTimeFindArmyNum=self:SelectArmyAtPage(targetArmyName) 
		ShowInfo.RunningInfo(targetArmyName..thisTimeFindArmyNum.."/"..sumNum)
		sumNum=sumNum+thisTimeFindArmyNum
		if collectArmyType>0 then self:CollectArmyType(collectArmyType) end
		if not findNextTime then break end
		if not self:ArmyNextPage() then
			ShowInfo.RunningInfo("到达底部")
			findNextTime=false
		end
		mSleep(500)
	end
	if sumNum>1 then--可合并
		self:SelectButton(1)
		ShowInfo.RunningInfo("合并"..sumNum.."组")
		self:ArmyRollToTop()
		mSleep(500)
	elseif sumNum==1 then--不可合并且需取消
		ShowInfo.RunningInfo("无可合并项，取消选择")
		while not self:CancelArmySelectAtPage() do
			if not self:ArmyLastPage() then
				ShowInfo.RunningInfo("取消失败!")
				break
			end
		end
	else--不可合并无需取消
		
	end
	self:ArmyRollToTop()
end
function Conscript:ArmyRollToTop()
	local tryTime=0
	while self:ArmyLastPage() do 
		tryTime=tryTime+1
		if tryTime>=10 then break end
	end
end
function Conscript:SelectArmyAtPage(targetArmyName,beginX)
	x,y=self:FindArmyAtPage(targetArmyName,beginX)
	if x>-1 then
		local selx,sely=self:ArmyBeenSelected(x-80,x+80)
		if selx==-1 then
			tap(x,y)
			mSleep(200)
			return self:SelectArmyAtPage(targetArmyName,x+50)+1
		else
			return self:SelectArmyAtPage(targetArmyName,x+50)
		end
	end
	return 0
end
function Conscript:ArmyBeenSelected(x1,x2)
	keepScreen(true)
	local leftFoundEdge=false
	local rightFoundEdge=false
	
	local resultX1=0
	local resultX2=0
	CheckEdge=function(x,index)
		index=index or 1
		
		local r,g,b=getColorRGB(x,429)
		if r>180 and g>180 then
			if index==3 then return true end
			return CheckEdge(x+20,index+1)
		end
	end
	for x=x1,x2 do 
		if CheckEdge(x) then
			leftFoundEdge=true
			resultX1=x
			break
		end
	end
	if leftFoundEdge then
		for x=resultX1+50,x2 do 
			if CheckEdge(x) then
				rightFoundEdge=true
				resultX2=x
				if resultX2-resultX1>300 then rightFoundEdge=false end
				break
			end
		end
	end
	keepScreen(false)
	if  rightFoundEdge and leftFoundEdge then
		return (resultX1+resultX2)/2,600
	else
		return -1,-1
	end
end
function Conscript:CancelArmySelectAtPage()
	mSleep(500)
	x,y=self:ArmyBeenSelected(130,1790)
	if x>-1 then 
		x=x+30
		tap(x,y)
		--ShowInfo.RunningInfo("取消成功")
		return true
	end
	return false
end
function Conscript:SelectButton(index)
	--[[合并	2]]
	tap(950+index*200,900)
	mSleep(300)
end
function Conscript:ArmyNextPage()
	swip(1368,575,500,575)
	x,y=findColor({1739,390,1794,399},"0|0|0x373e4a",90,0,0,0)
	return x>-1
end
function Conscript:ArmyLastPage()
	swip(300,575,1368,575)
	local atTop=false
	keepScreen(true)
	x,y=findColor({1739,390,1794,399},"0|0|0x373e4a",90,0,0,0)--检查末尾是否是空
	if x==-1 then atTop=true end
	if not atTop then
		xtop,ytop=findColor({128,390,135,399},"0|0|0x373e4a",90,0,0,0)--检查开头
		atTop=xtop==-1
	end
	keepScreen(false)
	if atTop then
		sysLog("到达顶部")
		mSleep(1000)--到达顶部后休息会
	end
	return not atTop
end
function Conscript:DoConscript(armyIndex)
		
		ShowInfo.RunningInfo("组建部队开始")
		sleepWithCheckLoading(500)
		local success=false
		local needPushButton=true
		local nowQueue,maxQueue=self:GetConscriptQueueNum()
		sleepWithCheckLoading(500)
		if nowQueue>0 then self.nextTimeNeedMerge=armyIndex end--存在组建时则需要检查
		for i,item in ipairs(Setting.Army.army) do
			if armyIndex==item[2] then
				if item.Build>0 then
					if nowQueue>=4 then
						ShowInfo.RunningInfo("正在组建中,取消")
						return true
					else
						if needPushButton then
							tap(1900,1050)--组建按钮
							needPushButton=false
							sleepWithCheckLoading(500)
						end
						ShowInfo.RunningInfo("生产"..item[1]..",数量"..item.Build)
						local find=self:SelectTargetArms(item[1],nil,nil,armyIndex)
						if find then
							self.needMerge=armyIndex
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
							nowQueue=nowQueue+1
							success=true
						else
							ShowInfo.RunningInfo("未能找到目标军备")
						end
					end
				end
			end
		end
		tap(1527,167)--用于退出
		ShowInfo.RunningInfo("组建部队结束")
		return success
end
function Conscript:GetArmamentAtPage(armamentName)
	local tryTime=0
	sleepWithCheckLoading(500)
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
function Conscript:FindArmamentAtPage(armamentName)--寻找军备
	--600 900
	mSleep(500)
	local x,y=findColor({285,500,1635,650},ArmyIconList[armamentName][1],90,0,0,0)
	if x>-1 then 
		return x,y
	else
		x,y=findColor({285,800,1635,950},ArmyIconList[armamentName][1],90,0,0,0)
		return x,y
	end
end
function Conscript:SelectTargetArms(targetName,tryTime,lastSelectName,selectArmyIndex)
	local nowRecognize=90
	local nowSelectName=""
	tryTime=tryTime or 0
	mSleep(500)
	keepScreen(true)
	

	while true do
		nowSelectName=self:GetNowSelectArms(nowRecognize,selectArmyIndex)
		if nowSelectName=="" then--只有在找到后才不退出
			nowRecognize=nowRecognize-5
			if nowRecognize==80 then
				nowSelectName="unknown"
				break
			end
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
				if lastSelectName~=nowSelectName then
					tryTime=0
				end
				return self:SelectTargetArms(targetName,tryTime+1,nowSelectName,selectArmyIndex)
			end
		end
		return false
	end
end
function Conscript:GetNowSelectArms(nowRecognize,selectArmyIndex)
	for i,item in ipairs(Setting.Army.army) do
		if selectArmyIndex == item[2] then
			local color=ArmyIconList[item[1]][2]
			--sysLog(color)
			local x,y=findColor({940,645,950,655},color,nowRecognize,0,0,0)--648
			if x>-1 then
				--sysLog("找到"..item[1])
				return item[1]
			else
				--sysLog("失败:"..item[1])
			end
		end
	end
	return ""
end
function Conscript:HaveLastConscript()
	x, y = findColor({820, 345, 860, 355}, 
"0|0|0x6d635d,11|0|0x6d635d,22|0|0x6d635d",
95, 0, 0, 0)
	return x==-1
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
	return not atTop
end
function Conscript:ManufactureNextPage()
	swip(1500,600,0,600)
	local atBottom= self:ManufactureCheckOnBottom()
	mSleep(200)
	return not atBottom
end
function Conscript:ManufactureCheckOnBottom()
		x, y = findColor({1526, 431, 1616, 436}, 
"0|0|0x373e4a",
95, 0, 0, 0)
	return x ==-1
end
function Conscript:ManufactureCheckOnTop()
	x, y = findColor({288, 429, 330, 434}, 
	"0|0|0x373e4a",
	95, 0, 0, 0)
	return x==-1
end
function Conscript:Enter(target,index)
	local targetBuilding=(target=="军备" and "兵工厂" or (index==1 and "陆军基地" or (index==2 and "空军基地")))
	local targetButton=(target=="军备" and "生产军备" or "部队列表")
	if index==3 and target~="军备" then return false end--禁止进入海军基地
	Building:SelectMainCityBuilding()
	local targrtPoint=City:FindBuilding(targetBuilding)
	if #targrtPoint>0 then
		tap(targrtPoint[1].x,targrtPoint[1].y)
		mSleep(200)
		local buildNewButtonPosX,buildNewButtonPosY=Form:GetBuildingButton(targetButton)
		if buildNewButtonPosX>-1 then
			tap(buildNewButtonPosX,buildNewButtonPosY)
			mSleep(500)--等待界面加载
			if target=="军备" then
				--军备页面选择
				if index==1 then
					tap(200,30)
				elseif index==2 then
					tap(400,30)
				elseif index==3 then
					tap(600,30)
				end
				mSleep(200)
			end
			
			return true
		else
			return false
		end
	end
	return false
end