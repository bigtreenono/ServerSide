//
//  DataBaseOperator.swift
//  JCPerfectDemos
//
//  Created by Jeff on 05/02/2017.
//
//

import Foundation
import MySQL
import PerfectLogger

class MySQLManager {
    
    static let sharedManager = MySQLManager()
    
    func selectDatabase(named: String) {
        guard mySQL.selectDatabase(named: named) else {
            LogFile.error("connect \(named) failure, errorCode \(mySQL.errorCode()), errorMessage \(mySQL.errorMessage())")
            return
        }
        
        LogFile.info("connect \(named) success")
    }
    
    private init() {
        mySQL = MySQL()
        
        guard mySQL.connect(host: host, user: user, password: password) else {
            LogFile.error(mySQL.errorMessage())
            return
        }
        
        LogFile.info("connect success")
    }
    
    let mySQL: MySQL
    
    var host: String {
        return "127.0.0.1"
    }
    
    var port: String {
        return "3306"
    }
    
    var user: String {
        return "root"
    }
    
    var password: String? {
        return nil
        return "admin!@#"
    }
}






























