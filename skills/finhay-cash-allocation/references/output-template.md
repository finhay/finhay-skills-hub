# Output template — khuôn 6 phần (bắt buộc)

> Dùng ở bước B5. Nguyên tắc sống còn: **hữu ích mà không phán định** — vị trí trên dải bằng số, không "nên giữ X%", không chọn khung hộ, không gợi ý sản phẩm. VND viết gọn; % 1 chữ số thập phân.

## Khuôn

```
## 🕐 1. Thời điểm & phạm vi
- <giờ VN, ngày> — <trạng thái phiên>. Tiểu khoản: <thường|ký quỹ|OpenAPI>.
- Dữ liệu từ: <tools đã gọi>.

## 📊 2. Bức tranh tiền mặt
📊 Dữ kiện (tiểu khoản):
- Tiền mặt (balance): <B> — <b>% tài sản đầu tư tiểu khoản (balance + giá trị CK).
- Tiền đang về (T+): <R> (receiving t1/t2/t3) — dùng được sau <n> phiên.
- Tiền đã cam kết: <C> (lệnh MUA đang treo: <chi tiết>) — hoặc "không có".
- Nợ margin: <D> (<d>%) — CÓ NỢ thì dòng này đứng NGAY SAU balance, kèm 💡 1 câu:
  "tiền mặt danh nghĩa đi cùng nợ nghĩa là buffer thực mỏng hơn con số <B>".
→ Khả dụng thực tế ≈ <B − C> (chưa tính T+ đang về).
- Toàn Finhay (số toàn tài khoản — ghi chú phạm vi): tiền <…> + CCQ <…> + tiết kiệm <…>
  + HayBond <…> (HayBond, không phải trái phiếu truyền thống).

## ⚖️ 3. Vị trí trên 3 khung tham chiếu (dải % là GIẢ ĐỊNH vận hành — xem mục 5)
| Khung | Dải tiền mặt | Vị trí của bạn |
|---|---|---|
| Thận trọng | ~20–40% | <so sánh bằng số> |
| Cân bằng | ~10–20% | <…> |
| Chủ động | ~0–10% | <vd "2,4% — NẰM TRONG dải này"> |
💡 <1–2 câu mô tả khoảng cách bằng số — vd "để chạm mép dưới dải Cân bằng (10%) cần thêm ~X
tiền mặt hoặc giảm ~Y giá trị CK". KHÔNG kết luận khung nào đúng với bạn.>
(Bối cảnh — dữ kiện, nếu đã gọi: lãi suất tiền gửi 12T quanh <r>%/năm theo bank_interest_rates.)

## 🧪 4. Kịch bản minh hoạ (số học "nếu…", không phải dự báo)
- Nếu danh mục giảm 10%: <tác động lên tài sản, buffer, nợ margin nếu có — bằng số>.
- Nếu cần gấp <Y> đồng: <khả dụng thực tế thiếu/đủ; phải bán ~Z CK và chờ T+n>.
- Nếu muốn giải ngân thêm <Z>: <khả dụng còn lại sau lệnh treo>.

## 📌 5. Giả định & ❓ câu hỏi cần bạn tự trả lời   ← BẮT BUỘC
- Giả định: dải 3 khung là giả định vận hành (không phải chuẩn tư vấn); chưa có hồ sơ khẩu vị
  rủi ro; <phạm vi số toàn Finhay vs tiểu khoản; thông lệ đệm 3–6 tháng nằm ngoài tài khoản đầu tư>.
- ❓ Để tự chọn khung phù hợp, bạn cần trả lời: (1) Khẩu vị rủi ro — mức sụt giảm tối đa chấp
  nhận được? (2) 3–6 tháng tới có khoản chi lớn nào cần rút từ tài khoản này? (3) Thời hạn đầu
  tư dự kiến? (4) Ngoài tài khoản này có đệm tiền mặt/nguồn thu khác không?

## ➡️ 6. Bước tiếp theo
- Trả lời 4 câu hỏi trên → lần phân tích sau đối chiếu khung sát hơn.
- Muốn nhìn tổng thể: "review danh mục của tôi" (portfolio-review) · quét rủi ro đầy đủ:
  "danh mục tôi đang có rủi ro gì" (risk-exposure-check).
- Muốn hành động (nạp/rút, giải ngân, huỷ lệnh treo): mở app Finhay — trợ lý không thực hiện thay.

*Thông tin mang tính tham khảo, không phải khuyến nghị đầu tư.*
```

## Golden example (dữ liệu giả lập — đối chiếu giọng điệu & cấu trúc)

Bối cảnh giả lập: tiểu khoản thường; CK 480tr; balance 12tr; receiving_t2 8tr; lệnh MUA treo 1,35tr; nợ margin 85tr; toàn Finhay: tiền 15tr + CCQ 40tr + HayBond 25tr; lãi suất tiền gửi 12T ~5,3%/năm.

```
## 🕐 1. Thời điểm & phạm vi
- 10:45 11/07/2026 — phiên khớp lệnh liên tục (HOSE). Tiểu khoản: thường (.1).
- Dữ liệu từ: market_session, account_summary, portfolio_positions, order_history,
  asset_summary, bank_interest_rates.

## 📊 2. Bức tranh tiền mặt
📊 Dữ kiện (tiểu khoản thường):
- Tiền mặt: 12 triệu ₫ — 2,4% tài sản đầu tư tiểu khoản (12tr + 480tr CK).
- Nợ margin: 85 triệu ₫ (17,3%). 💡 Tiền mặt danh nghĩa đi cùng nợ: buffer thực mỏng hơn
  nhiều con số 12tr — bức tranh "tiền nhàn rỗi" cần nhìn qua lăng kính nợ trước.
- Tiền đang về (T+2): 8 triệu ₫ — dùng được sau ~2 phiên.
- Tiền đã cam kết: 1,35 triệu ₫ (lệnh MUA 50 HPG @27.000 đang treo).
→ Khả dụng thực tế ≈ 10,65 triệu ₫ (chưa tính 8tr đang về).
- Toàn Finhay (số toàn tài khoản): tiền 15tr + chứng chỉ quỹ 40tr + HayBond 25tr
  (HayBond — không phải trái phiếu truyền thống).

## ⚖️ 3. Vị trí trên 3 khung tham chiếu (dải % là giả định vận hành — xem mục 5)
| Khung | Dải tiền mặt | Vị trí của bạn |
|---|---|---|
| Thận trọng | ~20–40% | Dưới mép dưới 17,6 điểm % |
| Cân bằng | ~10–20% | Dưới mép dưới 7,6 điểm % |
| Chủ động | ~0–10% | ✔ 2,4% — nằm trong dải này |
💡 Cash ratio hiện ở vùng thấp nhất của cả 3 khung; để chạm mép dưới dải Cân bằng (10%) cần
thêm ~37 triệu ₫ tiền mặt (hoặc cơ cấu tương ứng). Việc mức nào "đúng" phụ thuộc các câu hỏi
ở mục 5 — mình không kết luận thay bạn.
(Bối cảnh: lãi suất tiền gửi 12 tháng đang quanh 5,3%/năm — bank_interest_rates, 11/07.)

## 🧪 4. Kịch bản minh hoạ (số học "nếu…", không phải dự báo)
- Nếu danh mục giảm 10% (−48tr): tài sản tiểu khoản còn ~444tr trong khi nợ margin giữ nguyên
  85tr — tỷ lệ nợ tăng lên ~19,1%; buffer 10,65tr không thay đổi được nhiều ở quy mô này.
- Nếu cần gấp 30tr trong tuần: khả dụng thực tế 10,65tr + 8tr T+2 = 18,65tr → thiếu ~11,4tr,
  tương đương phải bán ~11,4tr CK và chờ tiền về T+.
- Nếu muốn giải ngân thêm 5tr: sau lệnh treo, khả dụng còn ~10,65tr → đủ, nhưng buffer về ~5,65tr.

## 📌 5. Giả định & ❓ câu hỏi cần bạn tự trả lời
- Giả định: dải 3 khung là giả định vận hành; chưa có hồ sơ khẩu vị rủi ro của bạn; số "toàn
  Finhay" là toàn tài khoản (không riêng tiểu khoản này); thông lệ chung — đệm chi tiêu 3–6
  tháng thường để ngoài tài khoản đầu tư (nêu như thông lệ, không phán định).
- ❓ (1) Mức sụt giảm tối đa bạn chấp nhận được? (2) 3–6 tháng tới có khoản chi lớn cần rút từ
  tài khoản này không? (3) Thời hạn đầu tư dự kiến? (4) Ngoài Finhay có đệm tiền mặt khác không?

## ➡️ 6. Bước tiếp theo
- Trả lời 4 câu hỏi trên → lần sau đối chiếu khung sát hơn.
- Nhìn tổng thể: "review danh mục của tôi" · quét rủi ro: "danh mục tôi đang có rủi ro gì".
- Muốn hành động (nạp thêm, huỷ lệnh treo, cơ cấu): mở app Finhay — mình không thực hiện thay.

*Thông tin mang tính tham khảo, không phải khuyến nghị đầu tư.*
```

## Checklist tự kiểm trước khi gửi (B5 — bắt buộc pass 100%)

- [ ] Đủ 6 phần; mục 2 đủ 4 lớp (balance / T+ / cam kết / nợ) + "khả dụng thực tế" + 1 dòng toàn Finhay có ghi chú phạm vi.
- [ ] Có nợ margin → xuất hiện ngay sau balance, TRƯỚC phần so khung.
- [ ] Bảng 3 khung + vị trí bằng số + khoảng cách; KHÔNG có: chọn khung hộ · "nên giữ X%" · kết luận "nhiều quá/ít quá" · gợi ý sản phẩm (kể cả sản phẩm Finhay).
- [ ] 2–3 kịch bản đều là "nếu…" thuần số học, không xác suất, không dự báo.
- [ ] Mục ❓ có ≥3 câu hỏi; dải khung khai báo là giả định; HayBond ghi đúng bản chất.
- [ ] Lãi suất tiền gửi (nếu nêu) chỉ là dữ kiện — không so "gửi lợi hơn/kém hơn đầu tư".
- [ ] Kết bằng handoff + disclaimer verbatim.
