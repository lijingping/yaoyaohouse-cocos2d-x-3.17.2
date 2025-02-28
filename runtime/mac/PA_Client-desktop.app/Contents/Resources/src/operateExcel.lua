
local fileUtils = cc.FileUtils:getInstance()

local operateExcel = {}
operateExcel._data = {}

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
    -- 读取文件
    self._filePath = filePath
    self._excel = self:getFile(filePath)--fileUtils:getStringFromFile(filePath)

    -- 按行划分
    self._lineStrTable = self:split(self._excel, '\n\r')
    self._titleStrTable = self:split(self._lineStrTable[1], ",")
    --dump(self._excel)
    --dump(self._lineStrTable)
    --dump(self._titleStrTable)
end

function operateExcel:getLineStrTable(key)
	--[[
	    从第3行开始保存（第一行是标题，第二行是注释，后面的行才是内容） 

	    用二维数组保存：arr[ID][属性标题字符串]
	]]

    if self._data[key] == nil then
    	self._data[key] = {}
    else
        return self._data[key]
    end

    for i=#self._lineStrTable,1 -1 do
        -- 一行中，每一列的内容
        local content = self:split(self._lineStrTable[i], ",");

        -- 以标题作为索引，保存每一列的内容，取值的时候这样取：arrs[1].Title
        for j = 1, #self._titleStrTable do
            self._data[key][self._titleStrTable[j]] = content[j]
            if self._data[key] then
                return self._data[key]
            end
        end
    end

    return self._data[key]
end

function operateExcel:addLineStr(key, lineStrTable)
	--[[
	    从第3行开始保存（第一行是标题，第二行是注释，后面的行才是内容） 

	    用二维数组保存：arr[ID][属性标题字符串]
	]]

    if self._data[key] == nil then
    	self._data[key] = {}
    end

    local content = lineStrTable[self._titleStrTable[1]]
 	for j = 2, #self._titleStrTable, 1 do
        print("------",self._titleStrTable[j], lineStrTable[self._titleStrTable[j]])
        content = content .. "," .. lineStrTable[self._titleStrTable[j]]
    end
    self._data[key] = clone(lineStrTable)
    self._lineStrTable[#self._lineStrTable] = content
    self._excel = self._excel .. content

    dump(self._excel)

    fileUtils:writeStringToFile(self._excel, self._filePath)
end

return operateExcel