import SwiftUI
import WidgetKit

@main
struct WidgetSetApp: App {
    init() {
        WidgetCenter.shared.reloadTimelines(ofKind: screenAwakeWidgetKind)
    }

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}
