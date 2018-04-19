resInfo={
	stock,yields
}
Building = {
	nowState=0,
	fund=resInfo,
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
	gameTask:NeedRefresh()--判断是否需要取野地事件
	if Setting.Building.CityMainSetting.EnableAutoDevelop==false and Setting.Building.CityOtherSetting.EnableAutoDevelop==false then
		ShowInfo.RunningInfo("城市建设被禁用")
		return false
	end
	if not self:Enter() then
		ShowInfo.RunningInfo("进入城市界面失败")
		return false
	end
	Building:BuildingBegin()
	self:Exit()
end
function Building:AnyExtractCity()
		return  findColor({10, 70, 100, 1072}, 
	"0|0|0x8f826b,21|19|0xf7e9cd,44|4|0xe8e5e3,42|10|0xd3cfc5,22|25|0xf7eacf,-1|8|0xf0d69e",
	80, 0, 0, 0)
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
		"0|0|0xf1efe9,-8|0|0xf5f4ed,10|23|0xf6e8ca,19|23|0xcec4a4"
		,80,0,0,0)
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
function Building:BuildingBegin()
	Building:EnterCityList()
	Building:FoldCity()
	Building:RollToBegin()
	local nextPos=155
	local handleCityNum=0
	while true do
		handleCityNum=handleCityNum+1
		tap(295,nextPos)--打开下一城市
		local tmpCity=City:new()
		tmpCity.pos.y=nextPos
		ShowInfo.RunningInfo("处理第"..handleCityNum.."座城")
		atEnd,nextPos=tmpCity:Run()
		if atEnd then --最末城市结束
			break
		end
		
	end
	ShowInfo.RunningInfo("成功处理"..handleCityNum.."座城")
end
function Building:SelectNowFocus()
	return Building:FindNowFocus()
end
function Building:FindNowFocus()
	sleepWithCheckLoading(200)
	local tryTime=0
	while tryTime<10 do
		local x, y = findColor({194, 71, 537, 1076}, 
			"0|0|0xe0ab3f,0|27|0xdfa93e,0|57|0xda9f36,0|88|0xd4942e",
			95, 0, 0, 0)
		if x > -1 then
			if y>850 then
				Building:NextPage()
			end
			local x, y = findColor({194, 71, 537, 1076}, 
			"0|0|0xe0ab3f,0|27|0xdfa93e,0|57|0xda9f36,0|88|0xd4942e",
			95, 0, 0, 0)
			return y
		else
			Building:NextPage()
			tryTime=tryTime+1
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
	sysLog("MainBuildingPos"..x..","..y)
	if x>0 and x2 > 0 then
		sleepWithCheckLoading(500)
		tap(x2,y2)
		ShowInfo.RunningInfo("MainBuildingPos"..x2..","..y2)
		Building:WaitMainBuildingLoading()
	else
		ShowInfo.RunningInfo("没有找到")
	end
end
function Building:SelectMainCityBuilding()
	Building:Enter()
	Building:EnterCityList()
	Building:FoldCity()
	local mainCityPosY=City:FindMainBuilding(0,1080)
	tap(100,mainCityPosY)
end
function Building:find()
	return  findColor({9, 463, 135, 590}, 
		"0|0|0x9c7143,20|31|0xcccbc3,43|50|0xcfcfc6",
		95, 0, 0, 0)
end
function Building:WaitMainBuildingLoading()--等待城市出现
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
	local x,y=self:find()
	if x>-1 then
		tap(x,y)
		mSleep(200)
		x,y=self:find()
		if x>-1 then
			return false
		else
			return true
		end

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
"0|0|0x737e96,0|6|0xffffff,0|12|0x8f9fbe,0|18|0xffffff",
85, 0, 0, 0)
end
function Building:EnterGeneral()
	sleepWithCheckLoading(500)
	ShowInfo.RunningInfo("进入全国产量")
	tap(150,10)
	sleepWithCheckLoading(500)
end
function Building:GetFundInfo()
	
end
