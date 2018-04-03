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
	if Setting.Building.CityOtherSetting.EnableTransportRescouseToMainCity then
		sysLog("2333")
	end

	if Setting.Building.CityMainSetting.EnableAutoDevelop==false and Setting.Building.CityOtherSetting.EnableAutoDevelop==false then
		ShowInfo.RunningInfo("城市建设被禁用")
		return false
	end
	self:Enter()
	Building:InitCityList()
	self:Exit()
end
function Building:InitCityList()
	self.cityList={}
	Building:EnterCityList()
	Building:FoldCity()
	ShowInfo.RunningInfo("获取城市列表")
	Building:RollToBegin()	
	Building:GetPageCityPos()
end
function Building:AnyExtractCity()
		return  findColor({10, 70, 70, 1072}, 
	"0|0|0x8f826b,21|19|0xf7e9cd,44|4|0xe8e5e3,42|10|0xd3cfc5,22|25|0xf7eacf,-1|8|0xf0d69e",
	90, 0, 0, 0)
end
function Building:FoldCity()
	ShowInfo.RunningInfo("折叠城市列表")
	x,y=Building:AnyExtractCity()
	if x > -1 then
		tap(x,y)
		sleepWithCheckLoading(200)
	else
		ShowInfo.RunningInfo("没有检测到可折叠的城市")
	end
end
function Building:ExtractFoldCity(cityY)
	x,y=Building:AnyExtractCity()
	if x==-1 then
		x,y=findColor({18,cityY-120,73,cityY+80},
		"0|0|0xf1efe9,-8|0|0xf5f4ed,10|23|0xf6e8ca,19|23|0xcec4a4,0|45|0xe7cf9a,-8|45|0xe5cf9b"
		,90,0,0,0)
		if x>-1 then
			tap(x,y)
			sleepWithCheckLoading(200)
		else
			ShowInfo.RunningInfo("展开城市失败！")
		end
	else
		ShowInfo.RunningInfo("无需展开城市")
	end
end
function Building:GetPageCityPos()
	point = findColors({69, 73, 129, 982}, 
	"0|0|0x92b380,8|4|0x4b6d3b,2|13|0x7c906b,14|33|0x577f43,-23|15|0x4d703c,-6|9|0x678559",
	90, 0, 0, 0)
	pointDeactive=findColors({69, 73, 129, 982}, 
	"0|0|0x839966,1|33|0x839966,35|36|0x829866,35|8|0x839966,24|17|0xaca79a,11|14|0xc0b9ac,17|30|0x8d877b,29|34|0xa9a195",
	90, 0, 0, 0)
	--合并points ING
	for i,item in ipairs(pointDeactive) do
		table.insert(point,item)
	end
	ShowInfo.RunningInfo("获取到"..#point.."个城市")
	local noNextPage=Building:AtBottom()
	if #point ~= 0 then
		for i,cityPos in pairs(point) do
			Building:ExtractFoldCity(cityPos.y)
			local tmpCity=City:new()
			tmpCity.pos=cityPos
			Building:AddCity(tmpCity)
			mainCityX,mainCityY=Building:GetMainBuildingInCityList()
			if mainCityY>0 then
				--sysLog("主城y:"..mainCityY..",当前"..cityPos.y)
				if cityPos.y>mainCityY and cityPos.y-mainCityY<100 then
					--奇怪的主城判定方法2333
					tmpCity.IsMainCity=1
					tmpCity.CityProperty="CityMain"
				end
			end
			ShowInfo.RunningInfo("处理第"..i.."个城市"..(tmpCity.IsMainCity==1 and "(主城)" or "(分城)"))
			tmpCity:Run()
			Building:RollToBegin()
			Building:FoldCity()
			if noNextPage then 
				return true
			end
		end
		return true
	else
		return false
	end
	
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
	x,y=Building:GetMainBuildingInResList()
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
		else
			x, y = findColor({792, 441, 1105, 681}, 
				"0|0|0xcdffff,22|9|0xe5ffff",
				95, 0, 0, 0)
			if x > -1 then
				found=true
				return true
			end
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
function Building:RollToBegin()
	for i=1,5 do
		Building:LastPage()--此处先实现以后再改
	end
end
function Building:NextPage()
	swip(300,950,300,390)
	mSleep(200)
end
function Building:LastPage()
	swip(300,390,300,950)
	mSleep(200)
end
function Building:AtBottom()
		x, y = findColor({0, 994, 539, 1079}, 
	"0|0|0x322620,39|20|0x382c25,183|49|0x2c241c,419|27|0x574538",
	90, 0, 0, 0)
	if x > -1 then
		return true
	else
		return false
	end
end
function Building:EnterResList()
	sleepWithCheckLoading(500)
	ShowInfo.RunningInfo("进入资源列表")
	tap(350,10)
	sleepWithCheckLoading(500)
end
function Building:GetMainBuildingInResList()
	return  findColor({412, 71, 465, 982}, 
"0|0|0xffffff,4|8|0xffffff,3|18|0x304772,12|14|0x7e8daa",
95, 0, 0, 0)
end
function Building:GetMainBuildingInCityList()
	return  findColor({8, 75, 524, 1070}, 
"0|0|0xdde2eb,7|10|0x5c7093,4|13|0x40557d",
90, 0, 0, 0)

end
function Building:EnterGeneral()
	sleepWithCheckLoading(500)
	ShowInfo.RunningInfo("进入全国产量")
	tap(150,10)
	sleepWithCheckLoading(500)
end
function Building:GetFundInfo()
	
end
