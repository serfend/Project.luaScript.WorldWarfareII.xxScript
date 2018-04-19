require "usingPack"
require "util"--加载工具

require "SettingACheck"--加载全局设置

function main()

	UserSettingForm=UI:new()
	start,userSetting=UserSettingForm:show()
	if start==0 then 
		return false;
	end
	skill=Skill:new{Interval=Skill["Interval"]}
	building = Building:new()
	auth=Authorization:new()
	gameTask=GameTask:new()
	messageHdl=Message:new()
	troop=Troop:new()
	conscript=Conscript:new()
	MainForm=Form:new()
	ocr=OCR:new()
	skill:setUseSkill(userSetting)
	gameTask:NeedRefresh()
	
	if Setting.Task.EnableAutoProcessTaskDuplicate then
		gameTask.MainThreadTaskRefresh=false
	end
	--GetUserImages(15,2)
	mainLoop()
end
function mainLoop()

	while(true) do
		--auth:Check()
	
		--messageHdl:Run()
		if MainForm:Exit(true) then
			mSleep(200)
		end
		if skill:Exit() then
			mSleep(1000)
		end
		conscript:Run()
		Init:GetNowDetail()
		Setting.Main.Runtime=Setting.Main.Runtime+1
		
		gameTask:Run()
		skill:Run()
		building:Run()
		conscript:Run()
		
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