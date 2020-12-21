///**
/**



Created by: Wayne Thornton on 11/10/20
Portions Copyright © 2020 to Present ViraTrace LLC. All Rights Reserved.

This file contains Original Code and/or Modifications of Original code as defined in and that are subject to the ViraTrace Public Source License Version 1.0 (the ‘License’). You may not use this file except in compliance with the License. Please obtain of copy of the Licenses at https://github.com/ViraTrace/License and read it before using this file.

The Original Code and all software distributed under the License are distributed on an ‘AS IS’ basis, WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESS OR IMPLIED, AND VIRATRACE HEREBY DISCLAIMS ALL SUCH WARRANTIES, INCLUDING WITHOUT LIMITATION, ANY WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, QUIET ENJOYMENT OR NON-INFRINGEMENT. Please see the License for the specific language governing rights and limitations under the License.

*/

import Foundation

class TextFile {
    private let logger = ConcreteSensorLogger(subsystem: "Sensor", category: "Data.TextFile")
    private var file: URL?
    private let queue: DispatchQueue
    
    init(filename: String) {
        file = try? FileManager.default
        .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        .appendingPathComponent(filename)
        queue = DispatchQueue(label: "Sensor.Data.TextFile(\(filename))")
    }
    
    func empty() -> Bool {
        guard let file = file else {
            return true
        }
        return !FileManager.default.fileExists(atPath: file.path)
    }
    
    /// Append line to new or existing file
    func write(_ line: String) {
        queue.sync {
            guard let file = file else {
                return
            }
            guard let data = (line+"\n").data(using: .utf8) else {
                return
            }
            if FileManager.default.fileExists(atPath: file.path) {
                if let fileHandle = try? FileHandle(forWritingTo: file) {
                    fileHandle.seekToEndOfFile()
                    fileHandle.write(data)
                    fileHandle.closeFile()
                }
            } else {
                try? data.write(to: file, options: .atomicWrite)
            }
        }
    }
    
    /// Overwrite file content
    func overwrite(_ content: String) {
        queue.sync {
            guard let file = file else {
                return
            }
            guard let data = content.data(using: .utf8) else {
                return
            }
            try? data.write(to: file, options: .atomicWrite)
        }
    }
    
    /// Quote value for CSV output if required.
    static func csv(_ value: String) -> String {
        guard value.contains(",") || value.contains("\"") || value.contains("'") || value.contains("’") else {
            return value
        }
        return "\"" + value + "\""

    }
}

