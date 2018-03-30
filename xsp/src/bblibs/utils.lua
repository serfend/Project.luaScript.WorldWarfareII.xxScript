-- 作者boyliang
-- 时间: 2015-11-26

-- 格式化输出
function sysLogFmt(fmt, ...)
  sysLog(string.format(fmt, ...))
end
function sleepWithCheckLoading(interval)
	local canGoOn=false
	local times=0
	while not canGoOn do
		mSleep(interval)
		if Form:CheckLoading() then
			times=times+1
			ShowInfo.RunningInfo("出现卡顿"..times)
		else
			canGoOn=true
		end
	end
end
-- 任意输出
function sysLogLst(...)
  local msg = ''
  for k,v in pairs({...}) do
    msg = string.format('%s %s ', msg, tostring(v))
  end
  sysLog(msg)
end

-- 模拟一次点击
function tap(x, y,delay)
	local x, y = x, y
  math.randomseed(tostring(os.time()):reverse():sub(1, 6))  --设置随机数种子
  local index = math.random(1,5)
  x = x + math.random(-1,1) 
  y = y + math.random(-1,1)
  touchDown(index,x, y)
  delay=delay or 0
  mSleep(math.random(delay+70,delay+80))                --某些特殊情况需要增大延迟才能模拟点击效果
  touchUp(index, x, y)
  mSleep(50)
end
function distance(x1,y1,x2,y2)
	return math.sqrt((x2-x1)^2+(y2-y2)^2)
end
-- 模拟滑动操作，从点(x1, y1)划到到(x2, y2)
function swip(x1,y1,x2,y2,step)
	step=step or 5
	index = math.random(1,5)
    touchDown(index, x1, y1)
    for i=1,step do
		touchMove(index,(x2-x1)*i/step+x1,(y2-y1)*i/step+y1)
	end

    touchMove(index, x2, y2)
    mSleep(30)
    touchUp(index, x2, y2)
end


-- 多点颜色对比，格式为{{x,y,color},{x,y,color}...} 
function cmpColor(array, s, isKeepScreen)
  s = s or 90
  s = math.floor(0xff * (100 - s) * 0.01)
  isKeepScreen = isKeepScreen or false
  
  local lockscreen = function(flag)
    if isKeepScreen == true then
      keepScreen(flag)
    end
  end

  lockscreen(true)
  for i = 1, #array do
    local lr,lg,lb = getColorRGB(array[i][1], array[i][2])
    local rgb = array[i][3]

    local r = math.floor(rgb/0x10000)
    local g = math.floor(rgb%0x10000/0x100)
    local b = math.floor(rgb%0x100)

    if math.abs(lr-r) > s or math.abs(lg-g) > s or math.abs(lb-b) > s then
      lockscreen(false)
      return false
    end
  end

  lockscreen(false)
  return true
end