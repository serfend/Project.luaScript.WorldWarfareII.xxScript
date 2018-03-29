
Skill = {
	nowState=0,
}--初始化
 	posX=1000
	beginY,endY=600,200
function Skill:new (o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

function Skill:FindSkillPoint1()
		x, y = findColor({1200, 550, 1261, 605}, 
			"0|0|0xe0e0d5,53|41|0xb8b8af,29|18|0x8b5c2d",
			95, 0, 0, 0)
		return x,y	
end
function Skill:CheckNewSkillPoint()
	x, y = findColor({1158, 27, 1263, 60}, 
		"0|0|0xc00000",
		95, 0, 0, 0)
	if x > -1 then
		ShowInfo.RunningInfo("获取技能点")
		tap(x,y)
		return true
	else
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
function Skill:Enter()
	ShowInfo.RunningInfo("打开技能")
	x,y=Skill:FindSkillPoint1()
	
	if x>-1 then
		Skill.nowState=1
		tap(x,y)
		mSleep(200);
		return true
	else
		sysLog("未找到技能块")
		return false
	end
end
function Skill:Exit()
	ShowInfo.RunningInfo("关闭技能")
	if Skill.nowState==0 then
		return true
	end
	x, y = findColor({842, 300, 902, 420}, 
		"0|0|0x958b7d,7|26|0x82796b",
		95, 0, 0, 0)
	if x > -1 then
		tap(x,y)
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
	"0|0|0x4e4a45,12|0|0x54504a,28|0|0x4c4843,38|0|0xffffcc,58|6|0xa4a185,74|5|0xeeeebf,95|5|0x4e4944,104|8|0xffffcc,93|15|0x4b4b3c,74|18|0x99977e",
	"",
	"0|0|0x544f49,10|2|0xbab997,15|2|0x8e8e73,23|1|0x272521,32|0|0xfefecb,42|0|0x7f7c6a,67|10|0xe4e4b7,82|5|0x544f49,100|4|0xf8f8c6,104|16|0xe7e7b9,94|16|0xffffcc,65|18|0x10100d,54|19|0x777363,43|16|0x736f61,24|14|0x37352f,12|13|0x2f2f26",
	"",
	""
}
function Skill:UseSkills(SkillIndexes)
	Skill:RollToBegin()
	for i,skill in ipairs(SkillIndexes) do
		Skill:UseSkill(skill)
	end
end
function Skill:UseSkill(index)
	local skillPos=skillList[index]

	local x, y = findColor({904, 100, 1272, 650}, 
	skillList[index],
	90, 0, 0, 0)
	if x > -1 then
		if index<=4 then --资源策略
			ShowInfo.RunningInfo("使用技能"..index)
			
		else
			ShowInfo.RunningInfo("不支持的策略"..index)
		end
	end
end
function Skill:RollToBegin()
	ShowInfo.RunningInfo("初始化技能")
	for i=0,5 do
		self.LastSkillPage()
	end
	mSleep(500)
end
function Skill:LastSkillPage()
	swip(posX,endY,posX,beginY)
end
function Skill:NextSkillPage()
	swip(posX,beginY,posX, endY)
end