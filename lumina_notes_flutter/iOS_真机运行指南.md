# 在 iPhone 真机运行 Lumina 笔记

## 当前问题

`flutter devices` 未识别 iPhone，是因为 **未安装完整的 Xcode**。  
当前系统只有 Command Line Tools，不足以进行 iOS 真机开发。

---

## 解决步骤

### 第一步：安装 Xcode（约 12GB，需一定时间）

1. 打开 **App Store**
2. 搜索 **Xcode** 并安装（免费）
3. 安装完成后，打开 Xcode 一次，按提示完成首次配置

### 第二步：配置 Xcode 命令行

在 **终端**（或 Cursor 的终端）中执行：

```bash
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -runFirstLaunch
```

### 第三步：安装 CocoaPods

```bash
brew install cocoapods
```

若提示「process has already locked」：等待几分钟后重试，或重启终端。

若 brew 失败，可尝试：`sudo gem install cocoapods`

验证：`pod --version` 应显示版本号（如 1.16.2）

### 第四步：连接 iPhone

1. 用数据线连接 iPhone 到 Mac
2. 在 iPhone 上选择「信任此电脑」
3. 若为 iOS 16+：`设置 → 隐私与安全 → 开发者模式` 打开，并按提示重启

### 第五步：验证设备识别

```bash
cd lumina_notes_flutter
flutter doctor
flutter devices
```

此时应能看到你的 iPhone。

### 第六步：配置签名并运行

```bash
open ios/Runner.xcworkspace
```

在 Xcode 中（找不到 Runner 时，详见 `ios/Xcode签名配置步骤.md`）：

1. **左侧边栏** 点击最顶部的蓝色项目图标（Runner）
2. **中间区域** TARGETS 下选中 **Runner**（不是 RunnerTests）
3. **顶部标签** 点击 **Signing & Capabilities**
4. 勾选 **Automatically manage signing**
5. **Team** 下拉选择你的 Apple ID（无则点 Add Account 登录）
6. 关闭 Xcode

然后运行：

```bash
flutter run
```

选择你的 iPhone 作为目标设备即可。

---

## 在 Cursor 中运行

完成上述配置后，在 Cursor 中：

1. 打开终端（Terminal → New Terminal）
2. 执行：`cd lumina_notes_flutter && flutter run`
3. 若有多台设备，会提示选择，输入对应编号

或使用 Cursor 的 Run 功能，选择 Flutter 运行配置。

---

## 常见问题

**Q: 提示「无法验证开发者」？**  
A: 在 iPhone 上：`设置 → 通用 → VPN 与设备管理`，信任你的开发者证书。

**Q: Xcode 安装很慢？**  
A: 正常，Xcode 体积较大，建议在稳定网络下安装。

**Q: 必须用 Mac 吗？**  
A: 是的，iOS 真机开发需要 Mac 和 Xcode。
