///**
/**



Created by: Wayne Thornton on 11/10/20
Portions Copyright © 2020 to Present ViraTrace LLC. All Rights Reserved.

This file contains Original Code and/or Modifications of Original code as defined in and that are subject to the ViraTrace Public Source License Version 1.0 (the ‘License’). You may not use this file except in compliance with the License. Please obtain of copy of the Licenses at https://github.com/ViraTrace/License and read it before using this file.

The Original Code and all software distributed under the License are distributed on an ‘AS IS’ basis, WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESS OR IMPLIED, AND VIRATRACE HEREBY DISCLAIMS ALL SUCH WARRANTIES, INCLUDING WITHOUT LIMITATION, ANY WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, QUIET ENJOYMENT OR NON-INFRINGEMENT. Please see the License for the specific language governing rights and limitations under the License.

*/

import UIKit
import VT_Communications

class ViewController: UIViewController, SensorDelegate {
    private let logger = Log(subsystem: "VT_Communications", category: "ViewController")
    private let appDelegate = UIApplication.shared.delegate as! AppDelegate
    private var sensor: Sensor!
    private let dateFormatter = DateFormatter()
    private let payloadPrefixLength = 6;
    private var didDetect = 0
    private var didRead = 0
    private var didMeasure = 0
    private var didShare = 0
    private var didVisit = 0
    private var payloads: [TargetIdentifier:String] = [:]
    private var didReadPayloads: [String:Date] = [:]
    private var didSharePayloads: [String:Date] = [:]

    @IBOutlet weak var labelDevice: UILabel!
    @IBOutlet weak var labelPayload: UILabel!
    @IBOutlet weak var labelDidDetect: UILabel!
    @IBOutlet weak var labelDidRead: UILabel!
    @IBOutlet weak var labelDidMeasure: UILabel!
    @IBOutlet weak var labelDidShare: UILabel!
    @IBOutlet weak var labelDidVisit: UILabel!
    @IBOutlet weak var labelDetection: UILabel!
    @IBOutlet weak var buttonCrash: UIButton!
    @IBOutlet weak var textViewPayloads: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sensor = appDelegate.sensor
        sensor.add(delegate: self)
        
        dateFormatter.dateFormat = "MMdd HH:mm:ss"
        
        labelDevice.text = SensorArray.deviceDescription
        if let payloadData = (appDelegate.sensor)?.payloadData {
            labelPayload.text = "RANDOM DEVICE IDENTIFIER : \(payloadData.shortName)"
        }
        
        enableCrashButton()
    }
    
    private func enableCrashButton() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(simulateCrashInTen))
        tapGesture.numberOfTapsRequired = 3
        buttonCrash.addGestureRecognizer(tapGesture)
    }
    
    @objc func simulateCrashInTen() {
        simulateCrash(after: 10)
        buttonCrash.isUserInteractionEnabled = false
        buttonCrash.setTitle("App will exit in 10 seconds...", for: .normal)
    }
    
    func simulateCrash(after: Double) {
        logger.info("simulateCrash (after=\(after))")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + after) {
            self.logger.fault("simulateCrash now")
            // CRASH
            if ([0][1] == 1) {
                exit(0)
            }
            exit(1)
        }
    }

    
    private func timestamp() -> String {
        let timestamp = dateFormatter.string(from: Date())
        return timestamp
    }
    
    private func updateDetection() {
        var payloadShortNames: [String:String] = [:]
        var payloadLastSeenDates: [String:Date] = [:]
        didReadPayloads.forEach() { payloadShortName, date in
            payloadShortNames[payloadShortName] = "read"
            payloadLastSeenDates[payloadShortName] = didReadPayloads[payloadShortName]
        }
        didSharePayloads.forEach() { payloadShortName, date in
            if payloadShortNames[payloadShortName] == nil {
                payloadShortNames[payloadShortName] = "shared"
            } else {
                payloadShortNames[payloadShortName] = "read,shared"
            }
            if let didSharePayloadDate = didSharePayloads[payloadShortName], let didReadPayloadDate = didReadPayloads[payloadShortName], didSharePayloadDate > didReadPayloadDate {
                payloadLastSeenDates[payloadShortName] = didSharePayloadDate
            }
        }
        var payloadShortNameList: [String] = []
        payloadShortNames.keys.forEach() { payloadShortName in
            if let method = payloadShortNames[payloadShortName], let lastSeenDate = payloadLastSeenDates[payloadShortName] {
                payloadShortNameList.append("\(payloadShortName) [\(method)] (\(dateFormatter.string(from: lastSeenDate)))")
            }
        }
        payloadShortNameList.sort()
        textViewPayloads.text = payloadShortNameList.joined(separator: "\n")
        labelDetection.text = "DETECTION (\(payloadShortNameList.count))"
    }

    // MARK:- SensorDelegate

    func sensor(_ sensor: SensorType, didDetect: TargetIdentifier) {
        self.didDetect += 1
        DispatchQueue.main.async {
            self.labelDidDetect.text = "didDetect: \(self.didDetect) (\(self.timestamp()))"
        }
    }

    func sensor(_ sensor: SensorType, didRead: PayloadData, fromTarget: TargetIdentifier) {
        self.didRead += 1
        payloads[fromTarget] = didRead.shortName
        didReadPayloads[didRead.shortName] = Date()
        DispatchQueue.main.async {
            self.labelDidRead.text = "didRead: \(self.didRead) (\(self.timestamp()))"
            self.updateDetection()
        }
    }
    
    func sensor(_ sensor: SensorType, didReceive: Data, fromTarget: TargetIdentifier) {
        DispatchQueue.main.async {
            self.labelDidRead.text = "didReceive: \(didReceive.base64EncodedString()) (\(self.timestamp()))"
            self.updateDetection()
        }
    }

    func sensor(_ sensor: SensorType, didShare: [PayloadData], fromTarget: TargetIdentifier) {
        self.didShare += 1
        let time = Date()
        didShare.forEach { self.didSharePayloads[$0.shortName] = time }
        DispatchQueue.main.async {
            self.labelDidShare.text = "didShare: \(self.didShare) (\(self.timestamp()))"
            self.updateDetection()
        }
    }

    func sensor(_ sensor: SensorType, didMeasure: Proximity, fromTarget: TargetIdentifier) {
        self.didMeasure += 1;
        if let payloadShortName = payloads[fromTarget] {
            didReadPayloads[payloadShortName] = Date()
        }
        DispatchQueue.main.async {
            self.labelDidMeasure.text = "didMeasure: \(self.didMeasure) (\(self.timestamp()))"
            self.updateDetection()
        }
    }

    func sensor(_ sensor: SensorType, didVisit: Location) {
        self.didVisit += 1;
        DispatchQueue.main.async {
            self.labelDidVisit.text = "didVisit: \(self.didVisit) (\(self.timestamp()))"
        }
    }
}

