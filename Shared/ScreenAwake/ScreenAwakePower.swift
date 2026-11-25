import AppKit
import IOKit.pwr_mgt
import os

private let hostBundleIdentifier = "com.zw.widgetset"
private let assertionName = "WidgetSet: Keep Display Awake"
private let assertionType = kIOPMAssertPreventUserIdleDisplaySleep

enum ScreenAwakeStatus: Sendable {
    case off
    case on
    case unavailable

    static func current() -> Self {
        let hosts = NSRunningApplication.runningApplications(withBundleIdentifier: hostBundleIdentifier)
        guard !hosts.isEmpty else { return .off }

        var assertions: Unmanaged<CFDictionary>?
        guard IOPMCopyAssertionsByProcess(&assertions) == kIOReturnSuccess,
              let assertions = assertions?.takeRetainedValue() as? [pid_t: [[String: Any]]] else {
            return .unavailable
        }

        // Query powerd so a terminated host leaves no stored "on" state behind.
        let isEnabled = hosts.contains { host in
            assertions[host.processIdentifier]?.contains { assertion in
                assertion[kIOPMAssertionNameKey as String] as? String == assertionName
                    && assertion[kIOPMAssertionTypeKey as String] as? String == assertionType
                    && assertion[kIOPMAssertionLevelKey as String] as? Int == kIOPMAssertionLevelOn
            } == true
        }
        return isEnabled ? .on : .off
    }
}

@MainActor
final class ScreenAwakePower {
    static let shared = ScreenAwakePower()

    private let logger = Logger(subsystem: hostBundleIdentifier, category: "ScreenAwake")
    private var assertionID: IOPMAssertionID?

    private init() {}

    func setEnabled(_ isEnabled: Bool) throws {
        guard Bundle.main.bundleIdentifier == hostBundleIdentifier else {
            throw ScreenAwakeError.hostUnavailable
        }

        if isEnabled {
            guard assertionID == nil else { return }

            var newAssertionID: IOPMAssertionID = 0
            let result = IOPMAssertionCreateWithName(
                assertionType as CFString,
                IOPMAssertionLevel(kIOPMAssertionLevelOn),
                assertionName as CFString,
                &newAssertionID
            )
            guard result == kIOReturnSuccess else { throw ScreenAwakeError.powerManagement(result) }
            assertionID = newAssertionID
            logger.info("Acquired display sleep assertion.")
        } else if let assertionID {
            let result = IOPMAssertionRelease(assertionID)
            guard result == kIOReturnSuccess else { throw ScreenAwakeError.powerManagement(result) }
            self.assertionID = nil
            logger.info("Released display sleep assertion.")
        }
    }
}

private enum ScreenAwakeError: LocalizedError {
    case hostUnavailable
    case powerManagement(IOReturn)

    var errorDescription: String? {
        switch self {
        case .hostUnavailable:
            String(localized: "无法连接 WidgetSet，请重试。")
        case let .powerManagement(code):
            String(localized: "无法更新屏幕常亮状态（\(code)）。")
        }
    }
}
