local CCBLoginView = require("app.views.LoginLayer")

local LoginView = class("LoginView", require("app.views.GameViewBase"))

function LoginView:init()
	self.m_ccbLoginView = CCBLoginView:create()
	self:addContent(self.m_ccbLoginView)
end

return LoginView