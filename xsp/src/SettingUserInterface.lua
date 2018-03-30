UI = {
	nowState=0,
}--初始化
function UI:new (o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

function UI:show(citylist,skillSetting)
	local ui = require "bblibs.G_ui"

	ui:new(_fsh,_fsw)

	local p = ui:newPage("通用")
	p:newLine()
	p:addLebel(1,0.6,"屏幕方向",20) 
	p:addComboBox(3,1,"orientation","0","Home键在右","Home键在左")
	p:newLine()
	p:addLebel(1,1,"脚本间隔",20) 
	p:addEdit(1.2,0.8,"Main.Interval","120","","number",16)
	p:addLebel(1,1,"策略间隔",20) 
	p:addEdit(1.2,0.8,"Skill.Interval","600","","number",16)
	p:newLine()
	p:addCheckBoxGroup(8,1,"UnitTaskRunEnable","0@1@2@3","自动处理活动页","完成分支任务","收集野地事件","处理邮件信息")
	p:newLine()
	p:addCheckBoxGroup(8,1,"UnitSkillRunEnable","0@1@2","策略点","策略使用") 
	p:newLine()
	p:addCheckBoxGroup(8,1,"使用策略","","军费","钢铁","橡胶","石油","人口")
	p:newLine()
	p:addLebel(1,1,"建设设置",20) 
	p:newLine()

	p:addCheckBoxGroup(8,1,"UnitCityRunEnable","0@1@2","城市建设","野地建设","军备生产")
	p:newLine()
	p:addCheckBoxGroup(8,1,"UnitAffairRunEnable","","打野","15叛","鹰")
	p:newLine()
	p:addCheckBoxGroup(8,1,"UnitWarRunEnable","","攻城","防御","增援军团","增援盟友")
	p:newLine()
	p:addLebel(1,1,"外交设置",20) 
	p:addCheckBoxGroup(8,1,"UnitPolicyRunEnable","0@1@2","同意所有同盟","同意所有中立") 

	local p = ui:newPage("城市未开放")
	
	p:newLine()
	p:addLebel(2,1,"单人设置:") 
	local b = p:newBox(10,0.5)
	b:addCheckBoxGroup(8,7,"单人设置","0@1@2@3","自动退队")
	p:newLine()
	p:addLebel(2,1,"主线选项:") 
	p:newLine()
	p:addLebel(2,1,"日常选项:") 
	p:newLine()
	
	p = ui:newPage("城市未开放")
	
	start,result= ui:show()
	printTable(result)
	if start==0 then
		lua_exit()
		return false
	end
	if result["orientation"]=="Home键在右" then
		_orientation=1
	else
		_orientation=2
	end
	init("0", _orientation)--初始化触摸操控脚本
	Setting.Main.Interval=tonumber(result["Main.Interval"])
	Setting.Skill.Interval=tonumber(result["Skill.Interval"])
	
	Setting.Task.EnableOtherTask=result["UnitTaskRunEnable"]["完成分支任务"]
	Setting.Task.EnableCollectEvent=result["UnitTaskRunEnable"]["收集野地事件"]
	Setting.Task.EnableMailMessageHandle=result["UnitTaskRunEnable"]["处理邮件信息"]
	Setting.Task.EnableAutoHandleActivity=result["UnitTaskRunEnable"]["自动处理活动页"]
	return start,result
end