
GameTask = {
	nowState=0,
}--初始化

function GameTask:new (o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end
function GameTask:Run()
	GameTask:AutoExitActivityForm()
	local times=0
	while self.Find()==true do
		times=times+1
		ShowInfo.RunningInfo("完成主线任务"..times)
	end
	self.CheckOtherTask()
	Form:Exit()
	GameTask:CollectMapEvent()
	GameTask:CheckUserMailMessage()
end
function GameTask:Find()
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
function GameTask:CheckOtherTask()
	if not Setting.Task.EnableOtherTask then
		return false
	end
	x, y = findColor({18, 217, 110, 325}, 
		"0|0|0xd00000,0|9|0xb60000",
		95, 0, 0, 0)
		if x > -1 then
			tap(x,y)
			sleepWithCheckLoading(500)
			local times=0
			while GameTask:FinishOtherTask() do
				times=times+1
				ShowInfo.RunningInfo("完成分支任务"..times)
			end
			return true
		else
			return false
		end
end
function GameTask:AutoExitActivityForm()
	if not Setting.Task.EnableAutoHandleActivity then
		return false
	end
	x, y = findColor({1563, 92, 1645, 168}, 
		"0|0|0x993434,0|20|0xf4fcff,-1|41|0x993333,-20|20|0x993434,21|16|0x993333",
		95, 0, 0, 0)
	if x > -1 then
		tap(x,y)
		sleepWithCheckLoading(500)
	end
end
function GameTask:CheckUserMailMessage()
	if not Setting.Task.EnableMailMessageHandle then
		return false
	end
		x, y = findColor({10, 330, 149, 462}, 
	"0|0|0xd00000,11|-3|0xd40000",
	95, 0, 0, 0)
	if x > -1 then
		ShowInfo.RunningInfo("处理新邮件")
	end
end
function GameTask:CollectMapEvent()
	if not Setting.Task.EnableCollectEvent then
		return false
	end
	local flag=true
	local times=0
	while flag do
			x, y = findColor({0, 2, 1919, 1079}, 
		"0|0|0xf7f7f7,5|61|0xd4d7de,93|65|0xd2d5dc,90|0|0xf6f6f6",
		95, 0, 0, 0)
		if x > -1 then
			tap(x,y)
			times=times+1
			ShowInfo.RunningInfo("收集到事件"..times)
			sleepWithCheckLoading(500)
			tap(x,y)
		else
			flag=false
		end
	end
end
function GameTask:FinishOtherTask()
	x, y = findColor({1313, 476, 1647, 1074}, 
		"0|0|0xfddc61,15|23|0x3e2f07,123|24|0x352706,155|4|0xfecb1d",
		95, 0, 0, 0)
	if x > -1 then
		tap(x,y)
		sleepWithCheckLoading(200)
		return true
	else
		return false
	end
end