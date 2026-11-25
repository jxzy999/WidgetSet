import SwiftUI
import WidgetKit

struct ScreenAwakeWidgetView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.widgetRenderingMode) private var renderingMode
    @ScaledMetric(relativeTo: .headline) private var titleSize = 18.0
    @ScaledMetric(relativeTo: .caption) private var statusSize = 12.0

    let status: ScreenAwakeStatus

    private var isOn: Bool { status == .on }
    private var isDark: Bool { colorScheme == .dark }
    private var usesColor: Bool { renderingMode == .fullColor }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                monitorSymbol
                Spacer(minLength: 4)
                switchButton
            }

            Spacer(minLength: 4)

            VStack(alignment: .leading, spacing: 3) {
                Text("屏幕常亮")
                    .font(.system(size: titleSize, weight: .semibold))
                    .foregroundStyle(primaryInk)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                Text(statusLabel)
                    .font(.system(size: statusSize, weight: isOn ? .semibold : .medium))
                    .foregroundStyle(statusInk)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .invalidatableContent()
        }
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .containerBackground(for: .widget) {
            cardColor
        }
    }

    private var monitorSymbol: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 13)
                .fill(symbolBackground)

            Image(systemName: "display")
                .font(.system(size: 24, weight: .medium))
                .foregroundStyle(primaryInk)
                .overlay(alignment: .center) {
                    Image(systemName: isOn ? "sun.max.fill" : "sun.max")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(usesColor && isOn ? Color(red: 1, green: 0.86, blue: 0.44) : Color.primary)
                        .offset(y: -2)
                }
        }
        .frame(width: 44, height: 44)
        .accessibilityHidden(true)
    }

    private var switchButton: some View {
        Button(intent: SetScreenAwakeIntent(isEnabled: !isOn)) {
            Capsule()
                .fill(isOn ? Color.white : Color(red: 0.45, green: 0.47, blue: 0.51))
                .overlay(alignment: isOn ? .trailing : .leading) {
                    Circle()
                        .fill(isOn ? thumbColor : Color.white)
                        .frame(width: 16, height: 16)
                        .padding(3)
                }
                .frame(width: 38, height: 24)
                .frame(width: 44, height: 44)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(isOn ? "关闭屏幕常亮" : "开启屏幕常亮")
        .accessibilityValue(Text(statusLabel))
    }

    private var statusLabel: LocalizedStringKey {
        switch status {
        case .off: "自动熄屏"
        case .on: "常亮中"
        case .unavailable: "状态不可用"
        }
    }

    private var primaryInk: Color {
        usesColor && isOn ? .white : .primary
    }

    private var statusInk: Color {
        guard usesColor else { return isOn ? .primary : .secondary }
        if isOn {
            return Color(red: 0.88, green: 0.93, blue: 1)
        }
        return Color(white: isDark ? 0.76 : 0.34)
    }

    private var cardColor: Color {
        if !usesColor {
            return isOn ? .primary.opacity(0.35) : .primary.opacity(0.12)
        }
        if isOn {
            return isDark ? Color(red: 0.071, green: 0.31, blue: 0.737) : Color(red: 0.027, green: 0.345, blue: 0.827)
        }
        return isDark ? Color(red: 0.165, green: 0.169, blue: 0.184) : Color(red: 0.973, green: 0.973, blue: 0.98)
    }

    private var symbolBackground: Color {
        if usesColor && isOn {
            return .black.opacity(0.19)
        }
        return .primary.opacity(isOn ? 0.28 : 0.09)
    }

    private var thumbColor: Color {
        usesColor ? cardColor : .black
    }
}
