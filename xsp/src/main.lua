require "usingPack"
require "util"--加载工具
require "SettingACheck"--加载全局设置
skill=Skill:new{Interval=Skill["Interval"]}
building = Building:new()
gameTask=GameTask:new()
messageHdl=Message:new()
MainForm=Form:new()
function main()
	
	UserSettingForm=UI:new()
	start,userSetting=UserSettingForm.show()
	skill:setUseSkill(userSetting)
	if start==0 then 
		return false;
	end
	if Setting.Building.TestModelSetting.Enable then
		mainTest(Setting.Building.TestModelSetting.TestOption)
		return true
	end
	gameTask:NeedRefresh()
	if Setting.Task.EnableAutoProcessTaskDuplicate then
		gameTask.MainThreadTaskRefresh=false
	end
	mainLoop()
end
function mainLoop()
	while(true) do
		--messageHdl:Run()
		MainForm:Exit()
		Setting.Main.Runtime=Setting.Main.Runtime+1
		
		gameTask:Run()
		skill:Run()
		building:Run()
		
		toast("本轮结束," .. Setting.Main.Interval .. "秒后开始")
		mSleep(Setting.Main.Interval*1000)
	end
end
function mainTest(testName)
	toast("进行测试:"..testName)
end
-- lua异常捕捉
function error(msg)
  local errorMsg = "[Lua error]"..msg
  printFunction(errorMsg)    
end

function beforeUserExit()

end
main()
--xpcall(main, error)