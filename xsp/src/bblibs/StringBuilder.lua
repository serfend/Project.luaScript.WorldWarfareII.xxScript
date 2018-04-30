StringBuilder = {
	data={}
}--初始化
function StringBuilder:new (o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

function StringBuilder:Append(str)
	table.insert(self.data,str)
end
function StringBuilder:ToString()
	return table.concat(self.data)
end

function string:getNumOnly(str)
	local cstr=StringBuilder:new()
	local strLen=string.len(str)
	for i=1,strLen do
		local thisChr=string.sub(str,i,i)
		local chrIndex= string.byte(thisChr)
		if chrIndex>=47 and chrIndex<=57 then
			cstr:Append(thisChr)
		end
	end
	return cstr:ToString()
end