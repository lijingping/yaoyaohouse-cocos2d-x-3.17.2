
local fileUtils = cc.FileUtils:getInstance()
local string_split = string.split
local string_find = string.find
local string_sub =  string.sub

local operateExcel = {}

--读取文件内容，返回一个字符串
function operateExcel:getFile(file_name)
  local f = assert(io.open(file_name,'r'))  --确保读取文件不会错误
  local string = f:read("*all") --读取文件的所有内容
  f:close()  --这里记得关闭文件指针
  return string 
end
 
function operateExcel:split(str,reps)  --这里是分割字符串的函数
    local resultStrsList = {}
    string.gsub(str,'[^' .. reps ..']+',function(w) table.insert(resultStrsList,w) end)
    return resultStrsList
end

function operateExcel:loadCsvFile(filePath)
    if self._filePath then return end

    -- 读取文件
    self._filePath = filePath
    self._excel = fileUtils:getStringFromFile(filePath)--self:getFile(filePath)

    -- 按行划分
    local _lineStrTable = string_split(self._excel, '\n')
    self._titleStrTable = {
        [1] = string_split(_lineStrTable[1], ","),
        [2] = string_split(_lineStrTable[2], ","),

        [3] = _lineStrTable[1],
        [4] = _lineStrTable[2]
    }
    self._data = {}
    self._lineStrTable = {}
    for i=3,#_lineStrTable do
        self._lineStrTable[string_sub(_lineStrTable[i], 0, string_find(_lineStrTable[i],",")-1)] =_lineStrTable[i]
    end

    --dump(self._titleStrTable)
end

function operateExcel:getLineStrTable(key)
    if self._data[key] then
        return self._data[key]
    end

	--[[
	    从第3行开始保存（第一行是标题，第二行是注释，后面的行才是内容） 

	    用二维数组保存：arr[ID][属性标题字符串]
	]]

    self._data[key] = {}

    local data = self._lineStrTable[key]
    if data then
        -- 一行中，每一列的内容
        local content = string_split(data, ",")

        -- 以标题作为索引，保存每一列的内容，取值的时候这样取：arrs[1].Title
        for j = 1, #self._titleStrTable[1] do
            self._data[key][self._titleStrTable[1][j]] = content[j]
        end
    end

    return self._data[key]
end

function operateExcel:addLineStr(key, lineStr)
	--[[
	    从第3行开始保存（第一行是标题，第二行是注释，后面的行才是内容） 

	    用二维数组保存：arr[ID][属性标题字符串]
	]]

    local lineStrTable = {}
    local lineStrSpilt = string_split(lineStr, ",")
 	for j = 1, #self._titleStrTable[1] do
        lineStrTable[self._titleStrTable[1][j]] = lineStrSpilt[j]
    end
    self._data[key] = clone(lineStrTable)

    self._lineStrTable[key] = clone(lineStr)
    --self._excel = self._excel .. "\n" .. lineStr
    --fileUtils:writeStringToFile(self._excel, self._filePath)

    --local file = io.open(self._filePath, "wb")

    self._excel = self._titleStrTable[3].."\n"..self._titleStrTable[4]
    --file:write(self._lineStrTable[1])
    for _,v in pairs(self._lineStrTable) do
        --file:write("\n")
        --file:write(self._lineStrTable[i])
        self._excel = self._excel.."\n"..v
    end
    fileUtils:writeStringToFile(self._excel, self._filePath)

    --file:write(self._excel)
    --file:close()
    --self._excel = self._excel .. '\n\r'
end

return operateExcel