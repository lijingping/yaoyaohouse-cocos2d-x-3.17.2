-----------------
-- 工具类
-----------------
local Utils = class("Utils")

function Utils:ctor()
	
end

-- 四舍五入
function Utils:round(number)
	local floored = math.floor(number)
	local floating = number - floored
	if floating >= 0.5 then
		return floored + 1
	end

	return floored
end

-- 设置上下限
function Utils:clamp(v, min, max)
	local temp = v
	if temp < min then
		temp = min
	end

	if temp > max then
		temp = max
	end

	return temp
end

-- 求一个向量的单位向量
function Utils:vec2Normalize(vector2)
    local n = vector2.x * vector2.x + vector2.y * vector2.y

    if n == 1 then return vector2 end

    n = math.sqrt(n)
    if n < 2e-37 then return vector2 end

    if n ~= 0 then
        n = 1 / n
    end

    return cc.vec2(vector2.x * n, vector2.y * n)
end

-- 求两个向量的夹角
function Utils:vec2Angle(vector1, vector2)
	local a1 = math.deg(math.atan2(vector1.y, vector1.x))
	local a2 = math.deg(math.atan2(vector2.y, vector2.x))

	return a1 - a2
end

-- 使节点晃动
function Utils:shake(node)
	node:stopAllActions()
	local rotateTo = cc.RotateTo:create(0.1, 1)
	local rotateBack = cc.RotateTo:create(0.1, -1)
	local seq = cc.Sequence:create(rotateTo, rotateBack)
	local repeating = cc.RepeatForever:create(seq)
	node:runAction(repeating)
end

-- 检查节点的范围内是否包含点
function Utils:containsPoint(node, point)
    if not node or not point then
        return false
    end

    local size = node:getContentSize()
    if not size then
        return false
    end
    
    if point.x > 0 and point.x < size.width and point.y > 0 and point.y < size.height then
        return true
    end

    return false
end

-- 复制文件
function Utils:copyFile(srcFile, dstFile)
	-- print(srcFile, dstFile)
    local inp = io.open(srcFile, "rb")
    local data = inp:read("*all")
    local out = io.open(dstFile, "wb")
    out:write(data)
    out:close()
    imp:close()
end

-- 二进制转字符串
function Utils:bytesToString(bytes)
  local s = {}
  
  for i = 1, #bytes do
    s[i] = string.char(bytes[i])
  end

  return table.concat(s)
end

function Utils:getRotationAngle(srcPos, destPos)
	local len_y = destPos.y - srcPos.y;
	local len_x = destPos.x - srcPos.x;
	local tan_yx = math.abs(len_y) / math.abs(len_x);

	if len_x == 0 and len_y > 0 then
		return 90;
	elseif len_x == 0 and len_y < 0 then
		return -90;
	elseif len_x > 0 and len_y == 0 then
		return 0;
	elseif len_x < 0 and len_y == 0 then
		return 180;
	elseif len_x > 0 and len_y < 0  then
		return math.atan(tan_yx)*180 / math.pi;
	elseif len_x < 0 and len_y < 0 then
		return 180 - math.atan(tan_yx)*180 / math.pi;
	elseif len_x < 0 and len_y > 0 then
		return 180 + math.atan(tan_yx)*180 / math.pi ;
	elseif len_x > 0 and len_y > 0 then
		return - math.atan(tan_yx)*180 / math.pi;
	end
end

function Utils:readJsonData(file)
	local jsonFile = cc.FileUtils:getInstance():getStringFromFile(file);
	local jsonTable = {};
	if jsonFile ~= nil and #jsonFile > 0 then
		jsonTable = json.decode(jsonFile);
	end
	if not jsonTable then
		jsonTable = {};
	end
	return jsonTable, jsonFile;
end


--长度计算
function Utils:getStringLenth(string)
	local len = string.len(string)
	local i = 1;
	local chCount = 0;
	local enCount = 0;
	while i <= len do
		if self:calcCharacterLength_UTF8(string.byte(string, i)) == 3 then
			chCount = chCount+1;
		elseif self:calcCharacterLength_UTF8(string.byte(string, i)) == 1 then
			enCount = enCount+1;
		end
		i = i+self:calcCharacterLength_UTF8(string.byte(string,i));
	end
	
	local stringLenth = chCount*3 + enCount;
	return stringLenth, chCount, enCount;
end

function Utils:calcCharacterLength_UTF8(ch)
	if ch >= 240 and ch <= 247 then
		return 4;
	elseif ch >= 224 and ch <= 239 then --中文
		return 3;
	elseif ch >= 192 and ch <= 223 then
		return 2;
	else --英文字符
		return 1;
	end
end

function Utils:writeConfigfile(data, path, mode)
    path = path or WRITABLE_PATH .. BILL_DATA_NAME

    local file = io.open(path, mode or "w")
    file:write("return {")
    file:write("\n  ")

    for i=1,31 do
        local houseNo = BillData[i]
        if houseNo then
            file:write("[" .. i .. "] = {")

            file:write(houseNo[1])
            for i=2,#houseNo do
                file:write(","..houseNo[i])
            end

            file:write("},")
            file:write("\n  ")
        end
    end

    file:write("[\"isLogin\"]=" .. (BillData.isLogin and "true" or "false"))
    file:write(",\n  ")
    file:write("[\"door\"]=" .. BillData.door)

    if BillData.user and BillData.pwd then
        file:write(",\n  ")
        file:write("[\"user\"]=" .. "\"" .. BillData.user .. "\"")
        file:write(",\n  ")
        file:write("[\"pwd\"]=" ..  "\"" .. BillData.pwd .. "\"")
    end

    file:write(",\n  ")
    file:write("[\"deleteData\"]=" .. (BillData.deleteData and "true" or "false"))

    file:write("\n}")
    io.close(file)

    package.loaded[BILL_DATA_LUA] = nil
    BillData = require(BILL_DATA_LUA)
end


local TOUCH_FILTER_NAME = "__touch_filter_node_name__"
local TouchFilter = class("TouchFilter", function(showTime, autohide, msg)
    return display.newLayer(cc.c4b(0, 0, 0, 0))
end)
--触摸过滤
function Utils:popupTouchFilter( showTime, autohide, msg, parent )
    local filter = TouchFilter:create(showTime, autohide, msg)
    local runScene = parent or cc.Director:getInstance():getRunningScene()
    if nil ~= runScene then
        local lastfilter = runScene:getChildByName(TOUCH_FILTER_NAME)
        if nil ~= lastfilter then
            lastfilter:stopAllActions()
            lastfilter:removeFromParent()
        end
        if nil ~= filter then
            filter:setName(TOUCH_FILTER_NAME)
            runScene:addChild(filter, 10000)
        end
    end
end

function Utils:dismissTouchFilter()
    local runScene = cc.Director:getInstance():getRunningScene()
    if nil ~= runScene then
        local filter = runScene:getChildByName(TOUCH_FILTER_NAME)
        if nil ~= filter then
            filter:stopAllActions()
            filter:removeFromParent()
        end
    end
end

return Utils