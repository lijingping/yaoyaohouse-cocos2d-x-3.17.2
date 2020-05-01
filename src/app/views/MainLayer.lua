
local operateExcel = require("operateExcel");

local fileUtils = cc.FileUtils:getInstance()
local MAX_INFO_COL = 6

local PAY_YES = "✔"
local PAY_NO = "□"

local OS_DATE = os.date
local TABLE_NUMS = table.nums
local string_split = string.split

local MainView = class("MainView", function ()
	return cc.CSLoader:createNode("MainView.csb")
end)

function MainView:ctor(params)
	params = params or {}

	self:enableNodeEvents();

	local BillDataFile = WRITABLE_PATH .. BILL_DATA_NAME
	if fileUtils:isFileExist(BillDataFile) == false and fileUtils:createDirectory(WRITABLE_PATH) then
		if copyFile(BILL_DATA_NAME) then
			print("-----------create file success,path=", BillDataFile)
		end
	end

	if (not BillData.deleteData or fileUtils:isFileExist(BILL_CSV) == false)
	and fileUtils:createDirectory(WRITABLE_PATH) then
		if copyFile(BILL_CSV_NAME) then
			print("-----------create file success,path=", BILL_CSV)

			BillData.deleteData = true
			Utils:writeConfigfile()
		end
	end


    operateExcel:loadCsvFile(BILL_CSV)

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
		["chanest"] = self:createBox("chanest"),
		["pay"] = self.Panel_bg:getChildByName("pay")
	}

	local pay = "0"
	self._node["pay"].pay = pay
	self._node["pay"]:setTitleText(pay == "1" and PAY_YES or PAY_NO)

	self._node["modifyDate"]:setText(OS_DATE("%Y/%m/%d-%H:%M:%S"))

	local data = string.gsub(OS_DATE("%Y/%m/%d"), "/0","/")
	self._node["date"]:setText(data)

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
	end)

	self.Panel_bg:getChildByName("back"):addTouchEventListener(function(sender, event)
		if event == ccui.TouchEventType.ended then
			-- require("app.views.LoginView"):create(function()
			-- 		require("app.views.MainView"):create():addTo(self);
			-- end):addTo(display.getRunningScene());

			App:enterScene("LoginScene")		
		end
	end)

	self.Panel_bg:getChildByName("help"):addTouchEventListener(function(sender, event)
		if event == ccui.TouchEventType.ended then
            -- require("app.views.HelpView"):create({mainView=self}):addTo(display.getRunningScene())
            App:enterScene("HelpScene")
		end
	end)

	self.Panel_bg:getChildByName("pay"):addTouchEventListener(function(sender, event)
		if event == ccui.TouchEventType.ended then
			local pay = self._node["pay"].pay == "1" and "0" or "1"
			self._node["pay"].pay = pay
			self._node["pay"]:setTitleText(pay == "1" and PAY_YES or PAY_NO)

			self.isModify = true
		end
	end)

	self.Panel_bg:getChildByName("shoot"):addTouchEventListener(function(sender, event)
		if event == ccui.TouchEventType.ended then
			local houseNoTable = string_split(self._node["houseNo"]:getText(),"-") or {}
			local filePath = houseNoTable[1] .. OS_DATE("_%Y_%m_%d_%H_%M_%S.png")
			
			local framesize = cc.Director:getInstance():getOpenGLView():getFrameSize()
	    	local area = cc.rect(0, 0, framesize.width, framesize.height)

			Utils:popupTouchFilter(0, false)
            captureScreenWithArea(area, filePath, function(ok, savepath)         
                if ok then
                	if device.platform == "android" then
		    			local luaj = require "cocos.cocos2d.luaj"
				   		local ok,ret = luaj.callStaticMethod("org/cocos2dx/lua/AppActivity"
				   			,"saveImgToSystemGallery",{savepath, filePath},"(Ljava/lang/String;Ljava/lang/String;)V")
				   	end
                end
                self:runAction(cc.Sequence:create(cc.DelayTime:create(3), cc.CallFunc:create(function()
                    Utils:dismissTouchFilter()
                end)))
            end)
		end
	end)
end

function MainView:onEnter()
	if self._id then
		self:readLineByID(nil, self._id)
	else
		self:findLineStr()
	end
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

	self._node["chanest"]:setText(self:numberTransiform(money))
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
	    elseif eventType == ccui.TextFiledEventType.detach_with_ime then
	    elseif eventType == ccui.TextFiledEventType.insert_text then
	        self:addTextEventListener()
	    elseif eventType == ccui.TextFiledEventType.delete_backward then
	        self:addTextEventListener()
	    end
	end)

	return node
end


function MainView:replaceAll(src, regex, replacement)
	return string.gsub(src, regex, replacement)
end

function MainView:cleanZero(s)
	-- 如果传入的是空串则继续返回空串
    if"" == s then    
        return ""
    end

    -- 字符串中存在多个'零'在一起的时候只读出一个'零'，并省略多余的单位
    
    local regex1 = {"零仟", "零佰", "零拾"}
    local regex2 = {"零亿", "零万", "零元"}
    local regex3 = {"亿", "万", "元"}
    local regex4 = {"零角", "零分"}
    
    -- 第一轮转换把 "零仟", 零佰","零拾"等字符串替换成一个"零"
    for i = 1, 3 do    
        s = MainView:replaceAll(s, regex1[i], "零")
    end

    -- 第二轮转换考虑 "零亿","零万","零元"等情况
    -- "亿","万","元"这些单位有些情况是不能省的，需要保留下来
    for i = 1, 3 do
        -- 当第一轮转换过后有可能有很多个零叠在一起
        -- 要把很多个重复的零变成一个零
        s = MainView:replaceAll(s, "零零零", "零")
        s = MainView:replaceAll(s, "零零", "零")
        s = MainView:replaceAll(s, regex2[i], regex3[i])
    end

    -- 第三轮转换把"零角","零分"字符串省略
    for i = 1, 2 do
        s = MainView:replaceAll(s, regex4[i], "")
    end

    -- 当"万"到"亿"之间全部是"零"的时候，忽略"亿万"单位，只保留一个"亿"
    s = MainView:replaceAll(s, "亿万", "亿")
    
    --去掉单位
    s = MainView:replaceAll(s, "元", "")
    return s
end

--人民币阿拉伯数字转大写
function MainView:numberTransiform(strCount)
	local big_num = {"零","壹","贰","叁","肆","伍","陆","柒","捌","玖"}
	local big_mt = {__index = function() return "" end }
	setmetatable(big_num,big_mt)
	local unit = {"元", "拾", "佰", "仟", "万",
                  --拾万位到千万位
                  "拾", "佰", "仟",
                  --亿万位到万亿位
                  "亿", "拾", "佰", "仟", "万",}
    local unit_mt = {__index = function() return "" end }
    setmetatable(unit,unit_mt)
    local tmp_str = ""
    local len = string.len(strCount)
    for i = 1, len do
    	tmp_str = tmp_str .. big_num[string.byte(strCount, i) - 47] .. unit[len - i + 1]
    end
    return MainView:cleanZero(tmp_str)
end

function MainView:readLineByID(str,id,isBill)
	self._id = id or (self._node["houseNo"]:getText() .. "-" .. self._node["date"]:getText())
	local lineStr = str or operateExcel:getLineStrTable(self._id)--CSVReaderLine(BILL_CSV, self._id);
	if TABLE_NUMS(lineStr) <= 0 then
		Tips:create("没有找到数据")
		return
	end

	--Tips:create("找到数据")

	--dump(lineStr)

	for i,v in pairs(self._node) do
		if lineStr[i] then
			if self._node[i].setText then
				self._node[i]:setText(lineStr[i])
			end
		end
	end

	local houseNoTable = string_split(self._node["houseNo"]:getText(),"-") or {}
	if houseNoTable[1] then
		self._node["houseNo"]:setText(houseNoTable[1])
	end

    if isBill then
	    self._node["curMonth1"]:setText("")
	    self._node["lastMonth1"]:setText(lineStr.lastMonth1)
	    self._node["curMonth2"]:setText("")
	    self._node["lastMonth2"]:setText(lineStr.lastMonth2)

	    local date = string.gsub(OS_DATE("%Y/%m/%d"), "/0","/")
		self._node["date"]:setText(date)

		self._node["pay"]:setTitleText(PAY_NO)
		self._node["pay"].pay = 0
	else
		self._node["pay"]:setTitleText(lineStr.pay == "1" and PAY_YES or PAY_NO)
		self._node["pay"].pay = lineStr.pay
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

	--CSVSaveLine(BILL_CSV, self._id, table.concat(self.m_line))
	self.m_line[#self.m_line+1] = self._node["money" .. (MAX_INFO_COL+1)]:getText() .. ","
	self.m_line[#self.m_line+1] = self._node["date"]:getText() .. ","
	self.m_line[#self.m_line+1] = self._node["marks"]:getText() .. ","

	self.m_line[#self.m_line+1] = self._node["people"]:getText() .. ","
	self.m_line[#self.m_line+1] = self._node["modifyDate"]:getText()

 	self.m_line = tostring(table.concat(self.m_line))

 	dump(self.m_line)

	operateExcel:addLineStr(self._id, self.m_line)
	--CSVSaveLine(BILL_CSV, self._id, self.m_line)
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
    local sign = "/"
	local date = string.gsub(OS_DATE("%Y"..sign.."%m"..sign.."%d"), "/0","/")

	local dataTable = self:getLastDay(string_split(date, sign))
    dataTable[2] = tonumber(dataTable[2])
    dataTable[3] = tonumber(dataTable[3])

    local day = dataTable[3]
    local houseNo = BillData[day] or {}
    
    local strPay = {}
    local str = ""
	for i=1,#houseNo do
		str = operateExcel:getLineStrTable(houseNo[i] .. "-" ..date)--CSVReaderLine(BILL_CSV, houseNo[i] .. "-" ..date)
		if TABLE_NUMS(str) <= 0 then--未开单
		    str = operateExcel:getLineStrTable(houseNo[i] .. "-" .. dataTable[1]..sign..dataTable[2]..sign..day)--CSVReaderLine(BILL_CSV, houseNo[i] .. "-" .. dataTable[1]..sign..dataTable[2]..sign..day)
            return self:readLineByID(str,nil,true)
        else--已开单
		    if str[2] == "1" then--已收钱
		    	strPay = str
            else--没收钱
				return self:readLineByID(str)
            end
		end
    end

    return self:readLineByID(strPay)
end

return MainView