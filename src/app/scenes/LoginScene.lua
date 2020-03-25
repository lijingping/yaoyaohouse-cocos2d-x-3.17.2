
local LoginScene = class("LoginScene", require("app.scenes.GameSceneBase"))

function LoginScene:init()
	self:initView("loginView.LoginView")
end

return LoginScene