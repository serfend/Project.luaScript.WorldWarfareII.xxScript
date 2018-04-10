Message = {
	nowState=0,UserEnableAutoSendMessage=false
}--初始化
 	posX=1360
	beginY,endY=980,150
function Message:new (o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end
function Message:Run()
	if self:CheckNew() then
		ShowInfo.RunningInfo("有新消息")
		self:Enter()
		sleepWithCheckLoading(500)
		messages=self:GetAllMessage()
		ShowInfo.RunningInfo("新消息数量"..#messages)
		for i,talk in pairs(messages) do
			tap(messages[1].x,messages[1].y+20)
			local thisMessage=self:GetMessageDetail()
			self:SendMessage("Test")
		end
		self:Reset()
	end
end
function Message:GetMyMessageBox()
	return findColor({1830, 88, 1831, 987}, 
	"0|0|0x82a92d,0|1|0x303615-0xff66ff",
	95, 0, 1, 0)
end
function Message:GetAllOtherMessageBox(beginY)
	return exceptPosTableByNewtonDistance(findColors({1830, beginY, 1831, 987}, 
	"0|0|0xc9c7c4,0|1|0x303615-0xff66ff",
	95, 0, 1, 0),20)
end
function Message:GetMessageInfo(messageY)
	touchDown(1,1200,messageY)
	mSleep(3000)
	touchUp(1,1200,messageY)
	return readPasteboard()
end
function Message:GetMessageDetail()
	local _,lastBoxY=self:GetMyMessageBox()
	local newMessage=self:GetAllOtherMessageBox(lastBoxY)
	sysLog("count:"..#newMessage)
	for i,message in pairs(newMessage) do
		local thisInfo=self:GetMessageInfo(message.y)
		sysLog("获得数据:"..thisInfo)
	end
end
function Message:Enter()
	tap(178,1046)
end
function Message:SendMessage(info)
	self:SelectMessageAera()
	inputText(info)
	inputText("#ENTER#")
	self:Submit()
	self:Submit()
end
function Message:Submit()
	tap(1850,1038)
	sleepWithCheckLoading(500)
end
function Message:Reset()
	tap(219,122)
	Form:Exit()
end
function Message:SelectMessageAera()
	tap(887,1034)
	sleepWithCheckLoading(500)
end
function Message:CheckNew()
	x, y = findColor({323, 974, 374, 1023}, 
	"0|0|0xd20000,-6|-4|0xd80000",
	95, 0, 0, 0)
	if x > -1 then
		return true
	else
		return false
	end
end
function Message:GetAllMessage()
	point = findColors({345, 393, 394, 980}, 
"0|0|0xeb0101,11|15|0x920000",
90, 0, 0, 0)
	return exceptPosTableByNewtonDistance(point,20)
end