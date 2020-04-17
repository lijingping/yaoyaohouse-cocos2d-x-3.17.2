
local HelpScene = class("HelpScene", require("app.scenes.GameSceneBase"))

function HelpScene:init()
	self:initView("HelpView")
end

return HelpScene