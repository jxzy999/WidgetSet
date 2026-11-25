# WidgetSet

WidgetSet 是一组 macOS 桌面小组件。第一个组件「屏幕常亮」提供最小方形尺寸，适用于 macOS 14 及以上。

## 运行

用 Xcode 打开 `WidgetSet.xcodeproj`，选择 `WidgetSet` scheme 运行。也可以运行 `./script/build_and_run.sh --verify`。宿主应用在后台运行。

在 Mac 桌面右键选择「编辑小组件」，搜索 `WidgetSet`，添加「屏幕常亮」。点击卡片右上角的开关即可切换。

- **开启**后，卡片变成亮蓝色并显示「常亮中」。Mac 闲置时保持屏幕点亮。
- **关闭**后，卡片恢复中性色并显示「自动熄屏」。macOS 按原来的设置自动熄屏。

重启后默认关闭。桌面组件的全彩或淡化效果取决于 macOS 的「桌面与程序坞」设置。

## 工程结构

`WidgetSet` 是宿主应用，`WidgetSetWidgets` 是它嵌入的 WidgetKit 扩展。在 `Widgets/WidgetSetWidgets.swift` 的 `WidgetBundle` 中注册同系列组件。

宿主的签名标识是 `com.zw.widgetset`，扩展使用 `com.zw.widgetset.widgets`。两者使用 `Config/WidgetSet.xcconfig` 中的 Developer ID Application 签名配置。
