require "Building.Building"
City = {
	nowState=0,
	res={
		iron=resInfo,
		rubbert=resInfo,
		petroleum=resInfo,
		people=resInfo
	}
}--初始化

function City:new (o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

