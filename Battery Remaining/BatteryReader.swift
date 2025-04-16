//
//  BatteryReader.swift
//  Battery Remaining
//
//  Created by Harlan Haskins on 4/15/25.
//

import Foundation
import Observation

@MainActor
@Observable
final class BatteryReader {
    var info: BatteryInfo? = .current
    var details: [String: String] = [:]
    var timer: Timer?
    
    init() {
        update()
    }

    func startUpdateTimer() {
        update()
        timer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.update()
            }
        }
    }

    func update() {
        info = BatteryInfo.current
    }
}
