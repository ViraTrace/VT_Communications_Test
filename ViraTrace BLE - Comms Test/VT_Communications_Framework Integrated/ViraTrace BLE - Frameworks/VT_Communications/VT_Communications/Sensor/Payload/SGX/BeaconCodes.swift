///**
/**



Created by: Wayne Thornton on 11/10/20
Portions Copyright © 2020 to Present ViraTrace LLC. All Rights Reserved.

This file contains Original Code and/or Modifications of Original code as defined in and that are subject to the ViraTrace Public Source License Version 1.0 (the ‘License’). You may not use this file except in compliance with the License. Please obtain of copy of the Licenses at https://github.com/ViraTrace/License and read it before using this file.

The Original Code and all software distributed under the License are distributed on an ‘AS IS’ basis, WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESS OR IMPLIED, AND VIRATRACE HEREBY DISCLAIMS ALL SUCH WARRANTIES, INCLUDING WITHOUT LIMITATION, ANY WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, QUIET ENJOYMENT OR NON-INFRINGEMENT. Please see the License for the specific language governing rights and limitations under the License.

*/

import Foundation

/**
 Beacon codes are derived from day codes. On each new day, the day code for the day, being a long value,
 is taken as 64-bit raw data. The bits are reversed and then hashed (SHA) to create a seed for the beacon
 codes for the day. It is cryptographically challenging to derive the day code from the seed, and it is this seed
 that will eventually be distributed by the central server for on-device matching. The generation of beacon
 codes is similar to that for day codes, it is based on recursive hashing and taking the modulo to produce
 a collection of long values, that are randomly selected as beacon codes. Given the process is deterministic,
 on-device matching is possible, once the beacon code seed is provided by the server.
 */
protocol BeaconCodes {
    /// Get beacon code for given timestamp. This will be transmitted as clear text to other devices.
    func get(_ timestamp: Timestamp) -> BeaconCode?
}

/// Beacon code for identifying a device. This is derived from the shared secret.
public typealias BeaconCode = Int64

class ConcreteBeaconCodes : BeaconCodes {
    private let logger = ConcreteSensorLogger(subsystem: "Sensor", category: "Payload.ConcreteBeaconCodes")
    private static let codesPerDay = 240
    private var dayCodes: DayCodes
    // Cached beacon codes to avoid regeneration for every get request
    private var beaconCodeSeed: BeaconCodeSeed?
    private var beaconCodes: [BeaconCode]?
    
    init(_ dayCodes: DayCodes) {
        self.dayCodes = dayCodes
    }
    
    func get(_ timestamp: Timestamp) -> BeaconCode? {
        guard let (seed, _) = dayCodes.seed(timestamp) else {
            logger.fault("No seed code available")
            return nil
        }
        if seed != beaconCodeSeed {
            beaconCodeSeed = seed
            beaconCodes = ConcreteBeaconCodes.beaconCodes(seed)
        }
        guard let beaconCodes = beaconCodes else {
            return nil
        }
        let (daySecond, _) = UInt64(NSDate(timeIntervalSince1970: timestamp.timeIntervalSince1970).timeIntervalSince1970).remainderReportingOverflow(dividingBy: UInt64(60*60*24))
        let (codeIndex, _) = daySecond.remainderReportingOverflow(dividingBy: UInt64(beaconCodes.count))
        return beaconCodes[Int(codeIndex)]
    }
    
    public static func beaconCodes(_ beaconCodeSeed: BeaconCodeSeed, count: Int = codesPerDay) -> [BeaconCode] {
        let data = Data(withUnsafeBytes(of: beaconCodeSeed) { Data($0) }.reversed())
        var hash = SHA.hash(data: data)
        var values = [BeaconCode](repeating: 0, count: count)
        for i in (0 ... (count - 1)).reversed() {
            values[i] = JavaData.byteArrayToLong(digest: hash)
            let hashData = Data(hash)
            hash = SHA.hash(data: hashData)
        }
        return values
    }

}

