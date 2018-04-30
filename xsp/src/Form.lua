Form = {
	nowState=0,
}--初始化
function Form:new (o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end
function Form:DetectNowFocus()
	
end
function Form:GetBuildingButton(buttonName)
	local x,y= findColor({771, 823, 1839, 1038}, 
		BuildingButtonList[buttonName],
		92, 0, 0, 0)
	if x<0 then
		ShowInfo.RunningInfo("寻找"..buttonName.."按钮失败")
	end
	return x,y
end
function Form:Exit(exitAll)
	keepScreen(false)
	exitAll=exitAll or false
	local success=true
	while success  do
		success=Form:DoAction(Form.findExit,"退出界面")
		if not exitAll then
			break
		end
	end
	return success
end
function Form:Submit()
	return Form:DoAction(Form.findSubmit,"提交(右下角）")
end
function Form:Build()
	return Form:DoAction(Form.findBuild,"提交(重建)")
end
function Form:Manufacture(produceNum,exceptSoilder)
	exceptSoilder=exceptSoilder or false
	if produceNum~=nil then
		if not Form:EditProduceNum(produceNum,exceptSoilder) then
			return false
		end
	end
	return Form:DoAction(Form.findBuild,"提交(生产/组建)")
end
function Form:GetNowManufactureNum()
	local x,y=Form:findBuild()
	local result=-1
	if y>760 then
		code,result=ocr:GetNum(1051,587,1135,617)
		sysLog("获取到组建数量"..result)
	else
		code,result=ocr:GetNum(1031,403,1149,443)
		sysLog("获取到生产数量"..result)
	end
	return tonumber(result)
end
function Form:EditProduceNum(num,exceptSoilder)
		local x, y = findColor({1240, 400, 1300, 600}, 
	"0|0|0xeaffff,-12|7|0xe0ffff",
	95, 0, 0, 0)--编辑按钮
	if x>-1 then
	
		if y>560 and exceptSoilder then--组建部队
			if  not Conscript:HaveLastConscript()  then
				ShowInfo.RunningInfo("生产已被禁止,需预留军备")
				Conscript:CheckConscriptStatus()
				return false
			end
		end
		ShowInfo.RunningInfo("修改数值"..num)
		tap(x,y)--进入编辑
		mSleep(500)
		inputText(tostring(num))
		mSleep(200)
		tap(x,y)--退出编辑
		mSleep(500)
		return true
	end
	return false
end
function Form:BuildAtMap()
	if Form:CheckBuildNewRequire() then
		local point =Form:GetAllBuildingPlaceValid()
		--此处可智能选点
		if #point>0 then
			tap(point[1].x,point[1].y)
			return true
		else
			return false
		end
	end
end
function Form:DoAction(fun,id)
	x,y=fun()
	if x>-1 then
		ShowInfo.RunningInfo(id)
		tap(x,y)
		sleepWithCheckLoading(500)
		return true
	else
		ShowInfo.RunningInfo("失败:"..id)
		return false
	end
end
function Form:GetAllBuildingPlaceValid()
	point = findColors({470, 240, 1485, 1019}, 
	"0|0|0x97fbff",
	95, 0, 0, 0)
	point=exceptPosTableByNewtonDistance(point,50)
	ShowInfo.RunningInfo("处理后建造点"..#point.."个")
	return point
end
function Form:CheckBuildNewRequire()
x, y = findColor({599, 924, 851, 1036}, 
"0|0|0x00b050,26|2|0x00b050,9|20|0x04ae50,26|27|0x00b050,26|37|0x00b050,74|28|0x02ae50,84|21|0x00b050,78|10|0x00b050,76|0|0x00b050,64|4|0x00b050,91|37|0x00b050",
90, 0, 0, 0)
if x > -1 then
	return true
else
	return false
end
end
function Form:findBuild()
	return  findColor({350, 125, 1565, 953}, 
"0|0|0xfcbf19,5|51|0xef9315,210|59|0xf19c13,195|4|0xfbbd19,108|6|0xfaba18,109|65|0xfeca0b,-804|-551|0x2d291e",
90, 0, 0, 0)
end
function Form:findSubmit()
	return findColor({1553, 978, 1916, 1076}, 
"0|0|0xfdc81d,9|67|0xf5a916,268|63|0xf6ad13,256|4|0xfdc51d,138|3|0xfdc71d,135|65|0xfed002",
95, 0, 0, 0)
end
function Form:findExit()
	local x,y= findColor({1869, 0, 1919, 50}, --右上角退出
"0|0|0x993333,7|7|0x993333",
90, 0, 0, 0)
	
	return x,y+10
end
local randomRange=100
function Form:CheckLoading(judgeTime)
	judgeTime=judgeTime or 0
	x, y = findColor({882, 438, 1037, 587}, 
	"0|0|0xfde992,-7|5|0xfae890",
	98, 0, 0, 0)
	 
	local posRandomX=math.random(-randomRange,randomRange)
	local posRandomY=math.random(-randomRange,randomRange)
	if x > -1 then
		swip(900,500,900+posRandomX,500+posRandomY)
		if judgeTime>2 then
			if x==lastX and y==lastY then
				return  false
			else
				return true
			end
		else
			mSleep(30)--三次判断防误判
			return Form:CheckLoading(judgeTime+1)
		end
	else
		return false
	end
end