--初始化游戏所需全局参数
Init={}

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
		EnableAutoProcessForkTask=false,
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
			EnableCityDevelop=false,
			EnableFieldDevelop=false,
			Supply={
				军费={false,0},--是否激活自动补充策略，当前资源量
				钢铁={false,0},
				橡胶={false,0},
				石油={false,0},
				人口={false,0},
			},
			
			EnableAutoImmediateBuilding=false,
			Value={
				MinImmediatePrice=0,
				MaxImmediatePrice=0,
			}
		},
		CityOtherSetting={
			SkipWhenHigherPriorityBuilingIsLackOfRescource=false,
			EnableAutoProductSupply=false,
			EnableAutoDevelop=false,
			EnableIntelligenceTransportRescource=false,
			EnableAutoRepair=false,
			EnableAutoConcilite=false,
			EnableCityDevelop=false,
			EnableFieldDevelop=false,
			
			EnableAutoImmediateBuilding=false,
			Value={
				MinImmediatePrice=0,
				MaxImmediatePrice=0,
			}
		},
		CityIndex={
			
		},
		FieldIndex={
			
		},

	},
	Army={
		Enable={
			AutoMerge=false,
			
		},
		Clearing={},
		army={--优先级 名称 种类 是否组建
			[1]={"步兵",1,true},
			[2]={"侦查车",1,true},
			[3]={"盟轻坦",1,true},
			[4]={"德轻坦",1,true},
			[5]={"反坦克",1,true},
			[6]={"盟摩托",1,true},
			[7]={"德摩托",1,true},
			[8]={"美装甲车",1,true},
			[10]={"德轻歼击",1,true},
			[9]={"美中坦",1,true},
			[11]={"盟中坦",1,true},
			[12]={"美轻歼击",1,true},
			[13]={"苏轻歼击",1,true},
			[14]={"攻城炮",1,true},
			[15]={"突击炮",1,true},
			[16]={"榴弹炮",1,true},
			[17]={"高射炮",1,true},
			[18]={"德重坦",1,true},
			[19]={"美重坦",1,true},
			[20]={"德重歼击",1,true},
			[21]={"自行火炮",1,true},
			[22]={"美重歼击",1,true},
			[23]={"德虎超坦",1,true},
			[24]={"苏超歼击",1,true},
			[25]={"侦察机",2,true},
			[26]={"运输机",2,true},
			[27]={"轰炸机",2,true},
			[28]={"战斗机",2,true},
			[29]={"俯冲轰炸机",2,true},
			[30]={"运输船",3,false},
			[31]={"驱逐舰",3,false},
			[32]={"巡洋舰",3,false},
			[33]={"战列舰",3,false},
			[34]={"航空母舰",3,false},
		},
		armyIndex={},
	}
}
for k,v in ipairs(Setting.Army.army) do
	Setting.Army.armyIndex[v[1]]=k
end
for k,v in ipairs(Setting.Building.City) do
	Setting.Building.CityIndex[v[1]]=k
end
for k,v in ipairs(Setting.Building.Field) do
	Setting.Building.FieldIndex[v[1]]=k
end
--可用性检测

--统计参数



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