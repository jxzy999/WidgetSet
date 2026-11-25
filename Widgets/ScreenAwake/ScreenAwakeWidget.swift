import SwiftUI
import WidgetKit

struct ScreenAwakeWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: screenAwakeWidgetKind, provider: ScreenAwakeProvider()) { entry in
            ScreenAwakeWidgetView(status: entry.status)
        }
        .configurationDisplayName("屏幕常亮")
        .description("保持 Mac 屏幕在闲置时点亮。")
        .supportedFamilies([.systemSmall])
        .contentMarginsDisabled()
    }
}

private struct ScreenAwakeEntry: TimelineEntry {
    let date: Date
    let status: ScreenAwakeStatus
}

private struct ScreenAwakeProvider: TimelineProvider {
    func placeholder(in context: Context) -> ScreenAwakeEntry {
        ScreenAwakeEntry(date: .now, status: .off)
    }

    func getSnapshot(in context: Context, completion: @escaping @Sendable (ScreenAwakeEntry) -> Void) {
        let status = context.isPreview ? .on : ScreenAwakeStatus.current()
        completion(ScreenAwakeEntry(date: .now, status: status))
    }

    func getTimeline(in context: Context, completion: @escaping @Sendable (Timeline<ScreenAwakeEntry>) -> Void) {
        let now = Date.now
        let status = ScreenAwakeStatus.current()
        // Check again while active in case the host is force-quit.
        let policy: TimelineReloadPolicy = status == .off ? .never : .after(now.addingTimeInterval(900))
        completion(Timeline(entries: [ScreenAwakeEntry(date: now, status: status)], policy: policy))
    }
}
