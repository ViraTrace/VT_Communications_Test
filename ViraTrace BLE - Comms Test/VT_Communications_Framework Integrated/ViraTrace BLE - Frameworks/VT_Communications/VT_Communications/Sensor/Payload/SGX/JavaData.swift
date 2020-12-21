///**
/**



Created by: Wayne Thornton on 11/10/20
Portions Copyright © 2020 to Present ViraTrace LLC. All Rights Reserved.

This file contains Original Code and/or Modifications of Original code as defined in and that are subject to the ViraTrace Public Source License Version 1.0 (the ‘License’). You may not use this file except in compliance with the License. Please obtain of copy of the Licenses at https://github.com/ViraTrace/License and read it before using this file.

The Original Code and all software distributed under the License are distributed on an ‘AS IS’ basis, WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESS OR IMPLIED, AND VIRATRACE HEREBY DISCLAIMS ALL SUCH WARRANTIES, INCLUDING WITHOUT LIMITATION, ANY WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, QUIET ENJOYMENT OR NON-INFRINGEMENT. Please see the License for the specific language governing rights and limitations under the License.

*/

import Foundation

/// Java compatible data conversion for interoperability with Android and Java Server.
class JavaData {
    
    /// Convert 32-byte array to Java long value.
    static func byteArrayToLong(digest: Data) -> Int64 {
        let data = [UInt8](digest)
        let valueData: [UInt8] = [data[0], data[1], data[2], data[3], data[4], data[5], data[6], data[7]].reversed()
        let value = valueData.withUnsafeBytes { $0.load(as: Int64.self) }
        return value
    }
    
    /// Convert Java long value to 32-byte array.
    static func longToByteArray(value: Int64) -> Data {
        let valueData = (withUnsafeBytes(of: value) { Data($0) }).reversed()
        let data = Data(valueData)
        return data
    }

}
