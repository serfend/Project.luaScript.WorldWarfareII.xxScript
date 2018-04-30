Mail={}
function Mail:new (o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end
function Mail:CheckMailRecived()
	x, y = findColor({811, 909, 1105, 1003}, 
	"0|0|0xfbc01d,183|0|0xfbc01d",
	95, 0, 0, 0)
	if x > -1 then
		return true
	else
		return false
	end
end
function Mail:CheckUserMailMessage()--检查邮件处理
	if not Setting.Task.EnableMailMessageHandle then
		ShowInfo.RunningInfo("跳过处理新邮件")
		return false
	end
		x, y = findColor({10, 330, 149, 462}, 
	"0|0|0xd00000,11|-3|0xd40000",
	95, 0, 0, 0)
	if x > -1 then
		ShowInfo.RunningInfo("处理新邮件")
		tap(x,y)
		sleepWithCheckLoading(500)
			x, y = findColor({1540, 100, 1580, 980}, 
			"0|0|0xf8fafb,0|15|0xcce8ee,0|30|0x20557d",
			95, 0, 0, 0)
		if x > -1 then
			ShowInfo.RunningInfo("有附件,领取...")
			tap(211,1033)--一键领取
			sleepWithCheckLoading(500)
			local haveNew=true
			while haveNew do
				tap(955,962)--确定
				sleepWithCheckLoading(300)
				haveNew=self:CheckMailRecived()
			end
		else
			tap(349,33)
		end
		sleepWithCheckLoading(500)
		Form:Exit()
	else
		
	end
end