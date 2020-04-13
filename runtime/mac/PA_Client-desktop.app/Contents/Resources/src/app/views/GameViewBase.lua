
local VersionLayer = require("app.views.common.VersionLayer")
local LoadingLayer = require("app.views.common.LoadingLayer")
--local CCBRevengeRequestPopup= require ("app.views.revengeView.CCBRevengeRequestPopup")

-----------------------
-- 界面基类，view继承此类
-----------------------
local GameViewBase = class("GameViewBase", cc.load("mvc").ViewBase)

function GameViewBase:onCreate()
    if self.init and type(self.init) == "function" then
        self:init()
    end
end

-- call every frame
function GameViewBase:baseUpdate(delta)
end

-- 添加版本号标签
-- function GameViewBase:addVersionLayer()
--     self:addContent(VersionLayer:create())
-- end

-- 弹出战舰搜索动画弹窗
function GameViewBase:popSearchView()

end

--弹出复仇请求
-- function GameViewBase:showRevengeRequestPopup(data)
--     --print("##########GameViewBase:showRevengeRequestPopup");
--     self.m_viewRevengeReques = CCBRevengeRequestPopup:create();
--     self:addContent(self.m_viewRevengeReques);
--     self.m_viewRevengeReques:setData(data);
-- end

return GameViewBase