require "Setting.usingPack"
require "Setting.UserSettingBase"
require "util"--加载工具

require "Setting.SettingACheck"--加载全局设置

function loadSetting()
	userTargetSettingName=getStringConfig("UserSettingBase","默认设置")
	ui=UI:new()
	option,userSetting=ui:show(userTargetSettingName)
	if option==0 then 
		setting=SettingBase:new()
		sysLog("设置初始化完成共计"..#setting.settings)
		setting:SwitchSetting()
		return loadSetting()
	end
	return true
end

function main()
	while not loadSetting() do end
	require "Setting.Hud"
	skill=Skill:new{Interval=Skill["Interval"]}
	building = Building:new()
	auth=Authorization:new()
	
	mainTask=MainTask:new()
	forkTask=ForkTask:new()
	mapEvent=MapEvents:new()
	Others=Others:new()
	
	messageHdl=Message:new()
	troop=Troop:new()
	conscript=Conscript:new()
	MainForm=Form:new()
	ocr=OCR:new()
	skill:setUseSkill(userSetting)
	mapEvent:NeedRefresh()
	
	if Setting.Task.EnableAutoProcessTaskDuplicate then
		MainTask.MainThreadTaskRefresh=false
	end
	--GetUserImages(45,2)
	ResetForm()--初始化
	buildPipeline()
	mainLoop()
end
mainLoopTargetQueue={}
function NormalTube()

end
function ResetForm()
	ShowInfo.RunningInfo("初始化")
	if MainForm:Exit(true) then
		mSleep(200)
	end
	if skill:Exit() then
		mSleep(1000)
	end
	Others:AutoExitActivityForm()
	Conscript:Reset()
end
PipelineTasks={}
function buildPipe(action,objSelf,nextTime,setEnable)
	nextTime=nextTime or 0
	setEnable=setEnable or true
	return {fun=action,this=objSelf,nextRuntime=nextTime,enable=setEnable}
end
function buildPipeline()
	table.insert(PipelineTasks,buildPipe(Init.GetNowDetail,nil))
	table.insert(PipelineTasks,buildPipe(mainTask.Run,mainTask))
	table.insert(PipelineTasks,buildPipe(conscript.Run,conscript))
	table.insert(PipelineTasks,buildPipe(forkTask.Run,forkTask))
	table.insert(PipelineTasks,buildPipe(skill.Run,skill))
	table.insert(PipelineTasks,buildPipe(mapEvent.NeedRefresh,mapEvent))--判断是否需要取野地事件
	table.insert(PipelineTasks,buildPipe(building.Run,building))
		--auth:Check()
		
		--messageHdl:Run()
end
function PipelinePredict(p1,p2)
	return p1.nextRuntime<=p2.nextRuntime
end
function DoPipeline()
	for i,pipelineTask in ipairs(PipelineTasks) do
		
		if pipelineTask.enable then
			if pipelineTask.nextRuntime<os.time() then
				if not pipelineTask.fun(pipelineTask.this) then
					ResetForm()
				end
			end
		end
	end
end
function mainLoop()
	while(true) do
		Setting.Main.Runtime=Setting.Main.Runtime+1
		DoPipeline()
		toast("本轮结束," .. Setting.Main.Interval .. "秒后开始")
		mSleep(Setting.Main.Interval*1000)
	end
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