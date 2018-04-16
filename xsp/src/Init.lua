--初始化游戏所需全局参数
Init={}
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
		Res={
			Diamond=0,
			Crystals=0,
			Coin=0,
		},
		
	},
	Skill={
		Interval=600,
		SupplyCard={
			card50=false,
			card100=false,
			card200=false,
			card不足时购买=false,
		}
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
			[1]={"主城",4,3,false,false,40,40,15},
			[2]={"农场",1,1,false,false,6,6,4},
			[3]={"铁矿",2,2,false,false,6,6,4},
			[4]={"橡胶厂",1,1,false,false,6,6,4},
			[5]={"油井",1,1,false,false,6,6,4},
			[6]={"兵工厂",2,-4,false,false,40,40,0},
			[7]={"陆军基地",2,-4,false,false,40,40,0},
			[8]={"炮塔",3,3,false,false,6,6,6},
			[9]={"商业区",6,6,false,false,6,6,6},
			[10]={"补给品厂",6,6,false,false,6,6,6},
			[11]={"空军基地",7,-7,false,false,20,20,20},
		},
		Field={
			[1]={"村庄",3,3,false,false,6,6,6},
			--[2]={"资源区",1,1,false,false,6},
			--[3]={"none",1,1,false,false,6},
			[2]={"单资源区",-4,-4,false,false,6,6,6},
			[3]={"双资源区",3,3,false,false,6,6,6},
			[4]={"农场",1,1,false,false,6,6,6},
			[5]={"铁矿",2,2,false,false,6,6,6},
			[6]={"橡胶厂",1,1,false,false,6,6,6},
			[7]={"油井",1,1,false,false,6,6,6},
			[8]={"狙击塔",-3,-3,false,false,6,6,6},
			[9]={"炮塔",-2,-2,false,false,6,6,6},
			--[10]={"军事区",-3,-3,false,false,6,6,6},
			--[11]={"港口",-3,-3,false,false,20,20,20,},
			--[12]={"海军基地",-3,-3,false,false,20,20,20},
		},
		CityMainSetting={
			SkipWhenHigherPriorityBuilingIsLackOfRescource=false,
			EnableAutoProductSupply=false,
			EnableAutoDevelop=false,
			EnableAutoRepair=false,
			EnableAutoConcilite=false,
			Supply={
				军费={false,0},--是否激活自动补充策略，当前资源量
				钢铁={false,0},
				橡胶={false,0},
				石油={false,0},
				人口={false,0},
			},
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

function Init:GetNowDetail()--获取钻石/水晶/金币数量
	local code,DiamondResult=ocr:GetNum(1752,30,1844,64)
	Setting.Main.Res.Diamond=tonumber(DiamondResult) or -1
	local code,CrystalsResult=ocr:GetNum(1752,116,1844,143)
	Setting.Main.Res.Crystals=tonumber(CrystalsResult) or -1
	local code,CointResult=ocr:GetNum(1752,197,1844,223)
	Setting.Main.Res.Coin=tonumber(CointResult) or -1
	ShowInfo.ResInfo("res:"..
		Setting.Main.Res.Diamond..","..
		Setting.Main.Res.Crystals..","..
		Setting.Main.Res.Coin
	)
end