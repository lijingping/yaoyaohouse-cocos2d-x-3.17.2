cc.FileUtils:getInstance():setPopupNotify(false)
cc.FileUtils:getInstance():addSearchPath("src/")
cc.FileUtils:getInstance():addSearchPath("res/")


require "config"
require "constant"
require "cocos.init"

App = require("app.MyApp");	
Network = require("packages.network.Network");		-- 网络连接相关接口

Utils = require("app.utils.Utils");

Audio = require("packages.audio.Audio");				-- 声音相关接口
Str = require("app.data.stringData");					-- 中文文本
-------------
-- 游戏入口 --
-------------
local function main()
	Network:init()
	Audio:init()
	Utils:ctor();

	-- App = require("app.MyApp"):create() -- 创建APP
	App:ctor();    
    App:run() --从正常游戏流程启动，调用AppBase的run方法
end

local status, msg = xpcall(main, __G__TRACKBACK__)
if not status then
    print(" ~ main.lua ~ ", msg);
end
