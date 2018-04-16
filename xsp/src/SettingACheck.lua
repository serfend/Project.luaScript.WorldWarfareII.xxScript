
_isDebug = false
_fitScreen=true
_fsw, _fsh = getScreenSize()
_sw = _fsh - 1
_sh = _fsw - 1
_userDpi=getScreenDPI()
_orientation = 0--dialogRet("请选择您设备的放置方式：", "", "Home键在右", "Home键在左", 0)
setSysConfig("isLogFile","1")
toast(_fsw .. "*" .. _fsh .. ":" .. _userDpi )
sysLog(_fsw .. "*" .. _fsh .. ":" .. _userDpi )
local supportSize=false
	require "SettingBase.Screen"
if _fsw==1080 and _fsh==1920 and _userDpi==480 then
	supportSize=true
elseif  _fsw==720 and _fsh==1280 and _userDpi==320 then
	setScreenScale(1080,1920)
	supportSize=true
else
	supportSize=false
end
if not supportSize then
	_fitScreen=false
	choiceIfRun = dialogRet("不支持当前分辨率".._fsw.."*".._fsh.."\n 强制运行无法保证脚本功能能够正常运转", "停止运行", "强制运行", "", 0)
	if choiceIfRun == 0 then
		lua_exit();
	end
	setScreenScale(1080,1920)
end

--local checkAssistant = appIsRunning("com.xxAssistant");--检测叉叉助手是否在运行
--if checkAssistant == 0 then
--  choice = dialogRet("请打开叉叉助手","取消","确定","",0);
--  if choice == 0 then
--    printFunction("脚本将退出")
--    lua_exit()
--  elseif choice == 1 then
--    runApp("com.xxAssistant")
--    s(60*1000)--等待一分钟
--  end
--end

--local appid = frontAppName() init("com.supercell.clashofclans",0);--检测部落冲突是否在运行
--if appid ~= "com.supercell.clashofclans" then
--  runApp("com.supercell.clashofclans")
--  s(60*1000)--等待一分钟
--end