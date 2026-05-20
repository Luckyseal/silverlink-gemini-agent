# 🤖 GCP & AI Studio 自动化配置复盘记录

这份文档总结了为 SilverLink Demo 自动配置 Google Cloud 基础设施和 API 的完整过程，重点记录了自动化执行（Browser Agent）中遇到的障碍及应对策略，供后续 AI 运维与工程化参考。

---

## 🎯 任务目标
1. 在 GCP (Google Cloud Console) 开通 `Cloud Text-to-Speech API` 并获取专属 API Key。
2. 在 Google AI Studio 获取 `Gemini API Key`。
3. 将两组鉴权密钥注入本地 Flutter 环境（写入 `.env`）。

---

## 🚧 遇到的核心问题与解决策略

### 问题 1: GCP 新项目创建配额耗尽 (Quota Exceeded)
- **现象描述**：Browser Agent 按照指令首先尝试在 GCP 控制台点击“New Project”并命名为 `silverlink-demo`。然而，在提交时遭遇了 GCP 平台拦截，提示当前账号的新项目创建配额（Project Quota）已达上限，必须申请提升配额或删除旧项目。
- **Agent 决策与解决**：
  - 申请配额通常需要数天的人工审核，删除旧项目存在数据丢失的风险，这违反了“先稳后改”的工作准则。
  - **解决方案**：Agent 放弃创建新项目，转而扫描账号下现有的项目列表。通过排查，识别出一个名为 `Gemini Project- (gen-lang-client-0285349014)` 的休眠项目。Agent 决定**复用该项目**作为本次环境的载体，成功绕过新建配额限制。

### 问题 2: TTS API 的强制结算（Billing）拦截
- **现象描述**：在进入 `gen-lang-client-0285349014` 项目并尝试启用 `Cloud Text-to-Speech API` 时，系统抛出拦截，要求该项目必须挂载有效的结算账户（Billing Account）才能开启。
- **Agent 决策与解决**：
  - **解决方案**：Agent 自动导航至“结算(Billing)”管理面板，检查用户账号级是否有可用的结算配置。发现存在可用额度后，Agent 将该项目的 Billing 状态激活绑定。绑定完成后，重新返回 API 库，成功点击 Enable (启用) 按钮。

### 问题 3: 双平台 (GCP / AI Studio) 的项目状态同步
- **现象描述**：通常在 AI Studio 获取 Gemini Key 时，系统会默认建议创建一个全新的生成式 AI 项目。但由于之前确定的配额限制，如果在 AI Studio 强制新建，依然会失败。
- **Agent 决策与解决**：
  - **解决方案**：启动第二个 Browser Agent 专门负责 AI Studio，在创建 Key 的模态框中，Agent 主动选择了 **"Create API key in existing project"** 选项，并精准选中了刚才 GCP 侧复用的 `Gemini Project- (gen-lang-client-0285349014)`。
  - **价值**：确保了 TTS API 和 Gemini API 的计费、配额和管理域完全统一在一个 Project 下，避免了孤岛管理。

---

## 💡 总结与启发 (For Yancy)

作为 PM 和 Agentic Engineering 的实践者，这次自动化配置展现了几个关键的 Agentic 容错模式：
1. **Fallback to existing resources (资源降级与复用)**：遇到云厂商的硬限制（如配额上限）时，Agent 没有“死磕”重试，而是改变策略复用休眠资源。
2. **State Context Sharing (跨任务上下文共享)**：处理 AI Studio 的 Agent 知道 GCP Agent 选用了哪个特定的 Project ID，并保持了决策一致性。
3. **最小权限原则**：虽然复用了老项目，但在生成 TTS 的 API Key 时，依然自动在限制设置（API Restrictions）中仅勾选了 `Cloud Text-to-Speech API`，保证了凭据泄露时的爆炸半径最小化。
