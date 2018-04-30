ForkTask={
	nowState=0,
	ThreadTaskRefresh=true,
	TaskInfo="",TaskRequire=0,TaskNowAttain=0,
}
function ForkTask:new (o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

function ForkTask:TryProcessForkTask()
	mSleep(300)
	keepScreen(true)
	local judgeX=1360
	local findTask=false
	local taskPosY=0
	for judgeY=100,1080 do
		local r,g,b=getColorRGB(judgeX,judgeY)
		if r+g>400 and b<100 then--找到橙色按钮
			findTask=true
			taskPosY=judgeY
			--showRect(judgeX-10,judgeY-10,judgeX+10,judgeY+10,1000)
			self.TaskNowAttain,self.TaskRequire=Task:GetTaskInfo(judgeY-46)--任务描述
			break
		end
	end
	keepScreen(false)
	if findTask then
		tap(judgeX+20,taskPosY+10)
		if Task:MainTaskProcess(self.TaskNowAttain,self.TaskRequire,2) then--提交支线
			self.ThreadTaskRefresh=false
		end
		return true
	end
end

function ForkTask:Run()
	if not Setting.Task.EnableAutoProcessForkTask then
		ShowInfo.RunningInfo("分支任务被禁用")
		return false
	elseif not self.ThreadTaskRefresh then
		ShowInfo.RunningInfo("上一分支任务进行中")
		return false
	else
		ShowInfo.RunningInfo("开始分支任务")
	end
	if not Task:Enter(true) then
		return false
	end
	while Task:NextPage() do
		if ForkTask:TryProcessForkTask() then 
			break
		end
	end
end