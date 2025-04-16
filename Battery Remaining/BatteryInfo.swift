//
//  BatteryInfo.swift
//  Battery Remaining
//
//  Created by Harlan Haskins on 4/15/25.
//

import Foundation
import IOKit.ps

struct BatteryInfo {
    // Time remaining
    let timeToEmpty: Int?         // Time remaining until battery is empty (minutes)
    let timeToFull: Int?          // Time remaining until battery is fully charged (minutes)

    // Capacity information
    let currentCapacity: Int?     // Current capacity (mAh or %)
    let maxCapacity: Int?         // Maximum capacity (mAh or %)
    let designCapacity: Int?      // Design capacity (mAh)

    // Power information
    let voltage: Double?          // Current voltage (mV)
    let amperage: Int?            // Current amperage (mA)
    let isCharging: Bool          // Whether the battery is currently charging
    let isPresent: Bool           // Whether a battery is present
    let powerSource: String       // Current power source (Battery Power/AC Power)

    // Health information
    let temperature: Double?      // Battery temperature
    let health: String?           // Battery health condition

    init(powerSourceInfo: [String: Any]) {
        // Time information
        self.timeToEmpty = powerSourceInfo[kIOPSTimeToEmptyKey as String] as? Int
        self.timeToFull = powerSourceInfo[kIOPSTimeToFullChargeKey as String] as? Int

        // Capacity information
        self.currentCapacity = powerSourceInfo[kIOPSCurrentCapacityKey as String] as? Int
        self.maxCapacity = powerSourceInfo[kIOPSMaxCapacityKey as String] as? Int
        self.designCapacity = powerSourceInfo[kIOPSDesignCapacityKey as String] as? Int

        // Power information
        self.voltage = powerSourceInfo[kIOPSVoltageKey as String] as? Double
        self.amperage = powerSourceInfo[kIOPSCurrentKey as String] as? Int
        self.isCharging = powerSourceInfo[kIOPSIsChargingKey as String] as? Bool ?? false
        self.isPresent = powerSourceInfo[kIOPSIsPresentKey as String] as? Bool ?? false
        self.powerSource = powerSourceInfo[kIOPSPowerSourceStateKey as String] as? String ?? "Unknown"

        // Health information
        self.temperature = powerSourceInfo[kIOPSTemperatureKey as String] as? Double
        self.health = powerSourceInfo[kIOPSBatteryHealthKey as String] as? String
    }

    // Helper method to get remaining percentage
    var percentageRemaining: Double? {
        guard let current = currentCapacity, let max = maxCapacity, max > 0 else {
            return nil
        }
        return (Double(current) / Double(max))
    }
}

// Function to get battery information from the system
extension BatteryInfo {
    static var current: BatteryInfo? {
        // Get the power sources information
        guard let powerSourcesInfo = IOPSCopyPowerSourcesInfo()?.takeRetainedValue() else {
            return nil
        }

        guard let powerSources = IOPSCopyPowerSourcesList(powerSourcesInfo)?.takeRetainedValue() as? NSArray else {
            return nil
        }

        // Look for the first battery power source
        for powerSource in powerSources {
            guard let info = IOPSGetPowerSourceDescription(powerSourcesInfo, powerSource as CFTypeRef)?.takeUnretainedValue() as? NSDictionary else {
                continue
            }

            // Check if this is a battery
            if let type = info[kIOPSTypeKey as String] as? String, type == kIOPSInternalBatteryType as String, let dict = info as? [String: Any] {
                return BatteryInfo(powerSourceInfo: dict)
            }
        }

        return nil
    }
}
