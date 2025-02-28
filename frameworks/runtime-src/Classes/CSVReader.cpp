//
//  CSVReader.cpp
//  PA_Client
//
//  Created by LI on 2020/3/25.
//

#include "CSVReader.h"
#include <stdio.h>
#include <fstream>
#include "cocos2d.h"

#define MAX_LINE 2048

CSVReader *CSVReader::m_inst = NULL;

//构造函数
CSVReader::CSVReader()
{
    m_firstVector.clear();
    m_contentMap.clear();
    m_fileMap.clear();
    
    m_srcContentMap.clear();
    m_fileSrcMap.clear();
}

CSVReader::~CSVReader()
{
    m_firstVector.clear();
    m_contentMap.clear();
    m_fileMap.clear();
    
    m_srcContentMap.clear();
    m_fileSrcMap.clear();
}
//获取实例
CSVReader *CSVReader::getInst()
{
    if(!m_inst)
    {m_inst = new CSVReader();}
    
    return m_inst;
}

//获取内容map. filename:文件名
const MAP_CONTENT &CSVReader::getContentMap(const std::string &filename)
{
    return m_fileMap.find(filename)->second;
}
//获取一行map.filename:文件名， code一行code
const MAP_LINE &CSVReader::getLineMap(const std::string &filename, const std::string &code)
{
    return getContentMap(filename).find(code)->second;
}

const MAP_LINE &CSVReader::getContentSrcMap(const std::string &filename)
{
    return m_fileSrcMap.find(filename)->second;
}

const std::string &CSVReader::getLineSrcMap(const std::string &filename, const std::string &code)
{
    auto src = getContentSrcMap(filename).find(code);
    if(src != m_srcContentMap.end())
    {
        return src->second;
    }
    
    return "";
}

//获取某行某列的值
const std::string  &CSVReader::getByCode(const std::string &filename, const std::string &code, const std::string &key)
{
    return getLineMap(filename, code).find(key)->second;
}

//解析csv. fileName:csv文件名,
void CSVReader::parse(const char *fileName)
{
    m_contentMap.clear();        //首先进行清理

    std::string path = fileName;
    ssize_t size;
    const char *data = (const char*)(cocos2d::CCFileUtils::sharedFileUtils()->getFileData(path.c_str(),"r" , &size));
    CCAssert(data != NULL, "File is not exist.");
    if (data == NULL)
        return;
    
    char line[32768];    //一行最多字节数
    const char *src = data;
    if (size == 0)
        size = strlen(src);
    
    char *pl = line;        //指向line数组的指针
    int index = 0;
    bool skip = false;    //若一行为空，skip则标记为true
    
    while (data - src < size)
    {
        //读取到一行的末尾
        if (*data == '\n' && !skip)
        {
            *pl = '\0';
            readCSVLine(line, index);
            ++index;
            pl = line;
        }
        else if (*data == '\r')
        {}
        else
        {
            //任何一个字段能留空
            if (*data == '"')
                skip = !skip;
            
            *pl = *data;
            ++pl;
        }
        ++data;
    }
    *pl = '\0';
    
    //添加到map
    m_fileMap.insert(std::map<std::string, MAP_CONTENT>::value_type(fileName, m_contentMap));
}

void CSVReader::parseSrc(const char *fileName)
{
    m_srcContentMap.clear();        //首先进行清理
    
    std::string path = fileName;
    ssize_t size;
    const char *data = (const char*)(cocos2d::CCFileUtils::sharedFileUtils()->getFileData(path.c_str(),"r" , &size));
    CCAssert(data != NULL, "File is not exist.");
    if (data == NULL)
        return;
    
    char line[32768];    //一行最多字节数
    const char *src = data;
    if (size == 0)
        size = strlen(src);
    
    char *pl = line;        //指向line数组的指针
    int index = 0;
    bool skip = false;    //若一行为空，skip则标记为true
    
    while (data - src < size)
    {
        //读取到一行的末尾
        if (*data == '\n' && !skip)
        {
            *pl = '\0';
            
            readCSVSrcLine(line, index);
            
            ++index;
            pl = line;
        }
        else if (*data == '\r')
        {}
        else
        {
            //任何一个字段能留空
            if (*data == '"')
                skip = !skip;
            
            *pl = *data;
            ++pl;
        }
        ++data;
    }
    *pl = '\0';
    
    //添加到map
    m_fileSrcMap.insert(std::map<std::string, MAP_LINE>::value_type(fileName, m_srcContentMap));
}

//读取csv的一行.line:一行的内容
void CSVReader::readCSVLine(const char *line, const int &index)
{
    char value[32768];    //一行最多字节数
    if (*line == '\0')
        return;
    
    char *pv[32];
    char *tv = value;
    bool skip = false;
    int count = 0;
    
    *tv = '\0';
    pv[count++] = tv;
    
    while (*line != '\0')
    {
        if (*line == ',' && !skip)
        {
            *tv = '\0';
            ++tv;
            pv[count++] = tv;
        }
        else if (*line == '"')
        {
            skip = !skip;
        }
        else
        {
            *tv = *line;
            ++tv;
        }
        ++line;
    }
    *tv = '\0';
    
    //临时数组
    std::vector<std::pair<std::string, int> > tVector;
    for (int i=0; i<count; ++i)
    {tVector.push_back(std::map<std::string, int>::value_type(pv[i], i));}
    
    //第一行作为key
    if(index == 0)
    {m_firstVector = tVector;}
    //第2行为注释
    else if(index > 1)
    {
        //一行的map
        std::map<string, string> tmp;
        for (int i = 0; i < m_firstVector.size(); i++)
        {tmp.insert(std::map<string, string>::value_type(m_firstVector[i].first, tVector[i].first));}
        
        m_contentMap.insert(std::map<string, std::map<string, string>>::value_type(tVector[0].first.c_str(), tmp));
    }
}

void CSVReader::readCSVSrcLine(const char *line, const int &index)
{
    string strKey = line;
    strKey = strKey.substr(0, strKey.find(","));
    if(index <= 1)
    {
        m_titleVector.push_back(line);
    }
    //第2行为注释
    else{
        m_srcContentMap.insert(MAP_LINE::value_type(strKey, line));
    }
}

void CSVReader::saveCSVLine(const std::string &filename, const char *line, int index/*=3*/)
{
    m_contentMap.clear();        //首先进行清理
    readCSVLine(line, index);
    m_fileMap.insert(std::map<std::string, MAP_CONTENT>::value_type(filename, m_contentMap));
    
    ofstream outfile;
    outfile.open(filename, ios::app);
    if(outfile) //检查文件是否正常打开
    {
        outfile << line;
        outfile.close();
    }
}

void CSVReader::saveCSVSrcLine(const std::string &filename)
{
    ofstream outfile;
    outfile.open(filename);
    if(outfile) //检查文件是否正常打开
    {
        for (auto str : m_titleVector)
        {
            outfile<<str<<endl;
        }
        
        auto srcContentMap = m_fileSrcMap.find(filename)->second;
        auto iter = srcContentMap.begin();
        for (; iter != srcContentMap.end(); iter++)
        {
            outfile<<(*iter).second<<endl;
        }
        
        outfile.close();
    }
}


void CSVReader::modifyCSVSrcLine(const std::string &filename, const char* key, const string &line)
{
    m_srcContentMap.clear();
    m_srcContentMap = m_fileSrcMap.find(filename)->second;
    
    auto srcKey = m_srcContentMap.find(key);
    if(srcKey != m_srcContentMap.end())
    {
        m_srcContentMap.erase(key);
    }
    
    m_srcContentMap.insert(MAP_LINE::value_type(key, line));
    
    m_fileSrcMap.clear();
    m_fileSrcMap.insert(std::map<std::string, MAP_LINE>::value_type(filename, m_srcContentMap));
    
    saveCSVSrcLine(filename);
}
