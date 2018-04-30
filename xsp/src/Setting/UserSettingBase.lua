SettingBase={
	settingNum=0,settings={},
	ui={},p={},
	indexQueue={},
}
local randomId=0
function SettingBase:Add(itemName,itemUsing,itemKeep,itemIndex)--添加新项目
	itemIndex=itemIndex or (#self.settings+1)
	sysLog("Add"..itemIndex..","..tostring(itemKeep))
	local tmp={name=itemName,using=itemUsing,keepInBase=itemKeep,newIndex=itemIndex}
	table.insert(self.settings,tmp)
	return tmp
end
function SettingBase:Remove(index)--移除现有项目,下次将不会加载
	self.settings[index].keepInBase=false
end
function SettingBase:Move(index,newIndex)--修改项目排序
	self.settings[index].newIndex=newIndex
end
function SettingBase:Refresh()--重置生效新的排序和数据
	local tmpSettingBase={}
	local totalSettingNum=#self.settings
	for i=1,totalSettingNum do
		if self.settings[i].newIndex==tostring(i) or self.settings[i].keepInBase==false then
			--序号未修改或已被删除则不处理
		elseif self.settings[i].keepInBase then
			local item=self.settings[i]
			local redictIndex=tonumber(item.newIndex)
			while tmpSettingBase[redictIndex]~=nil do--避免用户是个傻子的情况下出BUG的可能
				redictIndex=redictIndex+1
			end
			tmpSettingBase[redictIndex]=item
			sysLog("移动序号:"..i.."->"..redictIndex)
		end
	end
	local nowFreeIndex=1
	for i=1,totalSettingNum do
		if self.settings[i].keepInBase and self.settings[i].newIndex==tostring(i) then--添加其他未修改的项目进表
			local item=self.settings[i]
			while tmpSettingBase[nowFreeIndex]~=nil do
				nowFreeIndex=nowFreeIndex+1
			end
			sysLog("添加"..i.."->"..nowFreeIndex)
			tmpSettingBase[nowFreeIndex]=item
		end
	end

	self:Save(tmpSettingBase,nowFreeIndex)
	return tmpSettingBase
end
function SettingBase:Save(base,length)
	setNumberConfig("SettingBase.SettingNum",length)
	sysLog("保存总项目:"..length)
	for i=1,length do
		self:SaveSingleSetting(i,base[i])
	end
end
function SettingBase:SaveSingleSetting(index,setting)
	setStringConfig("SettingBase."..index..".name",setting.name)
	setNumberConfig("SettingBase."..index..".using",(setting.using and 1 or 0))
	setNumberConfig("SettingBase."..index..".keepInBase",(setting.keepInBase and 1 or 0))
end
function SettingBase:new (o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	
	self.settings={}
	self.indexQueue={}
	randomId=tostring(os.time())
	
	self.settingNum=getNumberConfig("SettingBase.SettingNum",0)
	for i=1,self.settingNum do
		local thisName=getStringConfig("SettingBase."..i..".name",i.."号设置")
		local thisUsing=getNumberConfig("SettingBase."..i..".using",0)
		local thisKeepInBase=getNumberConfig("SettingBase."..i..".keepInBase",0)
		self:Add(thisName,(thisUsing==1),(thisKeepInBase==1))
	end
	local tmpSetting=self:Add("新增设置名称",false,false)
	self:SaveSingleSetting(self.settingNum+1,tmpSetting)
	
	self.ui = require "bblibs.G_ui"
	self.ui:new(_fsh,_fsw,"确定","取消")
	self.p=self.ui:newPage("设置选择")
	return o
end
function SettingBase:SwitchSetting()
	self.p:addLabel(3,1,"当前使用设置")
	local loadSettingName={}
	for i=1,self.settingNum+1 do 
		if self.settings[i].using then 
			table.insert(loadSettingName,self.settings[i].name)
		end
		table.insert(self.indexQueue,tostring(i)) 
	end
	self.p:addComboBox(3,1, "SettingSelect."..randomId,"0",loadSettingName)
	self.p:newLine()
	self.p:newLine()
	self.p:addLabel(3,1,"设置库")
	self.p:newLine()
	self.p:addLabel(1,0.6,"序号",20,"center")
	self.p:addLabel(3,0.6,"设置名称",20,"center")
	self.p:addLabel(0.8,0.6,"使用",20)
	self.p:addLabel(0.8,0.6,"保存",20)
	
	for i=1,self.settingNum+1 do
		self:BuildSettingOption(i)
	end
	start,result= self.ui:show()
	local flag=start==1
	if flag then local newSettingNames=self:GetSetting(result) end
	return flag
end
function SettingBase:GetSetting(result)
	for k,v in pairs(result) do
		local tmp=split(k,".")
		if tmp[1]=="Setting" then
			local selectIndex=tonumber(tmp[2])
			local selectSettingOption=tmp[3]
			if tmp[3]=="name" then
				self.settings[tonumber(selectIndex)][tmp[3]]=v or "未命名设置"
			elseif tmp[3]=="newIndex" then
				self.settings[tonumber(selectIndex)][tmp[3]]=v
			elseif tmp[3]=="keepInBase" then
				self.settings[tonumber(selectIndex)][tmp[3]]=(v=="0" and true or false)
			elseif tmp[3]=="using" then
				self.settings[tonumber(selectIndex)][tmp[3]]=(v=="0" and true or false)
			else
				dialog("SettingBase:GetSetting().未知的设置"..k)
			end
			--sysLog("settings["..selectIndex.."]["..tmp[3].."]="..tostring(v))
		elseif tmp[1]=="SettingSelect" then
			setStringConfig("UserSettingBase",v)
		else
		
		end
	end
	return self:Refresh()
end

function SettingBase:BuildSettingOption(index)
	self.p:newLine()
	local SettingIndex="Setting."..index
	self.p:addComboBox(1,1,SettingIndex..".newIndex."..randomId,tostring(index-1),self.indexQueue)
	self.p:addEdit(3,1,SettingIndex..".name."..randomId,self.settings[index].name,nil,"utf-8",20,"center")
	self.p:addCheckBoxGroup_single(0.8,1,SettingIndex..".using."..randomId,self.settings[index].using and "0" or "")
	self.p:addCheckBoxGroup_single(0.8,1,SettingIndex..".keepInBase."..randomId,self.settings[index].keepInBase and "0" or "")
end