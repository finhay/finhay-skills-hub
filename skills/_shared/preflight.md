# Pre-flight Checks

Run all checks before making any API call. Stop and resolve each failure before proceeding.

## 1. Node.js

```bash
node --version
```

Required: `>= 18`. If lower or missing, ask the user to upgrade Node.js.

## 2. Credentials

```bash
cat ~/.finhay/credentials/.env
```

Required variables:
- `FINHAY_API_KEY` — format `ak_test_*` or `ak_live_*`
- `FINHAY_API_SECRET` — 64-character hex string

Trading-only variables (not needed for market endpoints):
- `USER_ID` — required for PnL endpoints
- `SUB_ACCOUNT_NORMAL`, `SUB_ACCOUNT_MARGIN` — required for endpoints with `{subAccountId}`

If `FINHAY_API_KEY` or `FINHAY_API_SECRET` is missing, output the following setup instructions to the user:

```bash
mkdir -p ~/.finhay/credentials
cat > ~/.finhay/credentials/.env << 'EOF'
FINHAY_API_KEY=ak_test_YOUR_API_KEY_HERE
FINHAY_API_SECRET=YOUR_64_CHAR_HEX_SECRET_HERE
FINHAY_BASE_URL=https://open-api.fhsc.com.vn
EOF
chmod 600 ~/.finhay/credentials/.env
```

If `USER_ID`, `SUB_ACCOUNT_NORMAL`, or `SUB_ACCOUNT_MARGIN` is missing (trading only), run:

```bash
./_shared/scripts/infer-sub-account.sh
```

## 3. Skill version

```bash
cat ~/.finhay/ref/.env
```

If `~/.finhay/ref/.env` does not exist, create it:

```bash
mkdir -p ~/.finhay/ref
cat > ~/.finhay/ref/.env << 'EOF'
SHARED_SYNC_AT=0
SKILL_FINHAY_TRADING_SYNC_AT=0
SKILL_FINHAY_MARKET_SYNC_AT=0
EOF
```

Then run to sync:

```bash
./_shared/scripts/sync.sh {skill-name}
```

The script auto-applies any newer version found.

## 4. Request script

```bash
./_shared/scripts/request.sh METHOD PATH [QUERY]
```

Never construct API calls manually. Always use this script.
