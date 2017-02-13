//
//  NoteOperator.swift
//  JCPerfectDemos
//
//  Created by Jeff on 05/02/2017.
//
//

import Foundation
import Result
import PerfectLogger

private let listKey = "list"
private let resultKey = "result"
private let descriptionKey = "description"
private let errorCodeKey = "errorCode"

enum ErrorCode: Int {
    case success
    case failure
}

class BaseOperator {
    let sqlManager = MySQLManager.sharedManager
    
    var result = [String : Any]()
    
    init() {
        sqlManager.selectDatabase(named: "Test")
    }
}

class UserOperator: BaseOperator {
    let userTableName = "user"
    
    func query(username: String) -> String? {
        let statement = "select id, username, password, create_time from user where username = '\(username)'"
        LogFile.info("process sql: \(statement)")
        
        if sqlManager.mySQL.query(statement: statement) {
            LogFile.info("sql: \(statement) query success")
            
            let results = sqlManager.mySQL.storeResults()!
            var dic = [String : String]()
            results.forEachRow(callback: { (row) in
                guard let userId = row.first! else { return }
                dic["userId"] = "\(userId)"
                dic["userName"] = "\(row[1]!)"
                dic["password"] = "\(row[2]!)"
                dic["create_time"] = "\(row[3]!)"
            })

            result[errorCodeKey] = 1
            result[resultKey] = dic
        } else {
            result[errorCodeKey] = ErrorCode.failure
            result[descriptionKey] = "查询失败"
        }
        
        return try? result.jsonEncodedString()
    }

    func insert(username: String, password: String) -> String? {
        let values = "('\(username)', '\(password)')"
        let statement = "insert into \(userTableName) (username, password) values \(values)"
        LogFile.info("process sql: \(statement)")
        
        var json: String?
        
        if sqlManager.mySQL.query(statement: statement) {
            LogFile.info("insert success")
            json = query(username: username)
        } else {
            LogFile.error("insert fail")
            result[errorCodeKey] = ErrorCode.failure
            result[descriptionKey] = "insert fail"
            
            json = try? result.jsonEncodedString()
        }
        print(json ?? "hahaha")
        return json
    }
    
    func delete(userId: String) -> String? {
        let statement = "delete from \(userTableName) where id='\(userId)'"
        
        LogFile.info("process sql: \(statement)")
        
        if sqlManager.mySQL.query(statement: statement) {
            LogFile.info("sql: \(statement) success")
            result[errorCodeKey] = ErrorCode.success
            result[resultKey] = [:]
        } else {
            result[errorCodeKey] = ErrorCode.failure
            result[descriptionKey] = "delete fail"
        }
        
        return try? result.jsonEncodedString()
    }
    
    func update(userId: String, userName: String, password: String) -> String? {
        let statement = "update \(userTableName) set username='\(userName)', password='\(password)', create_time=now() where id='\(userId)'"
        
        LogFile.info("process sql: \(statement)")

        if sqlManager.mySQL.query(statement: statement) {
            LogFile.info("sql: \(statement) success")
            return query(username: userName)
        } else {
            result[errorCodeKey] = ErrorCode.failure
            result[descriptionKey] = "update fail"
            return try? result.jsonEncodedString()
        }
    }
}





/// 操作内容相关的数据表
class ContentOperator: BaseOperator {
    let contentTableName = "content"
    
    
    /// 添加比较
    ///
    /// - Parameters:
    ///   - userId: 用户ID
    ///   - title: 标题
    ///   - content: 内容
    /// - Returns: 返回结果JSON
    func addContent(userId: String, title: String, content: String) -> String? {
        let values = "('\(userId)', '\(title)', '\(content)')"
        let statement = "insert into \(contentTableName) (userID, title, content) values \(values)"
        LogFile.info("执行SQL:\(statement)")
        
        if !sqlManager.mySQL.query(statement: statement) {
            LogFile.error("\(statement)插入失败")
            result[errorCodeKey] = ErrorCode.failure
            result[descriptionKey] = "创建\(title)失败"
        } else {
            LogFile.info("插入成功")
            result[errorCodeKey] = ErrorCode.success
            result[resultKey] = [:]
        }
        
        guard let josn = try? result.jsonEncodedString() else {
            return nil
        }
        return josn
    }
    
    
    /// 查询Note列表
    ///
    /// - Parameter userId: 用户ID
    /// - Returns: 返回JSON
    func queryContentList(userId: String) -> String? {
        let statement = "select id, title, content, create_time from \(contentTableName) where userID='\(userId)'"
        LogFile.info("执行SQL:\(statement)")
        
        if !sqlManager.mySQL.query(statement: statement) {
            result[errorCodeKey] = ErrorCode.failure
            result[descriptionKey] = "查询失败"
            LogFile.error("\(statement)查询失败")
        } else {
            LogFile.info("SQL:\(statement)查询成功")
            
            // 在当前会话过程中保存查询结果
            let results = sqlManager.mySQL.storeResults()! //因为上一步已经验证查询是成功的，因此这里我们认为结果记录集可以强制转换为期望的数据结果。当然您如果需要也可以用if-let来调整这一段代码。
            
            var ary = [[String:String]]() //创建一个字典数组用于存储结果
            if results.numRows() == 0 {
                LogFile.info("\(statement)尚没有录入新的Note, 请添加！")
            } else {
                results.forEachRow { row in
                    var dic = [String:String]() //创建一个字典用于存储结果
                    dic["contentId"] = "\(row[0]!)"
                    dic["title"] = "\(row[1]!)"
                    dic["content"] = "\(row[2]!)"
                    dic["time"] = "\(row[3]!)"
                    ary.append(dic)
                }
                result[resultKey] = ary
            }
            result[errorCodeKey] = ErrorCode.success
        }
        guard let josn = try? result.jsonEncodedString() else {
            return nil
        }
        return josn
    }
    
    
    /// 查询Note详情
    ///
    /// - Parameter contentId: 内容ID
    /// - Returns: 返回相关JOSN
    func queryContentDetail(contentId: String) -> String? {
        let statement = "select content from \(contentTableName) where id='\(contentId)'"
        LogFile.info("执行SQL:\(statement)")
        
        if !sqlManager.mySQL.query(statement: statement) {
            result[errorCodeKey] = ErrorCode.failure
            result[descriptionKey] = "查询失败"
            LogFile.error("\(statement)查询失败")
        } else {
            LogFile.info("SQL:\(statement)查询成功")
            
            // 在当前会话过程中保存查询结果
            let results = sqlManager.mySQL.storeResults()!
            
            var dic = [String:String]() //创建一个字典数于存储结果
            if results.numRows() == 0 {
                result[errorCodeKey] = ErrorCode.failure
                result[descriptionKey] = "获取Note详情失败！"
                LogFile.error("\(statement)获取Note详情失败！")
            } else {
                results.forEachRow { row in
                    guard let content = row.first! else {
                        return
                    }
                    dic["content"] = "\(content)"
                }
                result[resultKey] = dic
                result[errorCodeKey] = ErrorCode.success
            }
        }
        
        guard let josn = try? result.jsonEncodedString() else {
            return nil
        }
        return josn
    }
    
    
    /// 更新内容
    ///
    /// - Parameters:
    ///   - contentId: 更新内容的ID
    ///   - title: 标题
    ///   - content: 内容
    /// - Returns: 返回结果JSON
    func updateContent(contentId: String, title: String, content: String) -> String? {
        let statement = "update \(contentTableName) set title='\(title)', content='\(content)', create_time=now() where id='\(contentId)'"
        LogFile.info("执行SQL:\(statement)")
        
        if !sqlManager.mySQL.query(statement: statement) {
            result[errorCodeKey] = ErrorCode.failure
            result[descriptionKey] = "更新失败"
            LogFile.error("\(statement)更新失败")
        } else {
            LogFile.info("SQL:\(statement) 更新成功")
            result[errorCodeKey] = ErrorCode.success
        }
        
        guard let josn = try? result.jsonEncodedString() else {
            return nil
        }
        return josn
    }
    
    
    /// 删除内容
    ///
    /// - Parameter contentId: 删除内容的ID
    /// - Returns: 返回删除结果
    func deleteContent(contentId: String) -> String? {
        let statement = "delete from \(contentTableName) where id='\(contentId)'"
        LogFile.info("执行SQL:\(statement)")
        
        if !sqlManager.mySQL.query(statement: statement) {
            result[errorCodeKey] = ErrorCode.failure
            result[descriptionKey] = "删除失败"
            LogFile.error("\(statement)删除失败")
        } else {
            LogFile.info("SQL:\(statement) 删除成功")
            result[errorCodeKey] = ErrorCode.success
        }
        
        guard let josn = try? result.jsonEncodedString() else {
            return nil
        }
        return josn
    }
}






























