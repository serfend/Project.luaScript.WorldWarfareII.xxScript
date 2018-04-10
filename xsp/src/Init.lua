--初始化游戏所需全局参数
ArmySetting={
	TroopSetting={
		
	}
}
BuildingAeroMain={
	主城=1,村庄=1,港口=1,军事区=1,资源区=1
}


Setting={
	Main={
		Interval=120,
		Runtime=0,
	},
	Skill={
		Interval=600,
	},
	Task={
		EnableAutoCompleteTask=false,
		EnableAutoProcessTask=false,
		EnableAutoProcessTaskDuplicate=false,
		EnableCollectEvent=false,
		EnableActiveCollectEvent=false,
		EnableMailMessageHandle=false,
		EnableAutoHandleActivity=false,
		CollectEvent={
			Interval=600
		}
	},
	--优先级,识别色
	Building={
		City={
			[1]={"主城",4,3},
			[2]={"农场",1,1},
			[3]={"铁矿",2,2},
			[4]={"橡胶厂",1,1},
			[5]={"油井",1,1},
			[6]={"兵工厂",2,-4},
			[7]={"陆军基地",2,-4},
			[8]={"炮塔",3,3},
			[9]={"商业区",6,6},
			[10]={"补给品厂",6,6},
			[11]={"空军基地",7,-7},
		},
		Field={
			[1]={"村庄",3,3},
			--[2]={"资源区",1,1},
			--[3]={"none",1,1},
			[2]={"单资源区",-4,-4},
			[3]={"双资源区",3,3},
			[4]={"农场",1,1},
			[5]={"铁矿",2,2},
			[6]={"橡胶厂",1,1},
			[7]={"油井",1,1},
			[8]={"狙击塔",-3,-3},
			[9]={"炮塔",-2,-2},
			--[10]={"军事区",-3,-3},
			--[11]={"港口",-3,-3},
			--[12]={"海军基地",-3,-3},
		},
		CityMainSetting={
			SkipWhenHigherPriorityBuilingIsLackOfRescource=false,
			EnableAutoProductSupply=false,
			EnableAutoDevelop=false,
			EnableAutoRepair=false,
			EnableAutoConcilite=false,
		},
		CityOtherSetting={
			SkipWhenHigherPriorityBuilingIsLackOfRescource=false,
			EnableAutoProductSupply=false,
			EnableAutoDevelop=false,
			EnableIntelligenceTransportRescource=false,
			EnableAutoRepair=false,
			EnableAutoConcilite=false,
		},
		CityIndex={},
		FieldIndex={},
		
		TestModelSetting={
			Enable=false,
			TestOption="",
		}
	},

}


for k,v in ipairs(Setting.Building.City) do
	Setting.Building.CityIndex[v[1]]=k
end
for k,v in ipairs(Setting.Building.Field) do
	Setting.Building.FieldIndex[v[1]]=k
end
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
				info,_userDpi*0.03,"0xffffffff","0x4c000000"
				,0,_fsw*0.5,0,_fsw*0.15,_fsh*0.02)
	end,
	ResInfo=function(info)
		sysLog("resource:"..info)
		showHUD(HUD.resource,
				info,_userDpi*0.03,"0xffffffff","0x4c000000",
				0,_fsw*0.5,20,_fsw*0.3,_fsh*0.02)
	end
}