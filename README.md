# 🚀 Finhay Skills Hub

[![Version](https://img.shields.io/badge/version-2.0.0-blue.svg)](./package.json)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Integrate real-time financial data from [Finhay Securities](https://fhsc.com.vn/) directly into AI assistants like **Claude Code**, **Cursor**, and other AI agents.

## ✨ Key Skills

| Skill | Capabilities | When to use? |
|-------|--------------|--------------|
| `finhay-market` | Stock prices, gold, crypto, macro indicators, and technical charts. | When asking about markets, prices, or financial news. |
| `finhay-portfolio` | Asset management, balances, portfolios, order history, and P&L. | When checking personal accounts, NAV, or investment performance. |

---

## 🛠 Installation

### Claude Code Marketplace
Add both skills using the marketplace command:
```bash
claude plugin marketplace add finhay/finhay-skills-hub
```

### Manual Installation
Install via the setup script (clones and links scripts):
```bash
curl -sSL https://raw.githubusercontent.com/finhay/finhay-skills-hub/main/install.sh | bash
```

---

## 🔑 Authentication & Setup

You can configure credentials using either **Environment Variables** (best for sandboxes/CI) or a **Credentials File** (best for local dev).

### Method 1: Environment Variables
Set these variables in your terminal environment:
```bash
export FINHAY_API_KEY="your_api_key"
export FINHAY_API_SECRET="your_api_secret"
```

### Method 2: Credentials File
Run the interactive setup in one line:

**Linux / macOS (Bash):**
```bash
curl -sSL https://raw.githubusercontent.com/finhay/finhay-skills-hub/main/finhay.sh | bash -s auth
```

**Windows (PowerShell):**
```powershell
irm https://raw.githubusercontent.com/finhay/finhay-skills-hub/main/finhay.ps1 | iex; Cmd-Auth
```

### Method 3: Ask an AI Agent
If you are using **Claude Code**, **Cursor**, or another AI agent with terminal access, you can simply ask it:
> "Help me set up my Finhay API credentials."

### CLI Command Reference

| Command | Description |
|---------|-------------|
| `auth` | Configure API credentials interactively |
| `doctor` | Verify system dependencies and setup status |
| `infer` | Resolve `USER_ID` and trading sub-account IDs |
| `request` | Execute signed API requests |
| `sync` | Update local skill definitions from source |

---

## 🤖 Example AI Prompts

Once installed, you can ask Claude questions like:

- **Market Queries**:
  - "What is the current price of VNM stock?"
  - "Show me the SJC gold price chart for the last 30 days."
  - "What is the latest news for banking stocks?"
- **Portfolio Queries**:
  - "What is my total net worth right now?"
  - "Am I currently in profit or loss on my stock holdings?"
  - "List all the stock buy orders I made this month."

---

## 🔍 Verification & Troubleshooting

Verify your setup and dependencies:
```bash
./finhay.sh doctor
```

**System Requirements:**
- OS: macOS, Linux (Bash), or Windows (PowerShell 5.1+).
- Tools: `curl`, `openssl`, `jq`, `xxd`.

## 📜 License
This project is released under the [MIT License](./LICENSE).

## 📌 Disclaimer
Finhay Skills Hub is an informational tool only. Finhay Skills Hub and its outputs are provided to you on an “as is” and “as available” basis, without representation or warranty of any kind.

Finhay Skills Hub does not constitute investment, financial, securities trading or any other form of professional advice; does not represent a recommendation to buy, sell, hold or trade any stocks, bonds, fund certificates, securities or financial products; and does not guarantee the accuracy, timeliness or completeness of any data, analysis or content presented.

Your use of Finhay Skills Hub and any information provided in connection with this feature is at your own risk. You are solely responsible for evaluating the information provided and for all investment or trading decisions made by you.

Finhay does not endorse, verify or guarantee any AI-generated information. Any AI-generated information or summary should not be solely relied upon for decision making. AI-generated content may include or reflect information, views and opinions of third parties, and may also include errors, biases or outdated information.

Finhay is not responsible for any losses or damages incurred as a result of your use of or reliance on the Finhay Skills Hub feature. Finhay may modify or discontinue the Finhay Skills Hub feature at its discretion, and functionality may vary by region, account type or user profile.

Securities trading and financial products involve market risk, liquidity risk, interest rate risk, credit risk and other risks. The value of your investment may go down or up, and you may not get back the full amount invested. You are solely responsible for your investment decisions, and Finhay is not liable for any losses you may incur.

Past performance is not a reliable predictor of future performance. You should only invest in products you are familiar with and where you understand the risks. You should carefully consider your investment experience, financial situation, investment objectives and risk tolerance, and consult an independent professional adviser if needed before making any investment decision.

This material should not be construed as investment, financial, securities trading or any other form of advice.
