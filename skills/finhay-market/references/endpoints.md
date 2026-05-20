# Market Endpoints

Signing: use `./finhay.sh request` (or `.\finhay.ps1 request`).

## Errors

`400` = invalid request, `401` = auth failure, `429` = rate limited.

Common causes: missing API key, combining `symbol`/`symbols`/`exchange`, path mismatch in signature.


## Tickers — VN Stocks

| # | Path | Params | Res key | Note | Detail |
|---|------|--------|---------|------|--------|
| 1 | `GET /market/tickers/:ticker` | `:ticker`* (path) | `data` | single stock real-time object | [detail](./endpoints/stocks.md) |
| 2 | `GET /market/tickers` | 1-of: `symbols` (CSV), `exchange` (`HOSE`\|`HNX`\|`UPCOM`) | `data` | array of stocks | [detail](./endpoints/stocks.md) |
| 3 | `GET /market/tickers/global/:ticker/history` | `:ticker`* (`apple`\|`microsoft`\|`alphabet`\|`amazon`\|`meta`\|`nvidia`\|`tesla`), `limit` (default 30) | `data` | daily close price history for Mag7 stocks | [detail](./endpoints/stocks-global.md) |

## News

| # | Path | Params | Res key | Note | Detail |
|---|------|--------|---------|------|--------|
| 1 | `GET /market/global-news` | `category` (enum), `page`, `page_size` | `data` | global financial news | [detail](./endpoints/global-news.md) |
| 2 | `GET /market/global-news/:id` | `:id`* (path, integer) | `data` | global news article detail | [detail](./endpoints/global-news.md) |
| 3 | `GET /market/tickers/:ticker/corporate-actions` | `:ticker`* (path), `from_date`, `to_date` | `data` | VN corporate actions for a ticker (dividends, AGM, rights) | [detail](./endpoints/corporate-actions.md) |

## Commodities — VN Metals

| # | Path | Params | Res key | Note | Detail |
|---|------|--------|---------|------|--------|
| 1 | `GET /market/commodities/vn/metals` | `type`* (`gold_bar`\|`gold_ring`\|`silver_bar`) | `data` | single spot price record | [detail](./endpoints/commodities-vn-metals.md) |
| 2 | `GET /market/commodities/vn/metals/history` | `type`* (`gold_bar`\|`gold_ring`\|`silver_bar`), `days` (default 30) | `data` | price series for one product | [detail](./endpoints/commodities-vn-metals.md) |
| 3 | `GET /market/commodities/vn/metals/providers` | `type`* (`gold_bar`\|`gold_ring`\|`silver_bar`) | `data` | spot prices across all providers | [detail](./endpoints/commodities-vn-metals.md) |

## Commodities — Global Metals

| # | Path | Params | Res key | Note | Detail |
|---|------|--------|---------|------|--------|
| 1 | `GET /market/commodities/global/metals` | `type`* (`gold`\|`silver`\|`copper`) | `data` | spot + daily change | [detail](./endpoints/commodities-global-metals.md) |
| 2 | `GET /market/commodities/global/metals/history` | `type`* (`gold`\|`silver`\|`copper`), `limit` (default 30) | `data` | time-series descending | [detail](./endpoints/commodities-global-metals.md) |

## Commodities — Global Energy

| # | Path | Params | Res key | Note | Detail |
|---|------|--------|---------|------|--------|
| 1 | `GET /market/commodities/global/energy` | `type` (`crude-oil`\|`brent-oil`\|`natural-gas`\|`all`, default `all`) | `data` | spot + change | [detail](./endpoints/commodities-global-energy.md) |
| 2 | `GET /market/commodities/global/energy/history` | `type` (required, one of above excl. `all`), `limit` (default 30) | `data` | time-series descending | [detail](./endpoints/commodities-global-energy.md) |

## Economy

| # | Path | Params | Res key | Note | Detail |
|---|------|--------|---------|------|--------|
| 1 | `GET /market/economy/snapshot` | `type`*, `country`*, `period` | `data` | current macro indicator | [detail](./endpoints/economy.md) |
| 2 | `GET /market/economy/indicators` | `country`* (enum), `category`* (enum), `year`, `limit` (default 50), `offset` | `data` | historical economic indicators | [detail](./endpoints/economy.md) |
| 3 | `GET /market/economy/calendar` | `weeks` (default 1), `country` (e.g. `China`, `Vietnam`) | `data` | upcoming economic events | [detail](./endpoints/economy.md) |

## Crypto

| # | Path | Params | Res key | Detail |
|---|------|--------|---------|--------|
| 1 | `GET /market/crypto/trending` | — | `data` | [detail](./endpoints/crypto-trending.md) |

## Banking

| # | Path | Params | Res key | Detail |
|---|------|--------|---------|--------|
| 1 | `GET /market/banking/deposit-rates` | — | `data` | [detail](./endpoints/banking-deposit-rates.md) |

## Currencies

| # | Path | Params | Res key | Note | Detail |
|---|------|--------|---------|------|--------|
| 1 | `GET /market/currencies/:pair/history` | `:pair`* (`USD`\|`CNY`\|`EUR`\|`JPY`), `period` (`1M`\|`1Y`\|`YTD`, default `1M`), `value_type` | `data` | VND exchange rate history, grouped by bank | [detail](./endpoints/currencies.md) |
| 2 | `GET /market/currencies/cross/:pair/history` | `:pair`* (`eurusd`\|`usdjpy`\|`gbpusd`), `limit` (default 30) | `data` | cross-rate daily price series | [detail](./endpoints/currencies-cross.md) |

## Indices

| # | Path | Params | Res key | Note | Detail |
|---|------|--------|---------|------|--------|
| 1 | `GET /market/global-indices/:code/history` | `:code`* (`sp500`, `nasdaq`, `dow-jones`, `russell2000`, `vix`, `dxy`, `kospi`, `hangseng`, `shanghai`, `nikkei`), `limit` (default 50) | `data` | historical prices descending | [detail](./endpoints/indices.md) |

## Tickers — Fundamentals

| # | Path | Params | Res key | Note | Detail |
|---|------|--------|---------|------|--------|
| 1 | `GET /market/tickers/:ticker/ratios` | `:ticker`* (path), `period`* (`annual`\|`quarterly`) | `data` | financial ratio history | [detail](./endpoints/tickers-ratios.md) |
| 3 | `GET /market/tickers/:ticker/statements` | `:ticker`* (path), `statement`* (`income-statement`\|`balance-sheet`\|`cash-flow`), `period`* (`annual`\|`quarterly`), `limit` (default 5) | `data` | financial statements | [detail](./endpoints/tickers-statements.md) |
| 4 | `GET /market/tickers/:ticker/candles` | `:ticker`* (path), `resolution` (`1D`\|`1H`\|`4H`\|`30`\|`15`\|`5`), `from`*, `to`* (seconds) | `data` | OHLCV candle data | [detail](./endpoints/tickers-candles.md) |

## Funds

| # | Path | Params | Res key | Detail |
|---|------|--------|---------|--------|
| 1 | `/fund-trading/public/fund-certificates` | `fund-type`* (`STOCK_FUND`\|`BOND_FUND`\|`BALANCE_FUND`), `fund-company-id` | `data` | [detail](./endpoints/funds.md) |
| 2 | `/fund-trading/public/fund-companies` | — | `data` | [detail](./endpoints/fund-companies.md) |
| 3 | `/fund-trading/public/fund-certificates/benchmark/growth` | `fund-names`*, `amount`* (VND), `period`* | `data` | [detail](./endpoints/fund-benchmark.md) |
| 4 | `/fund-trading/public/fund-certificates/benchmark/nav` | `fund-names`*, `period` OR (`from-month`+`to-month`, `yyyy-MM`) | `data` | [detail](./endpoints/fund-benchmark.md) |
| 5 | `/fund-trading/public/fund-certificates/:fund/nav-histories` | `:fund`* (path), `period` (default `ALL_TIME`) | `data` | [detail](./endpoints/fund-nav-history.md) |
| 6 | `/fund-trading/public/fund-certificates/:fund/suggestions` | `:fund`* (path) | `data` | [detail](./endpoints/fund-details.md) |

---

## Choosing the Right Endpoint

### Tickers

| Need | Endpoint |
|------|----------|
| Single stock real-time quote (VN) | `GET /market/tickers/:ticker` |
| Multiple stocks or whole exchange (VN) | `GET /market/tickers?symbols=HPG,VNM` or `?exchange=HOSE` |
| Daily price history for Mag7 global stocks | `GET /market/tickers/global/apple/history?limit=30` |

| Financial ratio history (PE, PB, ROE…) | `GET /market/tickers/:ticker/ratios` |
| Income statement / balance sheet / cash flow | `GET /market/tickers/:ticker/statements?statement=income-statement&period=annual` |
| OHLCV candle data | `GET /market/tickers/:ticker/candles` |

### Commodities

| Need | Endpoint |
|------|----------|
| VN gold/silver spot prices | `GET /market/commodities/vn/metals?type=gold` |
| VN metals by provider (PNJ, DOJI…) | `GET /market/commodities/vn/metals/providers?type=gold` |
| VN metals price history (N days) | `GET /market/commodities/vn/metals/history?type=gold&days=30` |
| Global gold/silver/copper spot | `GET /market/commodities/global/metals?type=gold` |
| Global metals history | `GET /market/commodities/global/metals/history?type=gold` |
| Crude/Brent oil or natural gas spot | `GET /market/commodities/global/energy` |
| Energy history | `GET /market/commodities/global/energy/history?type=crude-oil` |

### Economy / Macro

| Need | Endpoint |
|------|----------|
| Current macro indicator (CPI, PMI…) | `GET /market/economy/snapshot?type=CPI&country=VN&period=...` |
| Historical economic indicators by country (GDP, inflation…) | `GET /market/economy/indicators?country=Vietnam&category=GDP` |
| Upcoming economic events (Fed meetings, CPI releases…) | `GET /market/economy/calendar?weeks=2&country=United States` |
| 10Y government bond yield | `GET /market/economy/snapshot?type=GOVERNMENT_10Y_BOND_YIELD&country=US` |

### Currencies / Forex

| Need | Endpoint |
|------|----------|
| Exchange rate history vs VND (by bank) | `GET /market/currencies/USD/history?period=1M` |
| Cross-rate history (EUR/USD, USD/JPY…) | `GET /market/currencies/cross/eurusd/history?limit=30` |

### Global Indices

| Need | Endpoint |
|------|----------|
| Historical prices for one index | `GET /market/indices/sp500/history?limit=50` |

### News

| Need | Endpoint |
|------|----------|
| Global financial news | `GET /market/global-news?category=forex` |
| Full article content | `GET /market/global-news/:id` |
| VN corporate actions (dividends, AGM, rights…) | `GET /market/tickers/VNM/corporate-actions` |

### Other

| Need | Endpoint |
|------|----------|
| Top trending crypto | `GET /market/crypto/trending` |
| Bank deposit interest rates | `GET /market/banking/deposit-rates` |

