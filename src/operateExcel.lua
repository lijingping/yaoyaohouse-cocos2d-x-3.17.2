
local fileUtils = cc.FileUtils:getInstance()
local string_split = string.split
local string_find = string.find
local string_len =  string.len
local table_remove = table.remove

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
    self._lineStrTable = string_split(self._excel, '\n')
    self._titleStrTable = string_split(self._lineStrTable[1], ",")
    self._data = {}

    --self:deleteBlankLine(3)
    --local endIndex = #self._lineStrTable
    --if self._lineStrTable[endIndex] == "" or string_len(self._lineStrTable[endIndex]) <= 0 then
    --    table_remove(self._lineStrTable, endIndex)
    --end
    dump(self._lineStrTable)
end

function operateExcel:deleteBlankLine(startIndex)
    for i=startIndex,#self._lineStrTable do
        if self._lineStrTable[i] == "" or string_len(self._lineStrTable[i]) <= 0 then
            table_remove(self._lineStrTable, i)
            return self:deleteBlankLine(i+1)
        end
    end
end

function operateExcel:getLineStrTable(key)
    if self._data[key] then
        return self._data[key]
    elseif self._data[key] == nil then
        self._data[key] = {}
    end

	--[[
	    从第3行开始保存（第一行是标题，第二行是注释，后面的行才是内容） 

	    用二维数组保存：arr[ID][属性标题字符串]
	]]
    for i=3,#self._lineStrTable do
        -- 一行中，每一列的内容
        local content = string_split(self._lineStrTable[i], ",");
        if self._data[content[1]] == nil then
            self._data[content[1]] = {}
        end

        -- 以标题作为索引，保存每一列的内容，取值的时候这样取：arrs[1].Title
        for j = 1, #self._titleStrTable do
            self._data[content[1]][self._titleStrTable[j]] = content[j]
        end

        if key == content[1] then
            return self._data[key]
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
 	for j = 1, #self._titleStrTable do
        lineStrTable[self._titleStrTable[j]] = lineStrSpilt[j]
    end

    if self._data[key] then
        for i=3,#self._lineStrTable do
            local startStr, endStr = string_find(self._lineStrTable[i], lineStrTable["houseNo"], 0, true)
            if start or endStr then
                self._lineStrTable[i] = clone(lineStr)
                break
            end
        end
    else
        self._lineStrTable[#self._lineStrTable+1] = lineStr
    end

    if self._data[key] == nil then
        self._data[key] = {}
    end
    self._data[key] = clone(lineStrTable)
    --self._excel = self._excel .. "\n" .. lineStr
    --fileUtils:writeStringToFile(self._excel, self._filePath)

    --local file = io.open(self._filePath, "wb")

    self._excel = self._lineStrTable[1]
    --file:write(self._lineStrTable[1])
    for i=2,#self._lineStrTable do
        --file:write("\n")
        --file:write(self._lineStrTable[i])
        self._excel = self._excel.."\n"..self._lineStrTable[i]
    end
    fileUtils:writeStringToFile(self._excel, self._filePath)

    --file:write(self._excel)
    --file:close()
    --self._excel = self._excel .. '\n\r'
end

return operateExcel