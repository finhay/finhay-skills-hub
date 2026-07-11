# Output template — khuôn 6 phần (bắt buộc)

> Dùng ở bước B4. Tiếng Việt đời thường; VND viết gọn; % 1 chữ số thập phân; **mọi số liệu tài chính kèm kỳ báo cáo, mọi giá kèm thời điểm, mọi tin/báo cáo kèm ngày + nguồn**.

## Khuôn

```
## 🕐 1. Thời điểm & nguồn
- <giờ VN, ngày> — <trạng thái phiên>. Kỳ BCTC mới nhất có được: <vd Q1/2026>.
- Dữ liệu từ: <tools đã gọi>.

## 📊 2. Snapshot giá <MÃ>
📊 <giá hiện tại (thời điểm)> · <±% hôm nay / 1 tuần / ${period}> · KLGD hôm nay vs bình quân
· <tương quan VNINDEX cùng kỳ nếu có — chỉ mô tả>

## 🏢 3. Nền tảng doanh nghiệp
| Chỉ tiêu | Giá trị | Kỳ |
|---|---|---|
| Doanh thu | … | Qx/20xx |
| LN sau thuế / biên | … | Qx/20xx |
| Nợ/VCSH | … | Qx/20xx |
| ROE | … | (4 quý gần nhất) |
📊 1–2 dòng diễn giải xu hướng các con số (so cùng kỳ) — không suy đoán tương lai.

## 📰 4. Tin tức & khuyến nghị bên thứ ba
- Tin (~14 ngày): <ngày — tiêu đề/ý chính (nguồn)> …
- Báo cáo CTCK (ý kiến của bên thứ ba, không phải của trợ lý):
  <CTCK X (dd/mm): khuyến nghị Y, giá mục tiêu Z> · <báo cáo >3 tháng → ghi rõ tuổi>
  (Không có báo cáo/tin → nói thẳng "chưa có trong dữ liệu".)

## ⚖️ 5. Điểm mạnh / Điểm cần lưu ý (mỗi ý kèm số dẫn chứng)
💡 Điểm mạnh: • <ý + số + kỳ> • …   (2–4 ý)
💡 Điểm cần lưu ý: • <ý + số + kỳ> • …   (2–4 ý — BẮT BUỘC có, không tô hồng)
<Mã ít thanh khoản / mới niêm yết / dữ liệu mỏng → nêu đầu tiên ở đây.>

## 📌 6. Giả định & thiếu dữ liệu · ➡️ Bước tiếp theo
- <mảng thiếu: BCTC trễ, không có báo cáo CTCK…; period tham chiếu là giả định>
- <nếu user đang nắm giữ mã (và đã có quyền): 1 dòng vị thế + gợi ý "phân tích rủi ro danh mục">
- Câu hỏi để bạn tự đánh giá: khẩu vị rủi ro? tỷ trọng dự kiến? thời hạn nắm giữ?
- Muốn giao dịch: mở app Finhay — trợ lý không đặt lệnh trong workflow này.

*Thông tin mang tính tham khảo, không phải khuyến nghị đầu tư.*
```

## Golden example (dữ liệu giả lập — đối chiếu giọng điệu & cấu trúc)

Bối cảnh giả lập: user hỏi "phân tích FPT"; phiên liên tục 11/07/2026; FPT 128.500đ +1,2% hôm nay, +18,4% 6 tháng; BCTC Q1/2026: doanh thu 15.720 tỷ (+21% yoy), biên LN gộp 38,2%, ROE 4 quý 27,3%, nợ/VCSH 0,45; 2 báo cáo CTCK; 1 tin trúng thầu 09/07.

```
## 🕐 1. Thời điểm & nguồn
- 11:02 11/07/2026 — phiên khớp lệnh liên tục (HOSE). Kỳ BCTC mới nhất có được: Q1/2026.
- Dữ liệu từ: market_session, stock_quote, price_history, company_overview,
  financial_analysis, stock_news, recommendation_reports.

## 📊 2. Snapshot giá FPT
📊 128.500đ (11:02) · +1,2% hôm nay · +18,4% trong 6 tháng · KLGD hôm nay ~1,1 triệu CP,
xấp xỉ bình quân 20 phiên · cùng kỳ VNINDEX +9,1% (FPT đi nhanh hơn chỉ số — mô tả, không dự báo).

## 🏢 3. Nền tảng doanh nghiệp
| Chỉ tiêu | Giá trị | Kỳ |
|---|---|---|
| Doanh thu | 15.720 tỷ ₫ (+21,0% yoy) | Q1/2026 |
| Biên LN gộp | 38,2% | Q1/2026 |
| ROE | 27,3% | 4 quý gần nhất |
| Nợ/VCSH | 0,45 | Q1/2026 |
📊 Doanh thu tăng trưởng hai chữ số 5 quý liên tiếp; biên gộp ổn định quanh 38%.

## 📰 4. Tin tức & khuyến nghị bên thứ ba
- Tin: 09/07 — FPT công bố trúng gói thầu chuyển đổi số X (stock_news).
- Báo cáo CTCK (ý kiến bên thứ ba, không phải của trợ lý):
  · CTCK A (02/07/2026): KHẢ QUAN, giá mục tiêu 145.000đ.
  · CTCK B (18/06/2026): TRUNG LẬP, giá mục tiêu 131.000đ.

## ⚖️ 5. Điểm mạnh / Điểm cần lưu ý
💡 Điểm mạnh: • Tăng trưởng doanh thu +21% yoy (Q1/2026) • ROE 27,3% (4 quý) thuộc nhóm cao
• Đòn bẩy vừa phải (nợ/VCSH 0,45 — Q1/2026).
💡 Điểm cần lưu ý: • Giá đã tăng 18,4%/6 tháng — nhanh hơn chỉ số đáng kể, kỳ vọng đã phản ánh
một phần vào giá • Hai báo cáo CTCK gần nhất lệch quan điểm (Khả quan vs Trung lập) — thị trường
chưa đồng thuận • Định giá hiện tại cao hơn giá mục tiêu của CTCK B (131.000đ, 18/06).

## 📌 6. Giả định & thiếu dữ liệu · ➡️ Bước tiếp theo
- Khung tham chiếu 6 tháng là mặc định; BCTC Q2/2026 chưa công bố.
- Câu hỏi để bạn tự đánh giá: khẩu vị rủi ro? tỷ trọng dự kiến trong danh mục? thời hạn nắm giữ?
- Bạn đang nắm giữ FPT và muốn xem nó trong bức tranh danh mục: hỏi "phân tích rủi ro danh mục".
- Muốn giao dịch: mở app Finhay — mình không đặt lệnh trong workflow này.

*Thông tin mang tính tham khảo, không phải khuyến nghị đầu tư.*
```

## Checklist tự kiểm trước khi gửi (bắt buộc pass 100%)

- [ ] Đúng 6 phần; có timestamp + phiên + kỳ BCTC mới nhất.
- [ ] Mọi số ở phần 3 có kỳ báo cáo; phần 2 giá có thời điểm; phần 4 tin/báo cáo có ngày + tên tổ chức.
- [ ] Phần 4 ghi rõ khuyến nghị là "ý kiến bên thứ ba"; không tính trung bình giá mục tiêu; báo cáo cũ ghi tuổi.
- [ ] Phần 5 có CẢ hai phía, mỗi ý một con số; mã thanh khoản thấp/dữ liệu mỏng được nêu đầu.
- [ ] KHÔNG có: giá mục tiêu tự đưa · dự báo hướng giá · "nên mua/bán" · so sánh mã khác không số liệu.
- [ ] Kết bằng câu hỏi tự đánh giá + handoff app Finhay + disclaimer.
