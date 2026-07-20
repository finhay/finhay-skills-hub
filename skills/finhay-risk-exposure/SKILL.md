---
name: finhay-risk-exposure
description: "Full portfolio risk-exposure scan for Finhay Securities: audit-style sweep of ALL 5 risk groups (concentration, cash/liquidity, margin/debt, symbol/event, market context) over the user's real holdings, pending orders and account data — every finding carries numeric evidence + severity, and groups with no findings are explicitly marked as checked. Reports exposure only; deliberately gives NO risk-reduction advice (hands off to finhay-portfolio-review for that). Read-only, compliance-guardrailed, answers in Vietnamese. Use when the user asks what risks their portfolio is carrying, for a full/thorough risk check or risk scan. NOT for an overall portfolio review with top-3 + reduction options (finhay-portfolio-review), NOT for news digests (finhay-market-briefing), NOT for single-stock analysis (finhay-stock-research)."
license: MIT
metadata:
  author: Finhay Securities
  version: "1.0.0"
  catalog-name: risk-exposure-check
  risk-tier: "2"
---

# Finhay Risk Exposure (`risk-exposure-check`)

Workflow skill theo catalog Finhay Agent Platform v2 (Confluence 99059118, nhóm P0):

> *User job: "Danh mục của tôi đang có rủi ro gì?" — Output: concentration, liquidity/cash, margin/debt, symbol/event risks **có bằng chứng**. Guardrails: không ngôn ngữ gây hoảng loạn; không khẳng định chắc chắn hướng thị trường; thể hiện severity và evidence.*

(Tên cũ trong taxonomy: `portfolio-risk-check` → v2 đổi thành `risk-exposure-check` vì phạm vi rộng hơn: liquidity, margin/debt, event và symbol risks.)

> **File này là SOURCE OF TRUTH của workflow.** Render cho Remote MCP (dòng router + prompt `risk-exposure-check`, đồng thời là body của `get_workflow_guide`) — xem [references/mcp-renders.md](references/mcp-renders.md).

## 1. Purpose & ranh giới với `portfolio-review`

Bản **quét kiểm tra phơi nhiễm rủi ro** kiểu audit: chấm **đủ cả 5 nhóm rủi ro** (không chỉ top 3), mọi phát hiện kèm bằng chứng số liệu + mức độ, nhóm sạch được đánh dấu "✓ đã kiểm — không phát hiện" để chứng minh không bỏ sót. **Cố ý KHÔNG đưa hướng giảm rủi ro** — đó là việc của `portfolio-review`.

| | `risk-exposure-check` (skill này) | `finhay-portfolio-review` |
|---|---|---|
| Bản chất | **Kiểm tra / audit** — quét đủ, liệt kê phơi nhiễm | **Review / tư vấn khung** — chọn lọc + định hướng |
| Độ phủ rủi ro | TẤT CẢ phát hiện ở cả 5 nhóm (kể cả Thấp, kể cả "không phát hiện") | Top 3 theo severity |
| Hướng giảm rủi ro | ❌ Không có (handoff sang portfolio-review) | ✅ 2–3 lựa chọn + trade-off |
| Ngưỡng quét mã | Rộng hơn: mọi mã ≥10% | Mã ≥15% hoặc top 5 |
| Dữ liệu thêm | + Lệnh đang treo (`get_order_history`) | — |
| Câu hỏi điển hình | "đang có rủi ro gì", "check/quét rủi ro toàn diện" | "review danh mục", "hướng giảm rủi ro" |

## 2. Trigger

**Dùng khi** user hỏi: "danh mục tôi đang có rủi ro gì", "kiểm tra rủi ro danh mục", "quét/soi hết rủi ro giúp tôi", "tôi đang phơi nhiễm những gì", audit định kỳ rủi ro.

**KHÔNG dùng khi:**
- Muốn review tổng quan + top rủi ro + **hướng giảm** → `finhay-portfolio-review`.
- Tin tức ảnh hưởng danh mục hôm nay → `finhay-market-briefing`.
- Phân tích sâu 1 mã → `finhay-stock-research`.
- Muốn đặt/sửa/huỷ lệnh → `finhay-trading` / app Finhay.

User hỏi lẫn cả hai ("có rủi ro gì và nên làm gì?") → chạy skill này để quét, rồi đề nghị chạy tiếp `portfolio-review` cho phần hướng giảm (hoặc ngược lại nếu trọng tâm là review).

## 3. Required user inputs

Giống `finhay-portfolio-review`: không input bắt buộc; tiểu khoản qua SELECT-mode `account` (`normal|margin|openapi`) — chưa rõ → hỏi một lần (gợi ý mặc định `normal`), dùng cùng giá trị cho mọi call; khẩu vị rủi ro tuỳ chọn (không có → giả định thận trọng, G5).

## 4. Data access

### 4.A. Remote MCP (ưu tiên)

| # | Tool | OpenAPI path (vendored spec) | Scope | Input `account`? | Vai trò |
|---|---|---|---|---|---|
| 1 | `get_market_session` | `/trading/market/session` | `read:market` | — | Phiên + mốc thời gian |
| 2 | `get_account_summary` | `/trading/accounts/{subAccountId}/summary` | `read:account` | ✅ | Tiền mặt (`balance`), nợ (`total_debt_amt`), margin (`margin_amt`) |
| 3 | `get_asset_summary` | `/users/v3/users/{userId}/assets/summary` | `read:account` | — (toàn user) | Bức tranh tài sản tổng (ghi chú phạm vi khi trộn) |
| 4 | `get_portfolio_positions` | `/trading/v2/sub-accounts/{subAccountId}/portfolio` | `read:account` | ✅ | TOÀN BỘ vị thế + tỷ trọng |
| 5 | `get_pnl_today` | `/trading/pnl-today/{userId}` | `read:account` | — (toàn user) | Lãi/lỗ hôm nay |
| 6 | `get_order_history` | `/trading/v1/accounts/{subAccountId}/order-book` | `read:account` | ✅ | **Lệnh đang treo** — mua treo = cam kết tiền; bán treo = đang thoát vị thế (catalog: "order book nếu cần") |
| 7 | `get_stock_quote` | `/market/stock-realtime` | `read:market` | — | Giá/biến động các mã ≥10% (gộp 1 call `symbols`) |
| 8 | `get_stock_news` | `/market/news` | `read:market` | — | Sự kiện theo mã (~7 ngày, gộp `stocks`) |
| 9* | `get_price_history` | `/market/price-histories-chart` | `read:market` | — | Chấm thanh khoản: vị thế lớn vs KLGD bình quân |
| 10* | `get_user_rights` | `/trading/v5/account/{subAccountId}/user-rights` | `read:account` | ✅ | Sự kiện quyền sắp tới |
| 11* | `get_index_quote` | `/market/index-realtime` | `read:market` | — | Bối cảnh chỉ số (chỉ mô tả) |

(*) tuỳ chọn theo dữ kiện. Scopes: `read:market` + `read:account` (order book thuộc `read:account` trong taxonomy thực tế — catalog ghi "optional orders:read" theo taxonomy memo cũ).

### 4.B. Fallback CLI (OpenAPI HMAC)

`./finhay.sh request GET <path>` với path ở bảng trên; schema chi tiết xem references của `finhay-portfolio` + `finhay-market`. Workflow/ngưỡng/output không đổi.

## 5. Risk tier

**Tier 2** (personalized analysis) — mọi control Tier 2 áp dụng qua kế thừa guardrails (mục 9).

## 6. Workflow

```
B0. Xác định tiểu khoản (SELECT-mode; chưa rõ → HỎI). Mốc thời gian: get_market_session.
B1. Kéo dữ liệu: get_account_summary + get_asset_summary + get_portfolio_positions
    + get_pnl_today + get_order_history (lệnh treo).
    → Tính: tỷ trọng TỪNG mã; tỷ lệ tiền mặt; tỷ lệ nợ; giá trị lệnh mua đang treo
      (cam kết tiền so với balance); ghi chú phạm vi số toàn-user vs tiểu khoản.
B2. Với MỌI mã tỷ trọng ≥10%: get_stock_quote (1 call) + get_stock_news; khi cần:
    get_price_history (thanh khoản), get_user_rights (sự kiện quyền), get_index_quote.
B3. Chấm ĐỦ 5 nhóm theo taxonomy dùng chung
    (../finhay-portfolio-review/references/risk-taxonomy.md): mỗi phát hiện = 📊 evidence
    + severity + lý do; nhóm không có phát hiện → "✓ đã kiểm — không phát hiện".
    Lệnh treo được chấm trong nhóm R2 (cam kết tiền làm mỏng buffer) và R1 (mua treo
    làm tăng tập trung nếu khớp).
B4. Soạn output đúng khuôn 6 phần (references/output-template.md); KHÔNG thêm mục
    khuyến nghị/hướng giảm.
B5. Tự kiểm checklist trong output-template.md rồi mới gửi.
```

## 7. Taxonomy & ngưỡng

Dùng **chung** bộ taxonomy 5 nhóm + ngưỡng-assumption với `finhay-portfolio-review`: [../finhay-portfolio-review/references/risk-taxonomy.md](../finhay-portfolio-review/references/risk-taxonomy.md) (R1 tập trung · R2 tiền mặt & thanh khoản · R3 nợ margin · R4 sự kiện theo mã · R5 bối cảnh thị trường — chỉ mô tả). Khác biệt khi áp cho skill này: quét mã từ ngưỡng **≥10%**; chấm **mọi** phát hiện thay vì chọn top 3; bổ sung dữ kiện **lệnh treo** vào R1/R2.

## 8. Output format — khuôn 6 phần (chi tiết + golden example: [references/output-template.md](references/output-template.md))

1. 🕐 Thời điểm & phạm vi → 2. 📊 Bảng phơi nhiễm (từng mã + tỷ trọng, tiền mặt %, nợ %, lệnh treo, sự kiện sắp tới) → 3. ⚠️ Kết quả quét 5 nhóm (phát hiện + evidence + severity, hoặc "✓ không phát hiện") → 4. 🔎 Tổng hợp (đếm theo mức + mục chưa kiểm được) → 5. 📌 Giả định & ngưỡng → 6. ➡️ Bước tiếp theo (muốn hướng giảm → `portfolio-review`; hành động → app Finhay) + disclaimer.

## 9. Guardrails

**Kế thừa toàn bộ bộ luật lõi G1–G10 từ [`finhay-guardrails`](../finhay-guardrails/SKILL.md)** (bề mặt Legal review duy nhất). Luật **RIÊNG** của workflow này:

1. **Chỉ kiểm tra, không khuyến nghị:** workflow này KHÔNG đưa "hướng giảm rủi ro" — phát hiện + bằng chứng + mức độ, hết. Nhu cầu định hướng → handoff `portfolio-review` (cụ thể hoá G4; đây cũng là ranh giới catalog đặt cho skill).
2. **Đủ 5 nhóm, không bỏ nhóm nào:** nhóm sạch phải ghi "✓ đã kiểm — không phát hiện"; mục không kiểm được (thiếu data/quyền) phải liệt kê ở phần 4 — không im lặng bỏ qua (cụ thể hoá G1).
3. **Severity kỷ luật:** mỗi mức Cao/TB/Thấp phải nêu ngưỡng đã dùng; danh mục sạch → nói thẳng "không phát hiện đáng kể", cấm thổi phồng để bản quét "trông có giá trị" (cụ thể hoá G8 — guardrail catalog: không ngôn ngữ gây hoảng loạn).
4. Ngưỡng là **giả định vận hành** — khai báo ở phần 5 (như portfolio-review).

## 10. Failure modes

| Tình huống | Hành vi bắt buộc |
|---|---|
| Thiếu `read:account` | Nói rõ cần cấp quyền + hướng dẫn reconnect; không bịa. Không có chế độ fallback công khai (khác market-briefing) vì bản chất skill là quét dữ liệu private |
| Danh mục rỗng | Không quét "rủi ro ma"; báo danh mục trống + phơi nhiễm duy nhất là tiền mặt/lệnh treo nếu có |
| `get_order_history` lỗi/không có lệnh | Ghi "lệnh treo: không có / không lấy được (lý do)" ở bảng phơi nhiễm — không bỏ trống im lặng |
| Không nhận diện được ngành đủ tin cậy | Bỏ chấm tỷ trọng ngành, ghi vào phần 4 "chưa kiểm được" |
| Tool market lỗi | Quét phần còn lại; nhóm bị ảnh hưởng ghi "chưa kiểm được vì thiếu dữ liệu X" |
| User đòi "vậy phải làm gì" | Guardrail riêng #1: mời chạy `portfolio-review` (hướng cân nhắc) / app Finhay (hành động) |

## 11. Success criteria

- [ ] Đủ 6 phần; bảng phơi nhiễm liệt kê TẤT CẢ vị thế + lệnh treo.
- [ ] Cả 5 nhóm đều xuất hiện ở phần 3 — có phát hiện hoặc "✓ không phát hiện"; không nhóm nào biến mất.
- [ ] Mọi phát hiện: evidence số liệu + nguồn tool + severity + ngưỡng đã dùng.
- [ ] KHÔNG có câu khuyến nghị/hướng giảm nào trong output.
- [ ] Phần 4 liệt kê trung thực mục chưa kiểm được.
- [ ] Kết bằng handoff (portfolio-review / app) + disclaimer verbatim.

## 12. Renders & sync

Xem [references/mcp-renders.md](references/mcp-renders.md): **1 dòng router** (đồng thời SỬA dòng router của `portfolio-review` để tách trigger "rủi ro") + **prompt `risk-exposure-check`** (không args; văn bản đồng thời là body `get_workflow_guide('risk-exposure-check')`). Quy trình sync như các skill trước.
