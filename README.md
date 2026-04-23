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
Run the interactive setup and follow the prompts:
```bash
./finhay.sh auth
```
Then, resolve your user identity and sub-accounts (required for Portfolio skill):
```bash
./finhay.sh infer
```

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
