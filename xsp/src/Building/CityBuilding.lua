
CityBuilding = {
	nowState=0,
	Name="",
	Level=0,
	Status="无",
}--初始化

function CityBuilding:new (o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

function CityBuilding:SynInfo()
	
end