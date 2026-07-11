---
name: finhay-stock-research
description: "Single-stock research brief for Vietnamese equities via Finhay Securities: quote + price history + company fundamentals (overview/analysis/statements) + recent news + third-party analyst reports, composed into a 6-section facts-grounded brief. Every number carries its reporting period/source; analyst recommendations are attributed as third-party opinions, never the assistant's own. Read-only, answers in Vietnamese. Use when the user asks to analyze/research/evaluate ONE specific stock (e.g. 'phân tích FPT', 'HPG có tốt không'). NOT for portfolio risk review (finhay-portfolio-review), NOT for portfolio-tied news digests (finhay-market-briefing), NOT for a bare price lookup (finhay-market), NOT for placing orders (finhay-trading)."
license: MIT
metadata:
  author: Finhay Securities
  version: "1.0.0"
  catalog-name: stock-research-brief
  risk-tier: "0"
---

# Finhay Stock Research (`stock-research-brief`)

Workflow skill cho user job trong catalog Finhay Agent Platform v2 (Confluence 99059118, nhóm P1):

> *"Research một mã cổ phiếu bằng quote, price history, financial overview/analysis/statement, reports và news."*

Điểm nhạy cảm nhất về compliance của workflow này: **báo cáo khuyến nghị của CTCK là DỮ KIỆN VỀ Ý KIẾN BÊN THỨ BA** — phải attribute rõ (tên CTCK, ngày, nội dung khuyến nghị) và tuyệt đối không biến thành khuyến nghị của trợ lý.

> **File này là SOURCE OF TRUTH của workflow.** Render cho Remote MCP (dòng router trong INSTRUCTIONS + prompt `stock-research-brief`, phục vụ cả `get_workflow_guide`) — xem [references/mcp-renders.md](references/mcp-renders.md). Từ workflow thứ 3, INSTRUCTIONS đã chuyển **Tier B**: chỉ chứa router, bản đầy đủ lấy qua `get_workflow_guide`.

## 1. Purpose

Bản research 1 mã: giá & xu hướng, nền tảng tài chính doanh nghiệp (kèm kỳ báo cáo từng con số), tin tức gần đây, khuyến nghị bên thứ ba (attribute đầy đủ), và điểm mạnh / điểm cần lưu ý dựa trên số liệu — để user tự ra quyết định. Không đưa giá mục tiêu riêng, không kết luận mua/bán.

## 2. Trigger

**Dùng khi** user muốn phân tích/đánh giá/research MỘT mã cụ thể: "phân tích FPT", "HPG có tốt không", "đánh giá cổ phiếu VNM giúp tôi", "research MWG".

**KHÔNG dùng khi:**
- Chỉ hỏi giá/khối lượng 1 mã → gọi tool trực tiếp (`get_stock_quote`) hoặc skill `finhay-market`.
- Rủi ro/sức khoẻ **danh mục** → `finhay-portfolio-review`.
- Tin tức theo **danh mục** ("hôm nay có gì ảnh hưởng danh mục tôi") → `finhay-market-briefing`.
- Muốn mua/bán mã đó → `finhay-trading` hoặc app Finhay (sau khi đọc brief, handoff).

## 3. Required user inputs

| Input | Bắt buộc | Ghi chú |
|---|---|---|
| `symbol` — mã cổ phiếu | ✅ | User chưa nêu mã → **HỎI** trước khi gọi bất kỳ tool nào. Không đoán mã từ tên công ty mơ hồ — xác nhận lại ("FPT Corp → mã FPT phải không?") |
| `period` — khung tham chiếu lịch sử giá | ❌ (mặc định ~6 tháng) | Ảnh hưởng `from/to` của price history |

Không cần tiểu khoản (dữ liệu public). **Cá nhân hoá tuỳ chọn:** nếu user đang nắm giữ mã này và token có `read:account` → có thể nêu vị thế hiện tại (KL, giá vốn, tỷ trọng) như một dòng ngữ cảnh; thiếu quyền thì bỏ qua, không hỏi xin quyền chỉ vì mục này.

## 4. Data access

### 4.A. Remote MCP (ưu tiên)

| # | Tool | OpenAPI path (vendored spec) | Scope | Params chính | Vai trò |
|---|---|---|---|---|---|
| 1 | `get_market_session` | `/trading/market/session` | `read:market` | — | Phiên + mốc thời gian |
| 2 | `get_stock_quote` | `/market/stock-realtime` | `read:market` | `symbol` | Giá, ±%, khối lượng hiện tại |
| 3 | `get_price_history` | `/market/price-histories-chart` | `read:market` | `symbol`, `resolution` (1D/1W/1M), `from`/`to` (Unix **giây**) | Xu hướng giá & thanh khoản trong `period` |
| 4 | `get_company_overview` | `/market/company-financial/overview` | `read:market` | `symbol` | Tổng quan tài chính doanh nghiệp |
| 5 | `get_financial_analysis` | `/market/company-financial/analysis` | `read:market` | `symbol`, `period` (opt) | Phân tích chỉ số theo kỳ |
| 6 | `get_financial_statement` | `/market/v2/financial-statement/statement` | `read:market` | `symbol`, `type` (req), `period`, `limit` | BCTC chi tiết khi cần đào sâu |
| 7 | `get_stock_news` | `/market/news` | `read:market` | `stock`, lọc ngày | Tin ~14 ngày gần nhất của mã |
| 8 | `get_recommendation_reports` | `/market/recommendation-reports/{symbol}` | `read:market` | `symbol` (path) | Báo cáo khuyến nghị CTCK — **ý kiến bên thứ ba** |
| 9* | `get_index_quote` | `/market/index-realtime` | `read:market` | `index` | Tương quan với VNINDEX/VN30 |
| 10* | `get_portfolio_positions` | `/trading/v2/sub-accounts/{subAccountId}/portfolio` | `read:account` | `account` | (Tuỳ chọn) vị thế hiện tại của user với mã này |

(*) tuỳ chọn. Thứ tự gọi tối ưu: 2+3 song song → 4+5 (6 khi cần) → 7+8 → 9/10 nếu liên quan.

### 4.B. Fallback CLI (OpenAPI HMAC)

`./finhay.sh request GET <path>` với path ở bảng trên. Schema chi tiết: references của `finhay-market` (stock-realtime, price-histories-chart, company-financial-overview, company-financial-analysis, financial-statement, news, recommendation-reports, index-realtime). Workflow/guardrails không đổi.

## 5. Required scopes & Risk tier

- `read:market` là đủ (toàn bộ dữ liệu public). `read:account` chỉ cho mục cá nhân hoá tuỳ chọn.
- Risk tier: **Tier 0** (public market data) — nhưng vì output là bản phân tích có nhận định, áp **chuẩn trình bày Tier 2**: tách facts/interpretation, kỳ báo cáo + nguồn cho mọi số, disclaimer. Khi nêu vị thế user (mục 10*) → phần đó là Tier 1/2.

## 6. Workflow

```
B0. Chốt mã: user chưa nêu → HỎI; tên công ty mơ hồ → xác nhận mã. Chốt period (mặc định ~6 tháng).
    Lấy mốc thời gian: get_market_session.
B1. get_stock_quote + get_price_history (resolution phù hợp period; from/to Unix GIÂY).
B2. get_company_overview + get_financial_analysis (+ get_financial_statement khi cần đào sâu
    một mảng: nợ, dòng tiền…). Ghi lại KỲ BÁO CÁO của từng con số.
B3. get_stock_news (~14 ngày) + get_recommendation_reports. Tuỳ chọn: get_index_quote
    (tương quan), get_portfolio_positions (vị thế user nếu đã có quyền).
B4. Soạn brief đúng khuôn 6 phần (mục 8) theo khung phân tích (mục 7);
    tự kiểm checklist trong references/output-template.md rồi mới gửi.
```

## 7. Khung phân tích (phần "trí tuệ" của skill)

1. **Mọi nhận xét gắn số liệu + kỳ:** "biên LN gộp Q1/2026 là 22,1% (financial_analysis)" — không nói "biên lợi nhuận tốt" suông. Số không có kỳ báo cáo = không dùng.
2. **Khuyến nghị CTCK = dữ kiện về ý kiến bên thứ ba:** trình bày dạng "CTCK X (ngày dd/mm): khuyến nghị Y, giá mục tiêu Z". KHÔNG tính trung bình giá mục tiêu thành "định giá hợp lý", KHÔNG dùng làm kết luận của mình, KHÔNG chọn lọc chỉ báo cáo thuận chiều.
3. **Xu hướng giá mô tả bằng dữ kiện:** "+18% trong 6 tháng, khối lượng bình quân tăng X%" — không dán nhãn "uptrend chắc chắn tiếp diễn".
4. **Điểm mạnh / điểm cần lưu ý:** mỗi bên 2–4 ý, cân bằng — bắt buộc có cả hai phía; mỗi ý một con số dẫn chứng. Không có dữ liệu cho phía nào → nói rõ thay vì bịa.
5. **So sánh ngành chỉ khi có số trong tay** (từ overview/analysis) — không so sánh từ trí nhớ.
6. Mã ít thanh khoản / mới niêm yết / dữ liệu mỏng → nêu như một *đặc điểm cần lưu ý* ngay đầu phần 5.

## 8. Output format — khuôn 6 phần (chi tiết + golden example: [references/output-template.md](references/output-template.md))

1. 🕐 Thời điểm & nguồn (+ kỳ BCTC mới nhất có được) → 2. 📊 Snapshot giá → 3. 🏢 Nền tảng doanh nghiệp (bảng số liệu + kỳ) → 4. 📰 Tin tức & khuyến nghị bên thứ ba (attribute đầy đủ) → 5. ⚖️ Điểm mạnh / Điểm cần lưu ý → 6. 📌 Giả định & thiếu dữ liệu + ➡️ bước tiếp theo + disclaimer.

## 9. Guardrails

**Kế thừa toàn bộ bộ luật lõi G1–G10 từ [`finhay-guardrails`](../finhay-guardrails/SKILL.md)** (meta-skill — bề mặt Legal review duy nhất; sửa luật chung tại đó). Luật **RIÊNG** của workflow này:

1. **Khuyến nghị CTCK = dữ kiện về Ý KIẾN BÊN THỨ BA:** kèm tên tổ chức + ngày phát hành; KHÔNG tính trung bình giá mục tiêu thành "định giá hợp lý"; KHÔNG chọn lọc một chiều; báo cáo cũ hơn ~3 tháng (ngưỡng giả định) phải nêu tuổi.
2. **Không đưa giá mục tiêu của riêng trợ lý** — phần "điểm mạnh/điểm cần lưu ý" dừng ở dẫn chứng số liệu, không quy đổi thành định giá (cụ thể hoá G3+G4 cho research).
3. **Mọi số liệu tài chính kèm KỲ BÁO CÁO** — số không rõ kỳ thì không dùng (nâng G1 lên mức bắt buộc từng con số).
4. **Không so sánh/xếp hạng với mã khác** nếu không có số liệu lấy được trong phiên làm việc — không so sánh từ trí nhớ.
5. "Vậy có nên mua không?" → deflect theo G4: câu hỏi tự đánh giá (khẩu vị rủi ro, tỷ trọng dự kiến, thời hạn) + nếu đang giữ mã: gợi ý `portfolio-review`; hành động → app Finhay.

## 10. Failure modes

| Tình huống | Hành vi bắt buộc |
|---|---|
| User chưa nêu mã / tên mơ hồ | HỎI + xác nhận mã trước khi gọi tool |
| Mã không tồn tại / tool trả rỗng | Báo không tìm thấy, gợi ý kiểm tra lại mã; không đoán mã thay thế |
| Không có báo cáo khuyến nghị nào | Nói thẳng "chưa có báo cáo CTCK nào trong dữ liệu" — không lấy ý kiến từ trí nhớ |
| BCTC kỳ mới chưa có | Dùng kỳ gần nhất + ghi rõ độ trễ |
| Mã ít thanh khoản/mới niêm yết | Nêu đặc điểm này ở đầu phần 5; dữ liệu mỏng → brief ngắn lại, không độn |
| Tool lỗi/timeout | Brief phần còn lại + ghi rõ mảng thiếu |
| User đòi mua/bán luôn | Guardrail #5 |

## 11. Success criteria

- [ ] Đúng khuôn 6 phần; mọi số có kỳ/thời điểm + nguồn; phần 4 attribute đầy đủ (tên CTCK + ngày).
- [ ] Phần 5 có CẢ điểm mạnh lẫn điểm cần lưu ý, mỗi ý một dẫn chứng số.
- [ ] Không có: giá mục tiêu tự đưa, dự báo hướng, kết luận mua/bán, so sánh không số liệu.
- [ ] Hỏi/xác nhận mã khi chưa rõ; nói thẳng khi thiếu dữ liệu.
- [ ] Kết bằng bước tiếp theo + disclaimer.

## 12. Renders & sync

Xem [references/mcp-renders.md](references/mcp-renders.md): **1 dòng router** trong INSTRUCTIONS (Tier B) + **prompt `stock-research-brief`** (arguments: `symbol` bắt buộc, `period` tuỳ chọn) — văn bản prompt đồng thời là nội dung `get_workflow_guide('stock-research-brief')` (serve từ `PromptService.generate`, không có bề mặt sync riêng).
