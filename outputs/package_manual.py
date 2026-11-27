"""Build the offline Finder package from the checked-in Chinese resources."""

from pathlib import Path
from zipfile import ZIP_DEFLATED, ZipFile, ZipInfo

ROOT = Path(__file__).resolve().parent.parent
NAME = "Snagit-2027.0.1-macOS-zh-Hans"
COMPONENTS = {
    "Snagit": "01-主程序",
    "SnagitCommon": "02-效果组件",
    "SnagitHelper": "03-捕获助手",
}


def build():
    sources = {"00-先读我.txt": ROOT / "docs" / "手动汉化说明.txt"}
    for component, folder in COMPONENTS.items():
        resources = sorted((ROOT / "work" / f"{component}.zh-Hans.lproj").glob("*.strings"))
        if not resources:
            raise ValueError(f"No resources for {component}")
        for path in resources:
            sources[f"{folder}/zh-Hans.lproj/{path.name}"] = path

    output = ROOT / "downloads" / f"{NAME}.zip"
    output.parent.mkdir(exist_ok=True)
    with ZipFile(output, "w") as archive:
        for name, path in sources.items():
            entry = ZipInfo(f"{NAME}/{name}", date_time=(1980, 1, 1, 0, 0, 0))
            entry.create_system = 3
            entry.external_attr = 0o100644 << 16
            archive.writestr(entry, path.read_bytes(), compress_type=ZIP_DEFLATED)
    print(output)


if __name__ == "__main__":
    build()
