///**
/**



Created by: Wayne Thornton on 11/10/20
Portions Copyright © 2020 to Present ViraTrace LLC. All Rights Reserved.

This file contains Original Code and/or Modifications of Original code as defined in and that are subject to the ViraTrace Public Source License Version 1.0 (the ‘License’). You may not use this file except in compliance with the License. Please obtain of copy of the Licenses at https://github.com/ViraTrace/License and read it before using this file.

The Original Code and all software distributed under the License are distributed on an ‘AS IS’ basis, WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESS OR IMPLIED, AND VIRATRACE HEREBY DISCLAIMS ALL SUCH WARRANTIES, INCLUDING WITHOUT LIMITATION, ANY WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, QUIET ENJOYMENT OR NON-INFRINGEMENT. Please see the License for the specific language governing rights and limitations under the License.

*/

import Foundation

///  payload supplier for integration with  backend. Payload data is 8 bytes.
public protocol SGXPayloadDataSupplier : PayloadDataSupplier {
}

///  payload supplier for generating time specific beacon codes based on day codes.
public class ConcretePayloadDataSupplier : SGXPayloadDataSupplier {
    private let dayCodes: DayCodes
    private let beaconCodes: BeaconCodes
    private let emptyPayloadData = PayloadData()
    
    public init(_ sharedSecret: SharedSecret) {
        dayCodes = ConcreteDayCodes(sharedSecret)
        beaconCodes = ConcreteBeaconCodes(dayCodes)
    }
    
    public func payload(_ timestamp: PayloadTimestamp = PayloadTimestamp()) -> PayloadData {
        guard let beaconCode = beaconCodes.get(timestamp) else {
            return emptyPayloadData
        }
        return JavaData.longToByteArray(value: beaconCode)
    }
}

