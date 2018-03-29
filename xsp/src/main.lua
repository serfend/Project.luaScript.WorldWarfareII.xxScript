require "usingPack"
function main()
	require "util"--加载工具
	require "SettingACheck"--加载全局设置
	
	init("0", _orientation)--初始化触摸操控脚本
	
	mainLoop()
end
skill=Skill:new{Interval=Skill["Interval"]}
building = Building:new()
MainForm=Form:new()
function mainLoop()
	while(true) do
		MainForm:Exit()
		Setting.Main.Runtime=Setting.Main.Runtime+1
		if skill:NeedRefresh() then
			if skill:Enter() then
				skill:CheckNewSkillPoint()
				skill:UseSkills({1,2,3})
				skill:Exit()
			end
		end
		
		building:Enter()

		toast("本轮结束," .. Setting.Main.Interval .. "秒后开始")
		mSleep(Setting.Main.Interval*1000)
	end
end
-- lua异常捕捉
function error(msg)
  local errorMsg = "[Lua error]"..msg
  printFunction(errorMsg)    
end

--退出时隐藏HUD
function beforeUserExit()
  hideHUD(HUD.runing)
  hideHUD(HUD.resource)
end
main()
--xpcall(main, error)