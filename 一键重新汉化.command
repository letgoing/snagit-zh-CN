#!/bin/bash
set -u

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
echo "开始前请结束录屏，并完全退出 Snagit 编辑器和菜单栏中的捕获助手。"
echo "按回车开始安装中文资源。"
read -r _

status=0
bash "$SCRIPT_DIR/outputs/reinstall_snagit_chinese.sh" || status=$?
echo
if [[ "$status" -eq 0 ]]; then
  echo "安装完成。请重新打开 Snagit。"
else
  echo "安装未完成，请查看上方错误信息。"
fi
echo "按回车关闭窗口。"
read -r _
exit "$status"
