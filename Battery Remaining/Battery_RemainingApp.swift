//
//  Battery_RemainingApp.swift
//  Battery Remaining
//
//  Created by Will Lueking on 3/8/25.
//

import SwiftUI

@main
struct Battery_RemainingApp: App {
    @State var reader = BatteryReader()

    var timeRemainingString: String? {
        guard let timeRemainingMins = reader.info?.timeToEmpty else {
            return nil
        }
        let hours = timeRemainingMins / 60
        let minutes = timeRemainingMins % 60
        let timeRemainingString = "\(hours):\(minutes.formatted(.number.precision(.integerLength(2))))"
        return timeRemainingString
    }

    var menuTitle: String? {
        guard let info = reader.info else {
            return nil
        }
        var pieces = [String]()
        if let timeRemainingString {
            pieces.append(timeRemainingString)
        }

        if let chargePercentage = info.currentCapacity {
            pieces.append("\(chargePercentage)%")
        }

        return pieces.isEmpty ? nil : pieces.joined(separator: " • ")
    }

    var body: some Scene {
        MenuBarExtra(menuTitle ?? "Calculating...") {
            ZStack {}
                .onAppear {
                    reader.startUpdateTimer()
                }
        }
    }
}
