#!/bin/bash
# iOS 真机运行脚本 - 必须用 Release 模式，Debug 从主屏打开会闪退
cd "$(dirname "$0")"
echo "正在以 Release 模式构建并安装..."
flutter run --release
echo ""
echo "安装完成后，在 iPhone 主屏点击 Lumina 笔记 打开应用"
