---
name: finhay-cash-allocation
description: "Cash-allocation analysis for the user's Finhay investment account: compute the real cash picture (balance, T+ receivables, cash committed by pending buy orders, margin debt → true available cash), position it against three reference frames (conservative / balanced / aggressive — ranges declared as assumptions), run 2–3 mechanical what-if scenarios on real numbers, and list the questions the user must answer themselves (risk appetite, 3–6-month spending needs, horizon). Deliberately NEVER picks a frame for the user, never says 'you should hold X%', and never suggests specific products to deploy idle cash — suitability-sensitive advice requires a risk profile that does not exist. Read-only, answers in Vietnamese. Use when the user asks whether their cash is too much/too little, how much cash to hold, or about idle cash. NOT for a full portfolio review (finhay-portfolio-review), NOT for a full risk scan (finhay-risk-exposure), NOT for placing orders or transfers (Finhay app)."
license: MIT
metadata:
  author: Finhay Securities
  version: "1.0.0"
  catalog-name: cash-allocation-advisor
  risk-tier: "2"
---

# Finhay Cash Allocation (`cash-allocation-advisor`)

Workflow skill theo catalog Finhay Agent Platform v2 (Confluence 99059118, nhóm P0):

> *User job: "Tiền mặt của tôi đang nhiều/quá ít không?" — Output: cash ratio, scenarios, conservative/balanced/aggressive framing, câu hỏi cần bổ sung. Guardrails: không đưa recommendation suitability-sensitive nếu thiếu profile; không hướng dẫn mua/bán trực tiếp.*

Đây là workflow **nhạy cảm suitability nhất** trong bộ P0: câu hỏi của user ("nhiều hay ít?") *mời gọi* một câu trả lời phán định — nhưng phán định đúng đòi hỏi hồ sơ khẩu vị rủi ro mà platform chưa có. Toàn bộ "trí tuệ" của skill nằm ở chỗ **trả lời hữu ích mà không phán định**: dựng bức tranh tiền mặt THẬT (nhiều lớp), đối chiếu 3 khung tham chiếu, chạy kịch bản cơ học, và trả lại cho user đúng những câu hỏi họ phải tự trả lời.

> **File này là SOURCE OF TRUTH của workflow.** Render cho Remote MCP — xem [references/mcp-renders.md](references/mcp-renders.md).

## 1. Purpose & ranh giới

| | `cash-allocation-advisor` (skill này) | `portfolio-review` / `risk-exposure-check` |
|---|---|---|
| Phạm vi | **Một chiều duy nhất: tiền mặt** — đào sâu (T+, lệnh treo, nợ, toàn Finhay) | Toàn danh mục (cash chỉ là 1 trong 5 nhóm — R2) |
| Kết quả | Vị trí trên 3 khung tham chiếu + kịch bản + câu hỏi bổ sung | Top-3 + hướng giảm (review) / bảng quét đủ (exposure) |
| Phán định | ❌ Không chọn khung hộ, không "nên giữ X%" | Review có "hướng cân nhắc" (vẫn không mệnh lệnh) |

## 2. Trigger

**Dùng khi** user hỏi: "tiền mặt của tôi nhiều/ít quá không", "tôi nên giữ bao nhiêu tiền mặt", "tiền nhàn rỗi trong tài khoản", "cash ratio của tôi thế nào", "để nhiều tiền mặt vậy có phí không".

**KHÔNG dùng khi:**
- Review tổng quan danh mục / hướng giảm rủi ro → `finhay-portfolio-review`.
- Quét rủi ro đầy đủ → `finhay-risk-exposure`.
- "Tiền nhàn rỗi nên MUA GÌ?" → không có workflow nào trả lời câu đó (product recommendation = suitability-sensitive): giải thích vì sao không thể khuyên mã/sản phẩm cụ thể, đưa câu hỏi tự đánh giá + handoff app Finhay (mục sản phẩm) — xem Guardrails #1.
- Nạp/rút/chuyển tiền, đặt lệnh → app Finhay.

## 3. Required user inputs

Không bắt buộc. Tiểu khoản qua SELECT-mode `account` (chưa rõ → hỏi, mặc định `normal`). Nếu user chủ động cho biết khẩu vị rủi ro / nhu cầu chi tiêu sắp tới → dùng để đối chiếu khung sát hơn (vẫn không phán định thay).

## 4. Data access

### 4.A. Remote MCP (ưu tiên)

| # | Tool | OpenAPI path (vendored spec) | Scope | Input `account`? | Vai trò |
|---|---|---|---|---|---|
| 1 | `get_market_session` | `/trading/market/session` | `read:market` | — | Phiên + mốc thời gian |
| 2 | `get_account_summary` | `/trading/accounts/{subAccountId}/summary` | `read:account` | ✅ | **Lõi**: `balance`, tiền đang về (`receiving_t1/t2/t3`), nợ (`total_debt_amt`, `margin_amt`) |
| 3 | `get_portfolio_positions` | `/trading/v2/sub-accounts/{subAccountId}/portfolio` | `read:account` | ✅ | Tổng giá trị CK — mẫu số của cash ratio tiểu khoản |
| 4 | `get_asset_summary` | `/users/v3/users/{userId}/assets/summary` | `read:account` | — (toàn user) | Bức tranh toàn Finhay: tiền + CCQ + tiết kiệm + HayBond (`products.bond` = **HayBond**, không phải trái phiếu truyền thống) |
| 5 | `get_order_history` | `/trading/v1/accounts/{subAccountId}/order-book` | `read:account` | ✅ | Lệnh MUA đang treo = tiền đã cam kết → trừ khỏi "khả dụng thực tế" |
| 6* | `get_bank_interest_rates` | `/market/financial-data/bank-interest-rates` | `read:market` | — | Bối cảnh lãi suất tiền gửi (chi phí cơ hội của tiền nhàn rỗi) — **chỉ nêu như dữ kiện** |

(*) tuỳ chọn. Scopes: `read:account` (+`read:market` cho session/lãi suất).

### 4.B. Fallback CLI (OpenAPI HMAC)

`./finhay.sh request GET <path>` với path ở bảng trên; schema chi tiết: references của `finhay-portfolio` (account-summary, portfolio, assets, orders) và `finhay-market` (bank-interest-rates). Workflow/khung/output không đổi.

## 5. Risk tier

**Tier 2** — và là ca "suitability-sensitive" điển hình: mọi control Tier 2 + guardrail riêng #1 (không phán định) là ranh giới sống còn.

## 6. Workflow

```
B0. Xác định tiểu khoản (SELECT-mode; chưa rõ → HỎI). Mốc thời gian: get_market_session.
B1. get_account_summary + get_portfolio_positions + get_order_history:
    → cash ratio tiểu khoản = balance / (balance + giá trị CK)
    → "khả dụng thực tế" = balance − tiền cam kết bởi lệnh mua treo; ghi chú tiền đang về T+
    → CÓ NỢ MARGIN → nêu TRƯỚC TIÊN (tiền mặt danh nghĩa đi cùng nợ = buffer thực mỏng/âm;
      "thừa tiền" chỉ có nghĩa sau khi nhìn nợ).
B2. get_asset_summary → 1 dòng bức tranh toàn Finhay (tiền + sản phẩm thanh khoản cao;
    ghi chú phạm vi toàn-user vs tiểu khoản).
B3. Đối chiếu 3 KHUNG THAM CHIẾU (mục 7) — chỉ ra vị trí, KHÔNG chọn khung hộ.
B4. Dựng 2–3 kịch bản cơ học gắn số thật (mục 7). (Tuỳ chọn: get_bank_interest_rates
    làm 1 dòng bối cảnh chi phí cơ hội.)
B5. Soạn output đúng khuôn 6 phần (references/output-template.md) — mục 5 BẮT BUỘC có
    "câu hỏi cần bạn tự trả lời". Tự kiểm checklist rồi mới gửi.
```

## 7. Khung tham chiếu & kịch bản (phần "trí tuệ" của skill)

**Ba khung tham chiếu cash ratio** (dải % tính trên tài sản đầu tư của tiểu khoản — **GIẢ ĐỊNH vận hành**, không phải chuẩn tư vấn, phải khai báo):

| Khung | Dải tiền mặt tham chiếu | Đặc trưng |
|---|---|---|
| Thận trọng (conservative) | ~20–40% | Ưu tiên đệm dày, chấp nhận đứng ngoài nhịp tăng |
| Cân bằng (balanced) | ~10–20% | Đệm vừa + vẫn tham gia thị trường |
| Chủ động (aggressive) | ~0–10% | Tối đa hoá exposure, chấp nhận không có đệm |

Quy tắc trình bày: chỉ ra **vị trí hiện tại của user trên dải** ("2,4% — nằm trong dải Chủ động, dưới dải Cân bằng 7,6 điểm %") — mô tả khoảng cách bằng số, **không phán khung nào đúng với user**. Ghi chú thông lệ (giả định): đệm chi tiêu khẩn cấp 3–6 tháng thường được khuyên để **ngoài** tài khoản đầu tư — nêu như thông lệ chung, không phán định cho trường hợp cụ thể.

**Kịch bản cơ học** (2–3 cái, gắn số thật, chỉ số học — không dự báo): (a) danh mục giảm X% → buffer hấp thụ thế nào, áp lực nợ margin nếu có; (b) cần tiền gấp Y đồng → thiếu bao nhiêu, phải bán CK và chờ T+ ra sao; (c) muốn giải ngân thêm Z → khả dụng thực tế còn lại.

## 8. Output format — khuôn 6 phần (chi tiết + golden example: [references/output-template.md](references/output-template.md))

1. 🕐 Thời điểm & phạm vi → 2. 📊 Bức tranh tiền mặt (balance/%, T+, tiền cam kết, nợ → **khả dụng thực tế**; 1 dòng toàn Finhay) → 3. ⚖️ Vị trí trên 3 khung tham chiếu (bảng + khoảng cách, không chọn hộ) → 4. 🧪 Kịch bản cơ học → 5. 📌 Giả định & ❓ câu hỏi cần bạn tự trả lời → 6. ➡️ Bước tiếp theo + disclaimer.

## 9. Guardrails

**Kế thừa toàn bộ bộ luật lõi G1–G10 từ [`finhay-guardrails`](../finhay-guardrails/SKILL.md)** (bề mặt Legal review duy nhất). Luật **RIÊNG** của workflow này:

1. **Không phán định suitability** (guardrail catalog, cụ thể hoá G5): không "nên giữ X%", không chọn khung hộ, không kết luận "nhiều quá/ít quá" như phán quyết — chỉ vị trí-trên-dải + khoảng cách bằng số. **Không gợi ý sản phẩm cụ thể để giải ngân tiền nhàn rỗi — kể cả sản phẩm Finhay** (CCQ/HayBond/tiết kiệm chỉ được nhắc như *danh mục đang có* trong asset summary, không phải như *gợi ý*).
2. **Nợ trước, tiền sau:** có nợ margin thì phân tích tiền mặt phải mở đầu bằng nợ (cụ thể hoá G1/G8 — tránh bức tranh "thừa tiền" giả tạo).
3. **Lãi suất tiền gửi chỉ là dữ kiện bối cảnh** — cấm suy ra "gửi tiết kiệm lợi hơn/kém hơn đầu tư" (so sánh đó là phán định rủi ro-lợi nhuận).
4. **Kịch bản là số học, không phải dự báo**: mọi kịch bản dùng chữ "nếu"; không gán xác suất, không chọn kịch bản "dễ xảy ra".
5. Mục "câu hỏi cần bổ sung" là **bắt buộc** trong mọi output (catalog yêu cầu) — thiếu nó là fail checklist.

## 10. Failure modes

| Tình huống | Hành vi bắt buộc |
|---|---|
| Thiếu `read:account` | Nói rõ cần cấp quyền + hướng dẫn reconnect; không bịa số |
| User ép "cứ nói tôi nên giữ bao nhiêu" | Guardrail #1 + thang quyết định G4: giải thích vì sao cần trả lời trước các câu hỏi ở mục 5; đưa lại 3 khung làm khung tự đối chiếu |
| Danh mục 100% tiền mặt / tài khoản mới | Không "phân tích ratio" vô nghĩa; mô tả trạng thái + câu hỏi bổ sung + handoff app nếu muốn bắt đầu |
| `get_order_history` lỗi / không có lệnh | Ghi rõ "lệnh treo: không có / không lấy được" — khả dụng thực tế = balance |
| Không lấy được asset summary | Phân tích trong phạm vi tiểu khoản, ghi rõ thiếu bức tranh toàn Finhay |
| User hỏi "vậy mua gì với tiền này" | Guardrail #1: từ chối gợi ý sản phẩm, câu hỏi tự đánh giá + handoff app Finhay |

## 11. Success criteria

- [ ] Đủ 6 phần; mục 2 có đủ 4 lớp: balance / T+ / tiền cam kết / nợ → "khả dụng thực tế".
- [ ] Có nợ margin → được nêu trước phần so khung.
- [ ] Bảng 3 khung + vị trí bằng số; KHÔNG có câu chọn khung hộ / "nên giữ X%" / gợi ý sản phẩm.
- [ ] 2–3 kịch bản gắn số thật, thuần số học ("nếu…").
- [ ] Mục ❓ câu hỏi cần bổ sung xuất hiện với ≥3 câu (khẩu vị, chi tiêu 3–6 tháng, thời hạn).
- [ ] Dải khung được khai báo là giả định; HayBond ghi đúng bản chất; kết bằng handoff + disclaimer.

## 12. Renders & sync

Xem [references/mcp-renders.md](references/mcp-renders.md): **1 dòng router** + **prompt `cash-allocation-advisor`** (không args; đồng thời là body `get_workflow_guide('cash-allocation-advisor')`). Bản ghép router đầy đủ: `finhay-stock-research/references/mcp-renders.md`.
