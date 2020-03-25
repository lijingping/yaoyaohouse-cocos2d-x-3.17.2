
local fileUtils = cc.FileUtils:getInstance()
local writablePath = fileUtils:getSearchPaths()[1]
local fileName = "electronicInvoice.csv"
local filePath = writablePath .. fileName

local CCBLoginView = class("CCBLoginView", function ()
	return CCBLoader("ccbi/loginView/CCBLoginView.ccbi")
end)

function CCBLoginView:ctor()
	if fileUtils:isFileExist(filePath) == false and fileUtils:createDirectory(writablePath) then
		if copyFile(fileName) then
			print("-----------create file success,path=", filePath)
		end
	end

	local lineStr = CSVReaderLine(filePath, "404-20200221")
	dump(lineStr)
	print("房间:",lineStr.ID)
	print("房租:",lineStr.price)
	print("上月电费:",lineStr.lastElectric)
	print("本月电费:",lineStr.curElectric)
	print("上月水费:",lineStr.lastWater)
	print("本月水费:",lineStr.curWater)
	print("是否有网:",lineStr.net)
	print("时间:",lineStr.date)
	print("备注或描述:",lineStr.desc)
	print("上月西边电费:",lineStr.lastValue)
	print("本月西边电费:",lineStr.curValue)

	local line = {}
	line[#line+1] = lineStr.ID
	line[#line+1] = ","
	line[#line+1] = lineStr.houseID
	line[#line+1] = ","
	line[#line+1] = lineStr.price
	line[#line+1] = ","
	line[#line+1] = lineStr.lastElectric
	line[#line+1] = ","
	line[#line+1] = lineStr.curElectric
	line[#line+1] = ","
	line[#line+1] = lineStr.lastWater
	line[#line+1] = ","
	line[#line+1] = lineStr.curWater
	line[#line+1] = ","
	line[#line+1] = lineStr.net
	line[#line+1] = ","
	line[#line+1] = lineStr.date
	line[#line+1] = ","
	line[#line+1] = lineStr.desc
	line[#line+1] = ","
	line[#line+1] = lineStr.lastValue
	line[#line+1] = ","
	line[#line+1] = lineStr.curValue
	
	CSVSaveLine(filePath, table.concat(line))
end

return CCBLoginView