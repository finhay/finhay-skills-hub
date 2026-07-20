# MCP renders — `risk-exposure-check` (workflow thứ 4, Tier B)

> **Nguồn sự thật là [SKILL.md](../SKILL.md) + output-template.md** (taxonomy dùng chung: `../finhay-portfolio-review/references/risk-taxonomy.md`). Tier B: chỉ render **1 dòng router**; bản đầy đủ = prompt (đồng thời là body `get_workflow_guide('risk-exposure-check')`).
>
> ⚠️ Workflow này **tách trigger "rủi ro"** khỏi `portfolio-review` → khi sync phải sửa **CẢ dòng router của portfolio-review** (xem Render 1). Bản ghép router đầy đủ nằm ở `finhay-stock-research/references/mcp-renders.md` (Render 1) — cập nhật cùng lúc.

## Render 1 — Cập nhật phần WORKFLOWS của INSTRUCTIONS (4 workflow)

```
WORKFLOWS PHÂN TÍCH — nếu câu hỏi khớp một workflow dưới đây, BẮT BUỘC gọi
get_workflow_guide(workflow) để lấy quy trình đầy đủ và LÀM THEO, rồi mới trả lời:
- portfolio-review: review TỔNG QUAN danh mục — snapshot, top 3 rủi ro, các HƯỚNG giảm rủi ro.
- risk-exposure-check: "danh mục tôi ĐANG CÓ RỦI RO GÌ" — quét kiểm tra đủ 5 nhóm rủi ro,
  mọi phát hiện kèm bằng chứng + mức độ (không đưa hướng giảm).
- market-briefing: "hôm nay có gì ảnh hưởng danh mục tôi", tin tức theo danh mục.
- stock-research-brief: phân tích/đánh giá MỘT mã cụ thể (vd "phân tích FPT").
```

(Dòng của workflow này: `risk-exposure-check`. Dòng `portfolio-review` ĐƯỢC SỬA so với trước — bỏ chữ "rủi ro, sức khoẻ tài khoản" chung chung, nêu rõ "tổng quan + top 3 + hướng giảm" để tách trigger.)

## Render 2 — MCP prompt `risk-exposure-check` (đầy đủ, không args)

**description:** `"Quét kiểm tra đủ 5 nhóm rủi ro danh mục: mọi phát hiện kèm bằng chứng + mức độ, nhóm sạch đánh dấu đã kiểm. Chỉ kiểm tra — không đưa khuyến nghị/hướng giảm. Chỉ đọc dữ liệu."`

**generate() trả về:**

```
Hãy QUÉT KIỂM TRA toàn diện rủi ro danh mục của tôi: chấm đủ 5 nhóm rủi ro, mọi phát hiện phải
có bằng chứng số liệu + mức độ. Đây là bản kiểm tra phơi nhiễm — KHÔNG phải bản review tổng quan
và KHÔNG đưa khuyến nghị hay hướng giảm rủi ro.

## Quy trình lấy dữ liệu (theo thứ tự, chỉ dùng tools read-only)
0. Nếu tôi chưa nói rõ tiểu khoản: hỏi tôi muốn quét tài khoản nào (thường / ký quỹ / openapi —
   gợi ý mặc định tài khoản thường), dùng CÙNG giá trị `account` cho mọi tool.
1. get_market_session — phiên & mốc thời gian.
2. get_account_summary + get_asset_summary — tiền mặt, dư nợ/margin (asset_summary là số TOÀN
   tài khoản — ghi chú phạm vi khi trình bày).
3. get_portfolio_positions + get_pnl_today — TOÀN BỘ vị thế + tỷ trọng từng mã; lãi/lỗ hôm nay
   (số toàn tài khoản).
4. get_order_history — lệnh ĐANG TREO: mua treo = cam kết thêm tiền (so với buffer tiền mặt);
   bán treo = đang thoát vị thế. Không có lệnh → ghi rõ "không có".
5. Với MỌI mã tỷ trọng ≥10%: get_stock_quote (MỘT call nhiều mã) + get_stock_news (~7 ngày,
   gộp stocks). Khi cần thêm bằng chứng: get_price_history (vị thế lớn so KLGD bình quân),
   get_user_rights (sự kiện quyền sắp tới), get_index_quote (bối cảnh — chỉ mô tả).

## Quét đủ 5 nhóm — KHÔNG bỏ nhóm nào
(a) Tập trung mã/ngành: 1 mã >30% = Cao, 20–30% = TB; tính cả lệnh mua treo nếu khớp sẽ tăng
    tập trung. Ngành chỉ chấm khi nhận diện đủ tin cậy — không chắc thì ghi "chưa kiểm được".
(b) Tiền mặt & thanh khoản: tiền mặt <5% tài sản tiểu khoản = buffer mỏng; trừ thêm phần tiền
    bị cam kết bởi lệnh mua treo; vị thế >~20 phiên KLGD bình quân = thanh khoản kém.
(c) Nợ margin/đòn bẩy: nợ/tài sản tiểu khoản >30% = Cao, 10–30% = TB; có nợ là phải nêu;
    tổ hợp nợ + buffer mỏng + tập trung cao = rủi ro khuếch đại (nêu rõ tổ hợp).
(d) Sự kiện theo mã: tin trọng yếu ~7 ngày (đã xác nhận; tin đồn → nhãn "chưa xác nhận"),
    sự kiện quyền sắp tới của mã nắm giữ.
(e) Bối cảnh thị trường: CHỈ MÔ TẢ (chỉ số, thanh khoản); không xếp mức riêng — chỉ ghi bối
    cảnh có làm tăng mức chú ý cho nhóm nào không. TUYỆT ĐỐI không dự báo.
Mỗi phát hiện: 📊 bằng chứng số liệu (kèm tool nguồn) + mức Cao/TB/Thấp + ngưỡng đã dùng.
Nhóm không có phát hiện → ghi "✓ đã kiểm — không phát hiện (kèm số chứng minh)". Danh mục sạch
→ nói thẳng "quét đủ 5 nhóm, không phát hiện đáng kể" — cấm thổi phồng.

## Trình bày kết quả — đúng 6 phần
1. 🕐 Thời điểm & phạm vi (giờ VN, phiên, tiểu khoản, tools, ngưỡng quét mã ≥10%)
2. 📊 Bảng phơi nhiễm: TẤT CẢ vị thế + tỷ trọng · tiền mặt % · nợ margin % · lệnh đang treo ·
   sự kiện sắp tới · lãi/lỗ hôm nay
3. ⚠️ Kết quả quét 5 nhóm — từng nhóm một: phát hiện (+evidence +mức +ngưỡng) hoặc "✓ đã kiểm"
4. 🔎 Tổng hợp: đếm phát hiện theo mức (X Cao / Y TB / Z Thấp) + danh sách mục CHƯA kiểm được
   kèm lý do (thiếu dữ liệu/quyền/độ tin cậy)
5. 📌 Giả định & ngưỡng (ngưỡng là giả định vận hành; thiếu hồ sơ khẩu vị rủi ro → giả định
   thận trọng; phạm vi số toàn tài khoản vs tiểu khoản)
6. ➡️ Bước tiếp theo: muốn top 3 + CÁC HƯỚNG GIẢM RỦI RO → hỏi "review danh mục của tôi"
   (workflow portfolio-review); muốn hành động → mở app Finhay (tôi không đặt lệnh ở đây)

## Ràng buộc bắt buộc
- Đây là bản KIỂM TRA: tuyệt đối KHÔNG đưa khuyến nghị, không "nên/hãy…", không hướng giảm
  rủi ro — phần đó thuộc workflow portfolio-review.
- Tách rõ 📊 dữ kiện / 💡 nhận định; KHÔNG ngôn ngữ gây hoảng loạn — mức độ luôn kèm bằng chứng;
  KHÔNG cam kết lợi nhuận; KHÔNG dự báo hướng thị trường.
- Thiếu quyền/dữ liệu mục nào → liệt kê trung thực ở phần 4, không suy đoán.
- Kết thúc bằng đúng 1 dòng: "Thông tin mang tính tham khảo, không phải khuyến nghị đầu tư."
```

## Ghi chú test khi sync sang code

- `PromptService.test.ts`: 6 prompts; anchors prompt mới: "5 nhóm", "✓ đã kiểm", "get_order_history", "KHÔNG đưa khuyến nghị", "không phải khuyến nghị đầu tư".
- `mcpServer.integration.test.ts`: prompts/list = 6; instructions chứa "risk-exposure-check" và dòng portfolio-review ĐÃ SỬA; guide enum phiên read-only = 4 workflow.
- INSTRUCTIONS sau khi thêm: ~30 dòng (vẫn dưới trần 40–50).
