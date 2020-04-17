local CCBHelpView = require("app.views.HelpLayer")

local HelpView = class("HelpView", require("app.views.GameViewBase"))

function HelpView:init()
	self.m_ccbHelpView = CCBHelpView:create()
	self:addContent(self.m_ccbHelpView)
end

return HelpView