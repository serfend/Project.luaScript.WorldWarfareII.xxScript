_isDebug = false

_fsw, _fsh = getScreenSize()
_sw = _fsh - 1
_sh = _fsw - 1

_orientation = 0--dialogRet("请选择您设备的放置方式：", "", "Home键在右", "Home键在左", 0)

printFunction("Global Value:")
printFunction("_orientation:".._orientation, "_fsw:".._fsw, "_fsh:".._fsh, "_sw:".._sw, "_sh:".._sh)

local supportSize = (_fsw == 1080 and _fsh == 1920) --检测是否支持该分辨率
if not supportSize then
  choiceIfRun = dialogRet("不支持当前分辨率".."宽:".._fsw..",高:".._fsh, "停止运行", "强制运行", "", 0)
  if choiceIfRun == 0 then
    lua_exit();
  end
  if choiceIfRun == 1 then
    dialog("警告：\n 强制运行无法保证脚本功能能够正常运转", 0)
    setScreenScale(1080,1920,0)
  end
end
toast(_fsw .. "*" .. _fsh .. ":" .. getScreenDPI() )
if(getScreenDPI()~=480) then 
	dialog("可能不支持的dpi:"..getScreenDPI().."，建议修改为480后再启动游戏")
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