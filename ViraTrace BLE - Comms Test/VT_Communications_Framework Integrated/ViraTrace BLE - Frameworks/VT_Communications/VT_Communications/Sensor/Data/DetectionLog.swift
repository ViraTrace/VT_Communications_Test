///**
/**



Created by: Wayne Thornton on 11/10/20
Portions Copyright © 2020 to Present ViraTrace LLC. All Rights Reserved.

This file contains Original Code and/or Modifications of Original code as defined in and that are subject to the ViraTrace Public Source License Version 1.0 (the ‘License’). You may not use this file except in compliance with the License. Please obtain of copy of the Licenses at https://github.com/ViraTrace/License and read it before using this file.

The Original Code and all software distributed under the License are distributed on an ‘AS IS’ basis, WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESS OR IMPLIED, AND VIRATRACE HEREBY DISCLAIMS ALL SUCH WARRANTIES, INCLUDING WITHOUT LIMITATION, ANY WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, QUIET ENJOYMENT OR NON-INFRINGEMENT. Please see the License for the specific language governing rights and limitations under the License.

*/

import Foundation
import UIKit

/// CSV contact log for post event analysis and visualisation
class DetectionLog: NSObject, SensorDelegate {
    private let logger = ConcreteSensorLogger(subsystem: "Sensor", category: "Data.DetectionLog")
    private let textFile: TextFile
    private let payloadData: PayloadData
    private let deviceName = UIDevice.current.name
    private let deviceOS = UIDevice.current.systemVersion
    private var payloads: Set<String> = []
    private let queue = DispatchQueue(label: "Sensor.Data.DetectionLog.Queue")
    
    init(filename: String, payloadData: PayloadData) {
        textFile = TextFile(filename: filename)
        self.payloadData = payloadData
        super.init()
        write()
    }
    
    private func csv(_ value: String) -> String {
        return TextFile.csv(value)
    }

    private func write() {
        var content = "\(csv(deviceName)),iOS,\(csv(deviceOS)),\(csv(payloadData.shortName))"
        var payloadList: [String] = []
        payloads.forEach() { payload in
            guard payload != payloadData.shortName else {
                return
            }
            payloadList.append(payload)
        }
        payloadList.sort()
        payloadList.forEach() { payload in
            content.append(",")
            content.append(csv(payload))
        }
        logger.debug("write (content=\(content))")
        content.append("\n")
        textFile.overwrite(content)
    }
    
    // MARK:- SensorDelegate
    
    func sensor(_ sensor: SensorType, didDetect: TargetIdentifier) {
    }
    
    func sensor(_ sensor: SensorType, didRead: PayloadData, fromTarget: TargetIdentifier) {
        queue.async {
            if self.payloads.insert(didRead.shortName).inserted {
                self.logger.debug("didRead (payload=\(didRead.shortName))")
                self.write()
            }
        }
    }
    
    func sensor(_ sensor: SensorType, didReceive: Data, fromTarget: TargetIdentifier) {
        // Do nothing
    }
    
    func sensor(_ sensor: SensorType, didMeasure: Proximity, fromTarget: TargetIdentifier) {
    }
    
    func sensor(_ sensor: SensorType, didShare: [PayloadData], fromTarget: TargetIdentifier) {
        didShare.forEach() { payloadData in
            queue.async {
                if self.payloads.insert(payloadData.shortName).inserted {
                    self.logger.debug("didShare (payload=\(payloadData.shortName))")
                    self.write()
                }
            }
        }
    }
    
    func sensor(_ sensor: SensorType, didVisit: Location) {
    }
    

}

