# 安装 CocoaPods

CocoaPods 是 iOS 开发必需的依赖管理工具，Flutter 的 iOS 插件需要它。

## 方法一：Homebrew（推荐）

在 **终端** 中执行：

```bash
brew install cocoapods
```

若提示「process has already locked」：等待几分钟后重试，或重启终端再执行。

---

## 方法二：使用 sudo（若 Homebrew 失败）

```bash
sudo gem install cocoapods
```

若失败并提示 Ruby 版本过旧，可先升级 Ruby 或改用方法一。

---

## 验证安装

```bash
pod --version
```

应显示版本号（如 1.16.2）。

---

## 安装后运行项目

```bash
cd /Users/xxx/Desktop/dir/lumina-notes/lumina_notes_flutter
flutter clean
flutter pub get
flutter run
```
