
local string_split = string.split

local HelpView = class("HelpView", function ()
	return cc.CSLoader:createNode("HelpView.csb")
end)

function HelpView:ctor(params)
	self.Panel_bg = self:getChildByName("Panel_bg")
	--dump(BillData)
	self._node = {}
	local pos = cc.p(196.93, 625)
	for i=1,10 do
		local data = BillData[i]
		local str = ""
		if data then
			str = data[1]
			for j=2,#data do
				str = str .. "," .. data[j]
			end
		end
		self._node[#self._node+1] = self:createEditBox(pos,str,"205,305,202,401")
		pos.y = pos.y - 58
	end

	pos = cc.p(627.72, 625)
	for i=11,20 do
		local data = BillData[i]
		local str = ""
		if data then
			str = data[1]
			for j=2,#data do
				str = str .. "," .. data[j]
			end
		end
		self._node[#self._node+1] = self:createEditBox(pos,str,"205,305,202,401")
		pos.y = pos.y - 58
	end

	pos = cc.p(1078.73, 625)
	for i=21,31 do
		local data = BillData[i]
		local str = ""
		if data then
			str = data[1]
			for j=2,#data do
				str = str .. "," .. data[j]
			end
		end
		self._node[#self._node+1] = self:createEditBox(pos,str,"205,305,202,401")
		pos.y = pos.y - 58
	end


	self._desc = {}
	self._desc["find"] = self.Panel_bg:getChildByName("find")
	self._desc["houseNo"] = self:createEditBox(cc.p(156.93,self._desc["find"]:getPositionY()),"201","比如：201",cc.size(100,36))
	self._desc["date"] = self:createEditBox(cc.p(306.93,self._desc["find"]:getPositionY()),"2020/4/5","2020/4/5",cc.size(160,36))

    self.Panel_bg:getChildByName("find"):addTouchEventListener(function(sender, event)
		if event == ccui.TouchEventType.ended then
            if self._desc["houseNo"]:getText() == "" or self._desc["date"]:getText() == "" then
				return Tips:create("请填入房间号/日期")
            end
			params.mainView:readLineByID(nil, self._desc["houseNo"]:getText() .."-"..self._desc["date"]:getText())

			self:removeSelf()
		end
	end)

    self.Panel_bg:getChildByName("bill"):addTouchEventListener(function(sender, event)
		if event == ccui.TouchEventType.ended then
			params.mainView:findLineStr()

			self:removeSelf()
		end
	end)

    self.Panel_bg:getChildByName("back"):addTouchEventListener(function(sender, event)
		if event == ccui.TouchEventType.ended then
			self:writeConfigfile()

			self:removeSelf()
		end
	end)

    self._desc["openFile"] = self.Panel_bg:getChildByName("openFile")
    --self._desc["openFile"]:setTitleText("打开发票数据")
    self._desc["openFile"]:addTouchEventListener(function(sender, event)
		if event == ccui.TouchEventType.ended then
			local luaj = require "cocos.cocos2d.luaj"
	   		local ok,ret = luaj.callStaticMethod("org/cocos2dx/lua/AppActivity"
	   			,"getSDCardDocPath",{},"()Ljava/lang/String;")

			local SDCardDocPath = ret .. "/" .. BILL_CSV_NAME
			Utils:copyFile(BILL_CSV, SDCardDocPath)

	   		luaj.callStaticMethod("org/cocos2dx/lua/AppActivity"
	   			,"getCsvFileIntent",{SDCardDocPath},"(Ljava/lang/String;)V")
		end
	end)

	self.Panel_bg:getChildByName("deleteData"):addTouchEventListener(function(sender, event)
		if event == ccui.TouchEventType.ended then
			if BillData.deleteData then
				Tips:create("清除数据成功")

				cc.FileUtils:getInstance():removeFile(BILL_CSV)
				BillData.deleteData = false
				Utils:writeConfigfile()
			else
				Tips:create("已清除数据")
			end
		end
	end)
end

function HelpView:reset()
    self._desc["houseNo"]:setText("")
    self._desc["date"]:setText("")

	self:setVisible(true)
    --self:setTouchEnabled(true)
end

function HelpView:createEditBox(pos, txt, placeHolder,size)
	placeHolder = placeHolder or "205,305,202,401,501"

	size = size or cc.size(315,30)
	local nameBox = ccui.Scale9Sprite:create("input.png")
	--nameBox:initWithSpriteFrameName()
	nameBox:setContentSize(size)

	local editName = ccui.EditBox:create(size, nameBox, nil, nil);
	editName:setPosition(pos);
    editName:setFontSize(size.height)
    editName:setPlaceholderFontSize(size.height)
    editName:setFontColor(cc.c3b(0,0,0))
    editName:setPlaceHolder(placeHolder)
    editName:setPlaceholderFontColor(cc.c3b(128,128,128))
   -- editName:setMaxLength(16)

    editName:setText(txt)
    
	local function editBoxTextEventHandle(stringEventName, pSender)
		if stringEventName == "changed" then

		end
	end
    editName:registerScriptEditBoxHandler(editBoxTextEventHandle)
    editName:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE )
    editName:setInputMode(cc.EDITBOX_INPUT_MODE_EMAILADDR)
    editName:setInputFlag(cc.EDITBOX_INPUT_FLAG_INITIAL_CAPS_WORD)
    self.Panel_bg:addChild(editName)

    return editName
end

function HelpView:writeConfigfile()
    for i,v in pairs(self._node) do
        if v:getText() ~= "" then
            --local str = string_split(v:getText(), "-")
            BillData[tonumber(i)] = string_split(v:getText(), ",")
        end
    end

	Utils:writeConfigfile()
end

return HelpView