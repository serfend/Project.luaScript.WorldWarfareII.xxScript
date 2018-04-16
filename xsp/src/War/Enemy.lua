Enemy = {
	nowState=0,
}--初始化

function Enemy:new (o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end