///**
/**



Created by: Wayne Thornton on 11/10/20
Portions Copyright © 2020 to Present ViraTrace LLC. All Rights Reserved.

This file contains Original Code and/or Modifications of Original code as defined in and that are subject to the ViraTrace Public Source License Version 1.0 (the ‘License’). You may not use this file except in compliance with the License. Please obtain of copy of the Licenses at https://github.com/ViraTrace/License and read it before using this file.

The Original Code and all software distributed under the License are distributed on an ‘AS IS’ basis, WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESS OR IMPLIED, AND VIRATRACE HEREBY DISCLAIMS ALL SUCH WARRANTIES, INCLUDING WITHOUT LIMITATION, ANY WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, QUIET ENJOYMENT OR NON-INFRINGEMENT. Please see the License for the specific language governing rights and limitations under the License.

*/

import Foundation

/// CSV contact log for post event analysis and visualisation
class StatisticsLog: NSObject, SensorDelegate {
    private let textFile: TextFile
    private let payloadData: PayloadData
    private var identifierToPayload: [TargetIdentifier:String] = [:]
    private var payloadToTime: [String:Date] = [:]
    private var payloadToSample: [String:Sample] = [:]
    
    init(filename: String, payloadData: PayloadData) {
        textFile = TextFile(filename: filename)
        self.payloadData = payloadData
    }
    
    private func csv(_ value: String) -> String {
        return TextFile.csv(value)
    }
    
    private func add(identifier: TargetIdentifier) {
        guard let payload = identifierToPayload[identifier] else {
            return
        }
        add(payload: payload)
    }

    private func add(payload: String) {
        guard let time = payloadToTime[payload], let sample = payloadToSample[payload] else {
            payloadToTime[payload] = Date()
            payloadToSample[payload] = Sample()
            return
        }
        let now = Date()
        payloadToTime[payload] = now
        sample.add(Double(now.timeIntervalSince(time)))
        write()
    }
    
    private func write() {
        var content = "payload,count,mean,sd,min,max\n"
        var payloadList: [String] = []
        payloadToSample.keys.forEach() { payload in
            guard payload != payloadData.shortName else {
                return
            }
            payloadList.append(payload)
        }
        payloadList.sort()
        payloadList.forEach() { payload in
            guard let sample = payloadToSample[payload] else {
                return
            }
            guard let mean = sample.mean, let sd = sample.standardDeviation, let min = sample.min, let max = sample.max else {
                return
            }
            content.append("\(csv(payload)),\(sample.count),\(mean),\(sd),\(min),\(max)\n")
        }
        textFile.overwrite(content)
    }


    // MARK:- SensorDelegate
    
    func sensor(_ sensor: SensorType, didDetect: TargetIdentifier) {
    }
    
    func sensor(_ sensor: SensorType, didRead: PayloadData, fromTarget: TargetIdentifier) {
        identifierToPayload[fromTarget] = didRead.shortName
        add(identifier: fromTarget)
    }
    func sensor(_ sensor: SensorType, didReceive: Data, fromTarget: TargetIdentifier) {
        // Do nothing
    }
    
    func sensor(_ sensor: SensorType, didMeasure: Proximity, fromTarget: TargetIdentifier) {
        add(identifier: fromTarget)
    }
    
    func sensor(_ sensor: SensorType, didShare: [PayloadData], fromTarget: TargetIdentifier) {
        didShare.forEach() { payloadData in
            add(payload: payloadData.shortName)
        }
    }
    
    func sensor(_ sensor: SensorType, didVisit: Location) {
    }
    

}

