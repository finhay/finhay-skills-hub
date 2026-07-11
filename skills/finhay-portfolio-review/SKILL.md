---
name: finhay-portfolio-review
description: "Portfolio risk-review workflow for Finhay Securities: pull the user's real account + market data, surface the top 3 portfolio risks with numeric evidence, and present safe risk-reduction OPTIONS (never direct buy/sell advice). Read-only, compliance-guardrailed, answers in Vietnamese. Use when the user asks to review their portfolio, assess portfolio health/risk, or how to reduce risk. NOT for placing orders (use finhay-trading) and NOT for single-symbol quote lookups (use finhay-market)."
license: MIT
metadata:
  author: Finhay Securities
  version: "1.0.0"
  catalog-name: portfolio-review
  risk-tier: "2"
---

# Finhay Portfolio Review (`portfolio-review`)

Workflow skill cho câu hỏi North Star của Finhay Agent Platform v2:

> *"Review danh mục của tôi hôm nay, chỉ ra 3 rủi ro lớn nhất, và nếu muốn giảm rủi ro thì tôi nên cân nhắc những hướng nào?"*

Đây là **workflow / intelligence layer** (không phải endpoint catalog): skill này quy định trình tự lấy dữ liệu, khung đánh giá rủi ro, khuôn output và guardrails compliance. Nguồn thiết kế: Confluence PD — memo 99059113, skill catalog 99059118, guardrails 99059227, north-star demo 99059228.

> **File này là SOURCE OF TRUTH của workflow.** Hai bản render cho Remote MCP (`instructions` + prompt `portfolio-review` trong `vnsc-mcp-server`) được sinh từ đây — xem [references/mcp-renders.md](references/mcp-renders.md). Sửa workflow ở đây trước, render sang code sau.

## 1. Purpose

Trả lời trọn vẹn user job "phân tích sức khoẻ danh mục của tôi hôm nay": snapshot danh mục bằng dữ liệu thật, top 3 rủi ro có bằng chứng số liệu + mức độ, giải thích dễ hiểu, và các **hướng** giảm rủi ro dạng lựa chọn kèm trade-off. Tuyệt đối không thực thi giao dịch; hành động cuối handoff về app Finhay.

## 2. Trigger

**Dùng skill này khi** user hỏi về: sức khoẻ / tổng quan danh mục; rủi ro danh mục ("danh mục tôi có rủi ro gì", "có đang quá tập trung không", "có nên lo không"); cách giảm rủi ro; review định kỳ danh mục.

**KHÔNG dùng khi:**
- Hỏi giá / tin của 1 mã đơn lẻ → gọi tool trực tiếp hoặc skill `finhay-market`.
- Hỏi "hôm nay có gì ảnh hưởng danh mục tôi" / tin tức theo danh mục → skill `finhay-market-briefing` (bản tin event-driven; skill này là đánh giá cấu trúc rủi ro).
- Phân tích/đánh giá sâu MỘT mã cụ thể ("phân tích FPT") → skill `finhay-stock-research`.
- Muốn đặt / sửa / huỷ lệnh → skill `finhay-trading` (nếu được cấp quyền) hoặc app Finhay. Skill này **chỉ đọc**.
- Hỏi số dư / lịch sử lệnh thuần tuý (không cần phân tích) → skill `finhay-portfolio`.

## 3. Required user inputs

Không có input bắt buộc. Quy ước xác định **tiểu khoản**:

- Qua **Remote MCP**: các tool account-scoped nhận input `account` ∈ `normal | margin | openapi` (SELECT-mode — chỉ chọn LOẠI tài khoản, server tự map sang id trong token, không bao giờ thấy/hỏi id thô).
- User chưa nói rõ tiểu khoản → **HỎI một lần** ("Bạn muốn review tiểu khoản nào: thường, ký quỹ, hay tài khoản OpenAPI? Mặc định mình xem tài khoản thường nhé"), rồi dùng **cùng một giá trị `account`** cho mọi call trong lần review đó. Ghi rõ tiểu khoản đã chọn vào output mục 6.
- Tuỳ chọn: khẩu vị rủi ro nếu user chủ động cung cấp. Không có → dùng **giả định thận trọng** và nói rõ (xem Guardrails).

## 4. Data access

### 4.A. Remote MCP (ưu tiên — khi đã kết nối Finhay MCP)

| # | Tool | OpenAPI path (vendored spec) | Scope | Input `account`? | Vai trò |
|---|---|---|---|---|---|
| 1 | `get_market_session` | `/trading/market/session` | `read:market` | — | Phiên + mốc thời gian cho toàn bộ phân tích |
| 2 | `get_asset_summary` | `/users/v3/users/{userId}/assets/summary` | `read:account` | — (theo userId, **toàn user**) | Tổng tài sản mọi sản phẩm Finhay |
| 3 | `get_account_summary` | `/trading/accounts/{subAccountId}/summary` | `read:account` | ✅ | Tiền mặt (`balance`), nợ (`total_debt_amt`), margin (`margin_amt`), sức mua — theo tiểu khoản |
| 4 | `get_portfolio_positions` | `/trading/v2/sub-accounts/{subAccountId}/portfolio` | `read:account` | ✅ | Vị thế: mã, KL, giá vốn, giá trị, lãi/lỗ — theo tiểu khoản |
| 5 | `get_pnl_today` | `/trading/pnl-today/{userId}` | `read:account` | — (theo userId, **toàn user**) | Lãi/lỗ hôm nay |
| 6 | `get_stock_quote` | `/market/stock-realtime` | `read:market` | — | Giá realtime — 1 call cho nhiều mã (`symbols=`) |
| 7 | `get_stock_news` | `/market/news` | `read:market` | — | Tin/sự kiện theo mã tỷ trọng lớn |
| 8* | `get_price_history` | `/market/price-histories-chart` | `read:market` | — | Biến động/thanh khoản khi cần thêm bằng chứng |
| 9* | `get_user_rights` | `/trading/v5/account/{subAccountId}/user-rights` | `read:account` | ✅ | Sự kiện quyền sắp tới (cổ tức, quyền mua) |
| 10* | `get_index_quote` | `/market/index-realtime` | `read:market` | — | Bối cảnh VNINDEX/VN30 trong ngày |

(*) = tuỳ chọn, gọi khi cần bằng chứng thêm.

> ⚠️ **Trộn phạm vi số liệu:** tool 2 & 5 là số **toàn user** (mọi tiểu khoản + mọi sản phẩm); tool 3, 4, 9 là số **theo tiểu khoản đã chọn**. Khi trình bày phải ghi chú rõ (vd: "PnL hôm nay là số tổng của tài khoản, không riêng tiểu khoản này"). Trong `get_asset_summary`, field `products.bond` là sản phẩm **HayBond**, không phải trái phiếu truyền thống.

### 4.B. Fallback CLI (khi dùng skills-hub trực tiếp qua OpenAPI HMAC, không có MCP)

Dùng `./finhay.sh request GET <path>` với đúng các path ở bảng trên (thay `{userId}` → `$USER_ID`, `{subAccountId}` → `$SUB_ACCOUNT_NORMAL` / `$SUB_ACCOUNT_MARGIN` sau khi `./finhay.sh infer`). Schema chi tiết từng endpoint: xem references của skill `finhay-portfolio` (account-summary, portfolio, assets, pnl-today, user-rights, orders) và `finhay-market` (stock-realtime, news, price-histories-chart, index-realtime, macro). Workflow, risk taxonomy, output và guardrails **không đổi** giữa hai chế độ.

## 5. Required scopes & Risk tier

- Scopes: `read:market` + `read:account`. **Không** cần `trade:securities` — skill này không bao giờ gọi tool ghi.
- Risk tier: **Tier 2 — Personalized financial analysis** (theo Guardrails 99059227) → bắt buộc: suitability caveats, tách facts/interpretation, không cam kết lợi nhuận, source + timestamp.

## 6. Workflow

```
B0. Xác định tiểu khoản (mục 3): chưa rõ → HỎI (gợi ý mặc định `normal`);
    dùng CÙNG giá trị `account` cho mọi call. Lấy mốc thời gian: get_market_session.
B1. Kéo dữ liệu tài khoản: get_asset_summary + get_account_summary
    + get_portfolio_positions + get_pnl_today.
    → Tính: tổng tài sản; tỷ trọng từng mã = giá trị mã / tổng giá trị CK của tiểu khoản;
      tỷ lệ tiền mặt = balance / (balance + giá trị CK); tỷ lệ nợ = total_debt_amt / tổng tài sản tiểu khoản.
B2. Với các mã tỷ trọng ≥15% (hoặc top 5 nếu không mã nào ≥15%):
    get_stock_quote (MỘT call, gộp symbols) + get_stock_news.
    Khi cần thêm bằng chứng: get_price_history (biến động/thanh khoản),
    get_user_rights (sự kiện quyền), get_index_quote (bối cảnh chỉ số).
B3. Chấm đủ 5 nhóm rủi ro theo references/risk-taxonomy.md. Mỗi rủi ro BẮT BUỘC có:
    evidence = con số cụ thể + tool nguồn; severity = Cao/Trung bình/Thấp + lý do xếp mức.
B4. Chọn TOP 3 theo quy tắc trong risk-taxonomy.md; soạn output đúng khuôn 7 mục
    theo references/output-template.md.
B5. TỰ KIỂM theo checklist cuối output-template.md (guardrails). Vi phạm → sửa rồi mới gửi.
```

## 7. Risk taxonomy (tóm tắt — chi tiết & ngưỡng: [references/risk-taxonomy.md](references/risk-taxonomy.md))

| Nhóm | Câu hỏi | Evidence chính |
|---|---|---|
| R1. Tập trung | Một mã/ngành chiếm quá lớn? | Tỷ trọng từ positions |
| R2. Tiền mặt & thanh khoản | Buffer mỏng? Vị thế khó thoát? | `balance`, KLGD bình quân vs KL nắm giữ |
| R3. Nợ margin | Đòn bẩy khuếch đại thua lỗ? | `total_debt_amt`, `margin_amt` |
| R4. Sự kiện theo mã | Tin/sự kiện trọng yếu sắp tác động? | news, user-rights, biến động giá |
| R5. Bối cảnh thị trường | Môi trường chung bất lợi? | session, index, macro — **chỉ nêu bối cảnh, không dự báo** |

## 8. Output format

Đúng khuôn **7 mục** (chi tiết + golden example: [references/output-template.md](references/output-template.md)):

1. 🕐 Thời điểm & nguồn dữ liệu → 2. 📊 Snapshot danh mục → 3. ⚠️ Top 3 rủi ro (evidence + severity) → 4. 💬 Giải thích dễ hiểu → 5. 🧭 Các hướng giảm rủi ro (options + trade-off) → 6. 📌 Dữ liệu thiếu & giả định → 7. ➡️ Bước tiếp theo + handoff app Finhay + disclaimer.

## 9. Guardrails

**Kế thừa toàn bộ bộ luật lõi G1–G10 từ [`finhay-guardrails`](../finhay-guardrails/SKILL.md)** (meta-skill `financial-safety-guardrails` — bề mặt Legal review duy nhất; sửa luật chung TẠI ĐÓ, không sửa ở đây; bản render nằm trong COMPLIANCE của instructions + phần "Ràng buộc bắt buộc" của prompt). Luật **RIÊNG** của workflow này:

1. **Ngưỡng đánh giá là giả định vận hành** (1 mã >30% = tập trung cao; tiền mặt <5% = mỏng; nợ/tài sản >30% = cao…) — bắt buộc khai báo ở output mục 6 mỗi khi dùng đến (cụ thể hoá G1+G5).
2. **Mục "hướng giảm rủi ro" luôn có phương án "giữ nguyên + điều kiện theo dõi"** — dải lựa chọn không được nghiêng mặc định về phía hành động (cụ thể hoá G4; được nêu tên mã trong hướng cân nhắc theo đúng phạm vi G4 cho phép).
3. **Không thổi phồng để đủ chỉ tiêu:** danh mục lành mạnh thì nói thẳng; "top 3" khi đó là *điểm đáng theo dõi* có nhãn rõ, không phải rủi ro Cao cơ học (cụ thể hoá G8).
4. Khi trộn số liệu toàn-tài-khoản (asset summary, PnL hôm nay) với số theo-tiểu-khoản → ghi chú phạm vi ngay tại chỗ trình bày (cụ thể hoá G1).

## 10. Failure modes

| Tình huống | Hành vi bắt buộc |
|---|---|
| Token thiếu `read:account` (MCP: account tools không xuất hiện trong tools/list) | Nói rõ cần cấp quyền dữ liệu tài khoản; hướng dẫn reconnect MCP + tick scope tương ứng ở màn consent. KHÔNG bịa dữ liệu danh mục; có thể chuyển sang phân tích thị trường chung (Tier 0) nếu user muốn |
| Tiểu khoản được chọn không tồn tại trong token (tool trả "Bạn không có tài khoản …") | Báo lại danh sách loại tài khoản khả dụng, hỏi chọn lại |
| Danh mục rỗng / tài khoản mới | Không "phân tích rủi ro" trên danh mục rỗng — đưa snapshot tài sản tổng (asset summary) + gợi ý câu hỏi tiếp theo |
| Tool lỗi / timeout | Nêu rõ mục nào thiếu dữ liệu do lỗi hệ thống, phân tích phần còn lại; KHÔNG đoán số, KHÔNG retry vô hạn |
| Ngoài giờ giao dịch / dữ liệu cũ | Ghi rõ "giá theo phiên gần nhất" + timestamp; không coi giá đứng im là "ổn định" |
| User đòi đặt lệnh ngay trong flow | Guardrail #6: từ chối nhẹ nhàng, handoff app Finhay / skill finhay-trading |
| Không có risk profile | Failure mode mặc định — xử lý theo Guardrail #5, không chặn output |

## 11. Success criteria (acceptance — theo Confluence 99059228)

- [ ] Chỉ dùng real user-scoped data sau khi user consent (OAuth/HMAC).
- [ ] Output đủ 7 mục; mỗi rủi ro trong top 3 có evidence số liệu + severity + nguồn.
- [ ] Không cam kết lợi nhuận; không khẳng định chắc chắn hướng thị trường.
- [ ] Không execute / không đặt lệnh; kết bằng handoff + disclaimer.
- [ ] Tách rõ facts và interpretation ở mọi phần.
- [ ] Các hướng giảm rủi ro có tính hành động nhưng an toàn (options + trade-off, không mệnh lệnh).
- [ ] Nêu rõ tiểu khoản đã review, dữ liệu thiếu và giả định (bao gồm ngưỡng đánh giá).

## 12. Renders & sync

Bản render cho `vnsc-mcp-server` (nhánh `feature/memo`) tại [references/mcp-renders.md](references/mcp-renders.md). **Từ 2026-07-11 (có workflow thứ 3) INSTRUCTIONS chuyển Tier B:**

1. **1 dòng router** trong header `WORKFLOWS PHÂN TÍCH` của `const INSTRUCTIONS` (`src/infrastructure/web/mcp/mcpServer.ts`).
2. **MCP prompt** `portfolio-review` (đầy đủ) — `src/service/prompts/definitions/portfolioReview.ts`; văn bản này đồng thời là body của `get_workflow_guide('portfolio-review')` (serve từ `PromptService.generate`, không có bề mặt sync riêng).

Quy trình sync: sửa SKILL.md/references → cập nhật mcp-renders.md → copy sang code + sửa test → ghi chú commit hai phía. (Tự động hoá theo `auto_openapi.md` là follow-up.)
