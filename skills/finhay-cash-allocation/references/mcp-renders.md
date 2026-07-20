# MCP renders — `cash-allocation-advisor` (workflow thứ 5, Tier B)

> **Nguồn sự thật là [SKILL.md](../SKILL.md) + output-template.md.** Tier B: chỉ render **1 dòng router**; bản đầy đủ = prompt (đồng thời là body `get_workflow_guide('cash-allocation-advisor')`). Bản ghép router đầy đủ: `finhay-stock-research/references/mcp-renders.md` (Render 1) — cập nhật cùng lúc.

## Render 1 — Dòng router thuộc workflow này trong INSTRUCTIONS

```
- cash-allocation-advisor: "tiền mặt của tôi nhiều/ít quá không", nên giữ bao nhiêu tiền mặt,
  tiền nhàn rỗi trong tài khoản.
```

## Render 2 — MCP prompt `cash-allocation-advisor` (đầy đủ, không args)

**description:** `"Phân tích tiền mặt tài khoản: bức tranh thật (T+, lệnh treo, nợ margin), vị trí trên 3 khung tham chiếu, kịch bản số học và câu hỏi cần tự trả lời. Không phán định mức nên giữ, không gợi ý sản phẩm. Chỉ đọc dữ liệu."`

**generate() trả về:**

```
Hãy phân tích TIỀN MẶT trong tài khoản đầu tư của tôi: đang ở đâu so với các khung tham chiếu,
và tôi cần tự trả lời những câu hỏi nào để chọn mức phù hợp. Đây là phân tích cấu trúc tiền mặt
— KHÔNG phải khuyến nghị phân bổ và KHÔNG gợi ý sản phẩm.

## Quy trình lấy dữ liệu (theo thứ tự, chỉ dùng tools read-only)
0. Nếu tôi chưa nói rõ tiểu khoản: hỏi (thường / ký quỹ / openapi — gợi ý mặc định tài khoản
   thường), dùng CÙNG giá trị `account` cho mọi tool.
1. get_market_session — phiên & mốc thời gian.
2. get_account_summary — tiền mặt (balance), tiền đang về (receiving t1/t2/t3), dư nợ margin.
3. get_portfolio_positions — tổng giá trị chứng khoán (mẫu số của cash ratio tiểu khoản).
4. get_order_history — lệnh MUA đang treo = tiền đã cam kết (trừ khỏi "khả dụng thực tế");
   không có lệnh → ghi rõ "không có".
5. get_asset_summary — bức tranh toàn Finhay: tiền + CCQ + tiết kiệm + HayBond (LƯU Ý:
   products.bond là HayBond, KHÔNG phải trái phiếu truyền thống) — số TOÀN tài khoản, ghi chú
   phạm vi khi trình bày.
6. Tuỳ chọn: get_bank_interest_rates — lãi suất tiền gửi làm bối cảnh chi phí cơ hội,
   CHỈ nêu như dữ kiện (cấm suy ra "gửi lợi hơn/kém hơn đầu tư").

## Cách tính & khung đối chiếu
- Cash ratio tiểu khoản = balance / (balance + giá trị CK). Khả dụng thực tế = balance − tiền
  cam kết bởi lệnh mua treo (+ ghi chú tiền T+ đang về).
- CÓ NỢ MARGIN → nêu TRƯỚC TIÊN, ngay sau balance: tiền mặt danh nghĩa đi cùng nợ nghĩa là
  buffer thực mỏng hơn — "thừa tiền" chỉ có nghĩa sau khi nhìn nợ.
- Đối chiếu 3 KHUNG THAM CHIẾU (dải % là GIẢ ĐỊNH vận hành, phải khai báo ở phần 5):
  Thận trọng ~20–40% · Cân bằng ~10–20% · Chủ động ~0–10% (trên tài sản đầu tư tiểu khoản).
  CHỈ chỉ ra vị trí + khoảng cách bằng số ("2,4% — trong dải Chủ động; cách mép dưới dải Cân
  bằng 7,6 điểm %, tương đương ~X tiền"). TUYỆT ĐỐI không chọn khung hộ, không "nên giữ X%",
  không kết luận "nhiều quá/ít quá" như phán quyết — tôi chưa có hồ sơ khẩu vị rủi ro của bạn.
- Thông lệ chung (nêu như giả định, không phán định): đệm chi tiêu khẩn cấp 3–6 tháng thường
  được khuyên để NGOÀI tài khoản đầu tư.

## Kịch bản minh hoạ — thuần số học "nếu…", không dự báo, không gán xác suất
Chọn 2–3 kịch bản gắn số thật: (a) danh mục giảm 10% → tài sản/nợ/buffer thay đổi thế nào;
(b) cần tiền gấp Y đồng → khả dụng thực tế + T+ đủ/thiếu, phải bán ~bao nhiêu CK; (c) muốn
giải ngân thêm Z → khả dụng còn lại.

## Trình bày kết quả — đúng 6 phần
1. 🕐 Thời điểm & phạm vi (giờ VN, phiên, tiểu khoản, tools)
2. 📊 Bức tranh tiền mặt: balance + % · tiền đang về T+ · tiền cam kết (lệnh treo) · nợ margin
   (nếu có — đứng ngay sau balance) → "khả dụng thực tế"; 1 dòng toàn Finhay (ghi chú phạm vi)
3. ⚖️ Bảng 3 khung tham chiếu + vị trí của tôi bằng số + khoảng cách; KHÔNG chọn khung hộ
   (kèm 1 dòng bối cảnh lãi suất tiền gửi nếu đã gọi — thuần dữ kiện)
4. 🧪 Kịch bản minh hoạ (2–3 kịch bản "nếu…" gắn số thật)
5. 📌 Giả định & ❓ CÂU HỎI CẦN TÔI TỰ TRẢ LỜI (bắt buộc, ≥3 câu): khẩu vị rủi ro / mức sụt
   giảm chấp nhận được? khoản chi lớn 3–6 tháng tới? thời hạn đầu tư? đệm ngoài tài khoản?
6. ➡️ Bước tiếp theo: trả lời các câu hỏi trên → lần sau đối chiếu sát hơn; review tổng thể →
   portfolio-review; quét rủi ro → risk-exposure-check; hành động (nạp/rút/giải ngân) → mở app
   Finhay (tôi không thực hiện thay)

## Ràng buộc bắt buộc
- KHÔNG khuyến nghị suitability khi chưa có hồ sơ khẩu vị: không "nên giữ X%", không chọn khung
  hộ, KHÔNG gợi ý sản phẩm cụ thể để giải ngân tiền nhàn rỗi — kể cả sản phẩm Finhay (CCQ/
  HayBond/tiết kiệm chỉ nhắc như danh mục đang có, không phải gợi ý).
- Không hướng dẫn mua/bán trực tiếp; tách rõ 📊 dữ kiện / 💡 nhận định; không cam kết lợi nhuận;
  không dự báo thị trường; HayBond ghi đúng là HayBond.
- Thiếu quyền/dữ liệu → nói rõ thiếu gì, không suy đoán.
- Kết thúc bằng đúng 1 dòng: "Thông tin mang tính tham khảo, không phải khuyến nghị đầu tư."
```

## Ghi chú test khi sync sang code

- `PromptService.test.ts`: 7 prompts; anchors prompt mới: "3 KHUNG", "khả dụng thực tế", "get_bank_interest_rates", "không chọn khung hộ"/"KHÔNG gợi ý sản phẩm", "CÂU HỎI CẦN TÔI TỰ TRẢ LỜI", "không phải khuyến nghị đầu tư".
- `mcpServer.integration.test.ts`: prompts/list = 7; instructions chứa "cash-allocation-advisor"; guide enum phiên read-only = 5 workflow.
- INSTRUCTIONS sau khi thêm: ~31 dòng (trần 40–50).
