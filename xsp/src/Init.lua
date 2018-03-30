--初始化游戏所需全局参数
Setting={
	Main={
		Interval=120,
		Runtime=0,
	},
	Skill={
		Interval=600,
	},
	Task={
		EnableOtherTask=false,
		EnableCollectEvent=false,
		EnableMailMessageHandle=false,
		EnableAutoHandleActivity=false,
	},
}
--可用性检测

--统计参数

--HUD显示参数
HUD={
	runing = createHUD(),			--用于显示当前状态
	resource = createHUD(),		--资源状态
}
ShowInfo={
	RunningInfo=function(info)
			sysLog("Running:"..info)
			showHUD(HUD.runing,
				info,10,"0xffffffff","0x4c000000"
				,0,_fsw*0.4,_fsh*0.05,100,20)
	end,
	ResInfo=function(info)
		sysLog("resource:"..info)
		showHUD(HUD.resource,
				info,10,"0xffffffff","0x4c000000",
				0,_fsw*0.4,_fsh*0.05+20,150,20)
	end
}