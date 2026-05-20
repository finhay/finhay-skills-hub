# Market API Refactor Plan

Plan refactor toàn bộ 30+ endpoints của skill `finhay-market` (backend: `vnsc-datafeed-service`) theo chuẩn RESTful.

## Mục tiêu

1. Loại bỏ junk-drawer prefix `/financial-data/` (16 endpoints, 7-8 domain trộn lẫn)
2. Thống nhất naming inconsistent (`candles` cho OHLCV stocks, `history` cho daily price; `statements` vs `reports`)
3. Resource-oriented URLs theo REST (noun, plural, hierarchical)
4. Response envelope nhất quán (`data` key, không lẫn `result`)
5. Bỏ polymorphic endpoint (1 endpoint với multiple shapes tùy param)
6. Giải quyết data overlap (GLOBAL_GOLD nằm ở cả `financial_data` lẫn `market_data`)
7. Ticker-centric cho per-asset data (stocks)

## Ràng buộc

- **Backward compat:** giữ endpoint cũ chạy song song, deprecation header
- **Không đổi DB schema:** chỉ refactor code layer
- **Không downtime:** deploy dần qua các phase

## RESTful design principles áp dụng

1. **Resource-oriented:** path là noun (`/market/stocks`), không phải verb (`/market/get-stocks`)
2. **Plural collection:** `/stocks`, `/funds`, `/tickers` thay vì `/stock`, `/fund`, `/ticker`
3. **Hierarchical:** `/tickers/:ticker/candles` thay vì `/chart?ticker=`
4. **Query params chỉ để filter/paginate/sort,** không select resource
5. **HTTP status semantic:** 200/400/401/404/429, không "200 + error_code in body"
6. **No verbs in path:** `/recommendation-reports/:symbol` → `/tickers/:symbol/analysis`
7. **No versioning prefix:** giữ path gọn `/market/...`. Versioning xử lý qua header `Accept-Version` hoặc deprecation header khi cần breaking change sau này — không scatter `/v2/` rải rác như hiện tại (`/market/v2/financial-statement/`).
8. **Response envelope:** luôn `{ data: ... }` (object hoặc array tùy ngữ cảnh)
9. **ISO 8601 datetime:** không lẫn `"2025-05-15 14:30:00"` và `"2025-05-15T14:30:00+07:00"`
10. **Monetary value bọc object:** `{ value, currency, unit }` thay vì plain number

## Path tree mới (implemented)

> **Gateway prefix:** API gateway tự động thêm `/market/` prefix. Datafeed router đăng ký path **không có** `/market/` — ví dụ router `"/stocks/:symbol"` được expose ra ngoài thành `/market/stocks/:symbol`.

```
# === Tickers (stocks + per-asset detail) ===
/market/tickers                             GET ?symbols=A,B,C        # multi (always array)
/market/tickers?exchange=HOSE               GET                       # by exchange
/market/tickers/global/:ticker/history      GET ?limit=N              # Mag7: apple|microsoft|alphabet|amazon|meta|nvidia|tesla
/market/tickers/:ticker                     GET                       # single real-time (always object)
/market/tickers/:ticker/ratios              GET ?period=annual|quarterly (required)  # financial ratio history
/market/tickers/:ticker/statements          GET ?statement=income-statement|balance-sheet|cash-flow&period=annual|quarterly (required)&limit=N
/market/tickers/:ticker/candles             GET ?resolution=1D|5|15|30|1H|4H&from=...&to=... (UNIX seconds)

# === Funds (giữ nguyên path hiện tại, không refactor) ===
/fund-trading/public/fund-certificates      GET ?fund-type=...&fund-company-id=...
/fund-trading/public/fund-companies         GET
/fund-trading/public/fund-certificates/top-{aum|investor|fund-flow}  GET ?fund-type=...
/fund-trading/public/fund-certificates/top-holding-symbols            GET
/fund-trading/public/fund-certificates/benchmark/growth               GET ?fund-names=...&amount=...&period=...
/fund-trading/public/fund-certificates/benchmark/{nav|operation}      GET ?fund-names=...&period=...
/fund-trading/public/fund-certificates/:fund/portfolio                 GET
/fund-trading/public/fund-certificates/:fund/nav-histories             GET ?period=...
/fund-trading/public/fund-certificates/:fund/{asset-allocation|sector-allocation|suggestions}  GET

# === Commodities ===
/market/commodities/vn/metals               GET ?type=gold|silver (required)
/market/commodities/vn/metals/history       GET ?type=gold|silver (required)&days=N
/market/commodities/vn/metals/providers     GET ?type=gold|silver (required)
/market/commodities/global/metals           GET ?type=gold|silver|copper (required)
/market/commodities/global/metals/history   GET ?type=gold|silver|copper (required)&limit=N
/market/commodities/global/energy           GET ?type=crude-oil|brent-oil|natural-gas|all
/market/commodities/global/energy/history   GET ?type=crude-oil|brent-oil|natural-gas (required)&limit=N

# === Currencies & FX ===
# VND exchange rates (vs VND, grouped by bank) — valid pairs: USD, CNY, EUR, JPY
/market/currencies/:pair/history            GET ?period=1M|1Y|YTD

# Cross-rate pairs — valid pairs: eurusd, usdjpy, gbpusd
/market/currencies/cross/:pair/history      GET ?limit=N

# === Indices ===
# No snapshot list — valid codes: sp500, nasdaq, dow-jones, russell2000, vix, dxy, kospi, hangseng, shanghai, nikkei
/market/global-indices/:code/history               GET ?limit=N

# === Crypto ===
/market/crypto/trending                     GET

# === Banking ===
/market/banking/deposit-rates               GET

# === Economy / Macro ===
/market/economy/snapshot                    GET ?type=...&country=...&period=...
/market/economy/indicators                  GET ?country=...&category=...&year=...
/market/economy/calendar                    GET ?weeks=N&country=...

# === News ===
/market/global-news                         GET ?category=...&page=N&page_size=N   # global financial news only
/market/global-news/:id                     GET     # full article content
/market/tickers/:ticker/corporate-actions    GET ?from_date=DD/MM/YYYY&to_date=DD/MM/YYYY  # VN sự kiện quyền theo mã

# Removed: /market/bonds/yields — use /market/economy/snapshot?type=GOVERNMENT_10Y_BOND_YIELD&country=US|EU|JP|...
# Removed: /market/currencies (list) — no value, valid pairs documented above
# Removed: /market/indices (list snapshot) — no value, valid codes documented above
# Removed: /market/tickers/:ticker/financials/meta — static enum values, documented in spec
```

## Mapping endpoint cũ → mới (full)

### Stocks

| Cũ | Mới | Note |
|----|-----|------|
| `/market/stock-realtime?symbol=X` | `/market/tickers/:ticker` | Single, object response |
| `/market/stock-realtime?symbols=A,B` | `/market/tickers?symbols=A,B` | Multi, array response |
| `/market/stock-realtime?exchange=HOSE` | `/market/tickers?exchange=HOSE` | Array response |
| `/market/price-histories-chart` | `/market/tickers/:ticker/candles` | Path-based, OHLCV, `from`/`to` UNIX seconds (document rõ) |

### Company financial → Tickers

| Cũ | Mới | Note |
|----|-----|------|
| `/market/company-financial/overview?symbol=X` | REMOVED | Bỏ — data đã có trong `/market/tickers/:ticker/ratios` |
| `/market/company-financial/analysis?symbol=X&period=...` | `/market/tickers/:ticker/ratios?period=...` | Chỉ trả chỉ số tài chính, bỏ analyst reports; `period` bắt buộc |
| `/market/v2/financial-statement/statement?symbol=X&type=...&period=...` | `/market/tickers/:ticker/statements?statement=...&period=...` | `type` → `statement`; cả `statement` và `period` đều bắt buộc |
| `/market/recommendation-reports/:symbol` | REMOVED | Bỏ hẳn — analyst reports không trả về nữa |

### Commodities & Metals

| Cũ | Mới | Note |
|----|-----|------|
| `/market/financial-data` | XÓA | "Everything" anti-pattern |
| `/market/financial-data/gold` | `/market/commodities/vn/metals?type=gold` + `/market/commodities/global/metals?type=gold` | Tách VN vs Global |
| `/market/financial-data/silver` | tương tự | |
| `/market/financial-data/gold-chart` | `/market/commodities/vn/metals/history?type=gold` | |
| `/market/financial-data/silver-chart` | `/market/commodities/vn/metals/history?type=silver` | |
| `/market/financial-data/gold-providers` | `/market/commodities/vn/metals/providers?type=gold` | |
| `/market/financial-data/metal-providers` | `/market/commodities/vn/metals/providers` (default all) | |
| `/market/financial-data/oil` | `/market/commodities/global/energy?type=crude-oil` | |
| `/market/financial-data/market?type=GOLD\|SILVER` | `/market/commodities/global/metals/history?type=...` | Tách metals khỏi MarketDataType enum |
| `/market/financial-data/market?type=SP500\|NASDAQ\|...` | `/market/global-indices/:code/history` hoặc `/market/indices?region=...` | |
| `/market/financial-data/market?type=APPLE\|TESLA\|...` | `/market/tickers/:symbol/candles` | Mag7 = tickers, có OHLCV |
| `/market/financial-data/market?type=CRUDE_OIL\|BRENT_OIL\|NATURAL_GAS` | `/market/commodities/global/energy/history?type=...` | |
| `/market/financial-data/market?type=EURUSD\|USDJPY\|GBPUSD` | `/market/currencies/cross/:pair/history` | Endpoint riêng cho cross-rate pairs, trả `points[]` đơn giản |
| `/market/financial-data/exchange-rate-chart` | `/market/currencies/:pair/history` | Dùng chung |
| `/market/financial-data/exchange-rate/currencies` | `/market/currencies` | List currencies |

### Crypto, Banking, Economy

| Cũ | Mới | Note |
|----|-----|------|
| `/market/financial-data/cryptos/top-trending` | `/market/crypto/trending` | |
| `/market/financial-data/bank-interest-rates` | `/market/banking/deposit-rates` | |
| `/market/financial-data/macro` | `/market/economy/snapshot` | |
| `/market/financial-data/trading-economics` | `/market/economy/indicators` | Bỏ vendor name khỏi path |
| `/market/financial-data/economic-calendar-events` | `/market/economy/calendar` | |

### News

| Cũ | Mới | Note |
|----|-----|------|
| `/market/news` (VN, by stock) | `/market/tickers/:ticker/corporate-actions` | Ticker vào path; đổi tên đúng nghĩa — sự kiện quyền, không phải news |
| `/market/financial-data/global-news` | `/market/global-news?category=...` | Tách riêng global news |
| `/market/financial-data/global-news/:id` | `/market/global-news/:id` | |

### Misc

| Cũ | Mới | Note |
|----|-----|------|
| `/global-stock-markets?area=...&type=...` | `/market/global-indices/:code/history` | List snapshot bỏ, dùng history theo code |
| `/financial-data/10-year-bond-yields` | `/market/economy/snapshot?type=GOVERNMENT_10Y_BOND_YIELD&country=...` | Không tạo endpoint riêng cho bond yields |
| `/market/currencies` (list) | REMOVED | Không cần thiết, valid pairs documented trong spec |

## Response schema chuẩn

### Quy tắc chung

- Envelope: luôn `{ data: ... }` cho success, `{ error: { code, message } }` cho fail
- HTTP status code semantic (200/400/401/404/429), không "200 + status=error"
- Monetary: `{ value: number, currency: "VND"|"USD"|..., unit: "tael"|"ounce"|... }`
- Datetime: ISO 8601 với timezone — `"2025-05-15T14:30:00+07:00"`
- Date-only: `"2025-05-15"`
- Pagination: `{ data: [...], meta: { page, page_size, total_pages, total } }`
- Không trả field rỗng (null/0) khi không có data thật — omit field

### Examples

#### `GET /market/stocks/:symbol`

```json
{
  "data": {
    "symbol": "VNM",
    "exchange": "HOSE",
    "price": { "value": 65000, "currency": "VND" },
    "change": { "absolute": 500, "percent": 0.78 },
    "volume": 1500000,
    "high": 65500,
    "low": 64000,
    "open": 64500,
    "reference": 64500,
    "updated_at": "2025-05-15T14:30:00+07:00"
  }
}
```

#### `GET /market/stocks?symbols=VNM,FPT`

```json
{
  "data": [
    { "symbol": "VNM", ... },
    { "symbol": "FPT", ... }
  ]
}
```

#### `GET /market/tickers/VNM/overview`

```json
{
  "data": {
    "symbol": "VNM",
    "pe": 15.2,
    "pb": 3.1,
    "roe": 22.5,
    "eps": 4200,
    "market_cap": { "value": 138000000000000, "currency": "VND" },
    "updated_at": "2025-05-15T14:30:00+07:00"
  }
}
```

#### `GET /market/tickers/VNM/financials?statement=income&period=annual&limit=5`

```json
{
  "data": {
    "symbol": "VNM",
    "statement": "income",
    "period": "annual",
    "currency": "VND",
    "items": [
      { "period_label": "2024", "revenue": 60000000000000, "gross_profit": ..., ... },
      ...
    ]
  }
}
```

#### `GET /market/tickers/VNM/candles?resolution=1D&from=...&to=...`

```json
{
  "data": {
    "symbol": "VNM",
    "resolution": "1D",
    "currency": "VND",
    "points": [
      { "date": "2025-05-14", "open": 64500, "high": 65000, "low": 64000, "close": 64800, "volume": 1200000 },
      ...
    ]
  }
}
```

#### `GET /market/commodities/vn/metals?type=gold`

```json
{
  "data": [
    {
      "provider": "SJC",
      "product": "GOLD_BAR",
      "name": "Vàng miếng SJC",
      "buy_price":  { "value": 85000000, "currency": "VND", "unit": "tael" },
      "sell_price": { "value": 86000000, "currency": "VND", "unit": "tael" },
      "change_percent": { "buy": 0.3, "sell": 0.4 },
      "date": "2025-05-15",
      "updated_at": "2025-05-15T14:30:00+07:00"
    }
  ]
}
```

#### `GET /market/commodities/global/metals?type=gold`

```json
{
  "data": {
    "type": "GOLD",
    "price": { "value": 3210.50, "currency": "USD", "unit": "ounce" },
    "change_percent": 0.5,
    "date": "2025-05-15",
    "updated_at": "2025-05-15T07:30:00Z"
  }
}
```

#### `GET /market/commodities/vn/metals/history?type=gold&days=30`

```json
{
  "data": {
    "type": "GOLD",
    "unit": "tael",
    "currency": "VND",
    "series": [
      {
        "provider": "SJC",
        "product": "GOLD_BAR",
        "points": [
          { "date": "2025-05-14", "value": 85000000 },
          { "date": "2025-05-15", "value": 86000000 }
        ]
      }
    ]
  }
}
```

#### `GET /market/funds?type=stock`

```json
{
  "data": [
    {
      "code": "DCDS",
      "name": "Quỹ Đầu tư Cổ phiếu Dragon Capital",
      "type": "STOCK_FUND",
      "company": { "id": "DCVFM", "name": "Dragon Capital VFM" },
      "nav": { "value": 25000, "currency": "VND", "unit": "share" },
      "aum": { "value": 2500000000000, "currency": "VND" },
      "updated_at": "2025-05-15T14:30:00+07:00"
    }
  ],
  "meta": { "total": 45 }
}
```

#### `GET /market/news?scope=vn&stocks=VNM&page=1`

```json
{
  "data": [
    {
      "id": "abc123",
      "title": "...",
      "summary": "...",
      "source": "CafeF",
      "published_at": "2025-05-15T10:00:00+07:00",
      "url": "https://...",
      "related_stocks": ["VNM"]
    }
  ],
  "meta": { "page": 1, "page_size": 20, "total_pages": 5, "total": 100 }
}
```

#### `GET /market/economy/snapshot?type=cpi&country=VN`

```json
{
  "data": {
    "type": "CPI",
    "country": "VN",
    "value": 3.5,
    "unit": "percent",
    "period": "2025-04",
    "updated_at": "2025-05-15T00:00:00Z"
  }
}
```

#### `GET /market/economy/calendar?weeks=1`

```json
{
  "data": [
    {
      "event": "Fed Interest Rate Decision",
      "country": "US",
      "scheduled_at": "2025-05-20T18:00:00Z",
      "importance": "high",
      "actual": null,
      "forecast": "5.25%",
      "previous": "5.25%"
    }
  ]
}
```

## Phases

### Phase 0 — Skill docs cleanup (current state)

**Mục tiêu:** docs hiện tại phải đúng trước khi refactor backend.

- [x] Fix duplicate numbering trong `endpoints.md` (đã done, reset trong từng group)
- [ ] Thêm warning về overlap `GLOBAL_GOLD` ở endpoint cũ
- [ ] Document `/financial-data/oil` (orphan endpoint hiện tại)
- [ ] Thống nhất response key trong docs (đang note `result` vs `data`)

**Deliverable:** 1 PR docs trong `finhay-skills-hub`.

### Phase 1 — Backend code cleanup (zero-risk, internal only)

**Mục tiêu:** giảm code duplication, fix inconsistency. KHÔNG đổi API path/response.

- Gộp `getGoldChartData` + `getSilverChartData` → 1 hàm private
- Fix `parseInt` vs `+`, thêm fallback `|| 0` cho silver
- Move display name rename (DOJI 9999) từ controller xuống serializer/helper, áp dụng cho mọi endpoint
- Đặt lại cache keys consistent
- Add response envelope test để verify backward compat

**Deliverable:** 1 PR backend, refactor thuần.

### Phase 2 — Backend: thêm `/market/*` endpoints song song (additive) ✅ DONE

**Mục tiêu:** có API mới sạch, endpoint cũ vẫn chạy.

Sub-phases (mỗi nhóm 1 PR):

- **2a — Commodities** ✅ `/market/commodities/*` (metals VN+Global, energy)
- **2b — Tickers** ✅ `/market/tickers/:ticker/*` (overview, analysis, financials, candles)
- **2c — Stocks** ✅ `/market/stocks/*` (tách polymorphic stock-realtime thành 2 endpoint: single + collection)
- **2d — News** ✅ `/market/news/*` (gộp VN + global, paginate chuẩn)
- **2e — Economy** ✅ `/market/economy/*` (snapshot, indicators, calendar)
- **2f — Misc** ✅ crypto/trending, banking/deposit-rates, currencies history, indices history

Quyết định trong quá trình implement:
- Bỏ `/market/bonds/yields` → dùng `economy/snapshot?type=GOVERNMENT_10Y_BOND_YIELD` thay thế
- Bỏ `/market/currencies` (list) và `/market/indices` (snapshot) — discovery không cần thiết, valid values documented trong spec
- Bỏ `/market/tickers/:ticker/financials/meta` — static enums, không cần roundtrip
- Gộp stocks + tickers routes → `SecuritiesRouter.ts` (cùng domain ticker, không có lý do tách)
- Chuẩn hóa toàn bộ path về `/tickers/*` — bỏ `/stocks/*` (stocks và tickers cùng là một entity)
- `/tickers/:ticker/analysis` → `/tickers/:ticker/ratios`, bỏ analyst reports — chỉ trả chỉ số tài chính; `period` bắt buộc
- `/tickers/:ticker/financials` → `/tickers/:ticker/statements`; `statement` và `period` đều bắt buộc
- Bỏ `/tickers/:ticker/overview` — data trùng với `/tickers/:ticker/ratios`
- `/market/news` tách thành `/market/global-news` (global only) + `/market/corporate-actions` (VN sự kiện quyền)
- Validators dùng `express-validator` cho mọi endpoint (path params dùng `param()`, query dùng `query()`)
- VN metals `type` bắt buộc (gold|silver), bỏ `all` — omit không được, phải chọn rõ
- Global metals thêm `copper` (từ `MarketDataType.COPPER`), `type` bắt buộc, unit copper = `pound`
- Thêm `GET /market/stocks/global/:symbol/history` cho Mag7 (daily close từ `market_data` table)
- Thêm `GET /market/currencies/cross/:pair/history` cho cross-rate pairs (EURUSD/USDJPY/GBPUSD) — endpoint riêng vì response shape khác hẳn VND rates
- Đặt tên controller functions mô tả rõ domain: `getVndExchangeRateHistory` (vs VND, by bank), `getCurrencyPairHistory` (cross-rates)

Mỗi endpoint cũ:
- Thêm response header `Deprecation: true`
- Thêm header `Link: <new-url>; rel="successor-version"`
- Giữ shape cũ, không đổi

### Phase 3 — Skill docs cho API mới ✅ DONE

**Mục tiêu:** docs phản ánh API mới, hướng dẫn migration.

- [x] Update `endpoints.md`: group mới, legacy group marked
- [x] Tạo file detail cho mỗi endpoint mới trong `references/endpoints/` (15 files)
- [x] Update `SKILL.md` với endpoint mới
- [x] Bỏ duplicate "Choosing the right endpoint" guide cũ, viết lại theo group mới
- [ ] Thêm `MIGRATION.md` mô tả mapping cũ → mới cho client (optional)

### Phase 4 — Client migration & monitoring

**Mục tiêu:** đo lượng dùng endpoint cũ vs mới.

- Add metric `api_endpoint_usage_total{endpoint, deprecated}`
- Dashboard: tỉ lệ traffic cũ/mới theo thời gian
- Ping team frontend/mobile/skill consumers thông báo migrate
- Đặt deadline 8-12 tuần để complete migration

**Deliverable:** Grafana dashboard + notification list.

### Phase 5 — Cleanup (sau Phase 4 done)

**Mục tiêu:** xóa hẳn endpoint cũ + code không còn dùng.

- Verify metric: endpoint cũ traffic = 0 trong 2 tuần
- Xóa router + controller + repo method cũ
- Xóa entry deprecated trong docs
- Final cleanup migration docs

**Deliverable:** 1 PR backend cleanup + 1 PR docs cleanup.

## Open questions

1. **Versioning strategy:** đã chốt không dùng `/v1/` prefix. Dùng deprecation header (`Deprecation: true`, `Link: <new-url>; rel="successor-version"`) cho endpoint cũ. Nếu sau này cần breaking change v2, cân nhắc `Accept-Version` header hoặc tạo prefix mới chỉ khi thật sự cần.
2. **Field `currency` cho VN gold:** unit chuẩn là "tael" (lượng) hay "luong"? Cần i18n key chuẩn.
3. **Pagination:** dùng `page`/`page_size` (offset) hay `cursor`? News có khả năng cần cursor cho real-time.
4. **`updated_at` timezone:** trả UTC (Z) hay local time (+07:00)? Hiện trộn lẫn.
5. **Provider icon resolution:** client tự resolve từ `provider` key, hay backend trả URL? Có cần endpoint `/market/providers/metadata`?
6. **GLOBAL_GOLD source of truth:** sau Phase 2a, có nên dừng crawler ghi GLOBAL_GOLD vào `financial_data` để chỉ còn `market_data` là source duy nhất?
7. **Polymorphic `stock-realtime`:** đã tách thành single + multi. Có nên xóa hẳn version polymorphic cũ ở Phase 5 không?
8. **Funds path:** đã chốt giữ nguyên path cũ `/fund-trading/public/fund-certificates/*`. Không refactor trong đợt này.
9. **HTTP status hiện tại:** backend đang trả `200 + ApiResponseV1.error(...)`. Có chuyển sang HTTP status semantic (400/401/...) ở Phase 2 không?
10. **Caching strategy:** sau khi thay path mới, có cần warm cache trước khi cutover không?

## Tổng kết số lượng endpoint

| | Hiện tại | Sau refactor | Ghi chú |
|---|---|---|---|
| Tickers (stocks + per-asset detail) | 1 polymorphic + ~6 scattered | 7 hierarchical | Gộp stocks + tickers về `/tickers/*`; `analysis` → `ratios`; Thêm Mag7 history |
| Funds | 9 (giữ nguyên) | 9 (không đổi) | |
| Commodities | 6 metals + market enum | 7 structured (vn/global × type) | VN metals type required (no all); global metals thêm copper |
| News | 2 (VN + global tách) | 3 (`/global-news`, `/global-news/:id`, `/corporate-actions`) | Tách rõ global news vs VN corporate actions |
| Economy | 3 | 3 | Bonds/yields gộp vào snapshot |
| Currencies | 2 (list + history) | 2 (VND history + cross-rate history) | List bỏ; thêm cross-rate endpoint riêng |
| Indices | 2 (snapshot + history) | 1 (history only) | Snapshot bỏ |
| Crypto | 1 | 1 | |
| Banking | 1 | 1 | |
| **Total** | **~30+** | **~31** | Legacy endpoints vẫn active |

Số endpoint xấp xỉ nhau, nhưng:
- Resource hierarchical rõ ràng
- Tên consistent
- Response shape predictable
- Không còn junk-drawer

## Estimate

| Phase | Effort | Risk | Status |
|---|---|---|---|
| 0 — Docs cleanup hiện tại | 0.5 day | Low | ✅ Done |
| 1 — Backend code cleanup | 1 day | Low | — |
| 2a — Commodities | 3 days | Medium | ✅ Done |
| 2b — Tickers | 3 days | Medium | ✅ Done |
| 2c — Stocks | 1 day | Low | ✅ Done |
| 2d — News | 1 day | Low | ✅ Done |
| 2e — Economy | 2 days | Low | ✅ Done |
| 2f — Misc | 1 day | Low | ✅ Done |
| 3 — Skill docs | 2 days | Low | ✅ Done |
| 4 — Monitoring (parallel) | 1 day setup | Low | — |
| 5 — Cleanup (sau 8-12 tuần) | 1 day | Low | — |

**Total active dev:** ~15 days (~3 weeks 1 dev) cho Phase 0-3.
**Total timeline:** 3-4 tháng tính cả deprecation window.

## References

### Source code (backend — `vnsc-datafeed-service`)

**Routers** (`src/datafeed/infrastructure/web/router/`):
- `CommoditiesRouter.ts` — commodities/vn/*, commodities/global/*
- `EconomyRouter.ts` — economy/snapshot, economy/indicators, economy/calendar
- `MarketNewsRouter.ts` — global-news, global-news/:id
- `TickersRouter.ts` — tickers, tickers/:ticker, tickers/global/:ticker/history, tickers/:ticker/*
- `MiscRouter.ts` — crypto/trending, banking/deposit-rates, currencies/:pair/history, indices/:code/history
- `route.ts` — entry point, mount tất cả routers

**Controllers** (`src/datafeed/infrastructure/web/controller/`):
- `TickersController.ts` — getTicker, getTickers, getGlobalTickerHistory, getTickerRatios, getTickerStatements, getTickerCandles, getTickerCorporateActions
- `TickersController.ts` — getTickerRatios, getTickerStatements, getTickerCandles, getTickerCorporateActions
- `CommoditiesController.ts` — getVnMetals, getVnMetalsHistory, getVnMetalsProviders, getGlobalMetals, getGlobalMetalsHistory, getGlobalEnergy, getGlobalEnergyHistory
- `EconomyController.ts` — getEconomySnapshot, getEconomyIndicators, getEconomyCalendar
- `MarketNewsController.ts` — getGlobalNews, getGlobalNewsDetail, getCorporateActions
- `MiscController.ts` — getCryptoTrending, getBankingDepositRates, getVndExchangeRateHistory, getCurrencyPairHistory, getIndexHistory

**Validators** (`src/datafeed/infrastructure/web/router/validators/`):
- `validateGetStocks.ts`, `validateGetGlobalStockHistory.ts`, `validateGetTickerRatios.ts`, `validateGetTickerStatements.ts`, `validateGetTickerCandles.ts`
- `validateGetMarketNews.ts`
- `validateGetEconomySnapshot.ts`, `validateGetEconomyIndicators.ts`, `validateGetEconomyCalendar.ts`
- `validateGetCurrencyHistory.ts`, `validateGetCurrencyPairHistory.ts`, `validateGetIndexHistory.ts`
- `validateGetCommoditiesVnMetals.ts`, `validateGetCommoditiesGlobalMetals.ts`, `validateGetCommoditiesGlobalEnergy.ts`

**Repositories**:
- `src/datafeed/infrastructure/repository/FinancialDataRepositoryImpl.ts`
- `src/datafeed/infrastructure/repository/MarketDataRepositoryImpl.ts`

**Domain models**:
- `src/datafeed/core/domain/model/{CommodityIndex,FinancialIndex,MarketData}.ts`

### Skill docs (`finhay-skills-hub`)

- Endpoints index: `skills/finhay-market/references/endpoints.md`
- Endpoint details: `skills/finhay-market/references/endpoints/*.md` (15 files)
- Skill spec: `skills/finhay-market/SKILL.md`
