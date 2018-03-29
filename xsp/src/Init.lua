--初始化游戏所需全局参数
Setting={
	Main={
		Interval=120,
		Runtime=0,
	},
	Skill={
		Interval=600,
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
			showHUD(HUD.runing,
				info,16,"0xffffffff","0x4c000000"
				,0,1000,38,200,50)
	end,
	ResInfo=function(info)
		showHUD(HUD.resource,info,16,"0xffffffff","0x4c000000",0,700,88,500,50)
	end
}