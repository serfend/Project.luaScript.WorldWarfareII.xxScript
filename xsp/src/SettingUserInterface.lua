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
	UI:BuildGeneralPage(ui)
	local p = ui:newPage("主城建设")
	UI:BuildCityDevelopPriortyOption(p,"CityMain")
	p = ui:newPage("分城建设")
	p:addCheckBoxGroup_single(3,1,"CityOther.EnableTransportRescouseToMainCity","","运输资源到主城")
	UI:BuildCityDevelopPriortyOption(p,"CityOther")
	--p = ui:newPage("军团城市(未开放)")
	UI:BuildAboutPage(ui)
	UI:BuildNoticeage(ui)
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
	UI:GetSetting(result,"CityMain")
	UI:GetSetting(result,"CityOther")
	return start,result
end
function UI:GetSetting(result,id)
	local tmp={}
	for k,v in pairs(result) do
		local startIndex=string.find(k,id) or 0
		local endIndex=string.len(id)+2
		
		if startIndex>0 then
			local itemKey=string.sub(k,endIndex,string.len(k))
			local itemCity_Index=string.find(itemKey,"%p")
			itemCity_Index=(itemCity_Index or 2) -1
			local itemCity=string.sub(itemKey,1,itemCity_Index)
			local itemSetting=string.sub(itemKey,itemCity_Index+2,string.len(itemKey))
			if itemCity=="City" or itemCity=="Field" then
				local PrioritySetting=string.find(itemSetting,"Priority") or -1
				local isPrioritySetting=PrioritySetting>0
				local itemTarget_Index=string.find(itemSetting,"%p",9)
				local itemTarget=string.sub(itemSetting,itemTarget_Index+1,string.len(itemSetting))
				
				local BuildingIndex=Setting.Building[itemCity.."Index"][itemTarget]
				if isPrioritySetting==true then
					Setting.Building[itemCity][BuildingIndex][id=="CityMain" and 2 or 3]=v
				else
					Setting.Building[itemCity][BuildingIndex][id=="CityMain" and 4 or 5]=v[itemTarget]
				end

			else
				local value=getTableFirstValue(v) or false
				
				Setting.Building[id.."Setting"][itemKey]=value
				sysLog("Setting.Building."..id.."Setting."..itemKey.."="..tostring(value))
			end
		end
	end
end
local nowLineOptNum=0
function UI:BuildCityDevelopPriortyOption(p,TabId)
	p:addCheckBoxGroup_single(2,1,TabId..".EnableAutoDevelop","","自动建设")
	p:newLine()
	p:addLebel(1,0.6,"城市建设",20)
	p:newLine()
	nowLineOptNum=0
	for buildIndex,buildingInfo in ipairs(Setting.Building.City) do
		UI:AddCityBuildingList(p,TabId..".City",buildingInfo[1],buildingInfo[2])
	end

	
	p:newLine()
	p:addLebel(1,0.6,"野地建设",20)
	p:newLine()
	nowLineOptNum=0
	for buildIndex,buildingInfo in ipairs(Setting.Building.Field) do
		UI:AddCityBuildingList(p,TabId..".Field",buildingInfo[1],buildingInfo[3])
	end
	
	p:newLine()
	p:newLine()
	nowLineOptNum=0
end
function UI:AddCityBuildingList(p,TabId,Name,defaultSelect)
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
	p:addCheckBoxGroup_single(1.8,1,TabId..".Develop.EnableBuild."..Name,buildEnable,Name)
	p:addLebel(0.8,1,"优先")
	p:addComboBox(1.1,1,TabId..".Develop.Priority."..Name,tostring(defaultSelect),"1","2","3","4","5","6","7")
end
function UI:BuildGeneralPage(ui)
	local p = ui:newPage("通用")
	p:addLebel(1,0.6,"屏幕方向",20) 
	p:addComboBox(3,1,"orientation","0","Home键在右","Home键在左")
	p:newLine()
	p:addLebel(1,1,"脚本间隔",20) 
	p:addEdit(1.2,0.8,"Main.Interval","120","","number",16)
	p:addLebel(1,1,"策略间隔",20) 
	p:addEdit(1.2,0.8,"Skill.Interval","600","","number",16)
	p:newLine()
	p:addCheckBoxGroup(8,2,"UnitTaskRunEnable","0@1@2@3","自动处理活动页","完成分支任务","收集野地事件","处理邮件信息")
	p:newLine()
	p:addCheckBoxGroup(8,1,"UnitSkillRunEnable","0@1@2","策略点","策略使用") 
	p:newLine()
	p:addCheckBoxGroup(8,1,"使用策略","","军费","钢铁","橡胶","石油","人口")
--[[
	p:newLine()
	p:addLebel(1,1,"建设策略",20) 
	p:newLine()

	p:addCheckBoxGroup(8,1,"UnitCityRunEnable","0@1@2","城市建设","野地建设","军备生产")
	p:newLine()
	p:addCheckBoxGroup(8,1,"UnitAffairRunEnable","","打野","15叛","鹰")
	p:newLine()
	p:addCheckBoxGroup(8,1,"UnitWarRunEnable","","攻城","防御","增援军团","增援盟友")
	p:newLine()
	p:addLebel(1,1,"外交设置",20) 
	p:addCheckBoxGroup(8,1,"UnitPolicyRunEnable","0@1@2","同意所有同盟","同意所有中立") 
]]
end
function UI:BuildAboutPage(ui)
	p = ui:newPage("关于")
	p:addLebel(10,1,"当前版本:"..Application.version.."\n更新日期:"..Application.updateDate,20)
	p:newLine()	
	p:addLebel(10,0.5,"欢迎使用本脚本,目前尚处于开发阶段",20) 
	p:newLine()
	p:addLebel(10,0.5,"交流群:"..Application.groupQQ..",进群备注游戏id",20,nil,"255,0,0") 
	p:newLine()
	p:addLebel(10,15,"更新信息:\n"..table.concat(Application.UpdateInfo,"\n"),20,nil,"100,150,100") 
	p:newLine()	
	p:addLebel(10,0.5,"power by "..Application.author.." on xxScript.lua.[2.0.1.3]",10)
	
end
function UI:BuildNoticeage(ui)
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
				p:addLebel(10,0.6,info,20) 
				
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