local CCBMainView = require("app.views.MainLayer")

local MainView = class("MainView", require("app.views.GameViewBase"))

function MainView:init()
	self.m_ccbMainView = CCBMainView:create()
	self:addContent(self.m_ccbMainView)
end

return MainView