
MapEvents={}
function MapEvents:new (o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

function MapEvents:CollectMapEvent()
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

local lastCollectEventTime=0
local thisTimeNeedRefresh=true
function MapEvents:NeedRefresh()
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
	sysLog("野外事件激活中。。。"..interval..","..tostring(thisTimeNeedRefresh))
	return thisTimeNeedRefresh;
end

function MapEvents:CheckNeedRefresh()
	return thisTimeNeedRefresh
end
