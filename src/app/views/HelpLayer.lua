
local Tips = require("app.views.common.Tips");

local writablePath = cc.FileUtils:getInstance():getSearchPaths()[1] .. BILL_DATA_NAME

local HelpView = class("HelpView", function ()
	return cc.CSLoader:createNode("HelpView.csb")
end)

function HelpView:ctor()
	self.Panel_bg = self:getChildByName("Panel_bg")
	dump(BillData)
	self._node = {}
	local pos = cc.p(196.93, 625)
	for i=1,10 do
		local data = BillData[i]
		local str = ""
		if data then
			str = i .. "-" .. data[1]
			for j=2,#data do
				str = str .. "," .. data[j]
			end
		end
		self._node[#self._node+1] = self:createEditBox(pos,str,i .. "-205,305,202,401")
		pos.y = pos.y - 58
	end

	pos = cc.p(627.72, 625)
	for i=11,20 do
		local data = BillData[i]
		local str = ""
		if data then
			str = i .. "-" .. data[1]
			for j=2,#data do
				str = str .. "," .. data[j]
			end
		end
		self._node[#self._node+1] = self:createEditBox(pos,str,i .. "-205,305,202,401")
		pos.y = pos.y - 58
	end

	pos = cc.p(1078.73, 625)
	for i=21,31 do
		local data = BillData[i]
		local str = ""
		if data then
			str = i .. "-" .. data[1]
			for j=2,#data do
				str = str .. "," .. data[j]
			end
		end
		self._node[#self._node+1] = self:createEditBox(pos,str,i .. "-205,305,202,401")
		pos.y = pos.y - 58
	end


	self._desc = {}
	self._desc["find"] = self.Panel_bg:getChildByName("find")
	self._desc["houseNo"] = self:createEditBox(cc.p(176.93,self._desc["find"]:getPositionY()),"201","比如：201",cc.size(100,36))
	self._desc["date"] = self:createEditBox(cc.p(306.93,self._desc["find"]:getPositionY()),"2020/4/5","2020/4/5",cc.size(160,36))

    self.Panel_bg:getChildByName("find"):addTouchEventListener(function(sender, event)
		if event == ccui.TouchEventType.ended then
            if self._desc["houseNo"]:getText() == "" or self._desc["date"]:getText() == "" then
				return Tips:create("请填入房间号/日期")
            end

			print("555555555555555555555555555,=",self._desc["houseNo"]:getText().."-"..self._desc["date"]:getText())
			App:enterScene("MainScene"):getViewBase().m_ccbMainView
			m_ccbMainView:readLineByID(nil,self._desc["houseNo"]:getText().."-"..self._desc["date"]:getText())

		end
	end)

    self.Panel_bg:getChildByName("back"):addTouchEventListener(function(sender, event)
		if event == ccui.TouchEventType.ended then
			self:writeConfigfile(writablePath)

			App:enterScene("MainScene")
		end
	end)

    self._desc["login"] = self.Panel_bg:getChildByName("login")
    self._desc["login"]:setTitleText(BillData.isLogin and "关闭登入" or "打开登入")
    self._desc["login"]:addTouchEventListener(function(sender, event)
		if event == ccui.TouchEventType.ended then
			self:setVisible(false)
			--self:setTouchEnabled(false)

			BillData.isLogin = not BillData.isLogin
    		self._desc["login"]:setTitleText(BillData.isLogin and "关闭登入" or "打开登入")
			self:writeConfigfile(writablePath)
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
	placeHolder = placeHolder or "1-205,305,202,401,501"

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

function HelpView:writeConfigfile(path, mode)
    local file = io.open(path, mode or "w")
    file:write("return {")
	file:write("\n  ")
	for i,v in pairs(self._node) do
		if v:getText() ~= "" then
			local str = string.split(v:getText(), "-")

			file:write("[" .. str[1] .. "] = {")

			local houseNo = string.split(str[2], ",")
			file:write(houseNo[1])

			for i=2,#houseNo do
				file:write(","..houseNo[i])
			end
			file:write("},")
			file:write("\n  ")
		end
	end

	file:write("[\"isLogin\"]=" .. (BillData.isLogin and "true" or "false"))

	file:write("\n}")
    io.close(file)

    package.loaded[BILL_DATA_LUA] = nil
    BillData = require(BILL_DATA_LUA)

end

return HelpView