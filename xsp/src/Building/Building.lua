resInfo={
	stock,yields
}
Building = {
	nowState=0,
	fund=resInfo,
	cityList={}
}--初始化

function Building:new (o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end
function Building:AddCity(city)
	if GetCity(city)>-1 then 
		return false
	end
	cityList[#cityList]=city
	return true
end
function Building:GetCity(city)
	for i=0,#cityList do
		if cityList[i].id==city.id then 
			return i
		end
	end
	return -1
end
function Building:find()
	return findColor({18, 323, 77, 374}, 
		"0|0|0x9c7143,22|16|0xddddd7,48|39|0x805d37",
		95, 0, 0, 0)
end
function  Building:Enter()
	ShowInfo.RunningInfo("进入内政")
	x,y=self.find()
	if x>-1 then
		tap(x,y)
		self.nowState=1
		self.EnterResList()
		return true
	else
		return false
	end
end
function Building:Exit()
	
end
function Building:EnterCityList()
	mSleep(500)
	ShowInfo.RunningInfo("进入建设列表")
end
function Building:EnterResList()
	mSleep(500)
	ShowInfo.RunningInfo("进入资源列表")
	tap(200,1)
end
function Building:EnterGeneral()
	mSleep(500)
	ShowInfo.RunningInfo("进入主页")
	tap(1,1)
end

function Building:GetFundInfo()
	
end
