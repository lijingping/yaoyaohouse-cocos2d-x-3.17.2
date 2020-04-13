
local Tips = require("app.views.common.Tips");

local fileUtils = cc.FileUtils:getInstance()
local writablePath = fileUtils:getSearchPaths()[1]
local fileName = "electronicInvoice.csv"
local filePath = writablePath .. fileName
local MAX_INFO_COL = 6

local CCBLoginView = class("CCBLoginView", function ()
	return cc.CSLoader:createNode("BillView.csb")
end)

function CCBLoginView:ctor()
	local operateExcel = require("operateExcel")
	operateExcel:loadCsvFile(filePath)
	operateExcel:addLineStr("306-2020/04/13",{
		ID="306-2020/04/13",houseID=306,price=45,lastElectric=69,curElectric=96,
		lastWater=9,curWater=7,net=1,date="2020年2月24号",lastValue=500,curValue=63,
		desc = "以后发电子收据，需要纸质收据说下 黄秀美"})

	if fileUtils:isFileExist(filePath) == false and fileUtils:createDirectory(writablePath) then
		if copyFile(fileName) then
			print("-----------create file success,path=", filePath)
		end
	end

	self.Panel_bg = self:getChildByName("Panel_bg")
	self._node = {
		["houseNo"] = self:createBox("houseNo"),
		["date"] = self:createBox("date"),
		["lastMonth1"] = self:createBox("lastMonth1"),
		["curMonth1"] = self:createBox("curMonth1"),
		["lastMonth2"] = self:createBox("lastMonth2"),
		["curMonth2"] = self:createBox("curMonth2"),
		["marks"] = self:createBox("marks"),
		["money" .. (MAX_INFO_COL+1)] = self:createBox("money" .. (MAX_INFO_COL+1))
	}

	self._node["marks"]:setString("")

	local desc = {"房租","电费","水费","网费","",""}
	for i=1,MAX_INFO_COL do
		self._node["desc" ..i] = self:createBox("desc" ..i):setString(desc[i])
		self._node["unit" ..i] = self:createBox("unit" ..i)
		self._node["quant" ..i] = self:createBox("quant" ..i)
		self._node["price" ..i] = self:createBox("price" ..i)
		self._node["money" ..i] = self:createBox("money" ..i)
	end

	self.Panel_bg:getChildByName("save"):addTouchEventListener(function(sender, event)
		if event == ccui.TouchEventType.ended then
			if self.isModify then
				self:saveLine()
				Tips:create("保存成功")

				self.isModify = false
			else
				Tips:create("已保存过或未修改")
			end
		end
	end);

	self.Panel_bg:getChildByName("find"):addTouchEventListener(function(sender, event)
		if event == ccui.TouchEventType.ended then
			self:readLineByID();
		end
	end);

	self:readLineByID()

--[[
	local date=string.split(os.date("%Y-%m-%d-%H-%M-%S"), "-");
	--local date = os.date(“%Y-%m-%d %H:%M:%S”);
	print("-----------------",os.date())
	while(true) do
	end
	]]
end

function CCBLoginView:getNumber(name)
	return tonumber(self._node[name]:getString()) or 0
end

function CCBLoginView:addTextEventListener()
	self.isModify = true

	local month1 = self:getNumber("curMonth1") - self:getNumber("lastMonth1")
	self._node["quant2"]:setString(month1)

	local month2 = self:getNumber("curMonth2") - self:getNumber("lastMonth2")
	self._node["quant3"]:setString(month2)

	local money = 0
	for i=1,MAX_INFO_COL do
		local quant = self:getNumber("quant" ..i)
		local price = self:getNumber("price" ..i)
		money = money + quant * price
		self._node["money" ..i]:setString(quant * price)
	end
	self._node["money" .. (MAX_INFO_COL+1)]:setString(money)
end

function CCBLoginView:createBox(nodeName)
	local node = self.Panel_bg:getChildByName(nodeName)
		:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
		--:setInputMode(cc.EDITBOX_INPUT_MODE_ANY)
	--print("2222222222222",node:getName(),node:getDescription())

	node:addEventListener(function(sender, eventType)
	    if eventType == ccui.TextFiledEventType.attach_with_ime then
	        print("00000000000000000")
	    elseif eventType == ccui.TextFiledEventType.detach_with_ime then
	        print("11111111111111")
	    elseif eventType == ccui.TextFiledEventType.insert_text then
	        print("222222222222")
	        self:addTextEventListener()
	    elseif eventType == ccui.TextFiledEventType.delete_backward then
	        print("333333333333")
	        self:addTextEventListener()
	    end
	end)
	return node
end

function CCBLoginView:readLineByID(id)
	self._id = id or (self._node["houseNo"]:getString() .. "-" .. self._node["date"]:getString())
	local str = CSVReaderLine(filePath, self._id);
	if string.len(str) <= 0 then
		Tips:create("没有找到数据")
		return
	end

	Tips:create("找到数据")

	local lineStr = string.split(str, ",")

	dump(lineStr)

	local col = 2
	self._node["houseNo"]:setString(lineStr[col])

	col = col + 1
	local c1 = col
	self._node["lastMonth1"]:setString(lineStr[col])
	col = col + 1
	local l1 = col
	self._node["curMonth1"]:setString(lineStr[col])
	col = col + 1
	local c2 = col
	self._node["lastMonth2"]:setString(lineStr[col])
	col = col + 1
	local l2 = col
	self._node["curMonth2"]:setString(lineStr[col])

	local unit = {"元","度","顿","元","元","元"};
	local quant = {"1",lineStr[c1]-lineStr[l1],lineStr[c2]-lineStr[l2]};
	for i=1,MAX_INFO_COL do
		self._node["unit" ..i]:setString(unit[i])

		col = col + 1
		self._node["quant" ..i]:setString(i > 3 and quant[i] or lineStr[col])

		col = col + 1
		self._node["price" ..i]:setString(lineStr[col])

		col = col + 1
		self._node["money" ..i]:setString(lineStr[col])
	end

	col = col + 1
	line[#line+1] = self._node["money" .. (MAX_INFO_COL+1)]:setString(lineStr[col])

	col = col + 1
	self._node["date"]:setString(lineStr[col])

	col = col + 1
	self._node["marks"]:setString(lineStr[col])
end	

function CCBLoginView:saveLine()
	local line = {}
	line[#line+1] = self._node["houseNo"]:getString() .. "-" .. self._node["date"]:getString() .. ","

	line[#line+1] = self._node["houseNo"]:getString() .. ","
	line[#line+1] = self._node["lastMonth1"]:getString() .. ","
	line[#line+1] = self._node["curMonth1"]:getString() .. ","
	line[#line+1] = self._node["lastMonth2"]:getString() .. ","
	line[#line+1] = self._node["curMonth2"]:getString() .. ","

	local money = 0;
	for i=1,MAX_INFO_COL do
		--line[#line+1] = self._node["desc" ..i]:getString() .. ","
		line[#line+1] = self._node["quant" ..i]:getString() .. ","
		line[#line+1] = self._node["price" ..i]:getString() .. ","
		line[#line+1] = self._node["money" ..i]:getString() .. ","
	end

	line[#line+1] = self._node["money" .. (MAX_INFO_COL+1)]:getString() .. ","
	line[#line+1] = self._node["date"]:getString() .. ","
	line[#line+1] = self._node["marks"]:getString()
	
	CSVSaveLine(filePath, self._id, table.concat(line))
end

return CCBLoginView