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

function Message:SendMessage(to,info)

end