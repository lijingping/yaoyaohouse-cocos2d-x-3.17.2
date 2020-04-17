
local MainScene = class("MainScene", require("app.scenes.GameSceneBase"))

function MainScene:init()
	self:initView("MainView")
end

return MainScene