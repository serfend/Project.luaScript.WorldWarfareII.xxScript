--HUD显示参数
HUD={
	runing = createHUD(),			--用于显示当前状态
	resource = createHUD(),		--资源状态
}
ShowInfo={
	RunningInfo=function(info)
			sysLog("Running:"..info)
			showHUD(HUD.runing,
				info,_userDpi*0.03,"0xffffffff","0x4c000000"
				,0,_fsw*0.5,0,_fsw*0.3,_fsh*0.02)
	end,
	ResInfo=function(info)
		sysLog("resource:"..info)
		showHUD(HUD.resource,
				info,_userDpi*0.03,"0xffffffff","0x4c000000",
				0,_fsw*0.5,_fsh*0.02,_fsw*0.3,_fsh*0.02)
	end
}