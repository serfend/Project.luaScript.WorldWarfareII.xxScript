
MainTask = {
	nowState=0,
	MainThreadTaskRefresh=true,
	MainTaskInfo="",MainTaskRequire=0,MainTaskNowAttain=0,
	
	nextTimeCompleteTaskEnableMergeArmy=false,--当任务完成时激活合并单位
	

}--初始化

function MainTask:new (o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

function MainTask:BuidlingIsOnProcess()
	x, y = findColor({533, 925, 1374, 1070}, 
	"0|0|0x301c15,11|11|0xc8c5be,28|23|0xa39c95,42|39|0xcbc8bf,54|47|0xd6d3d2,70|60|0xada99b,82|68|0x392b26,93|81|0x75493b,94|3|0x8e5747,71|24|0x8d5746,61|32|0x3b251d,49|39|0xcbc8bf,38|47|0x442a21,22|57|0x79483b,3|73|0x939085",
	90, 0, 0, 0)
	if x > -1 then
		return true
	else
		return false
	end
end
local CheckMainTaskTimes=0--第5次检查时强制检查任务完成情况
function MainTask:MainTask()
	if not self.MainThreadTaskRefresh then
		if CheckMainTaskTimes<5 then 
			ShowInfo.RunningInfo("上一任务正在完成中")
			CheckMainTaskTimes=CheckMainTaskTimes+1
			return false
		else
			CheckMainTaskTimes=0
			if Setting.Task.EnableAutoProcessTaskDuplicate then
				return false
			end
		end
	end
	if Task:Enter(true) then--强制进入
		keepScreen(true)
		self.MainTaskNowAttain,self.MainTaskRequire=Task:GetTaskInfo()
		keepScreen(false)
		
		Form:Exit()
		mSleep(200)
		tap(418,273)--任务提示
		local success=Task:MainTaskProcess(self.MainTaskNowAttain,self.MainTaskRequire,1)
		
	end
	
	return success or false
end

function MainTask:Run()
	local times=0
	local AnyTaskComplete=false
	while MainTask:Find()==true do
		times=times+1
		self.MainThreadTaskRefresh=true
		ShowInfo.RunningInfo("完成主线任务"..times)
		AnyTaskComplete=true
	end
	if Setting.Task.EnableAutoCompleteTask then
		if Task:Enter() then
			Task:CheckTask("OtherTask")
		end
	end
	if self.nextTimeCompleteTaskEnableMergeArmy and AnyTaskComplete then
		conscript.nextTimeNeedMerge=1--完成任务后立即合并以减少队列占用
		self.nextTimeCompleteTaskEnableMergeArmy=false
	end
	Form:Exit()
	
	mapEvent:CollectMapEvent()
	--self:CheckUserMailMessage()
	
	--最后开始以防干扰
	if Setting.Task.EnableAutoProcessTask then
		ShowInfo.RunningInfo("自动任务进程开始")
		return self:MainTask()
	else
		ShowInfo.RunningInfo("自动任务进程被禁用")
	end
end
function MainTask:Find()
	x, y = findColor({780, 665, 1147, 774}, 
"0|0|0xfbc01d,2|48|0xf6ab14,224|51|0xf9b90d,224|0|0xfbc01d,129|21|0x231e12",
95, 0, 0, 0)

	if x > -1 then
		tap(x,y)
		sleepWithCheckLoading(500)
		return true
	else
		return false
	end
end




