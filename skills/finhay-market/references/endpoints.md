# Market Endpoints

Signing: use `./finhay.sh request` (or `.\finhay.ps1 request`).

## Errors

`400` = invalid request, `401` = auth failure, `429` = rate limited.

Common causes: missing API key, combining `symbol`/`symbols`/`exchange`, path mismatch in signature.

## Response Keys

- `result` — stock-realtime
- `data` — all other endpoints

---

## Stock

| # | Path | Params | Res key | Note | Detail |
|---|------|--------|---------|------|--------|
| 1 | `/market/stock-realtime` | 1-of: `symbol`, `symbols`, `exchange` | `result` | object for `symbol`, array for `symbols`/`exchange` | [detail](./endpoints/stock-realtime.md) |

## News

| # | Path | Params | Res key | Detail |
|---|------|--------|---------|--------|
| 1 | `/market/news` | `stock`, `stocks`, `from_date`, `to_date` (all optional) | `result` | [detail](./endpoints/news.md) |

## Financial Data — Precious Metals

| # | Path | Params | Res key | Detail |
|---|------|--------|---------|--------|
| 1 | `/market/financial-data` | — | `data` | [detail](./endpoints/financial-data.md) |
| 2 | `/market/financial-data/gold` | — | `data` | [detail](./endpoints/gold.md) |
| 3 | `/market/financial-data/silver` | — | `data` | [detail](./endpoints/silver.md) |
| 4 | `/market/financial-data/gold-chart` | `days` (default 30) | `data` | [detail](./endpoints/gold-chart.md) |
| 5 | `/market/financial-data/silver-chart` | `days` (default 30) | `data` | [detail](./endpoints/silver-chart.md) |
| 6 | `/market/financial-data/gold-providers` | — | `data` | [detail](./endpoints/gold-providers.md) |
| 7 | `/market/financial-data/metal-providers` | — | `data` | [detail](./endpoints/metal-providers.md) |

## Financial Data — Other

| # | Path | Params | Res key | Detail |
|---|------|--------|---------|--------|
| 1 | `/market/financial-data/bank-interest-rates` | — | `data` | [detail](./endpoints/bank-interest-rates.md) |
| 2 | `/market/financial-data/cryptos/top-trending` | — | `data` | [detail](./endpoints/cryptos-top-trending.md) |
| 3 | `/market/financial-data/macro` | `type`*, `country`*, `period` | `data` | [detail](./endpoints/macro.md) |
| 4 | `/market/financial-data/trading-economics` | `country`* (enum), `category` (enum), `year` | `data` | [detail](./endpoints/trading-economics.md) |
| 5 | `/market/financial-data/global-news` | `category` (enum), `page`, `page_size` (max 50, default 20) | `data` | [detail](./endpoints/global-news.md) |
| 6 | `/market/financial-data/global-news/:id` | `:id`* (path) | `data` | [detail](./endpoints/global-news.md) |

## Financial Data — Market Indices & Assets

| # | Path | Params | Res key | Detail |
|---|------|--------|---------|--------|
| 1 | `/market/financial-data/market` | `type`* (enum), `limit` (default 50, max 500) | `data` | [detail](./endpoints/market-data.md) |

## Financial Data — Economic Calendar

| # | Path | Params | Res key | Detail |
|---|------|--------|---------|--------|
| 1 | `/market/financial-data/economic-calendar-events` | `weeks` (default 1), `country` (optional, e.g. `China`, `Vietnam`) | `data` | [detail](./endpoints/economic-calendar-events.md) |

## Funds

| # | Path | Params | Res key | Detail |
|---|------|--------|---------|--------|
| 1 | `/fund-trading/public/fund-certificates` | `fund-type`* (`STOCK_FUND`\|`BOND_FUND`\|`BALANCE_FUND`), `fund-company-id` | `data` | [detail](./endpoints/funds.md) |
| 2 | `/fund-trading/public/fund-companies` | — | `data` | [detail](./endpoints/fund-companies.md) |
| 3 | `/fund-trading/public/fund-certificates/top-{aum\|investor\|fund-flow}` | `fund-type`* | `data` | [detail](./endpoints/fund-rankings.md) |
| 4 | `/fund-trading/public/fund-certificates/top-holding-symbols` | — | `data` | [detail](./endpoints/fund-rankings.md) |
| 5 | `/fund-trading/public/fund-certificates/benchmark/growth` | `fund-names`*, `amount`* (VND), `period`* | `data` | [detail](./endpoints/fund-benchmark.md) |
| 6 | `/fund-trading/public/fund-certificates/benchmark/{nav\|operation}` | `fund-names`*, `period` OR (`from-month`+`to-month`, `yyyy-MM`) | `data` | [detail](./endpoints/fund-benchmark.md) |
| 7 | `/fund-trading/public/fund-certificates/:fund/portfolio` | `:fund`* (path) | `data` | [detail](./endpoints/fund-details.md) |
| 8 | `/fund-trading/public/fund-certificates/:fund/nav-histories` | `:fund`* (path), `period` (default `ALL_TIME`) | `data` | [detail](./endpoints/fund-nav-history.md) |
| 9 | `/fund-trading/public/fund-certificates/:fund/{asset-allocation\|sector-allocation\|suggestions}` | `:fund`* (path) | `data` | [detail](./endpoints/fund-details.md) |

## Reports

| # | Path | Params | Res key | Detail |
|---|------|--------|---------|--------|
| 1 | `/market/recommendation-reports/:symbol` | `symbol`* (path) | `data` | [detail](./endpoints/recommendation-reports.md) |

## Price History

| # | Path | Params | Res key | Note | Detail |
|---|------|--------|---------|------|--------|
| 1 | `/market/price-histories-chart` | `symbol`*, `resolution`* (`1D`, `5`, `15`, `30`, `1H`, `4H`, default `1D`), `from`*, `to`* (seconds) | `data` | `from`/`to` in **seconds** not ms | [detail](./endpoints/price-histories-chart.md) |

## Company Financial

| # | Path | Params | Res key | Detail |
|---|------|--------|---------|--------|
| 1 | `/market/company-financial/overview` | `symbol`* | `data` | [detail](./endpoints/company-financial-overview.md) |
| 2 | `/market/company-financial/analysis` | `symbol`*, `period` (`annual`\|`quarterly`) | `data` | [detail](./endpoints/company-financial-analysis.md) |
| 3 | `/market/v2/financial-statement/statement` | `symbol`*, `type`* (`income-statement`\|`balance-sheet`\|`cash-flow`), `period` (`annual`\|`quarterly`), `limit` | `data` | [detail](./endpoints/financial-statement.md) |

---

## Choosing the Right Company Financial Endpoint

| Need | Endpoint |
|------|----------|
| Current ratios (PE, PB, ROE, EPS…) | `/company-financial/overview` |
| Trend of ratios over years/quarters | `/company-financial/analysis` |
| Income statement / balance sheet / cash flow | `/market/v2/financial-statement/statement` |

`type` values for statement endpoints: `income-statement`, `balance-sheet`, `cash-flow`
`period` values: `annual`, `quarterly`

---

## Choosing the Right Financial Data Endpoint

| Need | Endpoint |
|------|----------|
| Everything (gold + silver + crypto + bank rates) | `/market/financial-data` |
| Only gold (SJC + global) | `/market/financial-data/gold` |
| Gold by provider (PNJ, DOJI, BTMC...) | `/market/financial-data/gold-providers` |
| Gold chart (N days) | `/market/financial-data/gold-chart?days=N` |
| Silver equivalents | replace `gold` → `silver` |
| Macro (CPI, PMI, interest rates...) | `/market/financial-data/macro` |
| Historical economic indicators by country (GDP, inflation, trade...) | `/market/financial-data/trading-economics?country=<NAME>&category=<CAT>` |
| Bank deposit rates | `/market/financial-data/bank-interest-rates` |
| Top crypto | `/market/financial-data/cryptos/top-trending` |
| Historical price for global indices, Mag7 stocks, commodities, forex | `/market/financial-data/market?type=<TYPE>` |
| Upcoming economic events (CPI releases, Fed meetings…) | `/market/financial-data/economic-calendar-events?weeks=N&country=<NAME>` |
| Global financial news (forex, commodities, crypto, macro…) | `/market/financial-data/global-news?category=<CAT>&page=N` |
| Full article content by ID | `/market/financial-data/global-news/:id` |
| Fund list (with `fund-type` filter) | `/fund-trading/public/fund-certificates?fund-type=<TYPE>` |
| Fund portfolio and holdings | `/fund-trading/public/fund-certificates/:fund/portfolio` |
| Fund rankings: AUM / Investors / Fund-flow | `/fund-trading/public/fund-certificates/top-{aum\|investor\|fund-flow}` |
| Top symbols held across funds | `/fund-trading/public/fund-certificates/top-holding-symbols` |
| Simulate growth of a VND investment | `/fund-trading/public/fund-certificates/benchmark/growth` |
| Compare NAV time series | `/fund-trading/public/fund-certificates/benchmark/nav` |
| Compare operational metrics (AUM, investors, flow) | `/fund-trading/public/fund-certificates/benchmark/operation` |
| Fund asset/sector allocation, similar funds | `/fund-trading/public/fund-certificates/:fund/{asset-allocation\|sector-allocation\|suggestions}` |
| Fund NAV historical chart | `/fund-trading/public/fund-certificates/:fund/nav-histories` |
| Fund management companies | `/fund-trading/public/fund-companies` |
