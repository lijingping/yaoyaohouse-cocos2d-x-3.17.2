
local Tips = require("app.views.common.Tips");

local LoginView = class("LoginView", function ()
	return cc.CSLoader:createNode("LoginView.csb")
end)

function LoginView:ctor(callBack)
	self:init()

	self.callBack = callBack
	
	self.Panel_bg:getChildByName("login"):addTouchEventListener(function(sender, event)
		if event == ccui.TouchEventType.ended then
			if self.editName:getText() ~= "yaoyao" and self.editPassword:getText() ~= "Zyj112020" then
				return Tips:create("账号或密码错误，请重新输入")
			end

			App:enterScene("MainScene")
		end
	end);
end

function LoginView:init()
	self.Panel_bg = self:getChildByName("Panel_bg")

	local pwdBg = self.Panel_bg:getChildByName("pwdBg");	
	local nameBg = self.Panel_bg:getChildByName("nameBg");
	local size = nameBg:getContentSize()
	local nameBox = ccui.Scale9Sprite:create("input.png")
	--nameBox:initWithSpriteFrameName()
	nameBox:setContentSize(size)

	local passwordBox = ccui.Scale9Sprite:create("input.png")
	--passwordBox:initWithSpriteFrameName()
	passwordBox:setContentSize(size)

	local editName = ccui.EditBox:create(size, nameBox, nil, nil);
	editName:setPosition(size.width * 0.5, size.height * 0.5);
    editName:setFontSize(28)
    editName:setPlaceholderFontSize(20)
    editName:setFontColor(cc.c3b(255,255,255))
    editName:setPlaceHolder("请输入账号")
    editName:setPlaceholderFontColor(cc.c3b(128,128,128))
    editName:setMaxLength(16)
    editName:setText("yaoyao")
    
	local function editBoxTextEventHandle(stringEventName, pSender)
		if stringEventName == "changed" then
			local nameIsEn = self:editNameIsEnglish(editName:getText());
   			if nameIsEn == false then
    			editName:setText("")
			end
		end
	end	
    editName:registerScriptEditBoxHandler(editBoxTextEventHandle)
    editName:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE )
    editName:setInputMode(cc.EDITBOX_INPUT_MODE_EMAILADDR)
    editName:setInputFlag(cc.EDITBOX_INPUT_FLAG_INITIAL_CAPS_WORD)

   
	local editPassword = ccui.EditBox:create(size, passwordBox, nil, nil)
	editPassword:setPosition(size.width * 0.5, size.height * 0.5);
    editPassword:setFontSize(28)
    editPassword:setPlaceholderFontSize(20)
    editPassword:setFontColor(cc.c3b(255,255,255))
    editPassword:setPlaceHolder("请输入密码")
    editPassword:setPlaceholderFontColor(cc.c3b(128,128,128))
    editPassword:setMaxLength(20)
    editPassword:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
    editPassword:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
    editPassword:setInputFlag(cc.EDITBOX_INPUT_FLAG_PASSWORD)
    editPassword:setText("Zyj112020")


    nameBg:addChild(editName)
    pwdBg:addChild(editPassword)

    self.editName = editName
    self.editPassword = editPassword
end

function LoginView:editNameIsEnglish(editName)
	local isNameEn = true;
	for i=1, #editName do
		local editNameAscII = string.byte(editName, i)
		if editNameAscII > 127 then
			isNameEn = false;
		else
			isNameEn = true;
		end
	end
	return isNameEn
end

return LoginView