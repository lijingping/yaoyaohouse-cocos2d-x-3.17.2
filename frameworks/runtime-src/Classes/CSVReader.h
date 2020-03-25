//
//  CSVReader.hpp
//  PA_Client
//
//  Created by LI on 2020/3/25.
//

#ifndef CSVReader_h
#define CSVReader_h

#include <iostream>
#include <string>
#include <map>
#include <vector>

using namespace std;

#define MAP_LINE std::map<std::string, std::string>            //key为首行字符串, value为此列字符串
#define MAP_CONTENT std::map<std::string, MAP_LINE>                //key为code, value为一行map
#define VEC_MAP  std::vector<std::pair<std::string, int>>

//csv文件读取器
class CSVReader
{
public:
    CSVReader();
    static CSVReader *getInst();    //获取实例
    
    //解析csv. fileName:csv文件名,
    void parse(const char *fileName);
    
    //获取内容map. filename:文件名
    const MAP_CONTENT &getContentMap(const std::string &filename);
    //获取一行map.filename:文件名， code一行code
    const MAP_LINE &getLineMap(const std::string &filename, const std::string &code);
    //获取某行某列的值
    const std::string  &getByCode(const std::string &filename, const std::string &code, const std::string &key);
    
    //保存csv的一行.line:一行的内容
    void saveCSVLine(const std::string &filename, const char *line, int index=3);
    
private:
    //读取csv的一行.line:一行的内容
    void readCSVLine(const char *line, const int &index);
    
    VEC_MAP m_firstVector;                                            //第一行的vector
    MAP_CONTENT m_contentMap;                                    //内容map
    std::map<std::string, MAP_CONTENT> m_fileMap;        //文件map
    
    static CSVReader *m_inst;        //实例
};

#endif /* CSVReader_h */
