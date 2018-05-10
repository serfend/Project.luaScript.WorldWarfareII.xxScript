
Skill = {
	nowState=0,UserEnableAutoCollect=false,
	useSkills={},NowSkillNum=0,UserEnableUseSkill=false,
	NowUseSkillIndex=1,

	MaxAssertSkillPoint=100,NowAssertSkillPoint=0,
	
	ReleaseWhenFull="",SkillReleaseWhenFull="",
}--初始化
function Skill:new (o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end
function Skill:setUseSkill(userSetting)
	self.ReleaseWhenFull=userSetting["Skill.ReleaseWhenFull"]
	self.SkillReleaseWhenFull=userSetting["Skill.SkillReleaseWhenFull"]
	local skillQueueNum=tonumber(userSetting["Skill.UsedSkillQueueNum"])
	setNumberConfig("Skill.UsedSkillQueueNum",skillQueueNum)
	self.useSkills={}
	self.NowSkillNum=0
	self.NowUseSkillIndex=1
	for i=1,skillQueueNum do
		if userSetting["Skill.Queue"..i..".Enable"] =="0" then
			self.NowSkillNum=self.NowSkillNum+1
			self.useSkills[self.NowSkillNum]=userSetting["Skill.Queue"..i..".SkillIndex"]
			sysLog("策略队列"..self.NowSkillNum..":"..self.useSkills[self.NowSkillNum])
		end
	end
	self.UserEnableAutoCollect =userSetting["UnitSkillRunEnable"]["策略点"]==true
	self.UserEnableUseSkill =userSetting["UnitSkillRunEnable"]["策略使用"]==true
	for key,item in pairs(result["Skill.SupplyCard"]) do
		Setting.Skill.SupplyCard["card"..key]=item
	end
end
local needUseNow=false
function Skill:Run()
	sleepWithCheckLoading(500)
	Skill:CheckIfAnySkillBeenSelect()
	if self:NeedRefresh() then
		if self:Enter() then
			if self.ReleaseWhenFull=="达到上限" then
				needUseNow=self.NowAssertSkillPoint>=self.MaxAssertSkillPoint
			else
				needUseNow=(self.NowAssertSkillPoint>=tonumber(self.ReleaseWhenFull))
			end
			if self.UserEnableAutoCollect then 
				local attainStatus,SkillPointX,SkillPointY=self:AttainNewSkillPoint()	
			else
				ShowInfo.RunningInfo("技能点获取被禁用")
			end
			if self.UserEnableUseSkill or needUseNow then
				self:UseSkills()
			else
				ShowInfo.RunningInfo("技能使用被禁用")
			end
			if attainStatus==2 then
				self:AttainNewSkillPoint()	
			end
			self:Exit()
		else
			if self:Exit() then
				ShowInfo.RunningInfo("初始化技能失败!")
			end
			sleepWithCheckLoading(500)
			return false
		end
		
	else
		ShowInfo.RunningInfo("技能无需检查")
	end
	return true
end
function Skill:FindSkillPoint1()
	x, y = findColor({1774, 802, 1914, 930}, 
	"0|0|0xe0e0d5,24|21|0x805629,44|39|0x85582b,72|63|0xbabab1",
	95, 0, 0, 0)
	return x,y	
end
function Skill:CheckNewSkillPoint()
	x, y = findColor({1745, 45, 1898, 90}, 
		"0|0|0xc00000",
		95, 0, 0, 0)
	if x > -1 then
		return true,x,y
	else
		return false
	end
end
function Skill:AttainNewSkillPoint()
		local haveNew,x,y=self:CheckNewSkillPoint()
	if haveNew then
		ShowInfo.RunningInfo("获取技能点")
		tap(x,y)
		mSleep(200)
		if self:CheckNewSkillPoint() then
			ShowInfo.RunningInfo("技能点已满")
			return 2,x,y
		else
			return 1
		end
		
	else
		ShowInfo.RunningInfo("暂无技能点可获取")
		return 0
	end
end
local lastAttainPoint=0
function Skill:NeedRefresh()
	if self.UserEnableAutoCollect ==false and  self.UserEnableUseSkill ==false then
		ShowInfo.RunningInfo("策略被禁用")
		return false
	end
	local nowTime=os.time()
	local interval=nowTime-lastAttainPoint
	--ShowInfo.RunningInfo(nowTime..","..interval..","..lastAttainPoint)
	local flag=false
	if interval>Setting.Skill.Interval then
		flag=true
		lastAttainPoint=nowTime
	end
	return flag;
end
function Skill:CheckIfAnySkillBeenSelect()
	x, y = findColor({1300, 821, 1331, 849}, 
	"0|0|0xf4fcff,15|0|0x993333,-15|0|0x993333",
	95, 0, 0, 0)
	if x > -1 then
		tap(x,y)
	end
end
function Skill:CheckPointNotEnough(y)
		x, y = findColor({1650, y, 1715, y+100}, 
			"0|0|0xff0000",
			100, 0, 0, 0)
	if x>0 then 
		return true
	else
		return false
	end
end
function Skill:Enter()
	ShowInfo.RunningInfo("打开技能")
	if self:SkillPageIsOn() then 
		ShowInfo.RunningInfo("已在技能界面")
		return true
	end
	x,y=self:FindSkillPoint1()
	
	if x>-1 then
		Skill.nowState=1
		tap(x,y)
		sleepWithCheckLoading(800)
		self:RefreshSkillPointValue()
		return true
	else
		if self:Exit() then
			sleepWithCheckLoading(800)
			return self:Enter()
		else
			ShowInfo.RunningInfo("未找到技能块")
		end
		return false
	end
end
function Skill:RefreshSkillPointValue()
	local ocrCode,result=ocr:GetNum(1460,48,1630,80)
	if ocrCode==0 then
		local tmp=split(result,"/")
		self.MaxAssertSkillPoint=tonumber(tmp[2])
		self.NowAssertSkillPoint=tonumber(tmp[1])
		if self.NowAssertSkillPoint>200 then
			self.NowAssertSkillPoint=self.NowAssertSkillPoint
		end
		ShowInfo.ResInfo("当前技能点:"..self.NowAssertSkillPoint.."/"..self.MaxAssertSkillPoint)
	else
		ShowInfo.ResInfo("识别技能数值错误")
		self.MaxAssertSkillPoint=-1
		self.NowAssertSkillPoint=-1
	end
end
function Skill:Exit()
	ShowInfo.RunningInfo("关闭技能")

	x, y = findColor({1270, 447, 1354, 632}, 
"0|0|0x7d766b,29|35|0xfaf1dd,51|82|0x867d72",
95, 0, 0, 0)

	if x > -1 then
		tap(x,y+5)
		Skill.nowState=0
		return true
	else
		return false
	end
end


function Skill:UseSkills()
	sleepWithCheckLoading(300)
	ShowInfo.RunningInfo("技能释放开始")
	if self.NowSkillNum==0 then
		if needUseNow then
			if self.SkillReleaseWhenFull=="用户队列" then
				ShowInfo.RunningInfo("用户队列未激活，使用军费")
				self:UseSkill("军费")
			else
				ShowInfo.RunningInfo("技能点达到上限,强制使用")
				self:UseSkill(self.SkillReleaseWhenFull)
			end	
		end
	else
		if needUseNow then
			if self.SkillReleaseWhenFull=="用户队列" then
				self:UseSkillsDirect()
			else
				self:UseSkill(self.SkillReleaseWhenFull)
			end
		else
			self:UseSkillsDirect()
		end
	end
	ShowInfo.RunningInfo("策略释放结束")
end
function Skill:UseSkillsDirect()
	local lastTimeQueueIndex=self.NowUseSkillIndex
	while true do
		if not self:Enter() then
			return false
		end
		
		self.NowUseSkillIndex=self.NowUseSkillIndex+1
		if self.NowUseSkillIndex>self.NowSkillNum then
			self.NowUseSkillIndex=1
		end
		ShowInfo.RunningInfo("技能队列"..self.NowUseSkillIndex.."/"..lastTimeQueueIndex)
		if not self:UseSkill(self.useSkills[self.NowUseSkillIndex]) then
			--self.NowUseSkillIndex=self.NowUseSkillIndex-1--等待上一使用后使用下一个
		end
		if self.NowUseSkillIndex==lastTimeQueueIndex then
			break
		end
	end
end
function Skill:UseSkill(index)
	
	local skillPos=skillList[index]
	local findSkill=false
	local beenTwiceAtButtom=false
	local findTime=0
	while not findSkill and findTime<10
	do
		findTime=findTime+1
		sleepWithCheckLoading(500)
		ShowInfo.RunningInfo("使用技能"..index)
		local x, y = findColor({1500, 150, 1700, 960}, 
		skillList[index],
		90, 0, 0, 0)
		if x > -1 then
			findSkill=true
			while self:CheckPointNotEnough(y) do
				if not self:UseSkillPointSupplyCard() then
					ShowInfo.RunningInfo("技能"..index.."策略值不足")
					return false
				else
					
					break
				end
			end
			tap(x,y)
			sleepWithCheckLoading(200)
			if not self.SkillCanRelease() then 
				ShowInfo.RunningInfo("技能"..index.."不可用")
				return false
			end
			Building:SelectMainCity()
			tap(960,540)--屏幕中心是主城
			sleepWithCheckLoading(200)
			tap(1213,1000)--使用技能【确定】
			ShowInfo.RunningInfo("使用技能"..index.."完成")
			sleepWithCheckLoading(500)

		else
			 
			if not self:NextSkillPage() then 
				if beenTwiceAtButtom then
					ShowInfo.RunningInfo("未找到技能"..index)
					return false
				else
					beenTwiceAtButtom=true
					self:RollToBegin()
				end
			end
		end
	end
	return true
end
function Skill:UseSkillPointSupplyCard()
	local successUsed=false
	if Setting.Skill.SupplyCard.card50 or Setting.Skill.SupplyCard.card100 or Setting.Skill.SupplyCard.card200 then
		tap(1667,67)--进入策略卡使用页面
		sleepWithCheckLoading(100)
		if Setting.Skill.SupplyCard.card200 then
			successUsed=self:UseCard(3)
		end
		if successUsed==false and Setting.Skill.SupplyCard.card100 then
			successUsed=self:UseCard(2)
		end
		if successUsed==false and Setting.Skill.SupplyCard.card50 then
			successUsed=self:UseCard(1)
		end
	end
	tap(1526,141)--退出策略卡界面
	return successUsed
end
function Skill:GetCardPos(index)
	return 240+index*200
end
function Skill:UseCard(index)
	sleepWithCheckLoading(200)
	if self:CheckCardLeft(index) then
		tap(1400,Skill:GetCardPos(index))--使用
		sleepWithCheckLoading(200)
		return true
	else
		if Setting.Skill.SupplyCard.card不足时购买 then
			if Setting.Main.Res.Diamond>50*index+50 then
				tap(1400,Skill:GetCardPos(index))--购买
				sleepWithCheckLoading(200)
				tap(970,650)--购买确认
				sleepWithCheckLoading(200)
				ShowInfo.RunningInfo("购买策略卡"..index)
				return true
			else
				ShowInfo.RunningInfo("钻石不足以购买策略卡"..index)
				return false
			end
		else
			return false
		end
	end
end
function Skill:CheckCardLeft(index)
	x, y = findColor({1310, Skill:GetCardPos(index), 1527, Skill:GetCardPos(index)+60}, 
	"0|0|0xfbc01d",
	90, 0, 0, 0)
	return (x>-1)
end
function Skill:SkillCanRelease()
		x, y = findColor({1098, 961, 1335, 1048}, 
	"0|0|0xfcc41d,126|28|0xf6ad17,16|29|0xf5ab18,102|9|0xf7b91d",
	95, 0, 0, 0)
	if x > -1 then
		return true
	else
		return false
	end
end
function Skill:RollToBegin()
	ShowInfo.RunningInfo("初始化技能")
	local tryTime=0
	while Skill:LastSkillPage() do
		mSleep(200)
		tryTime=tryTime+1
		if tryTime>10 then
			break
		end
	end
end
function Skill:SkillPageIsOn()
	x, y = findColor({1413, 1013, 1600, 1060}, 
	"0|0|0xcb9966,54|14|0x83725f,96|20|0xae8963",
	95, 0, 0, 0)
	if x > -1 then
		return true
	else
		return false
	end
end
function Skill:AtTopSkill()
		x, y = findColor({1860, 150, 1861, 200}, 
	"0|0|0x44413c",
	95, 0, 0, 0)
	if x > -1 then
		return false
	else
		ShowInfo.RunningInfo("到达顶部")
		return true
	end
end
function Skill:AtButtomSkill()
		x, y = findColor({1860, 800, 1861, 969}, 
	"0|0|0x44413c",
	95, 0, 0, 0)
	if x > -1 then
		return false
	else
		ShowInfo.RunningInfo("到达底部")
		return true
	end
end
function Skill:LastSkillPage()
	swip(1500,200,1500,900,5)
	return not Skill:AtTopSkill()
end
function Skill:NextSkillPage()
	swip(1500,900,1500, 200,5)
	return not self:AtButtomSkill()
end