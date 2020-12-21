///**
/**



Created by: Wayne Thornton on 11/10/20
Portions Copyright © 2020 to Present ViraTrace LLC. All Rights Reserved.

This file contains Original Code and/or Modifications of Original code as defined in and that are subject to the ViraTrace Public Source License Version 1.0 (the ‘License’). You may not use this file except in compliance with the License. Please obtain of copy of the Licenses at https://github.com/ViraTrace/License and read it before using this file.

The Original Code and all software distributed under the License are distributed on an ‘AS IS’ basis, WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESS OR IMPLIED, AND VIRATRACE HEREBY DISCLAIMS ALL SUCH WARRANTIES, INCLUDING WITHOUT LIMITATION, ANY WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, QUIET ENJOYMENT OR NON-INFRINGEMENT. Please see the License for the specific language governing rights and limitations under the License.

*/

import Foundation

/// SONAR payload supplier for integration with SONAR protocol. Payload data is 129 bytes.
public protocol SonarPayloadDataSupplier : PayloadDataSupplier {
}

/// Mock SONAR payload supplier for simulating payload transfer of the same size
public class MockSonarPayloadSupplier : SonarPayloadDataSupplier {
    static let length: Int = 129
    let identifier: Int32
    
    public init(identifier: Int32) {
        self.identifier = identifier
    }
    
    private func networkByteOrderData(_ identifier: Int32) -> Data {
        var mutableSelf = identifier.bigEndian // network byte order
        return Data(bytes: &mutableSelf, count: MemoryLayout.size(ofValue: mutableSelf))
    }
    
    public func payload(_ timestamp: PayloadTimestamp = PayloadTimestamp()) -> PayloadData {
        var payloadData = PayloadData()
        // First 3 bytes are reserved in SONAR
        payloadData.append(Data(repeating: 0, count: 3))
        payloadData.append(networkByteOrderData(identifier))
        // Fill with blank data to make payload the same size as that in SONAR
        payloadData.append(Data(repeating: 0, count: MockSonarPayloadSupplier.length - payloadData.count))
        return payloadData
    }
}

