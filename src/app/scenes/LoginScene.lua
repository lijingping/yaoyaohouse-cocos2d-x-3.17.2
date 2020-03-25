
local LoginScene = class("LoginScene", require("app.scenes.GameSceneBase"))

function LoginScene:init()
	self:initView("LoginView")
end

return LoginScene