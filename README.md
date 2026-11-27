# Snagit macOS 简体中文汉化

用于 macOS 版 Snagit 的非官方简体中文资源包，包含一键安装入口、资源生成器和可直接替换的 `.strings` 文件。

当前随仓库提供的替换文件基于 **Snagit 2027.0.1** 生成。汉化覆盖编辑器、效果组件和捕获助手，部分功能仍会显示英文。

## 直接下载（不用命令行）

**[下载 Snagit 2027.0.1 macOS 简体中文手动汉化包（ZIP）](https://github.com/letgoing/snagit-zh-CN/releases/download/v2027.0.1/Snagit-2027.0.1-macOS-zh-Hans.zip)** · [版本发布页](https://github.com/letgoing/snagit-zh-CN/releases/tag/v2027.0.1) · [查看访达安装与恢复步骤](docs/手动汉化说明.txt)

1. 在 Snagit 的“关于”窗口确认版本是 **2027.0.1**。保存文件、结束录屏，退出编辑器和菜单栏里的捕获助手。
2. 点击上面的下载链接并解压，打开 **00-先读我.txt**。不用下载仓库源码，也不用安装 Git 或 Python。
3. 按说明在访达里打开三个目标位置，先备份原有的中文文件夹，再分别复制 **01-主程序、02-效果组件、03-捕获助手** 里面的 `zh-Hans.lproj`。重新打开 Snagit 即可检查。

这是**中文翻译包，不含 Snagit 本体**。想撤销时按包内说明还原备份。若 Snagit 拒绝启动，请恢复备份或重新安装官方原版，不要关闭系统安全保护。版本不同请勿套用此包。

## 汉化预览

![Snagit 中文编辑器：顶部为标注工具栏，右侧为快速样式、阴影和其他工具属性](docs/images/snagit-zh-hans-preview.jpg)

## 其他版本或升级后：一键脚本

1. 下载本仓库的 ZIP 并解压，或者使用下方命令克隆。
2. 保存正在编辑的图像，结束录屏。
3. 双击根目录的 **一键重新汉化.command**。脚本会读取本机 Snagit 的版本，生成并安装中文资源，然后尝试正常退出编辑器和捕获助手，并用简体中文重新打开 Snagit。后续升级 Snagit 后，再双击同一脚本即可。可以在访达中为脚本创建替身放到桌面。

```bash
git clone https://github.com/letgoing/snagit-zh-CN.git
cd snagit-zh-CN
./一键重新汉化.command
```

自动生成和安装需要 macOS、Python 3 及已经安装的 Snagit。安装器默认使用 `/Applications/Snagit.app`，会重新生成当前版本对应的中文文件、校验格式并安装到三个资源目录。目录不可写时会请求管理员权限。

如果双击脚本无法运行，可在终端进入解压后的目录，使用上面的 `bash` 命令。也可以指定其他安装位置：

```bash
SNAGIT_APP="/其他位置/Snagit.app" bash outputs/reinstall_snagit_chinese.sh
```

## 已包含的替换文件

`work/` 内的三个目录包含可手动替换的中文资源。具体文件数会随本机 Snagit 版本变化。

| 仓库内的中文包 | 安装目标，相对于 `Snagit.app/` |
| --- | --- |
| `work/Snagit.zh-Hans.lproj` | `Contents/Resources/zh-Hans.lproj` |
| `work/SnagitCommon.zh-Hans.lproj` | `Contents/Frameworks/SnagitCommon.framework/Versions/A/Resources/zh-Hans.lproj` |
| `work/SnagitHelper.zh-Hans.lproj` | `Contents/Library/LoginItems/SnagitHelper.app/Contents/Resources/zh-Hans.lproj` |

手动替换前先完全退出 Snagit。将目标目录中已有的 `zh-Hans.lproj` 改名备份，再复制对应的中文包，并将其名称改为 **`zh-Hans.lproj`**。只替换此中文目录，保留 `Base.lproj`、`en.lproj`、`ja.lproj` 等原有资源。

随仓库提供的文件对应上述版本。其他版本优先使用安装脚本重新生成；界面结构发生变化后仍可能需要补充翻译。软件升级可能覆盖汉化，升级后可重新执行脚本。

## 脚本与备份

- `一键重新汉化.command`：可双击的安装入口。
- `outputs/reinstall_snagit_chinese.sh`：校验、备份及安装三套中文资源。
- `outputs/build_snagit_zh_hans.py`：根据本机 Snagit 的语言资源和现有词典生成中文包，输出到 `work/`。
- `outputs/ui_labels_zh_hans.json`：补充的界面原文和译文，须与生成器放在同一目录。

已有中文包会改名为 `zh-Hans.lproj.backup.时间戳`，保留在各自原目录中。需要恢复时，先退出 Snagit，将新中文目录移走，再把对应备份改回 `zh-Hans.lproj`。首次汉化没有旧中文包时不会生成此备份；移走新增的中文目录即可回到应用原有语言。

只重新生成文件、暂不安装：

```bash
python3 outputs/build_snagit_zh_hans.py
```

## 捕获小窗与已知限制

捕获小窗属于独立的 SnagitHelper。仅退出编辑器可能不会重启它，需要同时退出菜单栏中的 Snagit 捕获助手。当前版本的助手中文资源已安装并通过格式校验，但本机自动化未能完成小窗界面的可视核验。

已保存的默认预设名称存放在用户配置中，不会随语言包自动改变。安装器会尝试备份该配置并翻译四个默认名称；若 macOS 隐私权限阻止读取，会提示跳过，不影响应用中文资源的安装。个人预设归档不包含在本仓库中。

本仓库不包含 Snagit 应用程序、许可证或个人捕获图库。请自行安装并按其许可使用 Snagit；本项目与 TechSmith 无隶属关系。

## 自愿打赏

汉化包免费下载使用。如果这个项目帮到了你，欢迎扫码支持后续维护。

<img src="docs/images/support-code.png" alt="作者的打赏码" width="260">
