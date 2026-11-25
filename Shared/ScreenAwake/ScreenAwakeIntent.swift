import AppIntents
import WidgetKit

let screenAwakeWidgetKind = "com.zw.widgetset.screen-awake"

struct SetScreenAwakeIntent: AppIntent {
    static let title: LocalizedStringResource = "设置屏幕常亮"
    static let isDiscoverable = false

    // The containing app must own the assertion after the widget action returns.
    @available(macOS, deprecated: 26.0)
    static let openAppWhenRun = true

    @available(macOS 26.0, *)
    static var supportedModes: IntentModes { .foreground(.immediate) }

    @Parameter(title: "保持屏幕常亮")
    var isEnabled: Bool

    init() {}

    init(isEnabled: Bool) {
        self.isEnabled = isEnabled
    }

    @MainActor
    func perform() async throws -> some IntentResult {
        try ScreenAwakePower.shared.setEnabled(isEnabled)
        WidgetCenter.shared.reloadTimelines(ofKind: screenAwakeWidgetKind)
        return .result()
    }
}
