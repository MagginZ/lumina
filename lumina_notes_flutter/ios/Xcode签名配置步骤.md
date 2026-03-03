# Xcode 签名配置 - 图文步骤

## 第一步：确认打开的是正确的项目

在终端执行（不要直接双击打开）：

```bash
cd /Users/xxx/Desktop/dir/lumina-notes/lumina_notes_flutter
open ios/Runner.xcworkspace
```

⚠️ 必须打开 **Runner.xcworkspace**，不要打开 Runner.xcodeproj

---

## 第二步：找到 Runner

Xcode 打开后，看 **左侧边栏**（Project Navigator）：

```
📁 lumina_notes_flutter (或显示为 Runner)
   ├── 📁 Runner          ← 这是文件夹，不是我们要点的
   ├── 📁 RunnerTests
   ├── 📁 Flutter
   └── ...
```

**点击最顶部的蓝色项目图标**（可能显示为 `Runner` 或 `lumina_notes_flutter`），这是「项目」。

---

## 第三步：选择 Runner 目标

点击项目后，**中间主区域**会显示项目设置，上方有：

```
TARGETS
  Runner        RunnerTests
  [●]           [ ]
```

**点击 TARGETS 下的 `Runner`**（第一个，不是 RunnerTests）。

---

## 第四步：打开 Signing & Capabilities

选中 Runner 后，主区域**顶部有一排标签**：

```
General | Signing & Capabilities | Resource Tags | Info | Build Settings | Build Phases
         ↑
    点这个
```

**点击「Signing & Capabilities」**。

---

## 第五步：配置签名

在 Signing & Capabilities 页面：

1. ✅ **勾选**「Automatically manage signing」
2. 在 **Team** 下拉框中选择你的 Apple ID
   - 若显示 "Add an Account..."：点击 → 用 Apple ID 登录
   - 登录后返回，Team 会显示你的账号（如：你的名字 (Personal Team)）
3. 若提示 Bundle ID 冲突：把 `com.example.luminaNotesFlutter` 改成唯一的，如 `com.你的名字.luminanotes`

---

## 第六步：信任证书（首次安装到手机后）

应用安装到 iPhone 后，若提示「无法验证开发者」：

**iPhone** → 设置 → 通用 → VPN 与设备管理 → 找到你的开发者证书 → 点击「信任」

---

## 快捷检查清单

- [ ] 用 `open ios/Runner.xcworkspace` 打开
- [ ] 左侧点击蓝色项目图标
- [ ] 中间 TARGETS 选中 Runner
- [ ] 顶部点 Signing & Capabilities
- [ ] 勾选 Automatically manage signing
- [ ] Team 选择你的 Apple ID
