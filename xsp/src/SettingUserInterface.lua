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
	self:BuildGeneralPage(ui)
	self:BuildSkillPage(ui)
	local p = ui:newPage("主城建设")
	self:BuildCityDevelopPriortyOption(p,"CityMain")
	p = ui:newPage("分城建设")
	p:addCheckBoxGroup_single(5,1,"CityOther.EnableIntelligenceTransportRescource","","资源平仓（未开放）")
	p:newLine()
	self:BuildCityDevelopPriortyOption(p,"CityOther")
	--p = ui:newPage("军团建设")
	self:BuildArmyPage(ui)
	self:BuildAboutPage(ui)
	self:BuildNoticePage(ui)

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
	Setting.Building.Interval=tonumber(result["Building.Interval"])
	Setting.Task.CollectEvent.Interval=tonumber(result["Task.CollectEvent.Interval"])
	Setting.Task.EnableAutoCompleteTask=result["UnitTaskRunEnable"]["自动结束任务"]
	Setting.Task.EnableAutoProcessTask=result["UnitTaskRunEnable"]["自动完成主线任务"]
	Setting.Task.EnableAutoProcessTaskDuplicate=result["UnitTaskRunEnable"]["防重复执行主线"]
	Setting.Task.EnableCollectEvent=result["UnitTaskRunEnable"]["收集野地事件"]
	Setting.Task.EnableActiveCollectEvent=result["UnitTaskRunEnable"]["主动收集野地事件"]
	--Setting.Task.EnableMailMessageHandle=result["UnitTaskRunEnable"]["处理邮件信息"]
	Setting.Task.EnableAutoHandleActivity=result["UnitTaskRunEnable"]["处理活动页"]
	
	UI:GetArmySetting(result)
	UI:GetSetting(result,"CityMain")
	UI:GetSetting(result,"CityOther")
	setNumberConfig("Skill.UsedSkillQueueNum",result["Skill.UsedSkillQueueNum"])
	printTable(ArmyList)
	return start,result
end
function UI:GetArmySetting(result)
	for k,v in pairs(result) do
		
	end
end
function UI:GetSetting(result,id)
	for k,v in pairs(result) do
		local startIndex=string.find(k,id) or 0
		local endIndex=string.len(id)+2
		
		if startIndex>0 then
			local settingInfo=split(k,".")
			local itemCity=settingInfo[2]
			if itemCity=="City" or itemCity=="Field" then
				local optionSetting=settingInfo[4]
				local itemTarget=settingInfo[5]
				local BuildingIndex=Setting.Building[itemCity.."Index"][itemTarget]
				if optionSetting=="Priority" then
					Setting.Building[itemCity][BuildingIndex][id=="CityMain" and 2 or 3]=v
				elseif optionSetting=="TargetRank" then 
					Setting.Building[itemCity][BuildingIndex][id=="CityMain" and 7 or 8]=v
				elseif optionSetting=="EnableBuild" then
					Setting.Building[itemCity][BuildingIndex][id=="CityMain" and 4 or 5]=(v=="0" and true or false)
				else
					dialog("设置错误")
					lua_exit()
				end

			else
				local selectValue=v=="0" and true or false
				Setting.Building[id.."Setting"][settingInfo[2]]=selectValue
				sysLog("Setting.Building."..id.."Setting."..settingInfo[2].."="..tostring(selectValue))
			end
		end
	end
end
local nowLineOptNum=0
function UI:BuildCityDevelopPriortyOption(p,TabId)
	local CityIndex=(TabId=="CityMain" and 2 or 3)
	p:addCheckBoxGroup_single(2.5,1,TabId..".EnableAutoDevelop","0","自动建设")
	p:addCheckBoxGroup_single(2.5,1,TabId..".EnableAutoProductSupply","","生产补给")
	p:addCheckBoxGroup_single(2.5,1,TabId..".EnableAutoRepair","","自动修理")
	p:addCheckBoxGroup_single(2.5,1,TabId..".EnableAutoConcilite","","自动安抚")
	p:newLine()
	p:addCheckBoxGroup_single(9,1,TabId..".SkipWhenHigherPriorityBuilingIsLackOfRescource","0","当优先级更高的建筑缺少资源时暂停其他建筑升级")
	p:newLine()
	p:addLabel(1,0.6,"城市建设",20)
	p:newLine()
	nowLineOptNum=0
	for buildIndex,buildingInfo in ipairs(Setting.Building.City) do
		UI:AddCityBuildingList(p,TabId,"City",buildingInfo[1],buildingInfo[CityIndex])
	end

	
	p:newLine()
	p:addLabel(1,0.6,"野地建设",20)
	p:newLine()
	nowLineOptNum=0
	for buildIndex,buildingInfo in ipairs(Setting.Building.Field) do
		UI:AddCityBuildingList(p,TabId,"Field",buildingInfo[1],buildingInfo[CityIndex])
	end
	
	p:newLine()
	p:newLine()
	nowLineOptNum=0
end
function UI:AddCityBuildingList(p,TabId,Aero,Name,defaultSelect)
	if Name=="none" then
		return false
	end
	nowLineOptNum=nowLineOptNum+1
	if nowLineOptNum>2 then
		nowLineOptNum=1
		p:newLine()
	end
	local buildEnable=""
	if defaultSelect<0 then
		buildEnable="1"
		defaultSelect=-defaultSelect
	else
		buildEnable="0"
	end
	p:addCheckBoxGroup_single(2,1,TabId.."."..Aero..".Develop.EnableBuild."..Name,buildEnable,Name)
	p:addComboBox(1,1,TabId.."."..Aero..".Develop.Priority."..Name,tostring(defaultSelect-1),{"1","2","3","4","5","6","7"})
	local BuildingIndex=Setting.Building[Aero.."Index"][Name]
	local rankList={}
	for i=0,Setting.Building[Aero][BuildingIndex][6] do
		table.insert(rankList,i)
	end
	p:addComboBox(1.5,1,TabId.."."..Aero..".Develop.TargetRank."..Name,tostring(Setting.Building[Aero][BuildingIndex][(TabId=="CityMain" and 7 or 8)]),rankList)
end
function UI:BuildGeneralPage(ui)
	local p = ui:newPage("通用")
	p:addLabel(1,0.6,"屏幕方向",20) 
	p:addComboBox(3,1,"orientation","0",{"Home键在右","Home键在左"})
	p:newLine()
	p:addLabel(1,1,"脚本间隔",20) 
	p:addComboBox(1.2,1,"Main.Interval","0",{"1","30","60","120","240","480","960","1920"})
	p:addLabel(1,1,"策略间隔",20) 
	p:addComboBox(1.2,1,"Skill.Interval","2",{"1","30","60","120","240","600","1500","3600"})
	p:newLine()
	p:addLabel(1,1,"建筑间隔",20) 
	p:addComboBox(1.2,1,"Building.Interval","0",{"1","30","60","120","240","600","1500","3600"})
	p:addLabel(1.2,1,"野外事件间隔",16) 
	p:addComboBox(1.2,1,"Task.CollectEvent.Interval","4",{"1","60","120","360","600","900","1200","1500","1800","2400","3000","3600"})
	p:newLine()
	p:addCheckBoxGroup(8,4,"UnitTaskRunEnable","0@1@2@3@4@5@6@7",{"处理活动页","自动结束任务","自动完成主线任务","防重复执行主线","收集野地事件","主动收集野地事件"})
	
--[[
	p:newLine()
	p:addLabel(1,1,"建设策略",20) 
	p:newLine()

	p:addCheckBoxGroup(8,1,"UnitCityRunEnable","0@1@2","城市建设","野地建设","军备生产")
	p:newLine()
	p:addCheckBoxGroup(8,1,"UnitAffairRunEnable","","打野","15叛","鹰")
	p:newLine()
	p:addCheckBoxGroup(8,1,"UnitWarRunEnable","","攻城","防御","增援军团","增援盟友")
	p:newLine()
	p:addLabel(1,1,"外交设置",20) 
	p:addCheckBoxGroup(8,1,"UnitPolicyRunEnable","0@1@2","同意所有同盟","同意所有中立") 
]]
end
function UI:BuildSkillPage(ui)
	local Skills={}
	local resSkills={}
	for key,item in pairs(skillList) do
		table.insert(Skills,key)
	end
	for key,item in pairs(Setting.Building.CityMainSetting.Supply) do
		table.insert(resSkills,key)
	end
	local p = ui:newPage("策略")
	p:newLine()
	p:addCheckBoxGroup(4,1,"UnitSkillRunEnable","0@1@2",{"策略点","策略使用"}) 
	p:newLine()
	p:addLabel(5,1,"当资源不足时释放策略（未开启）")
	p:newLine()
	p:addCheckBoxGroup(8,1,"Skill.CheckResource","",resSkills)
	p:newLine()
	p:addLabel(5,1,"当策略点不足时使用策略卡")
	p:newLine()
	p:addCheckBoxGroup(8,1,"Skill.SupplyCard",skillIndex,{"50","100","200","不足时购买"})
	p:newLine()
	local queueNum=getNumberConfig("Skill.UsedSkillQueueNum",1)
	p:addLabel(2.5,1,"策略队列数量")
	p:addComboBox(1,1,"Skill.UsedSkillQueueNum",queueNum,{"1","2","3","4","5","6","7","8","9","10"})
	p:newLine()
	local BuildSkillQueueSelect=function(index,skillIndex)
		p:addLabel(1.6,1,"策略队列"..index)
		p:addCheckBoxGroup_single(0.35,1,"Skill.Queue"..index..".Enable","1","t")
		p:addComboBox(2,1,"Skill.Queue"..index..".SkillIndex",skillIndex,Skills)
	end
	for i=1,queueNum do
		BuildSkillQueueSelect(i,getNumberConfig(i,0))
		p:newLine()
	end
end
function UI:BuildArmyPage(ui)
	p = ui:newPage("军事(未开放)")
	p:addCheckBoxGroup_single(4,1,"Military.EnableBuild",false,"启用军事生产/组建")
	p:newLine()
	self:BuildArmyList(p,"生产军备")	
	p:newLine()
	p:newLine()
	self:BuildArmyList(p,"组建部队")	
	p:newLine()
	p:newLine()
	p:addCheckBoxGroup_single(4,1,"Military.EnableExtract","1","启用拓展领土（未开启）")
end
function UI:BuildArmyList(p,id)
	nowArmyLineNum=0
	p:addLabel(10,1,id)
	p:newLine()
	for i,item in ipairs(ArmyList) do
		if	i % 3==1 and i>1 then
			p:newLine()
		end
		self:AddArmyList(p,id,item[1],true,0)
	end
end
local ArmyBuildNum={"0","50","100","200","400","800","1200","1600","2400","3600","5400","10000","15000","20000"}
function UI:AddArmyList(p,id,Name,enableBuildAll,defaultNum)
	if Name=="none" then
		return false
	end
	local buildEnable=""
	if enableBuildAll then
		buildEnable="0"
	else
		buildEnable="1"
	end
	
	p:addLabel(1.5,1,Name)
	
	if id=="组建部队" then
		p:addCheckBoxGroup_single(0.35,1,"Military.EnableBuildAll."..Name,buildEnable,"t")
		p:addComboBox(1.1,1,"Military.Build."..Name,defaultNum,ArmyBuildNum)
	else
		p:addComboBox(1.1,1,"Military.Manufacture."..Name,defaultNum,ArmyBuildNum)
	end
	
end
function UI:BuildAboutPage(ui)
	p = ui:newPage("关于")
	p:addLabel(10,1,"当前版本:"..Application.version.."\n更新日期:"..Application.updateDate,20)
	p:newLine()	
	p:addLabel(10,0.5,"用户屏幕:".._fsh.."*".._fsw..":".._userDpi,20,nil,(_fitScreen==true and "100,200,100" or "255,100,100")) 
	p:newLine()
	p:addLabel(10,0.5,"欢迎使用本脚本,目前尚处于开发阶段,交流群:"..Application.groupQQ..",进群备注游戏id",20,nil,"255,0,0") 
	p:newLine()
	p:addLabel(10,5,"更新信息:\n"..table.concat(Application.UpdateInfo,"\n"),20,nil,"100,150,100") 
	p:newLine()	
	for j=1,1 do
	for i,item in ipairs(Application.ProcessInfo) do
		if item[1]==1 then
			p:addImage(0.3,0.3,(item[1]==1 and "Process.Completed.png"))
		else if item[1]==0 then
				p:addImage(0.3,0.3,(item[1]==0 and "Process.Processing.png"))
			else if item[1]==-1 then
					p:addImage(0.3,0.3,(item[1]==-1 and "Process.Closed.png"))
				else
					
				end
			end
		end
		p:addLabel(10,0.5,item[2],24,nil,"100,100,150") 
		p:newLine()	
	end
	end
	p:newLine()	
	p:addLabel(10,0.5,"power by "..Application.author.." on xxScript.lua.[2.0.1.3]",10)
	
end
function UI:BuildNoticePage(ui)
	notice,exception=getCloudContent("二战风云","984E2B3BE7D74DB5")
	if exception == 0 then
	  
	lines=split(notice,'\n')
	for i,info in ipairs(lines) do
		sysLog(info)
		local newPageCheck=string.find(info,"<page>") or 0
		if newPageCheck>0 then 
			p=ui:newPage(string.sub(info,newPageCheck+6))
		else
			local newImgCheck=string.find(info,"<img>") or 0
			if newImgCheck>0 then
				local imgInfo=string.sub(info,newImgCheck+5)
				local imgSize=string.find(imgInfo,"###") or 0
				if imgSize>0 then
					local imgSizeInfo=split(string.sub(imgInfo,1,imgSize),"##")
					imgW,imgH,url=imgSizeInfo[1],imgSizeInfo[2],string.sub(imgInfo,imgSize+3,string.len(imgInfo))
				else
					imgW,imgH,url=1,1,imgInfo
				end
				sysLog(imgW..",,,,"..imgH..",,,,"..url)
				p:addImage(imgW,imgH,url)
			else
				p:addLabel(10,0.6,info,20) 
				
			end
			p:newLine()
		end
	end
	  
	elseif exception == 1 then
	  p=ui:newPage("<网络异常>")
	elseif exception == 999 then
	  p=ui:newPage("<未知错误>")
	end
end