///**
/**



Created by: Wayne Thornton on 11/10/20
Portions Copyright © 2020 to Present ViraTrace LLC. All Rights Reserved.

This file contains Original Code and/or Modifications of Original code as defined in and that are subject to the ViraTrace Public Source License Version 1.0 (the ‘License’). You may not use this file except in compliance with the License. Please obtain of copy of the Licenses at https://github.com/ViraTrace/License and read it before using this file.

The Original Code and all software distributed under the License are distributed on an ‘AS IS’ basis, WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESS OR IMPLIED, AND VIRATRACE HEREBY DISCLAIMS ALL SUCH WARRANTIES, INCLUDING WITHOUT LIMITATION, ANY WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, QUIET ENJOYMENT OR NON-INFRINGEMENT. Please see the License for the specific language governing rights and limitations under the License.

*/

import Foundation

/// CSV contact log for post event analysis and visualisation
class ContactLog: NSObject, SensorDelegate {
    private let textFile: TextFile
    private let dateFormatter = DateFormatter()
    
    init(filename: String) {
        textFile = TextFile(filename: filename)
        if textFile.empty() {
            textFile.write("time,sensor,id,detect,read,measure,share,visit,data")
        }
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    }
    
    private func timestamp() -> String {
        let timestamp = dateFormatter.string(from: Date())
        return timestamp
    }
    
    private func csv(_ value: String) -> String {
        return TextFile.csv(value)
    }
    
    // MARK:- SensorDelegate
    
    func sensor(_ sensor: SensorType, didDetect: TargetIdentifier) {
        textFile.write(timestamp() + "," + sensor.rawValue + "," + csv(didDetect) + ",1,,,,,")
    }
    
    func sensor(_ sensor: SensorType, didRead: PayloadData, fromTarget: TargetIdentifier) {
        textFile.write(timestamp() + "," + sensor.rawValue + "," + csv(fromTarget) + ",,2,,,," + csv(didRead.shortName))
    }
    
    func sensor(_ sensor: SensorType, didReceive: Data, fromTarget: TargetIdentifier) {
        // Do nothing
    }
    
    func sensor(_ sensor: SensorType, didMeasure: Proximity, fromTarget: TargetIdentifier) {
        textFile.write(timestamp() + "," + sensor.rawValue + "," + csv(fromTarget) + ",,,3,,," + csv(didMeasure.description))
    }
    
    func sensor(_ sensor: SensorType, didShare: [PayloadData], fromTarget: TargetIdentifier) {
        let prefix = timestamp() + "," + sensor.rawValue + "," + csv(fromTarget)
        didShare.forEach() { payloadData in
            textFile.write(prefix + ",,,,4,," + csv(payloadData.shortName))
        }
    }
    
    func sensor(_ sensor: SensorType, didVisit: Location) {
        textFile.write(timestamp() + "," + sensor.rawValue + ",,,,,,5," + csv(didVisit.description))
    }
    

}

