#!/bin/bash
# iOS 构建修复脚本 - 解决 Framework 'Pods_Runner' not found

set -e
cd "$(dirname "$0")"

echo "=== 1. Flutter 清理 ==="
flutter clean
flutter pub get

echo ""
echo "=== 2. 清理 iOS 缓存 ==="
rm -rf ios/Pods
rm -rf ios/Podfile.lock
rm -rf ios/.symlinks
rm -rf ios/Flutter/Flutter.framework
rm -rf ios/Flutter/Flutter.podspec

echo ""
echo "=== 3. 重新安装 CocoaPods ==="
cd ios
pod install --repo-update
cd ..

echo ""
echo "=== 完成 ==="
echo "请用以下命令打开 Xcode（必须用 .xcworkspace）："
echo "  open ios/Runner.xcworkspace"
echo ""
echo "在 Xcode 中：Product → Clean Build Folder (⇧⌘K)，然后 Product → Run"
