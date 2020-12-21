///**
/**



Created by: Wayne Thornton on 11/10/20
Portions Copyright © 2020 to Present ViraTrace LLC. All Rights Reserved.

This file contains Original Code and/or Modifications of Original code as defined in and that are subject to the ViraTrace Public Source License Version 1.0 (the ‘License’). You may not use this file except in compliance with the License. Please obtain of copy of the Licenses at https://github.com/ViraTrace/License and read it before using this file.

The Original Code and all software distributed under the License are distributed on an ‘AS IS’ basis, WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESS OR IMPLIED, AND VIRATRACE HEREBY DISCLAIMS ALL SUCH WARRANTIES, INCLUDING WITHOUT LIMITATION, ANY WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, QUIET ENJOYMENT OR NON-INFRINGEMENT. Please see the License for the specific language governing rights and limitations under the License.

*/

import Foundation

/// Sensor delegate for receiving sensor events.
public protocol SensorDelegate {
    /// Detection of a target with an ephemeral identifier, e.g. BLE central detecting a BLE peripheral.
    func sensor(_ sensor: SensorType, didDetect: TargetIdentifier)
    
    /// Read payload data from target, e.g. encrypted device identifier from BLE peripheral after successful connection.
    func sensor(_ sensor: SensorType, didRead: PayloadData, fromTarget: TargetIdentifier)
    
    /// Read payload data of other targets recently acquired by a target, e.g. Android peripheral sharing payload data acquired from nearby iOS peripherals.
    func sensor(_ sensor: SensorType, didShare: [PayloadData], fromTarget: TargetIdentifier)
    
    /// Write signal requests - immediate send
    func sensor(_ sensor: SensorType, didReceive: Data, fromTarget: TargetIdentifier)

    /// Measure proximity to target, e.g. a sample of RSSI values from BLE peripheral.
    func sensor(_ sensor: SensorType, didMeasure: Proximity, fromTarget: TargetIdentifier)
    
    /// Detection of time spent at location, e.g. at specific restaurant between 02/06/2020 19:00 and 02/06/2020 21:00
    func sensor(_ sensor: SensorType, didVisit: Location)
    
    /// Measure proximity to target with payload data. Combines didMeasure and didRead into a single convenient delegate method
    func sensor(_ sensor: SensorType, didMeasure: Proximity, fromTarget: TargetIdentifier, withPayload: PayloadData)
    
    /// Sensor state update
    func sensor(_ sensor: SensorType, didUpdateState: SensorState)
}

/// Sensor delegate functions are all optional.
public extension SensorDelegate {
    func sensor(_ sensor: SensorType, didDetect: TargetIdentifier) {}
    func sensor(_ sensor: SensorType, didRead: PayloadData, fromTarget: TargetIdentifier) {}
    func sensor(_ sensor: SensorType, didShare: [PayloadData], fromTarget: TargetIdentifier) {}
    func sensor(_ sensor: SensorType, didReceive: Data, fromTarget: TargetIdentifier) {}
    func sensor(_ sensor: SensorType, didMeasure: Proximity, fromTarget: TargetIdentifier) {}
    func sensor(_ sensor: SensorType, didVisit: Location) {}
    func sensor(_ sensor: SensorType, didMeasure: Proximity, fromTarget: TargetIdentifier, withPayload: PayloadData) {}
    func sensor(_ sensor: SensorType, didUpdateState: SensorState) {}
}

// MARK:- SensorDelegate data

/// Sensor type as qualifier for target identifier.
public enum SensorType : String {
    /// Bluetooth Low Energy (BLE)
    case BLE
    /// GPS location sensor
    case GPS
    /// Physical beacon, e.g. iBeacon
    case BEACON
    /// Ultrasound audio beacon.
    case ULTRASOUND
}

/// Sensor state
public enum SensorState : String {
    /// Sensor is powered on, active and operational
    case on
    /// Sensor is powered off, inactive and not operational
    case off
    /// Sensor is not available
    case unavailable
}

/// Ephemeral identifier for detected target (e.g. smartphone, beacon, place). This is likely to be an UUID but using String for variable identifier length.
public typealias TargetIdentifier = String

// MARK:- Proximity data

/// Raw data for estimating proximity between sensor and target, e.g. RSSI for BLE.
public struct Proximity {
    /// Unit of measurement, e.g. RSSI
    let unit: ProximityMeasurementUnit
    /// Measured value, e.g. raw RSSI value.
    let value: Double
    /// Get plain text description of proximity data
    public var description: String { get {
        unit.rawValue + ":" + value.description
    }}
}

/// Measurement unit for interpreting the proximity data values.
public enum ProximityMeasurementUnit : String {
    /// Received signal strength indicator, e.g. BLE signal strength as proximity estimator.
    case RSSI
    /// Roundtrip time, e.g. Audio signal echo time duration as proximity estimator.
    case RTT
}

// MARK:- Location data

/// Raw location data for estimating indirect exposure, e.g.
public struct Location {
    /// Measurement values, e.g. GPS coordinates in comma separated string format for latitude and longitude
    let value: LocationReference
    /// Time spent at location.
    let time: (start: Date, end: Date)
    /// Get plain text description of proximity data
    public var description: String { get {
        value.description + ":[from=" + time.start.description + ",to=" + time.end.description + "]"
    }}
}

public protocol LocationReference {
    var description: String { get }
}

/// GPS coordinates (latitude,longitude,altitude) in WGS84 decimal format and meters from sea level.
public struct WGS84PointLocationReference : LocationReference {
    let latitude: Double
    let longitude: Double
    let altitude: Double
    public var description: String { get {
        "WGS84(lat=\(latitude),lon=\(longitude),alt=\(altitude))"
        }}
}

/// GPS coordinates and region radius, e.g. latitude and longitude in decimal format and radius in meters.
public struct WGS84CircularAreaLocationReference : LocationReference {
    let latitude: Double
    let longitude: Double
    let altitude: Double
    let radius: Double
    public var description: String { get {
        "WGS84(lat=\(latitude),lon=\(longitude),alt=\(altitude),radius=\(radius))"
        }}
}

/// Free text place name.
public struct PlacenameLocationReference : LocationReference {
    let name: String
    public var description: String { get {
        "PLACE(name=\(name))"
        }}
}

