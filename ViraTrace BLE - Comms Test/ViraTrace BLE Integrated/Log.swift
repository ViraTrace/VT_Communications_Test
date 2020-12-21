///**
/**



Created by: Wayne Thornton on 11/10/20
Portions Copyright © 2020 to Present ViraTrace LLC. All Rights Reserved.

This file contains Original Code and/or Modifications of Original code as defined in and that are subject to the ViraTrace Public Source License Version 1.0 (the ‘License’). You may not use this file except in compliance with the License. Please obtain of copy of the Licenses at https://github.com/ViraTrace/License and read it before using this file.

The Original Code and all software distributed under the License are distributed on an ‘AS IS’ basis, WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESS OR IMPLIED, AND VIRATRACE HEREBY DISCLAIMS ALL SUCH WARRANTIES, INCLUDING WITHOUT LIMITATION, ANY WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, QUIET ENJOYMENT OR NON-INFRINGEMENT. Please see the License for the specific language governing rights and limitations under the License.

*/
import Foundation
import os

/// Common log interface across supported iOS versions
class Log: NSObject {
    /// Define log level acros all logger messages
    private let logLevel: LogLevel = .debug
    private let subsystem: String
    private let category: String
    private let dateFormatter = DateFormatter()
    private let log: OSLog?
    
    required init(subsystem: String, category: String) {
        self.subsystem = subsystem
        self.category = category
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        if #available(iOS 10.0, *) {
            log = OSLog(subsystem: subsystem, category: category)
        } else {
            log = nil
        }
    }
    
    private func suppress(_ level: LogLevel) -> Bool {
        switch level {
        case .debug:
            return (logLevel == .info || logLevel == .fault);
        case .info:
            return (logLevel == .fault);
        default:
            return false;
        }
    }
    
    func log(_ level: LogLevel, _ message: String) {
        guard !suppress(level) else {
            return
        }
        // Write to unified os log if available, else print to console
        let timestamp = dateFormatter.string(from: Date())
        let csvMessage = message.replacingOccurrences(of: "\"", with: "'")
        let quotedMessage = (message.contains(",") ? "\"" + csvMessage + "\"" : csvMessage)
        let entry = timestamp + "," + level.rawValue + "," + subsystem + "," + category + "," + quotedMessage
        guard let log = log else {
            print(entry)
            return
        }
        if #available(iOS 10.0, *) {
            switch (level) {
            case .debug:
                os_log("%s", log: log, type: .debug, message)
            case .info:
                os_log("%s", log: log, type: .info, message)
            case .fault:
                os_log("%s", log: log, type: .fault, message)
            }
            return
        }
    }
    
    func debug(_ message: String) {
        log(.debug, message)
    }
    
    func info(_ message: String) {
        log(.debug, message)
    }
    
    func fault(_ message: String) {
        log(.debug, message)
    }
    
}

/// Log level for messages
enum LogLevel : String {
    case debug, info, fault
}
