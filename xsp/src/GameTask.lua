
GameTask = {
	nowState=0,
	MainThreadTaskRefresh=true,
	MainTaskInfo="",MainTaskRequire=0,MainTaskNowAttain=0
}--初始化

function GameTask:new (o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end
function GameTask:MainTaskProcess()
	
	local lastMaxX,lastMaxY=0,0
	local lastMinX,lastMinY=1920,1080
	local detectX1,detectX2,detectY1,detectY2=0,1920,0,1080
	local beginTime=os.time()
	local directionTimes={0,0,0,0}
	mSleep(800)
	while os.time()-beginTime<4 do
		mSleep(100)
		local nowX,nowY,direction=self:GetNowTipPos(detectX1,detectY1,detectX2,detectY2)
		directionTimes[direction]=directionTimes[direction]+1
		
		if nowY>lastMaxY and nowY>-1 then
			lastMaxY=nowY
			detectY2=lastMaxY+200
		end
		if nowX>lastMaxX and nowX>-1 then
			lastMaxX=nowX
			detectX2=lastMaxX+200
		end
		if nowY<lastMinY and nowY>-1 then
			lastMinY=nowY
			detectY1=lastMinY-200
		end
		if nowX<lastMinX and nowX>-1 then
			lastMinX=nowX
			detectX1=lastMinX-200
		end
	end
	local lastX,lastY=0,0
	sysLog("dirTime:"..directionTimes[1]..","..directionTimes[2]..","..directionTimes[3])
	if directionTimes[1]<directionTimes[2] then--左上出现次数多于左下,则应取Min,Min
		lastX,lastY= lastMinX,lastMinY
	elseif directionTimes[1]>directionTimes[3] then
		lastX,lastY= lastMinX,lastMaxY--左下出现次数多于右下,则应取Min,Max
	else--否则是右下Max,Max
		lastX,lastY= lastMaxX,lastMaxY
	end
	if lastX>0 and lastX<1920 then
		showRect(lastX-15,lastY-15,lastX+15,lastY+15,500)
		ShowInfo.RunningInfo("up:"..lastX..","..lastY.."at("..detectX1..","..detectY1.."),("..detectX2..","..detectY2..")")
		tap(lastX,lastY)
		self:MainTaskProcess()
	else
		Form:Submit()
		sleepWithCheckLoading(200)
		if not GameTask:BuidlingIsOnProcess() then
			if not Form:BuildAtMap() then
				if not Form:Submit() then
					local RequireLeft=nil
					if self.MainTaskRequire>0 then
						if self.MainTaskNowAttain==-1 then
							RequireLeft=self.MainTaskRequire
						else
							RequireLeft=self.MainTaskRequire-self.MainTaskNowAttain
						end
					end
					ShowInfo.RunningInfo("生产:"..(RequireLeft or "nil"))
					if not Form:Manufacture(RequireLeft) then
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
local CheckMainTaskTimes=0--第5次检查时强制检查任务完成情况
function GameTask:MainTask()
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
	self:Enter(true)--强制进入
	keepScreen(true)
	local splitCharPos,splitCharPosEnd=self:GetMainTaskSplitCharPos()
	showRect(splitCharPos,213,splitCharPosEnd,247,1000)
	local ocrCode,result=ocr:GetNum(splitCharPos,213,splitCharPosEnd,247,"0xffffff-0xbfbfbf")
	keepScreen(false)
	self.MainTaskInfo=""
	local tmp=split(result,"/")
	if #tmp>1 then
		tmp[2]=replace(tmp[2]," ","")
		self.MainTaskRequire=tonumber(GetLastValue(tmp[2]))
		self.MainTaskNowAttain=tonumber(GetLastValue(tmp[1]))
	end
	if self.MainTaskNowAttain==0 then 
		self.MainTaskNowAttain=-1
	end
	if self.MainTaskRequire<20 then
		self.MainTaskRequire=-1
	end
	ShowInfo.ResInfo("任务需求:"..self.MainTaskRequire..",当前已完成:"..self.MainTaskNowAttain.." raw:"..result)
	Form:Exit()
	mSleep(200)
	tap(418,273)--任务提示
	local success=self:MainTaskProcess()
	mSleep(1200)
	Form:Exit()
	return success
end
function GameTask:GetMainTaskSplitCharPos()
	local x=1350
	local beginX,endX=0
	while x>0 do
		x=x-1
		local r,g,b=getColorRGB(x,225)--中间位置
		local aberration=GetAberration(r,g,b,255,255,255)
		if aberration<300 then---检查与纯白的差距
			local chrRect=GetRect(x,225,x-100,x+100,210,255,r,g,b,200)
			showRect(chrRect.x1,chrRect.y1,chrRect.x2,chrRect.y2,500)
			if beginX~=0 then
				if beginX-chrRect.x1>24 then--当边距超过50时(需要检查分辨率)
					beginX=chrRect.x2
					break
				end
			else
				endX=chrRect.x2+10
			end
			beginX=chrRect.x1
			x=chrRect.x1-3
		end
	end
	return beginX+5,endX
end
function GameTask:GetNowTipPos(x,y,w,h)
	local x,y=0,0
	local tryTime=0
	local TipDirectionTime={0,0,0,0}
	while tryTime<TipDirectionUsed do
		local searchDirectionY=1 searchDirectionX=0
		if TipDirection==2 then-- 为左上手指时从上向下扫描
			searchDirectionY=0
		else
			searchDirectionY=1
		end
		if TipDirection==3 then--为右下手指时从右向左扫描
			searchDirectionX=1
		else
			searchDirectionX=0
		end
		TipDirectionTime[TipDirection]=TipDirectionTime[TipDirection]+1
		x,y = findColor({x, y, w, h}, 
			TipDirectionData[TipDirection],
			95, 0, searchDirectionX, searchDirectionY)
		if x<0 then
			tryTime=tryTime+1
			TipDirection=math.mod(TipDirection,TipDirectionUsed)+1
		else
			break
		end
	end
	
	local direction=0
	if TipDirectionTime[1]>TipDirectionTime[2] then
		direction=1
	else
		if TipDirectionTime[2]>TipDirectionTime[3] then
			direction=2
		else
			direction=3
		end
	end
	return x,y,direction
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
		if self:Enter() then
			self:CheckTask("OtherTask")
		end
	end
	Form:Exit()
	
	self:CollectMapEvent()
	--self:CheckUserMailMessage()
	
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
	local times=0
	while GameTask:FinishTask(TaskType[taskType][1],TaskType[taskType][2]) do
		times=times+1
		if taskType=="MainTask" then
			self.MainThreadTaskRefresh=true
		end
		ShowInfo.RunningInfo("完成"..taskType.."任务"..times)
	end
end
function GameTask:Enter(directIn)
	directIn=directIn or false
	x, y = findColor({18, 233, 110,316 }, 
			"0|0|0xd00000,0|9|0xb60000",
			95, 0, 0, 0)
		if x > -1 or directIn then
			tap(63,271)--任务图标
			sleepWithCheckLoading(500)
			return true
		else
			return false
		end
end
function GameTask:FinishTask(beginY,endY)
	x, y = findColor({1313, beginY, 1647, endY}, 
		"0|0|0xfbc01d,0|15|0xc08915,0|30|0xc18f0c,0|45|0xfed002",
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
			x, y = findColor({1540, 100, 1580, 980}, 
			"0|0|0xf8fafb,0|15|0xcce8ee,0|30|0x20557d",
			95, 0, 0, 0)
		if x > -1 then
			ShowInfo.RunningInfo("有附件,领取...")
			tap(211,1033)--一键领取
			sleepWithCheckLoading(500)
			local haveNew=true
			while haveNew do
				tap(955,962)--确定
				sleepWithCheckLoading(300)
				haveNew=self:CheckMailRecived()
			end
		else
			tap(349,33)
		end
		sleepWithCheckLoading(500)
		Form:Exit()
	else
		
	end
end
function GameTask:CheckMailRecived()
	x, y = findColor({811, 909, 1105, 1003}, 
	"0|0|0xfbc01d,183|0|0xfbc01d",
	95, 0, 0, 0)
	if x > -1 then
		return true
	else
		return false
	end
end
local lastCollectEventTime=0
local thisTimeNeedRefresh=true
function GameTask:NeedRefresh()
	if Setting.Task.EnableCollectEvent ==false then
		--ShowInfo.RunningInfo("野外事件被禁用")
		return false
	end
	local nowTime=os.time()
	local interval=nowTime-lastCollectEventTime
	--sysLog(nowTime..","..lastCollectEventTime)
	if interval>Setting.Task.CollectEvent.Interval then
		thisTimeNeedRefresh=true
		lastCollectEventTime=nowTime
	else
		thisTimeNeedRefresh=false
	end
	sysLog("needR"..interval..","..tostring(thisTimeNeedRefresh))
	return thisTimeNeedRefresh;
end
function GameTask:CheckNeedRefresh()
	return thisTimeNeedRefresh
end
function GameTask:CollectMapEvent()
	--sysLog("collect")
	local flag=true
	local times=0
	while flag do
			x, y = findColor({480, 125, 1700, 1000}, 
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
