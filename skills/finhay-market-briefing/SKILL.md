---
name: finhay-market-briefing
description: "Portfolio-tied market briefing for Finhay Securities: pull the user's holdings, then surface ONLY the news, intraday moves, and upcoming events that affect those positions — every item tied to a held symbol with publish date + source. Two modes: personalized (account access granted) or general market briefing (market-only). Read-only, compliance-guardrailed, answers in Vietnamese. Use when the user asks what's affecting their portfolio today, news about their holdings, or a personal market digest. NOT for full risk assessment (use finhay-portfolio-review), NOT for general market/price lookups without portfolio context (use finhay-market), NOT for placing orders (use finhay-trading)."
license: MIT
metadata:
  author: Finhay Securities
  version: "1.0.0"
  catalog-name: market-briefing-for-my-portfolio
  risk-tier: "0/2"
---

# Finhay Market Briefing (`market-briefing-for-my-portfolio`)

Workflow skill cho user job trong catalog Finhay Agent Platform v2 (Confluence 99059118):

> *"Hôm nay có gì ảnh hưởng tới danh mục của tôi không?"*

Đây là workflow **bản tin gắn với danh mục** — khác về bản chất với "tổng quan thị trường" (chung chung) và với "review rủi ro" (đánh giá cấu trúc danh mục). Guardrail đặc thù từ catalog: *"Không dump tin thị trường chung chung; phải gắn insight với holdings; nêu timestamp/source khi có thể."*

> **File này là SOURCE OF TRUTH của workflow.** Bản render cho Remote MCP (header WORKFLOWS + block instructions + prompt `market-briefing`) — xem [references/mcp-renders.md](references/mcp-renders.md). Sửa workflow ở đây trước, render sang code sau.

## 1. Purpose

Trả lời user job "hôm nay có gì ảnh hưởng danh mục tôi": bản tin chọn lọc — tin tức, biến động trong ngày, sự kiện sắp tới — trong đó **mọi item đều gắn với một mã đang nắm giữ**, kèm ngày đăng/nguồn, và watch-items để theo dõi tiếp. Không phân tích rủi ro tổng thể (đó là việc của `portfolio-review`), không thực thi giao dịch.

## 2. Trigger

**Dùng skill này khi** user hỏi: "hôm nay có gì ảnh hưởng danh mục tôi", "có tin gì về các mã tôi đang giữ", "bản tin theo danh mục của tôi", "tuần này có sự kiện gì liên quan cổ phiếu của tôi".

**KHÔNG dùng khi:**
- Đánh giá rủi ro / sức khoẻ danh mục ("danh mục tôi có rủi ro gì", "có nên lo không") → skill `finhay-portfolio-review`.
- Tổng quan thị trường chung không gắn danh mục ("thị trường hôm nay thế nào") → prompt `market-overview` / skill `finhay-market`.
- Giá/tin của 1 mã đơn lẻ user tự nêu tên → gọi tool trực tiếp.
- Phân tích/đánh giá sâu MỘT mã cụ thể ("phân tích FPT") → skill `finhay-stock-research`.
- Muốn đặt/sửa/huỷ lệnh → `finhay-trading` hoặc app Finhay.

**Ranh giới với `portfolio-review`:** briefing = "chuyện gì đang/sắp xảy ra bên ngoài tác động vào danh mục" (event-driven, nhìn ra ngoài); review = "cấu trúc danh mục đang khoẻ hay yếu" (structure-driven, nhìn vào trong). User hỏi lẫn cả hai → làm briefing rồi gợi ý chạy tiếp portfolio-review (hoặc ngược lại theo trọng tâm câu hỏi).

## 3. Required user inputs & 2 chế độ

Không có input bắt buộc. Quy ước tiểu khoản giống `finhay-portfolio-review`: tool account-scoped nhận input `account` ∈ `normal | margin | openapi`; user chưa nói rõ → **hỏi một lần** (gợi ý mặc định `normal`), dùng cùng giá trị cho mọi call.

| Chế độ | Điều kiện | Hành vi |
|---|---|---|
| **Cá nhân hoá** (mặc định) | Token có `read:account` | Bản tin gắn với holdings thật |
| **Bản tin chung** (fallback) | User chưa cấp quyền tài khoản (account tools không xuất hiện) | Bản tin thị trường chung (chỉ số, tin nổi bật, lịch sự kiện) + **nói rõ** đang ở chế độ chung + mời kết nối danh mục để được bản tin cá nhân hoá. KHÔNG bịa danh mục |

## 4. Data access

### 4.A. Remote MCP (ưu tiên)

| # | Tool | OpenAPI path (vendored spec) | Scope | Input `account`? | Vai trò |
|---|---|---|---|---|---|
| 1 | `get_market_session` | `/trading/market/session` | `read:market` | — | Phiên + mốc thời gian |
| 2 | `get_portfolio_positions` | `/trading/v2/sub-accounts/{subAccountId}/portfolio` | `read:account` | ✅ | Danh sách mã nắm giữ + tỷ trọng (chế độ cá nhân hoá) |
| 3 | `get_stock_news` | `/market/news` | `read:market` | — | Tin theo mã — **gộp 1 call** qua param `stocks` (nhiều mã), lọc ~7 ngày gần nhất |
| 4 | `get_stock_quote` | `/market/stock-realtime` | `read:market` | — | Biến động trong ngày — **gộp 1 call** qua param `symbols` |
| 5* | `get_index_quote` | `/market/index-realtime` | `read:market` | — | Bối cảnh VNINDEX/VN30 (param `index`) |
| 6* | `get_user_rights` | `/trading/v5/account/{subAccountId}/user-rights` | `read:account` | ✅ | Sự kiện quyền sắp tới của mã nắm giữ (cổ tức, quyền mua, ĐHCĐ) |
| 7* | `get_economic_calendar` | `/market/financial-data/economic-calendar-events` | `read:market` | — | Sự kiện kinh tế sắp tới (param `weeks`, `country`) |
| 8* | `get_macro_data` | `/market/financial-data/macro` | `read:market` | — | Chỉ báo vĩ mô khi liên quan |
| 9* | `get_global_news` | `/market/financial-data/global-news` | `read:market` | — | Tin quốc tế — chỉ khi danh mục nhạy với global (ngành xuất khẩu, tỷ giá…) |

(*) = tuỳ chọn, gọi khi liên quan. Chế độ bản tin chung: bỏ tool 2 & 6, dùng 1 + 3 (tin nổi bật, không lọc theo mã) + 5 + 7.

### 4.B. Fallback CLI (OpenAPI HMAC, không có MCP)

`./finhay.sh request GET <path>` với đúng path ở bảng trên (`{subAccountId}` → `$SUB_ACCOUNT_NORMAL`/`$SUB_ACCOUNT_MARGIN` sau `./finhay.sh infer`). Schema chi tiết: references của `finhay-portfolio` (portfolio, user-rights) và `finhay-market` (news, stock-realtime, index-realtime, economic-calendar-events, macro, global-news). Workflow, quy tắc chọn lọc, output và guardrails **không đổi**.

## 5. Required scopes & Risk tier

- Chế độ cá nhân hoá: `read:market` + `read:account`. Chế độ bản tin chung: chỉ `read:market`.
- Risk tier theo catalog: **Tier 0** (public data, chế độ chung) / **Tier 2** (personalized — khi gắn với danh mục thật) → chế độ cá nhân hoá phải tuân đầy đủ controls Tier 2: facts vs interpretation, timestamp/source, không cam kết lợi nhuận.

## 6. Workflow

```
B0. Xác định chế độ + tiểu khoản: có read:account? → cá nhân hoá (hỏi account nếu chưa rõ);
    không → bản tin chung + mời kết nối. Lấy mốc thời gian: get_market_session.
B1. (Cá nhân hoá) get_portfolio_positions → danh sách mã + tỷ trọng từng mã.
B2. get_stock_news (gộp `stocks` = tất cả mã nắm giữ, ~7 ngày) + get_stock_quote (gộp `symbols`).
B3. Khi liên quan: get_index_quote; get_user_rights (sự kiện quyền sắp tới); get_economic_calendar
    (1–2 tuần tới); get_macro_data; get_global_news (nếu danh mục nhạy global).
B4. Chọn lọc & xếp hạng item theo mục 7; soạn output đúng khuôn 5 phần (mục 8);
    tự kiểm theo checklist trong references/output-template.md rồi mới gửi.
```

## 7. Quy tắc chọn lọc & gắn kết (thay cho risk taxonomy — phần "trí tuệ" của skill này)

1. **Điều kiện vào bản tin:** item phải map được về ≥1 mã đang nắm giữ (hoặc nhóm ngành chiếm tỷ trọng lớn của danh mục). Không map được → bỏ (trừ 2–3 dòng bối cảnh chung ở phần 2 của output).
2. **Cấu trúc bắt buộc mỗi item:** `mã (tỷ trọng x%)` + 📊 fact (nội dung 1–2 dòng, **ngày đăng**, nguồn/tool) + 💡 vì sao đáng chú ý với vị thế này (cơ chế tác động, KHÔNG phán đoán tương lai).
3. **Xếp hạng:** theo mức đáng chú ý ≈ tỷ trọng vị thế × mức trọng yếu của tin (tin đã xác nhận > tin đồn; sự kiện có lịch > tin mô tả). Tin chưa xác nhận → nhãn **"chưa xác nhận"**, xếp cuối, không được là item đầu.
4. **Không độn tin:** không có tin trọng yếu nào với danh mục → **nói thẳng** ("hôm nay không có tin trọng yếu với các mã bạn nắm giữ") — đó cũng là thông tin hữu ích; chỉ đưa watch-items sắp tới. Cấm lấp chỗ trống bằng tin thị trường chung.
5. **Biến động giá bất thường** của mã nắm giữ (±3%+ trong phiên — ngưỡng giả định) được coi là một "item" kể cả khi chưa thấy tin: nêu fact biến động + ghi rõ "chưa rõ nguyên nhân từ dữ liệu hiện có", không suy diễn.
6. Giữ bản tin **ngắn**: tối đa ~5 item chính + watch-items; dài hơn = đang độn.

## 8. Output format — khuôn 5 phần (chi tiết + golden example: [references/output-template.md](references/output-template.md))

1. 🕐 Thời điểm & phạm vi → 2. 📈 Bối cảnh thị trường (2–3 dòng, chỉ mô tả) → 3. 📰 Tin & sự kiện THEO MÃ NẮM GIỮ (mục chính) → 4. 👀 Watch-items sắp tới → 5. 📌 Giả định & thiếu dữ liệu + ➡️ bước tiếp theo + disclaimer.

## 9. Guardrails

**Kế thừa toàn bộ bộ luật lõi G1–G10 từ [`finhay-guardrails`](../finhay-guardrails/SKILL.md)** (meta-skill — bề mặt Legal review duy nhất; sửa luật chung tại đó). Luật **RIÊNG** của workflow này:

1. **Mỗi item tin bắt buộc có ngày đăng + nguồn** — không dẫn tin không rõ nguồn (nâng G1 lên mức bắt buộc từng item).
2. **Không suy diễn quá nội dung tin**; tin đồn/chưa kiểm chứng → nhãn **"chưa xác nhận"**, xếp cuối, không được là item đầu và không tính vào các item chính.
3. **Chống độn tin:** bối cảnh thị trường chung tối đa 2–3 dòng; không có tin trọng yếu với danh mục → nói thẳng điều đó thay vì lấp bằng tin chung (cụ thể hoá G8).
4. **Chế độ bản tin chung phải được nói rõ** ("chưa kết nối danh mục nên đây là bản tin chung") — không bịa/ám chỉ đang cá nhân hoá.
5. Tin gợi nhu cầu hành động → route sang `portfolio-review` (đánh giá) hoặc app Finhay (hành động) — không tự tư vấn hành động tại chỗ (cụ thể hoá G4+G6).

## 10. Failure modes

| Tình huống | Hành vi bắt buộc |
|---|---|
| Token thiếu `read:account` | Chuyển chế độ bản tin chung (mục 3) + mời kết nối danh mục. KHÔNG bịa holdings |
| Danh mục rỗng | Nói rõ + đưa bản tin chung ngắn + gợi ý bắt đầu từ đâu trong app |
| Không có tin nào ~7 ngày cho các mã | Quy tắc 7.4 — nói thẳng, chỉ đưa watch-items |
| `get_stock_news` lỗi/timeout | Vẫn brief bằng phần còn lại (quote/biến động, rights, calendar) + ghi rõ "chưa lấy được tin tức do lỗi hệ thống" |
| Tin mâu thuẫn nhau giữa các nguồn | Nêu cả hai kèm nguồn, không tự phân xử |
| User đòi hành động ngay ("bán luôn") | Guardrail #4: từ chối nhẹ nhàng + handoff app Finhay |

## 11. Success criteria

- [ ] Mọi item ở phần 3 đều gắn với mã nắm giữ + có ngày đăng/nguồn + có tỷ trọng vị thế.
- [ ] Không có tin chung chung độn bản tin; không có dự báo hướng.
- [ ] Đúng khuôn 5 phần; ngắn gọn (≤5 item chính).
- [ ] Chế độ đúng theo quyền (cá nhân hoá vs chung) và nói rõ chế độ đang dùng.
- [ ] Không execute; kết bằng bước tiếp theo + disclaimer.

## 12. Renders & sync

Bản render cho `vnsc-mcp-server` (nhánh `feature/memo`) tại [references/mcp-renders.md](references/mcp-renders.md). **Từ 2026-07-11 (có workflow thứ 3) INSTRUCTIONS chuyển Tier B:** workflow này chỉ còn **1 dòng router** trong header `WORKFLOWS PHÂN TÍCH`; bản đầy đủ = **prompt `market-briefing`** (đồng thời là body của `get_workflow_guide('market-briefing')`). Quy trình sync giống `finhay-portfolio-review`: sửa spec → cập nhật renders → copy sang code + test.
