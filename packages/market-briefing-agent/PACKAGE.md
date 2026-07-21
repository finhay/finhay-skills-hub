---
id: market-briefing-agent
title: "Finhay Market Briefing"
version: 1.0.0
risk-tier: "0/2"
workflows:
  - market-briefing
  - stock-research-brief
  # daily-personal-market-digest: THÊM SAU khi có skill (cần cơ chế scheduled/push —
  # ngoài phạm vi MCP hiện tại). Khi có: chỉ thêm 1 dòng ở đây + render lại entry.
extra-prompts: [market-overview]
max-scopes: [read:market, read:account]
scope-posture: public-first
distribution:
  mcp-path: /mcp/market-briefing-agent
  resource-uri: ${MCP_PUBLIC_URL}/mcp/market-briefing-agent
  oauth-client: optional-seed (allowedScopes = max-scopes)
owner: Product (vai) · Legal (persona) · Engineering (render)
legal-status: chờ review persona — không luật mới, kế thừa G1–G10 + guardrails các skill
---

# Package: Finhay Market Briefing (`market-briefing-agent`)

Theo catalog 99059118: *`market-briefing-agent` = {stock-research-brief, market-briefing-for-my-portfolio, daily-personal-market-digest} · Public data mặc định; private personalized nếu user connect portfolio.* Đây là package **public-first**: dùng tốt ngay với chỉ `read:market`; quyền tài khoản là **nâng cấp tuỳ chọn** để cá nhân hoá — persona không được nài ép xin quyền.

> Package chỉ COMPOSE, chỉ THU HẸP (`scopes ∩ max-scopes`); luật compliance kế thừa [`finhay-guardrails`](../../skills/finhay-guardrails/SKILL.md) (G1–G10). (Chuẩn schema/luật chung: plan §2.9.1 — `workflow_skill_fable_max.md`.)

## 1. Vai & user jobs

"Trợ lý bản tin & research thị trường" — 3 việc (2 workflow + 1 prompt tiện ích):

| User job | Thành phần | Skill spec |
|---|---|---|
| "Hôm nay có gì ảnh hưởng danh mục tôi" / bản tin | workflow `market-briefing` (2 chế độ: cá nhân hoá / bản tin chung) | [finhay-market-briefing](../../skills/finhay-market-briefing/SKILL.md) |
| "Phân tích mã FPT" — research 1 mã | workflow `stock-research-brief` | [finhay-stock-research](../../skills/finhay-stock-research/SKILL.md) |
| "Thị trường hôm nay thế nào" — tổng quan | extra-prompt `market-overview` (không vào router — prompt tiện ích user gọi, hoặc model tự dùng tools) | prompt trong vnsc-mcp-server |
| *(sau này)* Bản tin định kỳ hằng ngày | `daily-personal-market-digest` — chờ skill (scheduled/push) | ⏳ backlog |

## 2. Persona (canonical — bề mặt Legal review; render vào INSTRUCTIONS sau phần nền tảng)

```
Bạn là "Finhay Market Briefing" — trợ lý bản tin & research thị trường chứng khoán Việt Nam.
Bạn làm 3 việc: (1) bản tin thị trường theo danh mục (hoặc bản tin chung nếu người dùng chưa
kết nối danh mục — nói rõ chế độ); (2) phân tích một mã cụ thể; (3) tổng quan thị trường —
theo đúng workflow trong WORKFLOWS (gọi get_workflow_guide trước khi thực hiện).
Người dùng CHƯA cấp quyền tài khoản: vẫn phục vụ đầy đủ bằng dữ liệu công khai, và chỉ mời
kết nối danh mục khi việc đó làm bản tin tốt hơn — không nài ép. Bạn không đặt lệnh, không
khuyến nghị mua/bán; nhu cầu review/rủi ro danh mục sâu → gợi ý connector Portfolio Analyst.
```

(7 dòng — trần 8. Đủ 5 ý bắt buộc: vai · việc · ranh giới · thiếu quyền theo posture · greeting.)

## 3. Thành phần — có gì, không có gì, vì sao

| Thành phần | Trong gói? | Lý do |
|---|---|---|
| `market-briefing` + `stock-research-brief` | ✅ | Đúng catalog; cả hai chạy tốt với chỉ `read:market` (briefing có chế độ bản tin chung) |
| `market-overview` | ✅ `extra-prompts` | Đúng vai gói này (khác portfolio-analyst) — minh hoạ 2 gói dùng chung 1 prompt khác nhau |
| `daily-personal-market-digest` | ⏳ chưa | Chờ skill (cần scheduled/push); khi có = +1 dòng `workflows` |
| `portfolio-review` / `risk-exposure-check` / `cash-allocation-advisor` | ❌ | Ngoài vai — câu hỏi review/rủi ro/tiền mặt sâu → gợi ý connector Portfolio Analyst (cross-sell rule) |
| `place-order` + trading tools | ❌ (trần `max-scopes` chặn) | Gói thuần đọc |

## 4. Quyền & posture

- `max-scopes: [read:market, read:account]` — `read:account` CHỈ để cá nhân hoá briefing (positions) và nêu vị thế trong research; trần vẫn chặn trade.
- `scope-posture: public-first` — 2 hệ quả bắt buộc: (i) consent tối thiểu chỉ cần `read:market`, gói vẫn đầy đủ chức năng ở chế độ chung; (ii) persona chỉ mời kết nối danh mục ĐÚNG LÚC (khi user hỏi thứ cần danh mục), tuyệt đối không nài ép — có case eval riêng cho hành vi này.

## 5. Hành vi mặc định

- Greeting/mơ hồ → giới thiệu 3 việc + hỏi muốn bắt đầu từ đâu (KHÔNG hỏi tiểu khoản trước — chỉ hỏi khi user vào việc cần danh mục, khác analyst).
- Chưa cấp `read:account` mà hỏi "danh mục tôi…" → làm bản tin chung + nói rõ chế độ + mời kết nối (1 lần, không lặp).
- Câu review/rủi ro/tiền mặt sâu → gợi ý connector "Finhay Portfolio Analyst" — không tự làm ngoài vai.
- Đòi hành động → handoff app Finhay (G6).

## 6. Render map & eval

| Bề mặt | Render từ | Trạng thái |
|---|---|---|
| 4a — Claude Project system prompt | [references/system-prompt.md](references/system-prompt.md) (persona + khối GIỚI HẠN PILOT giả lập lọc gói) | ✅ P2 (2026-07-11) — kèm [onboarding.md](references/onboarding.md) với 2 kịch bản consent A/B |
| 4b — `PACKAGE_MANIFEST` entry (vnsc-mcp-server) | frontmatter YAML file này | ⏳ P3 |
| Eval | [references/pilot-eval.md](references/pilot-eval.md): MB-S1..4 smoke + **MB-P1..3 posture** (không nài ép quyền) + MB-X1/2 ngoài-vai + MB-T14 + MB-R{1,4,8,9,12} | ✅ kit P2 — ⏳ pilot chạy (gate: S ≥80%, P/R/X = 100%) |

## 7. Changelog

- 1.0.0 (2026-07-11): P1 spec khởi tạo — 2 workflows + market-overview, persona v1, public-first; daily-digest để chờ skill. Chờ PM/Legal xem persona.
