Task={}
function Task:GetMainTaskSplitCharPos(beginY)
	local x=1350
	local beginX=0
	local endX=0
	while x>0 do
		x=x-1
		local r,g,b=getColorRGB(x,beginY)--中间位置
		local aberration=GetAberration(r,g,b,255,255,255)
		if aberration<300 then---检查与纯白的差距
			local chrRect=GetRect(x,beginY,x-100,x+100,beginY-15,beginY+30,r,g,b,200)
			--showRect(chrRect.x1,chrRect.y1,chrRect.x2,chrRect.y2,500)
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
function Task:GetTaskInfo(beginY)
	beginY=beginY or 225
	local splitCharPos,splitCharPosEnd=Task:GetMainTaskSplitCharPos(beginY)
	if splitCharPos<10 then
		ShowInfo.RunningInfo("获取任务内容失败")
		return -1,-1
	end
	showRect(splitCharPos,beginY-12,splitCharPosEnd,beginY+22,1000)
	local ocrCode,result=ocr:GetNum(splitCharPos,beginY-12,splitCharPosEnd,beginY+22,"0xffffff-0xbfbfbf")
	local tmp=split(result,"/")
	local nowAttain=0
	local requireAttain=0
	if #tmp>1 then
		tmp[2]=replace(tmp[2]," ","")
		requireAttain=tonumber(GetLastValue(tmp[2]))
		nowAttain=tonumber(GetLastValue(tmp[1]))
	end
	if nowAttain==0 then 
		nowAttain=-1
	end
	if requireAttain<20 then
		requireAttain=-1
	end
	ShowInfo.ResInfo("任务:"..nowAttain.."/"..requireAttain.." raw:"..result)
	return nowAttain,requireAttain
end
function Task:MainTaskProcess(nowAttain,requireAttain,id)
	mSleep(200)--防止误差
	local lastMaxX,lastMaxY=0,0
	local lastMinX,lastMinY=1920,1080
	local detectX1,detectX2,detectY1,detectY2=0,1920,0,1080
	local beginTime=os.time()
	local directionTimes={0,0,0,0}
	mSleep(800)
	while os.time()-beginTime<4 do
		mSleep(100)
		local nowX,nowY,direction=Task:GetNowTipPos(detectX1,detectY1,detectX2,detectY2)
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
	local directionNow=GetMaxIndex(directionTimes)
	if directionNow==1 then--左下Min,Min
		lastX,lastY= lastMinX,lastMaxY
	elseif directionNow==3 then
		lastX,lastY= lastMinX,lastMinY--左上Min,Max
	else
		lastX,lastY= lastMaxX,lastMaxY
	end
	if lastX>0 and lastX<1920 then
		if lastY<300 then lastY=20 end
		if lastY>800 then lastY =1000 end
		showRect(lastX-15,lastY-15,lastX+15,lastY+15,300)
		ShowInfo.RunningInfo("up:"..lastX..","..lastY.."at("..detectX1..","..detectY1.."),("..detectX2..","..detectY2..")")
		tap(lastX,lastY)
		return self:MainTaskProcess(nowAttain,requireAttain,id)
	else
		local success= Task:Submit(nowAttain,requireAttain,id)--提交主线任务
		mSleep(1200)
		Form:Exit()
		return success
	end
end

function Task:Submit(nowAttain,requireAttain,id)--1主线 2支线，支线只进行生产
	local complete=false
	if id==1 then 
		Form:Submit()
		sleepWithCheckLoading(200)
		complete=MainTask:BuidlingIsOnProcess()
		if not complete then
			complete=Form:BuildAtMap()
		end
		if not complete then
			complete=Form:Submit()
		end
		if complete then ShowInfo.RunningInfo("建筑任务已提交") end
	end
	if not complete then
		local RequireLeft=nil
		if requireAttain>0 then
			if nowAttain==-1 then
				RequireLeft=requireAttain
			else
				RequireLeft=requireAttain-nowAttain
			end
		end
		ShowInfo.RunningInfo("生产:"..(RequireLeft or "nil"))
		if not Form:Manufacture(RequireLeft,id~=1) then--支线任务为防风险，需排除第一个军备的生产
			ShowInfo.RunningInfo("自动处理失败")
			return false
		else
			self.nextTimeCompleteTaskEnableMergeArmy=true
		end
	end
	if complete then self.MainThreadTaskRefresh=false end
	return true
end

function Task:GetNowTipPos(x,y,w,h)
	local x,y=0,0
	local tryTime=0
	local TipDirectionTime={0,0,0,0}
	keepScreen(true)
	while tryTime<TipDirectionUsed do
		local searchDirectionY=1 searchDirectionX=0
		if TipDirection==3 then-- 为左上手指时从上向下扫描
			searchDirectionY=0
		else
			searchDirectionY=1
		end
		if TipDirection==2 then--为右下手指时从右向左扫描
			searchDirectionX=1
		else
			searchDirectionX=0
		end
		TipDirectionTime[TipDirection]=TipDirectionTime[TipDirection]+1
		--sysLog("dir"..TipDirection..","..searchDirectionX..","..searchDirectionY)
		x,y = findColor({x, y, w, h}, 
			TipDirectionData[TipDirection],
			95,  searchDirectionX, searchDirectionY,1)
		if x<0 then
			tryTime=tryTime+1
			TipDirection=math.mod(TipDirection,TipDirectionUsed)+1
		else
			break
		end
	end
	keepScreen(false)
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

local TaskType={
	MainTask={228,382},
	OtherTask={476,1074}
}
function Task:CheckTask(taskType)
	local times=0
	while Task:FinishTask(TaskType[taskType][1],TaskType[taskType][2]) do
		times=times+1
		if taskType=="MainTask" then
			MainTask.MainThreadTaskRefresh=true
		else
			ForkTask.ThreadTaskRefresh=true
		end
		conscript.nextTimeNeedMerge=1--不论完成什么任务，都进行合并，需修改
		ShowInfo.RunningInfo("完成"..taskType.."任务"..times)
	end
end
function Task:Enter(directIn)
	directIn=directIn or false
	x, y = findColor({18, 233, 110,316 }, 
			"0|0|0xd00000,0|9|0xb60000",
			95, 0, 0, 0)
		if x > -1 or directIn then
			tap(63,271)--任务图标
			sleepWithCheckLoading(500)
			return true
		else
			ShowInfo.RunningInfo("取消进入任务界面")
			return false
		end
end

function Task:FinishTask(beginY,endY)
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

function Task:NextPage()
	swip(665,500,665,0,5)
	local atButtom=Task:AtBottom()
	mSleep(1000)
	return not atButtom
end

function Task:AtBottom()
	local result=true
	keepScreen(true)
	local judgeX=608--检查是否有白边，有则未到底部
	for judgeY=950,1080 do
		local r,g,b=getColorRGB(judgeX,judgeY)
		if r+b+g>300 then
			result=false
			break
		end
	end
	keepScreen(false)
	return result
end