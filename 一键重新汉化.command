#!/bin/bash
set -euo pipefail

launcher="$0"
while [[ -L "$launcher" ]]; do
  parent="$(dirname "$launcher")"
  launcher="$(readlink "$launcher")"
  [[ "$launcher" == /* ]] || launcher="$parent/$launcher"
done
root="$(cd "$(dirname "$launcher")" && pwd)"
app="${SNAGIT_APP:-/Applications/Snagit.app}"
version="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$app/Contents/Info.plist")"
echo "正在为 Snagit $version 安装简体中文资源…"
lock="${TMPDIR:?}/snagit-zh-hans-installer.lock"
if ! /usr/bin/shlock -p "$$" -f "$lock"; then
  echo "已有汉化任务正在运行，请等它完成。"
  exit 1
fi
trap 'unlink "$lock"' EXIT

bash "$root/outputs/reinstall_snagit_chinese.sh"

echo "正在重新打开 Snagit。如有保存提示，请在 Snagit 中处理。"
quit_component() {
  local pids pid n
  pids="$(/usr/bin/osascript -l JavaScript - "$1" "$2" <<'JXA'
ObjC.import('AppKit');
function run(argv) {
    const instances = $.NSRunningApplication.runningApplicationsWithBundleIdentifier(argv[0]);
    const pids = [];
    for (let i = 0; i < instances.count; i++) {
        const instance = instances.objectAtIndex(i);
        if (ObjC.unwrap(instance.bundleURL.path) !== argv[1]) continue;
        pids.push(instance.processIdentifier);
        instance.terminate;
    }
    return pids.join(' ');
}
JXA
)" || return 1
  for pid in $pids; do
    for ((n=0; n<80; n++)); do
      kill -0 "$pid" 2>/dev/null || break
      sleep 0.25
    done
    if kill -0 "$pid" 2>/dev/null; then return 1; fi
  done
  return 0
}
if ! quit_component com.TechSmith.Snagit "$app"; then
  echo "中文包已安装。请处理编辑器的保存提示，然后重新打开 Snagit。"
  exit 1
fi
if ! quit_component com.techsmith.snagit.capturehelper "$app/Contents/Library/LoginItems/SnagitHelper.app"; then
  echo "捕获助手仍在运行。结束录屏后可从菜单栏退出助手，让小窗重新加载中文。"
fi
/usr/bin/open -a "$app" --args -AppleLanguages '(zh-Hans)'
echo "Snagit $version 汉化完成。"
