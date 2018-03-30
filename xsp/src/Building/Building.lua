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
function Building:Run()
	self:Enter()
	Building:InitCityList()
	self:Exit()
end
function Building:InitCityList()
	self.cityList={}
	ShowInfo.RunningInfo("获取城市列表")
	Building:EnterCityList()
	Building:FoldCity()
	Building:GetPageCityPos()
end
function Building:FoldCity()
	x, y = findColor({10, 70, 70, 1072}, 
"0|0|0x8f826b,21|19|0xf7e9cd,44|4|0xe8e5e3,42|10|0xd3cfc5,22|25|0xf7eacf,-1|8|0xf0d69e",
90, 0, 0, 0)
if x > -1 then
	tap(x,y)
	sleepWithCheckLoading(200)
end
end
function Building:GetPageCityPos()
	point = findColors({69, 73, 129, 982}, 
	"0|0|0x92b380,8|4|0x4b6d3b,2|13|0x7c906b,14|33|0x577f43,-23|15|0x4d703c,-6|9|0x678559",
	90, 0, 0, 0)
	if #point ~= 0 then
		for i,cityPos in pairs(point) do
			local tmpCity=City:new()
			tmpCity.pos.x=cityPos.x
			tmpCity.pos=cityPos
			Building:AddCity(tmpCity)
			tmpCity.Init()
		end
	end
end
function Building:NextPage()

end
function Building:AddCity(city)
	if self.GetCity(city)>-1 then 
		return false
	end
	self.cityList[#self.cityList]=city
	return true
end
function Building:GetCity(city)
	if self.cityList==nil then
		return -1
	end
	for i=0,#self.cityList do
		if self.cityList[i].id==city.id then 
			return i
		end
	end
	return -1
end
function Building:SelectMainCity()
	Building:Enter()
	Building:EnterResList()
	x,y=Building:GetMainBuilding()
	x2,y2=findColor({470, y+20, 540, y+100}, 
		"0|0|0xffffff,1|1|0xffffff",
		90, 0, 0, 0)
		if x>0 and x2 > 0 then
			sleepWithCheckLoading(500)
			tap(x2,y2)
			sysLog("MainBuildingPos"..x2..","..y2)
			Building:WaitMainBuildingLoading()
		else
			sysLog("没有找到")
		end
end
function Building:find()
	return  findColor({9, 463, 135, 590}, 
		"0|0|0x9c7143,20|31|0xcccbc3,43|50|0xcfcfc6",
		95, 0, 0, 0)
end
function Building:WaitMainBuildingLoading()
	local found=false
	local checkTimes=0
	while not found and checkTimes<5 do
		checkTimes=checkTimes+1
		sleepWithCheckLoading(500)
		x, y = findColor({839, 417, 1133, 675}, 
		"0|0|0x9ab3e7,36|13|0xa0b8eb,23|317|0x837e6c",
		95, 0, 0, 0)
		if x > -1 then
			found=true
			return true
		end
	end
	return false
end
function  Building:Enter()
	ShowInfo.RunningInfo("进入内政")
	x,y=self.find()
	if x>-1 then
		tap(x,y)
		self.nowState=1
		self.EnterCityList()
		return true
	else
		return false
	end
end
function Building:Exit()
	MainForm.Exit()
end
function Building:EnterCityList()
	sleepWithCheckLoading(500)
	ShowInfo.RunningInfo("进入建设列表")
	tap(550,10)
	sleepWithCheckLoading(500)
end
function Building:EnterResList()
	sleepWithCheckLoading(500)
	ShowInfo.RunningInfo("进入资源列表")
	tap(350,10)
	sleepWithCheckLoading(500)
end
function Building:GetMainBuilding()
	return  findColor({412, 71, 465, 982}, 
"0|0|0xffffff,4|8|0xffffff,3|18|0x304772,12|14|0x7e8daa",
95, 0, 0, 0)
end
function Building:EnterGeneral()
	sleepWithCheckLoading(500)
	ShowInfo.RunningInfo("进入主页")
	tap(150,10)
	sleepWithCheckLoading(500)
end

function Building:GetFundInfo()
	
end
