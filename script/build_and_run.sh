#!/usr/bin/env bash
set -euo pipefail

mode="${1:-run}"
configuration=Release
case "$mode" in
  run|--logs|--telemetry|--verify) ;;
  --debug) configuration=Debug ;;
  *)
    printf 'Usage: %s [--debug|--logs|--telemetry|--verify]\n' "$0" >&2
    exit 2
    ;;
esac

root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
build_dir="$root_dir/.build/DerivedData"
products_dir="$build_dir/Build/Products"
app="$products_dir/$configuration/WidgetSet.app"
native_arch="$(/usr/bin/uname -m)"

running_pid() {
  local app_path="$1" pid
  while IFS= read -r pid; do
    if [[ "$(/bin/ps -ww -p "$pid" -o comm=)" == "$app_path/Contents/MacOS/WidgetSet" ]]; then
      printf '%s\n' "$pid"
      return 0
    fi
  done < <(/usr/bin/pgrep -x WidgetSet || true)
  return 1
}

for previous_configuration in Debug Release; do
  if pid="$(running_pid "$products_dir/$previous_configuration/WidgetSet.app")"; then
    /bin/kill "$pid" 2>/dev/null || true
  fi
done

xcodebuild -project "$root_dir/WidgetSet.xcodeproj" -scheme WidgetSet \
  -configuration "$configuration" -destination "platform=macOS,arch=$native_arch" \
  -derivedDataPath "$build_dir" -quiet build

/usr/bin/open -g "$app"

case "$mode" in
  --debug|--verify)
    for ((attempt = 0; attempt < 30; attempt++)); do
      if pid="$(running_pid "$app")"; then
        if [[ "$mode" == --debug ]]; then
          exec /usr/bin/lldb --attach-pid "$pid"
        fi
        printf 'Running %s (PID %s)\n' "$app" "$pid"
        exit 0
      fi
      /bin/sleep 0.2
    done
    printf 'WidgetSet did not start.\n' >&2
    exit 1
    ;;
  --logs)
    exec /usr/bin/log stream --info --style compact --predicate 'process == "WidgetSet"'
    ;;
  --telemetry)
    exec /usr/bin/log stream --info --style compact --predicate 'subsystem == "com.zw.widgetset"'
    ;;
esac
