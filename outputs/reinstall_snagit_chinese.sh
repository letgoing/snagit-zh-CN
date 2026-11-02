#!/usr/bin/env bash
set -euo pipefail

APP_PATH="${SNAGIT_APP:-/Applications/Snagit.app}"
USER_HOME="${SNAGIT_USER_HOME:-$HOME}"
RESOURCES_DIR="$APP_PATH/Contents/Resources"
TARGET_DIR="$RESOURCES_DIR/zh-Hans.lproj"
COMMON_RESOURCES_DIR="$APP_PATH/Contents/Frameworks/SnagitCommon.framework/Versions/A/Resources"
COMMON_TARGET_DIR="$COMMON_RESOURCES_DIR/zh-Hans.lproj"
HELPER_RESOURCES_DIR="$APP_PATH/Contents/Library/LoginItems/SnagitHelper.app/Contents/Resources"
HELPER_TARGET_DIR="$HELPER_RESOURCES_DIR/zh-Hans.lproj"
PRESET_ARCHIVE="$USER_HOME/Library/Group Containers/7TQL462TU8.com.techsmith.snagit/Snagit/CaptureProfiles/ArchivedCaptureProfiles"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
GENERATOR="$SCRIPT_DIR/build_snagit_zh_hans.py"
SOURCE_DIR="$WORKSPACE_DIR/work/Snagit.zh-Hans.lproj"
COMMON_SOURCE_DIR="$WORKSPACE_DIR/work/SnagitCommon.zh-Hans.lproj"
HELPER_SOURCE_DIR="$WORKSPACE_DIR/work/SnagitHelper.zh-Hans.lproj"
BACKUP_STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP_DIR="$RESOURCES_DIR/zh-Hans.lproj.backup.$BACKUP_STAMP"
COMMON_BACKUP_DIR="$COMMON_RESOURCES_DIR/zh-Hans.lproj.backup.$BACKUP_STAMP"
HELPER_BACKUP_DIR="$HELPER_RESOURCES_DIR/zh-Hans.lproj.backup.$BACKUP_STAMP"
PRESET_BACKUP="$PRESET_ARCHIVE.backup.$BACKUP_STAMP"

echo "Snagit 简体中文包重新安装器"
echo "应用位置: $APP_PATH"

if [[ ! -d "$APP_PATH" ]]; then
  echo "错误：找不到 Snagit.app。"
  echo "可用 SNAGIT_APP 指定路径，例如："
  echo "SNAGIT_APP=\"/Applications/Snagit.app\" \"$0\""
  exit 1
fi

if [[ ! -d "$RESOURCES_DIR/Base.lproj" || ! -d "$RESOURCES_DIR/ja.lproj" || ! -f "$COMMON_RESOURCES_DIR/ja.lproj/SnagitCommon.strings" || ! -d "$HELPER_RESOURCES_DIR/Base.lproj" || ! -d "$HELPER_RESOURCES_DIR/ja.lproj" ]]; then
  echo "错误：Snagit 资源目录结构不符合预期，无法生成中文包。"
  exit 1
fi

if [[ ! -f "$GENERATOR" ]]; then
  echo "错误：找不到生成器脚本：$GENERATOR"
  exit 1
fi

if [[ ! -w "$RESOURCES_DIR" || ! -w "$COMMON_RESOURCES_DIR" || ! -w "$HELPER_RESOURCES_DIR" ]]; then
  echo "当前用户没有写入 Snagit 资源目录的权限，正在请求 sudo 权限重新执行。"
  exec sudo SNAGIT_APP="$APP_PATH" SNAGIT_USER_HOME="$USER_HOME" bash "$0"
fi

restore_backup() {
  if [[ -d "$BACKUP_DIR" && ! -d "$TARGET_DIR" ]]; then
    echo "安装中断，正在恢复主应用旧中文包..."
    mv "$BACKUP_DIR" "$TARGET_DIR"
  fi
  if [[ -d "$COMMON_BACKUP_DIR" && ! -d "$COMMON_TARGET_DIR" ]]; then
    echo "安装中断，正在恢复 SnagitCommon 旧中文包..."
    mv "$COMMON_BACKUP_DIR" "$COMMON_TARGET_DIR"
  fi
  if [[ -d "$HELPER_BACKUP_DIR" && ! -d "$HELPER_TARGET_DIR" ]]; then
    echo "安装中断，正在恢复 SnagitHelper 旧中文包..."
    mv "$HELPER_BACKUP_DIR" "$HELPER_TARGET_DIR"
  fi
}
trap restore_backup ERR

echo "1/7 生成中文资源包..."
cd "$WORKSPACE_DIR"
python3 "$GENERATOR"

if [[ ! -d "$SOURCE_DIR" || ! -d "$COMMON_SOURCE_DIR" || ! -d "$HELPER_SOURCE_DIR" ]]; then
  echo "错误：中文资源包生成不完整。"
  exit 1
fi

echo "2/7 校验生成的 .strings 文件..."
plutil -lint "$SOURCE_DIR"/*.strings >/dev/null
plutil -lint "$COMMON_SOURCE_DIR"/*.strings >/dev/null
plutil -lint "$HELPER_SOURCE_DIR"/*.strings >/dev/null

if [[ -d "$TARGET_DIR" ]]; then
  echo "3/7 备份主应用中文包到：$BACKUP_DIR"
  mv "$TARGET_DIR" "$BACKUP_DIR"
else
  echo "3/7 主应用当前没有旧中文包，跳过备份。"
fi

if [[ -d "$COMMON_TARGET_DIR" ]]; then
  echo "4/7 备份 SnagitCommon 中文包到：$COMMON_BACKUP_DIR"
  mv "$COMMON_TARGET_DIR" "$COMMON_BACKUP_DIR"
else
  echo "4/7 SnagitCommon 当前没有旧中文包，跳过备份。"
fi

if [[ -d "$HELPER_TARGET_DIR" ]]; then
  echo "5/7 备份 SnagitHelper 中文包到：$HELPER_BACKUP_DIR"
  mv "$HELPER_TARGET_DIR" "$HELPER_BACKUP_DIR"
else
  echo "5/7 SnagitHelper 当前没有旧中文包，跳过备份。"
fi

echo "6/7 安装主应用、效果组件和捕获助手中文包..."
ditto "$SOURCE_DIR" "$TARGET_DIR"
ditto "$COMMON_SOURCE_DIR" "$COMMON_TARGET_DIR"
ditto "$HELPER_SOURCE_DIR" "$HELPER_TARGET_DIR"
plutil -lint "$TARGET_DIR"/*.strings >/dev/null
plutil -lint "$COMMON_TARGET_DIR"/*.strings >/dev/null
plutil -lint "$HELPER_TARGET_DIR"/*.strings >/dev/null

echo "7/7 汉化已保存的默认捕获预设名称..."
if [[ -f "$PRESET_ARCHIVE" ]]; then
  python3 - "$PRESET_ARCHIVE" "$PRESET_BACKUP" <<'PY'
import os
import plistlib
import shutil
import sys
from pathlib import Path

archive = Path(sys.argv[1])
backup = Path(sys.argv[2])
translations = {
    "Open in Camtasia Editor": "在 Camtasia 编辑器中打开",
    "Step Capture": "步骤捕获",
    "Grab Text + Copy to Clipboard": "抓取文本并复制到剪贴板",
    "Scrolling Capture": "滚动捕获",
}

try:
    with archive.open("rb") as source:
        data = plistlib.load(source)
except PermissionError:
    print("提示：macOS 隐私权限阻止读取个人预设，已跳过名称修改；应用中文资源已安装。")
    sys.exit(0)

replaced = 0

def localize(value):
    global replaced
    if isinstance(value, str) and value in translations:
        replaced += 1
        return translations[value]
    if isinstance(value, list):
        return [localize(item) for item in value]
    if isinstance(value, dict):
        return {key: localize(item) for key, item in value.items()}
    return value

localized = localize(data)
if replaced:
    metadata = archive.stat()
    shutil.copy2(archive, backup)
    temporary = archive.with_name(f"{archive.name}.tmp.{os.getpid()}")
    with temporary.open("wb") as destination:
        plistlib.dump(localized, destination, fmt=plistlib.FMT_BINARY, sort_keys=False)
    os.chmod(temporary, metadata.st_mode)
    if os.geteuid() == 0:
        os.chown(temporary, metadata.st_uid, metadata.st_gid)
    os.replace(temporary, archive)
    print(f"已汉化 {replaced} 个默认预设名称，备份：{backup}")
else:
    print("默认预设名称已经是中文，无需修改。")
PY
else
  echo "未找到捕获预设归档，跳过。"
fi

trap - ERR

echo
echo "完成：已安装 Snagit 主应用、效果组件和捕获助手简体中文资源包。"
echo "请完全退出 Snagit 后重新打开，让新资源生效。"
if [[ -d "$BACKUP_DIR" ]]; then
  echo "主应用旧中文包备份：$BACKUP_DIR"
fi
if [[ -d "$COMMON_BACKUP_DIR" ]]; then
  echo "SnagitCommon 旧中文包备份：$COMMON_BACKUP_DIR"
fi
if [[ -d "$HELPER_BACKUP_DIR" ]]; then
  echo "SnagitHelper 旧中文包备份：$HELPER_BACKUP_DIR"
fi
if [[ -f "$PRESET_BACKUP" ]]; then
  echo "捕获预设旧文件备份：$PRESET_BACKUP"
fi
