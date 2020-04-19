
local operateExcel = require("operateExcel");
local Tips = require("app.views.common.Tips");

local fileUtils = cc.FileUtils:getInstance()
local writablePath = fileUtils:getSearchPaths()[1]
local fileName = "bill.csv"
local filePath = writablePath .. fileName
local MAX_INFO_COL = 6

local PAY_YES = "✔"
local PAY_NO = "□"

local OS_DATE = os.date
local TABLE_NUMS = table.nums

local MainView = class("MainView", function ()
	return cc.CSLoader:createNode("MainView.csb")
end)

function MainView:ctor(params)
	params = params or {}
	if fileUtils:isFileExist(filePath) == false and fileUtils:createDirectory(writablePath) then
		if copyFile(fileName) then
			print("-----------create file success,path=", filePath)
		end
	end

	local BillDataFile = writablePath .. BILL_DATA_NAME
	if fileUtils:isFileExist(BillDataFile) == false and fileUtils:createDirectory(writablePath) then
		if copyFile(BILL_DATA_NAME) then
			print("-----------create file success,path=", BillDataFile)
		end
	end

    operateExcel:loadCsvFile(filePath)

	self.Panel_bg = self:getChildByName("Panel_bg")
	self._node = {
		["title"] = self:createBox("title"), 
		["houseNo"] = self:createBox("houseNo"),
		["date"] = self:createBox("date"),
		["lastMonth1"] = self:createBox("lastMonth1"),
		["curMonth1"] = self:createBox("curMonth1"),
		["lastMonth2"] = self:createBox("lastMonth2"),
		["curMonth2"] = self:createBox("curMonth2"),
		["marks"] = self:createBox("marks"),
		["money" .. (MAX_INFO_COL+1)] = self:createBox("money" .. (MAX_INFO_COL+1)),
		["people"] = self:createBox("people"),
		["modifyDate"] = self:createBox("modifyDate"),

		["pay"] = self.Panel_bg:getChildByName("pay")
	}

	self._node["pay"].pay = (self._node["pay"]:getTitleText() == "PAY_YES" and "1" or "0")
	self._node["modifyDate"]:setText(OS_DATE("%Y/%m/%d-%H:%M:%S"))

	for i=1,MAX_INFO_COL do
		self._node["desc" ..i] = self:createBox("desc" ..i)
		self._node["unit" ..i] = self:createBox("unit" ..i)
		self._node["quant" ..i] = self:createBox("quant" ..i)
		self._node["price" ..i] = self:createBox("price" ..i)
		self._node["money" ..i] = self:createBox("money" ..i)
	end

	self.Panel_bg:getChildByName("save"):addTouchEventListener(function(sender, event)
		if event == ccui.TouchEventType.ended then
			if self.isModify then
                if self._node["curMonth1"]:getText() == "" or self._node["curMonth2"]:getText() == "" then
				    return Tips:create("请填入本月水/电")
                end

				self:saveLine()
				Tips:create("保存成功")

				self.isModify = false
			else
				Tips:create("已保存过或未修改")
			end
		end
	end);

	self.Panel_bg:getChildByName("back"):addTouchEventListener(function(sender, event)
		if event == ccui.TouchEventType.ended then
			require("app.views.LoginView"):create(function()
					require("app.views.MainView"):create():addTo(self);
			end):addTo(display.getRunningScene());

			display.runScene("MainScene")		
		end
	end);

	self.Panel_bg:getChildByName("help"):addTouchEventListener(function(sender, event)
		if event == ccui.TouchEventType.ended then
            App:enterScene("HelpScene")
		end
	end);

	self.Panel_bg:getChildByName("pay"):addTouchEventListener(function(sender, event)
		if event == ccui.TouchEventType.ended then
			self._node["pay"].pay = (self._node["pay"].pay == "1" and "0" or "1")
			self._node["pay"]:setTitleText((self._node["pay"].pay == "1" and PAY_YES or PAY_NO))
		end
	end);

	--self:readLineByID(params.str, params.id)

--[[
	local date=string.split(OS_DATE("%Y-%m-%d-%H-%M-%S"), "-");
	--local date = OS_DATE(“%Y-%m-%d %H:%M:%S”);
	print("-----------------",OS_DATE())
	while(true) do
	end
	]]

	self:enableNodeEvents();
end

function MainView:onEnter()
	print("-----------------MainView:onEnter----------------")
    self:findLineStr();
end

function MainView:getNumber(name)
	return tonumber(self._node[name]:getText()) or 0
end

function MainView:addTextEventListener()
	self.isModify = true

	local month1 = self:getNumber("curMonth1") - self:getNumber("lastMonth1")
	self._node["quant2"]:setText(month1)

	local month2 = self:getNumber("curMonth2") - self:getNumber("lastMonth2")
	self._node["quant3"]:setText(month2)

	local money = 0
	for i=1,MAX_INFO_COL do
		local quant = self:getNumber("quant" ..i)
		local price = self:getNumber("price" ..i)
		money = money + quant * price
		self._node["money" ..i]:setText(quant * price)
	end
	self._node["money" .. (MAX_INFO_COL+1)]:setText(money)
end

function MainView:createBox(nodeName,txt,size)
	local node = self.Panel_bg:getChildByName(nodeName)

	size = size or node:getContentSize()

	local nameBox = ccui.Scale9Sprite:create("blank.png")
	--nameBox:initWithSpriteFrameName()
	nameBox:setContentSize(size)

	local editName = ccui.EditBox:create(size, nameBox, nil, nil)
	editName:setAnchorPoint(node:getAnchorPoint())
	editName:setPosition(node:getPosition())
    editName:setFontSize(node:getFontSize())
    editName:setPlaceholderFontSize(node:getFontSize())
    editName:setFontColor(node:getColor())
    editName:setPlaceHolder(node:getPlaceHolder())
    editName:setPlaceholderFontColor(cc.c3b(128,128,128) or node:getPlaceHolderColor())
   -- editName:setMaxLength(16)

    editName:setText(node:getString())
    
	local function editBoxTextEventHandle(eventType)
        if eventType == "began" then
        elseif eventType == "ended" then
	        self:addTextEventListener()
        elseif eventType == "changed" then
	        self:addTextEventListener()
        elseif eventType == "return" then
	        self:addTextEventListener()
        end
     end
    editName:registerScriptEditBoxHandler(editBoxTextEventHandle)
    editName:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE )
    editName:setInputMode(cc.EDITBOX_INPUT_MODE_EMAILADDR)
    editName:setInputFlag(cc.EDITBOX_INPUT_FLAG_INITIAL_CAPS_WORD)
    self.Panel_bg:addChild(editName)

    node:removeSelf();

    return editName
end

function MainView:createEditBox(nodeName)
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

function MainView:readLineByID(str,id,isBill)
	print("666666666666666666666666666666,=",str)
	self._id = id or (self._node["houseNo"]:getText() .. "-" .. self._node["date"]:getText())
	local lineStr = str or operateExcel:getLineStrTable(self._id)--CSVReaderLine(filePath, self._id)
	if TABLE_NUMS(lineStr) <= 0 then
		Tips:create("没有找到数据")
		return
	end

	Tips:create("找到数据")

	--dump(lineStr)

	for i,v in pairs(self._node) do
		if lineStr[i] then
			self._node[i]:setText(lineStr[i])
		end
	end

	self._node["pay"]:setTitleText(lineStr.pay == "1" and PAY_YES or PAY_NO)
	self._node["pay"].pay = lineStr.pay

    if isBill then
	    self._node["curMonth1"]:setText("")
	    self._node["lastMonth1"]:setText(lineStr.lastMonth1)
	    self._node["curMonth2"]:setText("")
	    self._node["lastMonth2"]:setText(lineStr.lastMonth2)
    end
end	

function MainView:saveLine()
	self.m_line = {}
	self.m_line[#self.m_line+1] = self._node["houseNo"]:getText() .. "-" .. self._node["date"]:getText() .. ","
	self._id = self.m_line[#self.m_line]

	self.m_line[#self.m_line+1] = self._node["pay"].pay .. ","
	self.m_line[#self.m_line+1] = self._node["curMonth1"]:getText() .. ","
	self.m_line[#self.m_line+1] = self._node["lastMonth1"]:getText() .. ","
	self.m_line[#self.m_line+1] = self._node["curMonth2"]:getText() .. ","
	self.m_line[#self.m_line+1] = self._node["lastMonth2"]:getText() .. ","

	local money = 0;
	for i=1,MAX_INFO_COL do
		self.m_line[#self.m_line+1] = self._node["desc" ..i]:getText() .. ","
		self.m_line[#self.m_line+1] = self._node["unit" ..i]:getText() .. ","
		self.m_line[#self.m_line+1] = self._node["quant" ..i]:getText() .. ","
		self.m_line[#self.m_line+1] = self._node["price" ..i]:getText() .. ","
		self.m_line[#self.m_line+1] = self._node["money" ..i]:getText() .. ","
	end

	--CSVSaveLine(filePath, self._id, table.concat(self.m_line))
	self.m_line[#self.m_line+1] = self._node["money" .. (MAX_INFO_COL+1)]:getText() .. ","
	self.m_line[#self.m_line+1] = self._node["date"]:getText() .. ","
	self.m_line[#self.m_line+1] = self._node["marks"]:getText() .. ","

	self.m_line[#self.m_line+1] = self._node["people"]:getText() .. ","
	self.m_line[#self.m_line+1] = self._node["modifyDate"]:getText()

 	self.m_line = tostring(table.concat(self.m_line))

 	--dump(self.m_line)

	operateExcel:addLineStr(self._id, self.m_line)
	--CSVSaveLine(filePath, self._id, self.m_line)
end

function MainView:getLastDay(dataTable)
	local h = tonumber(dataTable[1])
	local month = tonumber(dataTable[2]) - 1
	if month <= 0 then
		month = 12
		h = h - 1
	end

	return {h,month,dataTable[3]}
end

function MainView:findLineStr()
	print("-----------------MainView:findLineStr----------------")
	--if self._id then
		return self:readLineByID(nil,"306-2020/04/10")
	-- end

 --    local sign = "/"
	-- local date = OS_DATE("%Y"..sign.."%m"..sign.."%d")
	-- local dataTable = self:getLastDay(string.split(date, sign))
 --    dataTable[2] = tonumber(dataTable[2])
 --    dataTable[3] = tonumber(dataTable[3])

 --    local day = dataTable[3]
 --    local houseNo = BillData[day] or {}
 --    local str = ""
	-- for i=1,#houseNo do
	-- 	str = operateExcel:getLineStrTable(houseNo[i] .. "-" ..date)--CSVReaderLine(filePath, houseNo[i] .. "-" ..date)
	-- 	if TABLE_NUMS(str) <= 0 then--未开单
	-- 	    str = operateExcel:getLineStrTable(houseNo[i] .. "-" .. dataTable[1]..sign..dataTable[2]..sign..day)--CSVReaderLine(filePath, houseNo[i] .. "-" .. dataTable[1]..sign..dataTable[2]..sign..day)
 --            self:readLineByID(str,nil,true)
 --        else--已开单
	-- 	    if str[2] == "1" then--已收钱
 --            else--没收钱
 --            end
	-- 		self:readLineByID(str)
	-- 	end
 --    end
end

return MainView