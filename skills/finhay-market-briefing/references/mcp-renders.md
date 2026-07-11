# MCP renders — bản phân phối của workflow `market-briefing-for-my-portfolio`

> **Nguồn sự thật là [SKILL.md](../SKILL.md) + output-template.md.** File này giữ các khối render để copy sang `vnsc-mcp-server` (nhánh `feature/memo`). Quy trình sync giống `finhay-portfolio-review/references/mcp-renders.md`.
>
> ~~Workflow này đánh dấu chuyển sang **Tier A hybrid**~~ **Cập nhật 2026-07-11: khi có workflow thứ 3 (`stock-research-brief`), INSTRUCTIONS đã chuyển hẳn Tier B** — block chi tiết `MARKET BRIEFING` (bản cũ của render này) đã được gỡ; bản đầy đủ giờ chính là Render 2 (prompt), đồng thời là body của `get_workflow_guide('market-briefing')`. Header router chung: xem `finhay-stock-research/references/mcp-renders.md` (Render 1).

## Render 1 — Dòng router thuộc workflow này trong INSTRUCTIONS (Tier B)

```
- market-briefing: "hôm nay có gì ảnh hưởng danh mục tôi", tin tức theo danh mục.
```

## Render 2 — MCP prompt `market-briefing` (đầy đủ)

**description:** `"Bản tin thị trường hôm nay theo danh mục của tôi: tin & sự kiện gắn với các mã đang nắm giữ, kèm watch-items. Chỉ đọc dữ liệu, không đặt lệnh."`

**generate() trả về:**

```
Hãy làm bản tin thị trường HÔM NAY theo danh mục của tôi: những tin tức, biến động và sự kiện
nào đang/sắp ảnh hưởng tới các mã tôi nắm giữ?

## Quy trình lấy dữ liệu (theo thứ tự, chỉ dùng tools read-only)
0. Nếu tôi chưa nói rõ tiểu khoản: hỏi tôi muốn xem tài khoản nào (thường / ký quỹ / openapi —
   gợi ý mặc định tài khoản thường), dùng CÙNG giá trị `account` cho mọi tool. Nếu tôi CHƯA cấp
   quyền dữ liệu tài khoản (không thấy tool danh mục): làm bản tin thị trường chung, NÓI RÕ
   đang ở chế độ chung và mời tôi kết nối danh mục.
1. get_market_session — phiên & mốc thời gian.
2. get_portfolio_positions — danh sách mã nắm giữ + tỷ trọng từng mã.
3. get_stock_news cho TẤT CẢ mã nắm giữ (gộp MỘT call qua tham số stocks, lọc ~7 ngày gần nhất)
   + get_stock_quote (gộp MỘT call qua symbols) — biến động trong ngày của từng mã.
4. Khi liên quan: get_index_quote (VNINDEX/VN30), get_user_rights (sự kiện quyền sắp tới của mã
   nắm giữ), get_economic_calendar (sự kiện 1–2 tuần tới), get_macro_data, get_global_news (chỉ
   khi danh mục nhạy với thị trường quốc tế).

## Quy tắc chọn lọc (quan trọng nhất — chống bản tin chung chung)
- CHỈ đưa tin/sự kiện map được về ít nhất 1 mã đang nắm giữ (hoặc nhóm ngành chiếm tỷ trọng lớn).
- Mỗi item bắt buộc: mã + tỷ trọng trong danh mục + 📊 fact (1–2 dòng, NGÀY ĐĂNG, nguồn)
  + 💡 vì sao đáng chú ý với vị thế này (cơ chế tác động — không phán đoán tương lai).
- Xếp hạng: tỷ trọng vị thế × mức trọng yếu. Tin đồn/chưa xác nhận → nhãn "chưa xác nhận",
  xếp cuối, không được là item đầu. Tối đa ~5 item chính.
- Mã nắm giữ biến động bất thường (±3%+ trong phiên — ngưỡng giả định) là một item kể cả khi
  chưa thấy tin: nêu fact + "chưa rõ nguyên nhân từ dữ liệu hiện có", không suy diễn.
- Không có tin trọng yếu nào → NÓI THẲNG điều đó (cũng là thông tin hữu ích), chỉ đưa
  watch-items. Cấm độn tin thị trường chung; bối cảnh chung tối đa 2–3 dòng.

## Trình bày kết quả — đúng 5 phần
1. 🕐 Thời điểm & phạm vi (giờ VN, phiên, tiểu khoản hoặc "bản tin chung", tools đã dùng)
2. 📈 Bối cảnh thị trường (2–3 dòng — chỉ mô tả, không dự báo)
3. 📰 Tin & sự kiện THEO MÃ NẮM GIỮ (mục chính, theo quy tắc chọn lọc trên)
4. 👀 Watch-items sắp tới (sự kiện quyền, lịch kinh tế, mốc theo dõi — mỗi cái 1 dòng)
5. 📌 Giả định & thiếu dữ liệu + ➡️ bước tiếp theo (gợi ý: "phân tích rủi ro danh mục" nếu muốn
   đánh giá tổng thể; muốn hành động → mở app Finhay, tôi không đặt lệnh trong workflow này)

## Ràng buộc bắt buộc
- Tách rõ 📊 dữ kiện / 💡 nhận định; mọi tin kèm ngày đăng + nguồn; mọi giá kèm thời điểm.
- KHÔNG dự báo hướng thị trường/giá; KHÔNG cam kết lợi nhuận; KHÔNG mệnh lệnh "nên mua/bán mã X";
  KHÔNG suy diễn quá nội dung tin.
- Kết thúc bằng đúng 1 dòng: "Thông tin mang tính tham khảo, không phải khuyến nghị đầu tư."
```

## Ghi chú test khi sync sang code

- `PromptService.test.ts`: số prompt = 4 (`market-briefing`, `market-overview`, `place-order`, `portfolio-review`); anchor prompt mới: "get_portfolio_positions", "get_stock_news", "5 phần", "chưa xác nhận", "không phải khuyến nghị đầu tư".
- `mcpServer.integration.test.ts`: instructions chứa "WORKFLOWS" + "MARKET BRIEFING" (và vẫn còn "PHÂN TÍCH DANH MỤC", "GIAO DỊCH = TIỀN THẬT", "COMPLIANCE"); prompts/list = 4.
- Ngân sách INSTRUCTIONS sau khi thêm: ≤ ~50 dòng.
