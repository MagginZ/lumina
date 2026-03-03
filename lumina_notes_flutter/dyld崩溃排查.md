# dyld __abort_with_payload 崩溃排查

应用在启动时崩溃于 dyld（动态链接器），通常与框架加载或路径有关。

## 方案一：移动项目到无特殊字符路径（推荐）

项目路径中的 emoji（🐟）可能导致 dyld 加载失败。建议将项目移到简单路径：

```bash
# 复制到新路径
cp -r "/Users/seven/Desktop/-🐟的文件夹/lumina-notes/lumina_notes_flutter" ~/Desktop/lumina_notes_flutter

# 进入新路径
cd ~/Desktop/lumina_notes_flutter

# 重新构建
flutter clean
flutter pub get
export LANG=en_US.UTF-8
cd ios && pod install && cd ..
flutter run
```

## 方案二：在 Xcode 中 Clean Build

1. 打开 `ios/Runner.xcworkspace`
2. 菜单 **Product → Clean Build Folder**（⇧⌘K）
3. 关闭 Xcode
4. 终端执行：
```bash
cd lumina_notes_flutter
flutter clean
flutter pub get
cd ios && pod install && cd ..
```
5. 重新打开 Xcode，**Product → Run**

## 方案三：查看设备崩溃日志

1. iPhone 连接 Mac
2. Xcode → **Window → Devices and Simulators**
3. 选中你的 iPhone → 点击 **View Device Logs**
4. 找到最新的 Runner 崩溃记录，查看详细错误信息（如 "code signature invalid"）

## 方案四：检查签名

Xcode → Runner → Signing & Capabilities：
- 确认 **Automatically manage signing** 已勾选
- 确认 **Team** 已选择
- 若有多台设备，确认 **Provisioning Profile** 包含当前设备
