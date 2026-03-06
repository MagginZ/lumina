# iOS 运行修复指南

针对「Framework 'Pods_Runner' not found」和「Dart VM Service was not discovered」的完整解决方案。

---

## 一、Framework 'Pods_Runner' not found

**原因**：Xcode 打开了错误的工作区，或 Pods 未正确安装。

### 必须使用 .xcworkspace

⚠️ **永远用 `Runner.xcworkspace` 打开项目，不要用 `Runner.xcodeproj`**

```bash
# 正确：用 workspace 打开
open lumina_notes_flutter/ios/Runner.xcworkspace
```

### 完整清理并重建

在项目根目录执行：

```bash
cd lumina_notes_flutter

# 1. Flutter 清理
flutter clean
flutter pub get

# 2. 删除 iOS 构建缓存
rm -rf ios/Pods
rm -rf ios/Podfile.lock
rm -rf ios/.symlinks
rm -rf ios/Flutter/Flutter.framework
rm -rf ios/Flutter/Flutter.podspec

# 3. 重新安装 Pods
cd ios
pod install --repo-update
cd ..

# 4. 用 workspace 打开 Xcode
open ios/Runner.xcworkspace
```

在 Xcode 中：**Product → Clean Build Folder** (⇧⌘K)，然后 **Product → Run**。

---

## 二、Dart VM Service was not discovered / 白屏 / SIGABRT（iOS 18.4+ 真机必看）

**根本原因**：iOS 18.4+ 禁止 Debug 模式的 JIT 编译，真机上 Debug 会崩溃。

### ⭐ 必须使用 Release 模式（真机唯一可行方式）

```bash
cd lumina_notes_flutter
flutter run --release
```

或使用脚本：
```bash
./run_ios_release.sh
```

### 若从 Xcode 运行

已修改 Runner scheme，**Product → Run** 会使用 Release 配置。若仍崩溃，请：
1. **Product → Scheme → Edit Scheme**
2. **Run** → **Build Configuration** 改为 **Release**
3. 关闭 Xcode，终端执行 `flutter run --release`

### 方案 A：先跑模拟器验证（Debug 可用）

```bash
cd lumina_notes_flutter
flutter run
# 选择 iOS 模拟器（如 iPhone 15）
```

模拟器不受 JIT 限制，Debug 模式可正常使用。

### 方案 B：移到简单路径（推荐）

```bash
# 复制到无特殊字符的路径
cp -r "/Users/xxx/Desktop/-dir/lumina-notes/lumina_notes_flutter" ~/Desktop/lumina_notes_flutter

cd ~/Desktop/lumina_notes_flutter

flutter clean
flutter pub get
cd ios && pod install && cd ..
flutter run
```

### 方案 C：升级 Flutter

```bash
flutter upgrade
cd lumina_notes_flutter
flutter clean
flutter pub get
cd ios && pod install && cd ..
flutter run
```

### 方案 D：查看真机崩溃日志

1. iPhone 连接 Mac
2. Xcode → **Window → Devices and Simulators**
3. 选中设备 → **View Device Logs**
4. 找到最新 Runner 崩溃记录，查看具体错误（如 code signature、dyld 等）

---

## 三、白屏 / 黑屏（Impeller 渲染问题）

若 Release 模式能安装但显示白屏或黑屏，可能是 Impeller 与 iOS 18+ 的兼容问题。

### 已添加的修复

项目中已在 `Info.plist` 加入 `FLTEnableImpeller = false`，禁用 Impeller 渲染引擎。

### 命令行尝试

```bash
flutter run --release --no-enable-impeller
```

（若 Flutter 版本较新，`--no-enable-impeller` 可能已移除）

### 升级 Flutter（推荐）

Flutter 3.6.0 与 iOS 18 存在兼容问题，建议升级到最新稳定版：

```bash
flutter upgrade
cd lumina_notes_flutter
flutter clean
flutter pub get
cd ios && pod install && cd ..
flutter run --release
```

---

## 四、快速检查清单

- [ ] 使用 `Runner.xcworkspace` 而非 `Runner.xcodeproj`
- [ ] 已执行 `pod install`
- [ ] Xcode 中已做 Clean Build
- [ ] 签名：Signing & Capabilities 中 Team 已选择
- [ ] 若真机崩溃，先试模拟器
- [ ] 若仍失败，尝试将项目移到 `~/Desktop/` 等简单路径
