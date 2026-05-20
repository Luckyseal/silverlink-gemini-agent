# 🌐 SilverLink API Setup Guide (GCP & AI Studio)

本手册详细说明如何从零开始配置 SilverLink Demo 所依赖的云端服务，包含 **Gemini API** 与 **Google Cloud Text-to-Speech (TTS)**。

---

## 1. 🤖 获取 Gemini API Key (Google AI Studio)

推荐使用 Google AI Studio 获取 Gemini API Key（免费额度充足，且无需强制绑定信用卡）。

### 步骤
1. **登录**: 访问 [Google AI Studio](https://aistudio.google.com/) 并使用 Google 账号登录。
2. **创建 API Key**:
   - 在左侧导航栏点击 **"Get API key"**。
   - 点击 **"Create API key"**。
   - 如果有现有的 Google Cloud Project，可以选择它；否则选择在新的默认项目中创建。
3. **复制并保存**: 生成的 Key 即为项目所需的 `GEMINI_API_KEY`。

---

## 2. 🗣 获取 Google Cloud TTS API Key (GCP Console)

为了使用高质量的 `ja-JP-Neural2-B` 或 `ja-JP-Chirp3-HD-Kore` 等日语语音，需要在 Google Cloud Console (GCP) 启用 Cloud Text-to-Speech API。

### 步骤 2.1: 创建 GCP 项目与启用结算
1. **登录**: 访问 [Google Cloud Console](https://console.cloud.google.com/)。
2. **创建项目**:
   - 点击顶部导航栏的项目下拉菜单，选择 **"新建项目" (New Project)**。
   - 命名为 `silverlink-demo` 或其他名称，点击 **"创建"**。
3. **启用结算 (Billing)**:
   - *注意：TTS API 要求必须绑定结算账号。*
   - 在左侧菜单找到 **"结算" (Billing)**，并关联或创建一个结算账号（新用户有免费赠金）。

### 步骤 2.2: 启用 Cloud Text-to-Speech API
1. 在顶部搜索栏搜索 **"Cloud Text-to-Speech API"** 并点击进入。
2. 点击 **"启用" (Enable)** 按钮。

### 步骤 2.3: 生成并限制 API Key
1. 在左侧菜单前往 **"API 和服务" (APIs & Services) > "凭据" (Credentials)**。
2. 点击顶部的 **"创建凭据" (Create Credentials)**，选择 **"API 密钥" (API key)**。
3. **限制 API Key（强烈推荐安全实践）**:
   - 在生成的弹窗中点击 **"修改 API 密钥" (Edit API key)**。
   - 在 "API 限制" 部分，选择 **"限制密钥" (Restrict key)**。
   - 在下拉列表中勾选 **Cloud Text-to-Speech API**。
   - 点击保存。
4. **复制并保存**: 该 Key 即为项目所需的 `GOOGLE_TTS_API_KEY`。

---

## 3. ⚙️ 配置 Flutter 项目

获取到上述两个 Key 后，请将其注入到 Flutter App 中。你有两种方式：

### 方式 A: 环境变量启动（推荐开发者使用）

在终端运行项目时，通过 `--dart-define` 注入参数：

```bash
flutter run \
  --dart-define=GEMINI_API_KEY="你的_GEMINI_API_KEY" \
  --dart-define=GEMINI_MODEL=gemini-2.0-flash \
  --dart-define=GOOGLE_TTS_API_KEY="你的_GCP_TTS_API_KEY" \
  --dart-define=GOOGLE_TTS_VOICE=ja-JP-Neural2-B
```

### 方式 B: App 内置设置（推荐给评委演示时使用）

1. 终端直接运行基础命令：`flutter run`
2. 在 App 启动后，点击界面右上角的 **「設定」 (Settings) 齿轮图标**。
3. 在设置面板中直接粘贴入：
   - **Gemini API Key**
   - **Google TTS API Key**
4. 点击保存。配置会保存在手机的本地存储（SharedPreferences）中，下次启动无需重新输入。

---

## 🚨 注意事项

- **切勿将包含真实 API Key 的文件提交到 Git**。请参考根目录的 `.env.example` 的结构。
- **配额与费用**: Google AI Studio 的 Gemini Flash 模型提供充足的免费调用层级（Free Tier）。Google Cloud TTS 每月有 100 万字符的免费额度，Hackathon 演示绝对够用。
