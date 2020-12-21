///**
/**



Created by: Wayne Thornton on 11/10/20
Portions Copyright © 2020 to Present ViraTrace LLC. All Rights Reserved.

This file contains Original Code and/or Modifications of Original code as defined in and that are subject to the ViraTrace Public Source License Version 1.0 (the ‘License’). You may not use this file except in compliance with the License. Please obtain of copy of the Licenses at https://github.com/ViraTrace/License and read it before using this file.

The Original Code and all software distributed under the License are distributed on an ‘AS IS’ basis, WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESS OR IMPLIED, AND VIRATRACE HEREBY DISCLAIMS ALL SUCH WARRANTIES, INCLUDING WITHOUT LIMITATION, ANY WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, QUIET ENJOYMENT OR NON-INFRINGEMENT. Please see the License for the specific language governing rights and limitations under the License.

*/

import UIKit
import NotificationCenter
import os

/// Battery log for monitoring battery level over time
class BatteryLog {
    private let logger = ConcreteSensorLogger(subsystem: "Sensor", category: "BatteryLog")
    private let textFile: TextFile
    private let dateFormatter = DateFormatter()
    private let updateInterval = TimeInterval(30)

    init(filename: String) {
        textFile = TextFile(filename: filename)
        if textFile.empty() {
            textFile.write("time,source,level")
        }
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        UIDevice.current.isBatteryMonitoringEnabled = true
        NotificationCenter.default.addObserver(self, selector: #selector(batteryLevelDidChange), name: UIDevice.batteryLevelDidChangeNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(batteryStateDidChange), name: UIDevice.batteryStateDidChangeNotification, object: nil)
        let _ = Timer.scheduledTimer(timeInterval: updateInterval, target: self, selector: #selector(update), userInfo: nil, repeats: true)
    }
    
    private func timestamp() -> String {
        let timestamp = dateFormatter.string(from: Date())
        return timestamp
    }

    @objc func update() {
        let powerSource = (UIDevice.current.batteryState == .unplugged ? "battery" : "external")
        let batteryLevel = Float(UIDevice.current.batteryLevel * 100).description
        textFile.write(timestamp() + "," + powerSource + "," + batteryLevel)
        logger.debug("update (powerSource=\(powerSource),batteryLevel=\(batteryLevel))");
    }
    
    @objc func batteryLevelDidChange(_ sender: NotificationCenter) {
        update()
    }
    
    @objc func batteryStateDidChange(_ sender: NotificationCenter) {
        update()
    }
}

