---
name: finhay-market
description: "Stock prices, commodities, macro indicators, charts, and company financials. Use for market analysis, price lookups, and corporate performance data."
license: MIT
metadata:
  author: Finhay Securities
  version: "2.0.0"
---

# Finhay Market

Read-only market data via the Finhay Securities Open API.

> **MANDATORY**: Ensure credentials are set (via environment variables `FINHAY_API_KEY`/`FINHAY_API_SECRET` or via `./finhay.sh auth`). Run `./finhay.sh doctor` to verify.

## Usage Examples

```bash
# Get real-time stock quote
./finhay.sh request GET /market/stock-realtime "symbol=VNM"

# Get gold spot price
./finhay.sh request GET /market/financial-data/gold

# Get historical OHLCV chart data
./finhay.sh request GET /market/price-histories-chart "symbol=VNM&resolution=1D&from=1609459200&to=1704067200"
```

## CLI Command Reference

| Command | Description |
|---------|-------------|
| `auth` | Configure API credentials interactively |
| `doctor` | Verify system dependencies and setup status |
| `request` | Execute signed API requests |
| `sync` | Update local skill definitions from source |

### Agent Attribution

> **REQUIRED**: Export `AGENT_NAME` before making any request. Use your tool's canonical lowercase identifier in `kebab-case` (e.g. `claude-code`). Any value is accepted as long as it consistently identifies your tool.

```bash
export AGENT_NAME=claude-code
./finhay.sh request GET /market/stock-realtime "symbol=VNM"
```

Sent as `X-FH-OPENAPI-AGENT` and embedded in `User-Agent`.

## Endpoints

### Tickers

| Endpoint | Description | Params |
|----------|-------------|--------|
| `GET /market/tickers/:ticker` | **Stock Quote**: Single real-time stock object. | `:ticker` (path) |
| `GET /market/tickers` | **Stock List**: Multi-stock or full exchange snapshot. | `symbols` (CSV) or `exchange` (`HOSE`\|`HNX`\|`UPCOM`) |
| `GET /market/tickers/global/:ticker/history` | **Global Stock History**: Daily close price for Mag7 stocks (Apple, Microsoft, Alphabet, Amazon, Meta, Nvidia, Tesla). | `:ticker`* (path, lowercase), `limit` (default 30) |

| `GET /market/tickers/:ticker/ratios` | **Financial Ratios**: Historical ratio trends (PE, PB, ROE, EPS…). | `:ticker` (path), `period`* (`annual`\|`quarterly`) |
| `GET /market/tickers/:ticker/statements` | **Financial Statements**: Income/Balance/Cash flow. | `:ticker`, `statement`* (`income-statement`\|`balance-sheet`\|`cash-flow`), `period`* (`annual`\|`quarterly`), `limit` |
| `GET /market/tickers/:ticker/candles` | **OHLCV Candles**: Price and volume history. | `:ticker`, `resolution` (`1D`\|`1H`\|`4H`\|`30`\|`15`\|`5`), `from`, `to` (seconds) |

### Commodities

| Endpoint | Description | Params |
|----------|-------------|--------|
| `GET /market/commodities/vn/metals` | **VN Metals Spot**: Single spot price for a product. Use `/providers` for all providers. | `type`* (`gold_bar`\|`gold_ring`\|`silver_bar`) |
| `GET /market/commodities/vn/metals/history` | **VN Metals History**: N-day price series for a product. | `type`* (`gold_bar`\|`gold_ring`\|`silver_bar`), `days` (default 30) |
| `GET /market/commodities/vn/metals/providers` | **VN Metal Providers**: Spot prices across all providers for a product. | `type`* (`gold_bar`\|`gold_ring`\|`silver_bar`) |
| `GET /market/commodities/global/metals` | **Global Metals Spot**: International gold, silver, copper spot prices with daily change. | `type`* (`gold`\|`silver`\|`copper`) |
| `GET /market/commodities/global/metals/history` | **Global Metals History**: Time-series for gold, silver, or copper. | `type`* (`gold`\|`silver`\|`copper`), `limit` (default 30) |
| `GET /market/commodities/global/energy` | **Energy Spot**: Crude oil, Brent oil, natural gas spot prices with change. | `type` (`crude-oil`\|`brent-oil`\|`natural-gas`\|`all`) |
| `GET /market/commodities/global/energy/history` | **Energy History**: Time-series for a specific energy commodity. | `type` (required), `limit` (default 30) |

### Economy & Macro

| Endpoint | Description | Params |
|----------|-------------|--------|
| `GET /market/economy/snapshot` | **Macro Snapshot**: Current value for a macro indicator (CPI, PMI, interest rate…). | `type`*, `country`*, `period` |
| `GET /market/economy/indicators` | **Economic Indicators**: Historical data by country and category (GDP, Labour, Trade…). | `country`*, `category`*, `year`, `limit`, `offset` |
| `GET /market/economy/calendar` | **Economic Calendar**: Upcoming events (CPI releases, Fed meetings, trade data). | `weeks` (default 1), `country` |

### Currencies

| Endpoint | Description | Params |
|----------|-------------|--------|
| `GET /market/currencies/:pair/history` | **Exchange Rate History**: Historical rate vs VND, grouped by bank. | `:pair`* (`USD`\|`CNY`\|`EUR`\|`JPY`), `period` (`1M`\|`1Y`\|`YTD`) |
| `GET /market/currencies/cross/:pair/history` | **Cross-Rate History**: Daily price series for major cross-rate pairs. | `:pair`* (`eurusd`\|`usdjpy`\|`gbpusd`), `limit` (default 30) |

### Indices

| Endpoint | Description | Params |
|----------|-------------|--------|
| `GET /market/global-indices/:code/history` | **Index History**: Historical prices for a specific index (`sp500`, `nasdaq`, `dow-jones`, `russell2000`, `vix`, `dxy`, `kospi`, `hangseng`, `shanghai`, `nikkei`). | `:code`, `limit` |

### News

| Endpoint | Description | Params |
|----------|-------------|--------|
| `GET /market/global-news` | **Global News**: Paginated global financial news. | `category`, `page`, `page_size` |
| `GET /market/global-news/:id` | **News Detail**: Full global news article content. | `:id` (path, integer) |
| `GET /market/tickers/:ticker/corporate-actions` | **Corporate Actions**: VN corporate actions for a ticker (dividends, AGM, rights issues). | `:ticker` (path), `from_date`, `to_date` |

### Other

| Endpoint | Description | Params |
|----------|-------------|--------|
| `GET /market/crypto/trending` | **Crypto Trends**: Top trending cryptocurrencies. | — |
| `GET /market/banking/deposit-rates` | **Deposit Rates**: Current bank deposit interest rates. | — |

### Funds

| Endpoint | Description | Params |
|----------|-------------|--------|
| `/fund-trading/public/fund-certificates` | **Fund List**: Available funds, sorted by 1y profit. | `fund-type`* (`STOCK_FUND`\|`BOND_FUND`\|`BALANCE_FUND`), `fund-company-id` |
| `/fund-trading/public/fund-companies` | **Fund Companies**: Management company list. | — |
| `/fund-trading/public/fund-certificates/benchmark/growth` | **Growth Simulation**: Projected return for a VND investment. | `fund-names`* (CSV), `amount`* (VND), `period`* |
| `/fund-trading/public/fund-certificates/benchmark/nav` | **NAV Comparison**: NAV time series for multiple funds. | `fund-names`*, `period` OR (`from-month`+`to-month` `yyyy-MM`) |
| `/fund-trading/public/fund-certificates/:fund/nav-histories` | **NAV History**: Price chart vs benchmarks. | `period` (default `ALL_TIME`) |
| `/fund-trading/public/fund-certificates/:fund/suggestions` | **Similar Funds**: Suggestions by criteria. | — |

## Constraints

- **Read-only**: Execute `GET` requests only.
- **Privacy**: Mask sensitive credentials in all output.
- **Credentials**: If `FINHAY_API_KEY` or `FINHAY_API_SECRET` are missing, stop and ask the user to provide them or run `./finhay.sh auth`.
- **Parameters**: Pass exactly one identifier for stock quotes (symbol, symbols, or exchange).
- **Timeframes**: Price history timestamps must be in **seconds**. Default to the last 5 years if range is not provided.
