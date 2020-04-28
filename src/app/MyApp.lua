local savepath = device.writablePath.."yaoyaohome/";
cc.FileUtils:getInstance():addSearchPath(device.writablePath, true);
cc.FileUtils:getInstance():addSearchPath(savepath.."res", true);
cc.FileUtils:getInstance():addSearchPath(savepath.."src", true);
cc.FileUtils:getInstance():addSearchPath(savepath, true);

WRITABLE_PATH = cc.FileUtils:getInstance():getSearchPaths()[1]
BILL_CSV_NAME = "bill.csv"
BILL_CSV = WRITABLE_PATH .. BILL_CSV_NAME

BILL_DATA_NAME = "src/BillData.lua"
BILL_DATA_LUA = "src.BillData"
BillData = require(BILL_DATA_LUA)

local MyApp = class("MyApp", cc.load("mvc").AppBase)

function MyApp:onCreate()
    math.randomseed(os.time())
end

return MyApp
