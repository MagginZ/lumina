# Lumina 笔记 - Flutter 版

读书笔记应用，支持本地存储与 Gemini AI 助手。

## 功能特性

- **书籍列表**：展示所有书籍，支持滑动删除
- **笔记编辑**：标题、内容编辑，AI 生成图片展示
- **本地存储**：使用 Hive 持久化数据（支持 App + 浏览器）
- **搜索**：按笔记/书籍搜索，AI 洞察卡片
- **AI 助手**：接入 OpenRouter API（支持免费模型），基于笔记内容对话
- **深色模式**：跟随系统主题
- **全中文界面**

## 配置

1. 复制 `env.example` 为 `env`（或直接编辑项目根目录的 `env` 文件）
2. 在 [OpenRouter](https://openrouter.ai/keys) 获取 API Key（有免费额度）
3. 在 `env` 中填入：`OPENROUTER_API_KEY=你的密钥`

## 运行项目

```bash
cd lumina_notes_flutter
flutter pub get
flutter run
```

### Web 预览

若在 Chrome 调试时遇到「The targeted input element must be the active input element」导致无法点击保存/返回，可：

1. **使用 release 模式**（推荐）：`flutter run -d chrome --web-port 5555 --release`
2. **升级 Flutter**：`flutter upgrade`（该问题已在 3.27.2+ 修复）

### 在 iOS 真机运行

⚠️ **iOS 18.4+ 真机必须用 Release 模式**，否则会崩溃白屏。

1. **前置**：Mac + Xcode + 数据线连接 iPhone
2. **iPhone**：`设置 → 隐私与安全 → 开发者模式` 打开
3. **信任电脑**：连接后点击「信任」
4. **配置签名**：`open ios/Runner.xcworkspace` 打开 Xcode → Runner → Signing & Capabilities → 勾选 Automatically manage signing → 选择你的 Apple ID 作为 Team
5. **运行**：在终端执行 `./run_ios_release.sh` 或 `flutter run --release`（务必带 `--release`，否则会闪退）
6. 安装完成后，在 iPhone 主屏点击应用图标打开

## 项目结构

```
lib/
├── main.dart
├── models/           # 数据模型
├── data/              # 初始数据
├── services/          # 数据库、AI 服务
├── state/             # 状态管理
├── theme/             # 主题
├── screens/           # 页面
└── widgets/           # 组件
```

## 依赖

- `provider` - 状态管理
- `hive` / `hive_flutter` - 本地存储（App + Web 通用）
- `google_generative_ai` - Gemini AI
- `flutter_slidable` - 滑动删除
