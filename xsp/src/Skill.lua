
Skill = {
	nowState=0,UserEnableAutoCollect=false,
	useSkills={},NowSkillNum=0,UserEnableUseSkill=false,
}--初始化
 	posX=1360
	beginY,endY=980,150
function Skill:new (o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end
function Skill:setUseSkill(userSetting)
	local newSkillList=userSetting["使用策略"]
	self.useSkills={}
	self.NowSkillNum=0
	for k,v in pairs(newSkillList) do
		self.NowSkillNum=self.NowSkillNum+1
		self.useSkills[self.NowSkillNum]=tostring(k)
	end
	self.UserEnableAutoCollect =userSetting["UnitSkillRunEnable"]["策略点"]==true
	self.UserEnableUseSkill =userSetting["UnitSkillRunEnable"]["策略使用"]==true
end
function Skill:Run()
	sleepWithCheckLoading(500)
	Skill:CheckIfAnySkillBeenSelect()
	if self:NeedRefresh() then
		if self:Enter() then
			if self.UserEnableAutoCollect then 
				self:CheckNewSkillPoint()			
				self:Exit()
			else
				ShowInfo.RunningInfo("技能点获取被禁用")
			end
			if self.UserEnableUseSkill then
				self:UseSkills()
				self:Exit()
			else
				ShowInfo.RunningInfo("技能使用被禁用")
			end
			self:Exit()
		else
			if self:Exit() then
				sysLog("初始化技能失败!")
			end
			sleepWithCheckLoading(500)
			return self:Run()
		end
		
	else
		ShowInfo.RunningInfo("技能无需检查")
	end
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
		ShowInfo.RunningInfo("获取技能点")
		tap(x,y)
		return true
	else
		ShowInfo.RunningInfo("暂无技能点可获取")
		return false
	end
end
lastAttainPoint=0
function Skill:NeedRefresh()
	local nowTime=os.time()
	local interval=nowTime-lastAttainPoint
	local flag=false
	if interval>Setting.Skill.Interval then
		flag=true
		lastAttainPoint=nowTime
	end
	return flag;
end
function Skill:CheckIfAnySkillBeenSelect()
	tap(1314,836)
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
	
	x,y=Skill:FindSkillPoint1()
	
	if x>-1 then
		Skill.nowState=1
		tap(x,y)
		sleepWithCheckLoading(500)
		return true
	else
		if self:Exit() then
			sleepWithCheckLoading(1500)
			return self:Enter()
		else
			sysLog("未找到技能块")
		end
		return false
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
--[[
	1-5:军费,钢铁,橡胶,石油,人口
]]
skillList={
	["军费"]="0|0|0xffffcc,8|16|0xffffcc,20|19|0xffffcc,36|24|0xfefecb,46|13|0xffffcc,65|16|0xffffcc,82|13|0xffffcc,102|6|0xfafac8,110|16|0xffffcc,139|8|0xffffcc",
	["钢铁"]="0|0|0xffffcc,2|10|0xfefecb,2|19|0xfdfdca,19|15|0xffffcc,28|14|0xffffcc,42|16|0xfcfcca,62|17|0xffffcc,84|12|0xfefecc,110|8|0xfefecc,128|20|0xffffcc",
	["橡胶"]="0|0|0xffffcc,30|5|0xffffcc,5|8|0xfdfdca,87|16|0xffffcc,119|19|0xffffcc,128|20|0xffffcc,8|14|0xfbfac8,-10|11|0xffffcc,50|20|0xffffcc,76|6|0xffffcc",
	["石油"]="0|0|0xffffcc,-4|27|0xffffcc,18|27|0xffffcc,75|26|0xffffcc,55|26|0xffffcc,96|10|0xffffcc,129|14|0xffffcc,137|-5|0xffffcc,79|-3|0xfefecb,52|4|0xffffcc",
	["人口"]="0|0|0xffffcc,-14|31|0xffffcc,16|29|0xffffcc,46|32|0xffffcc,86|19|0xffffcc,137|16|0xffffcc,98|7|0xffffcc,82|-1|0xffffcc,50|9|0xffffcc,2|12|0xffffcc",
}

function Skill:UseSkills()
	sleepWithCheckLoading(500)
	ShowInfo.RunningInfo("使用技能...")
	printTable(self.useSkills)
	for i,skill in ipairs(self.useSkills) do
		Skill:Enter()
		Skill:RollToBegin()
		Skill:UseSkill(skill)
	end
end
function Skill:UseSkill(index)
	
	local skillPos=skillList[index]
	local findSkill=false
	while not findSkill
	do
		sleepWithCheckLoading(500)
		ShowInfo.RunningInfo("使用技能"..index)
		local x, y = findColor({posX, endY, 1920, beginY}, 
		skillList[index],
		90, 0, 0, 0)
		if x > -1 then
			findSkill=true
			if Skill:CheckPointNotEnough(y) then
				ShowInfo.RunningInfo("技能"..index.."策略值不足")
				return false
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
			self.NextSkillPage()
			if Skill:AtButtomSkill() then 
				ShowInfo.RunningInfo("未找到技能"..index)
				return false
			end
		end
	end
	return true
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
	while not Skill:AtTopSkill() do
		Skill:LastSkillPage()
	end
end
function Skill:AtTopSkill()
		x, y = findColor({1361, 167, 1907, 260}, 
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
		x, y = findColor({1361, 800, 1907, 969}, 
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
	swip(posX,endY,posX,beginY,10)
end
function Skill:NextSkillPage()
	swip(posX,beginY,posX, endY,10)
end