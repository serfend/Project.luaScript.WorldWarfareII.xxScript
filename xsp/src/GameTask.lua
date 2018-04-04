
GameTask = {
	nowState=0,
	MainThreadTaskRefresh=true,
}--初始化

function GameTask:new (o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end
function GameTask:MainTaskProcess()
	local lastX,lastY=-1,-1
	for i=1,10 do
		local nowX,nowY=GameTask:GetNowTipPos()
		if nowY>lastY and nowY>-1 then
			lastX=nowX
			lastY=nowY
		end
		mSleep(50)
	end
	ShowInfo.RunningInfo(lastX..","..lastY)
	if lastX>-1 then
		tap(lastX,lastY)
		self:MainTaskProcess()
	else
		Form:Submit()
		sleepWithCheckLoading(200)
		if not GameTask:BuidlingIsOnProcess() then
			if not Form:BuildAtMap() then
				if not Form:Submit() then
					if not Form:Build() then
						ShowInfo.RunningInfo("自动处理失败")
						return false
					end
				end
			end
		else
			ShowInfo.RunningInfo("任务已提交")
		end
		self.MainThreadTaskRefresh=false
		return true
	end
end
function GameTask:BuidlingIsOnProcess()
	x, y = findColor({533, 925, 1374, 1070}, 
	"0|0|0x301c15,11|11|0xc8c5be,28|23|0xa39c95,42|39|0xcbc8bf,54|47|0xd6d3d2,70|60|0xada99b,82|68|0x392b26,93|81|0x75493b,94|3|0x8e5747,71|24|0x8d5746,61|32|0x3b251d,49|39|0xcbc8bf,38|47|0x442a21,22|57|0x79483b,3|73|0x939085",
	90, 0, 0, 0)
	if x > -1 then
		return true
	else
		return false
	end
end
function GameTask:MainTask()
	if self.MainThreadTaskRefresh==false then 
		ShowInfo.RunningInfo("上一任务正在完成中")
		return false
	end
	tap(415,275)
	local success=self:MainTaskProcess()
	Form:Exit()
	return success
end
local TipDirection=1
local TipDirectionUsed=2
TipDirectionData={
	[1]="0|0|0x679077,12|-19|0xcbeded,30|-34|0xc2ebeb,47|-47|0xafe4e4,37|-62|0xd8f2f2,71|-27|0xe3f6f6,89|-42|0xeff9f9,51|-85|0xffffff",--左下
	[2]="0|0|0xa9ccbf,5|-5|0x76ad97,22|7|0xacd0c4,15|15|0xacd8d1,42|30|0xd0efef,31|42|0xc1eaea",--左上
	[3]="",--右下
	[4]="",--右上
}
function GameTask:GetNowTipPos()
	local x,y=0,0
	local tryTime=0
	while tryTime<TipDirectionUsed do
		sysLog("direction"..TipDirection)
		x,y = findColor({0, 0, 1920, 1080}, 
			TipDirectionData[TipDirection],
			95, 0, 0, 0)
		if x<0 then
			tryTime=tryTime+1
			TipDirection=math.mod(TipDirection,TipDirectionUsed)+1
			
		else
			break
		end
	end

	return x,y
end
function GameTask:Run()
	GameTask:AutoExitActivityForm()
	local times=0
	while GameTask:Find()==true do
		times=times+1
		self.MainThreadTaskRefresh=true
		ShowInfo.RunningInfo("完成主线任务"..times)
	end
	if Setting.Task.EnableAutoCompleteTask then
		self:CheckTask("OtherTask")
	end
	Form:Exit()
	self:CollectMapEvent()
	self:CheckUserMailMessage()
	
	--最后开始以防干扰
	if Setting.Task.EnableAutoProcessTask then
		ShowInfo.RunningInfo("自动任务进程开始")
		self:MainTask()
	else
		ShowInfo.RunningInfo("自动任务进程被禁用")
	end
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
local TaskType={
	MainTask={228,382},
	OtherTask={476,1074}
}
function GameTask:CheckTask(taskType)
	x, y = findColor({18, 233, 110,316 }, 
		"0|0|0xd00000,0|9|0xb60000",
		95, 0, 0, 0)
		if x > -1 then
			tap(x,y)
			sleepWithCheckLoading(500)
			local times=0
			while GameTask:FinishTask(TaskType[taskType][1],TaskType[taskType][2]) do
				times=times+1
				if taskType=="MainTask" then
					self.MainThreadTaskRefresh=true
				end
				ShowInfo.RunningInfo("完成"..taskType.."任务"..times)
			end
			return true
		else
			return false
		end
end
function GameTask:FinishTask(beginY,endY)
	x, y = findColor({1313, beginY, 1647, endY}, 
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
		ShowInfo.RunningInfo("跳过处理新邮件")
		return false
	end
		x, y = findColor({10, 330, 149, 462}, 
	"0|0|0xd00000,11|-3|0xd40000",
	95, 0, 0, 0)
	if x > -1 then
		ShowInfo.RunningInfo("处理新邮件")
		tap(x,y)
		sleepWithCheckLoading(500)
			x, y = findColor({1481, 68, 1600, 976}, 
		"0|0|0xe1ffff,9|6|0xd5ffff,14|6|0x7aaabf,29|-5|0xcbe3e9,20|-8|0xa7c3d2,6|-12|0xe5f2f5",
		90, 0, 0, 0)
		if x > -1 then
			ShowInfo.RunningInfo("有附件,领取...")
			tap(211,1033)--一键领取
			sleepWithCheckLoading(500)
			tap(955,962)--确定
		else
			tap(349,33)
		end
		sleepWithCheckLoading(500)
		Form:Exit()
	else
		
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
			tap(800,1000)--关闭对话框
			if times>5 then
				break
			end
		else
			flag=false
		end
	end
end
