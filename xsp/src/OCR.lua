OCR = {
	ocrNum,ocrNumBold,ocrString, msg = nil,nil,nil
}--初始化
function OCR:showError()
	dialog("加载字库错误:"..self.msg)
	lua_exit()
end
function OCR:new (o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
	self.ocrNum,self.msg=createOCR({
		type = "tesseract",
		path = "res/", -- 自定义字库暂时只能放在脚本res/目录下
		lang = "num" -- 使用生成的num.traineddata文件
	})
	if self.ocrNum==nil then
		self:showError()
	end
	self.ocrString,self.msg=createOCR({
		type = "tesseract",
		path = "[external]", 
		lang = "eng" 
	})
	if self.ocrString==nil then
		self:showError()
	end
	self.ocrNumBold,self.msg=createOCR({
		type = "tesseract",
		path = "res/", 
		lang = "numBold" 
	})
	if self.ocrNumBold==nil then
		self:showError()
	end
    return o
end
function OCR:GetNum(x1,y1,x2,y2,foreColor)
	local rect = {x1, y1, x2, y2}
	local diff = {foreColor or "0xffffff-0x0f0f0f"}
	local code, text = self.ocrNum:getText({
		rect = rect,
		diff = diff,
	})
	return code ,text
end
function OCR:GetNumBold(x1,y1,x2,y2,foreColor)
	local rect = {x1, y1, x2, y2}
	local diff = {foreColor or "0xffffff-0x0f0f0f"}
	local code, text = self.ocrNumBold:getText({
		rect = rect,
		diff = diff,
	})
	return code ,text
end
function OCR:GetString(x1,y1,x2,y2,foreColor)
	local rect = {x1, y1, x2, y2}
	local diff = {foreColor or "0xffffff-0x0f0f0f"}
	local code, text = self.ocrString:getText({
		rect = rect,
		diff = diff,
	})
	return code ,text
end
function OCR:GetStringInNum(x1,y1,x2,y2,foreColor)
	local rect = {x1, y1, x2, y2}
	local diff = {foreColor or "0xffffff-0x0f0f0f"}
	local code, text = self.ocrString:getText({
		rect = rect,
		diff = diff,
		whitelist="0123456789/M",
	})
	return code ,text
end