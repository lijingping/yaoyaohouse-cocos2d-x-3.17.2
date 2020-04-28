
cc.FileUtils:getInstance():setPopupNotify(false)

require "config"
require "cocos.init"

App = require("app.MyApp")

Tips = require("app.views.common.Tips")
Utils = require("app.utils.Utils")

local function main()
    App:create():run()
end

local status, msg = xpcall(main, __G__TRACKBACK__)
if not status then
    print(msg)
end
