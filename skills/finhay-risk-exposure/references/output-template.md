# Output template — khuôn 6 phần (bắt buộc)

> Dùng ở bước B4. Đây là bản QUÉT KIỂM TRA: đủ 5 nhóm, mọi phát hiện có evidence + severity + ngưỡng, **không có bất kỳ câu khuyến nghị/hướng giảm nào**. VND viết gọn; % 1 chữ số thập phân.

## Khuôn

```
## 🕐 1. Thời điểm & phạm vi
- <giờ VN, ngày> — <trạng thái phiên>. Tiểu khoản: <thường|ký quỹ|OpenAPI>.
- Dữ liệu từ: <tools đã gọi>. Ngưỡng quét mã: tỷ trọng ≥10%.

## 📊 2. Bảng phơi nhiễm
| Vị thế | Tỷ trọng | Ghi chú |
|---|---|---|
| <MÃ 1..n — TẤT CẢ, không chỉ top> | x% | <±% hôm nay nếu bất thường> |
- Tiền mặt: <B> (<b>% tài sản tiểu khoản) · Nợ margin: <C> (<c>%) — không có thì ghi "0".
- Lệnh đang treo: <mua X KL/giá trị — cam kết tiền · bán Y> hoặc "không có".
- Sự kiện sắp tới liên quan mã nắm giữ: <từ user_rights/news> hoặc "không thấy trong dữ liệu".
- Lãi/lỗ hôm nay (toàn tài khoản): <±P>.

## ⚠️ 3. Kết quả quét 5 nhóm rủi ro
R1 — Tập trung mã/ngành: <phát hiện + 📊 evidence + mức **Cao|TB|Thấp** (ngưỡng đã dùng)>
     hoặc "✓ đã kiểm — không phát hiện (mã lớn nhất x% < 20%)".
R2 — Tiền mặt & thanh khoản: <…, gồm tác động của lệnh mua treo lên buffer> hoặc "✓ …".
R3 — Nợ margin/đòn bẩy: <…> hoặc "✓ đã kiểm — không dùng margin".
R4 — Sự kiện theo mã: <tin/sự kiện đã xác nhận + ngày/nguồn> hoặc "✓ … (không có tin trọng yếu ~7 ngày)".
R5 — Bối cảnh thị trường: <chỉ MÔ TẢ: chỉ số ±%, thanh khoản> — nhóm này không xếp mức, chỉ ghi
     bối cảnh có làm tăng severity nhóm nào không.

## 🔎 4. Tổng hợp & phạm vi kiểm tra
- Phát hiện: <X> Cao · <Y> Trung bình · <Z> Thấp. (Không phát hiện nào → nói thẳng:
  "Quét đủ 5 nhóm — không phát hiện đáng kể theo ngưỡng hiện dùng.")
- CHƯA kiểm được: <vd tỷ trọng ngành (không nhận diện đủ tin cậy), thanh khoản mã ABC
  (thiếu price history), …> — mỗi mục kèm lý do.

## 📌 5. Giả định & ngưỡng
- Ngưỡng quét là giả định vận hành (chưa phải chuẩn tư vấn): 1 mã >30% = Cao, 20–30% = TB;
  tiền mặt <5% = mỏng; nợ/tài sản >30% = Cao, 10–30% = TB; vị thế >20 phiên KLGD = thanh khoản kém.
- Chưa có hồ sơ khẩu vị rủi ro → đánh giá theo giả định thận trọng.
- <Phạm vi số liệu: asset summary & PnL là số toàn tài khoản; còn lại theo tiểu khoản đã chọn.>

## ➡️ 6. Bước tiếp theo
- Muốn bản review tổng quan + top 3 rủi ro + CÁC HƯỚNG GIẢM RỦI RO: hỏi "review danh mục của tôi"
  (workflow portfolio-review). — Bản quét này cố ý không đưa khuyến nghị.
- Muốn hành động: mở app Finhay — trợ lý không đặt lệnh trong workflow này.

*Thông tin mang tính tham khảo, không phải khuyến nghị đầu tư.*
```

## Golden example (dữ liệu giả lập — đối chiếu giọng điệu & cấu trúc)

Bối cảnh giả lập: tiểu khoản thường; HPG 45% · SSI 25% · VNM 18% · NVL 12%; tiền mặt 12tr (2,4%); nợ margin 85tr (17,3%); lệnh MUA treo 50 HPG×27.000 (1,35tr); NVL tin tái cấu trúc nợ 08/07; VNM chốt quyền 25/07; VNINDEX −0,8%.

```
## 🕐 1. Thời điểm & phạm vi
- 10:45 11/07/2026 — phiên khớp lệnh liên tục (HOSE). Tiểu khoản: thường (.1).
- Dữ liệu từ: market_session, account_summary, asset_summary, portfolio_positions, pnl_today,
  order_history, stock_quote, stock_news, user_rights, index_quote. Ngưỡng quét mã: ≥10%.

## 📊 2. Bảng phơi nhiễm
| Vị thế | Tỷ trọng | Ghi chú |
|---|---|---|
| HPG | 45,0% | +2,1% trong phiên |
| SSI | 25,0% | — |
| VNM | 17,9% | — |
| NVL | 12,1% | — |
- Tiền mặt: 12 triệu ₫ (2,4%) · Nợ margin: 85 triệu ₫ (17,3%).
- Lệnh đang treo: MUA 50 HPG @27.000 (~1,35tr — cam kết thêm tiền từ buffer 12tr).
- Sự kiện sắp tới: VNM chốt quyền cổ tức 25/07 (user_rights).
- Lãi/lỗ hôm nay (toàn tài khoản): −3,2 triệu ₫.

## ⚠️ 3. Kết quả quét 5 nhóm rủi ro
R1 — Tập trung: HPG chiếm 45,0% (📊 portfolio_positions) — mức **Cao** (ngưỡng >30%/mã);
     lệnh mua treo HPG nếu khớp sẽ tăng thêm tập trung. Ngành: chưa chấm (xem phần 4).
R2 — Tiền mặt & thanh khoản: buffer 2,4% (📊 account_summary) — mức **Cao** khi kết hợp nợ margin;
     lệnh mua treo 1,35tr chiếm ~11% buffer còn lại. Thanh khoản từng mã: chưa chấm (phần 4).
R3 — Nợ margin: 17,3% tài sản tiểu khoản (📊 account_summary) — mức **Trung bình** (10–30%),
     nhưng tổ hợp R3+R2+R1 tạo rủi ro khuếch đại (nợ + không đệm + tập trung).
R4 — Sự kiện theo mã: NVL tin tái cấu trúc nợ 08/07 (📊 stock_news, đã xác nhận) — mức
     **Trung bình** (vị thế 12,1%); VNM chốt quyền 25/07 — giá tham chiếu sẽ điều chỉnh kỹ thuật.
R5 — Bối cảnh: VNINDEX −0,8% lúc 10:45, thanh khoản nhỉnh hơn trung bình — bối cảnh giảm nhẹ,
     làm tăng mức chú ý cho R1/R3 (chỉ mô tả, không dự báo).

## 🔎 4. Tổng hợp & phạm vi kiểm tra
- Phát hiện: 2 Cao (R1 tập trung, R2 buffer) · 2 Trung bình (R3 nợ, R4 sự kiện NVL) · 0 Thấp.
- CHƯA kiểm được: tỷ trọng ngành (không nhận diện đủ tin cậy từ dữ liệu hiện có); thanh khoản
  từng mã so KLGD bình quân (chưa gọi price_history — vị thế đều là bluechip thanh khoản cao).

## 📌 5. Giả định & ngưỡng
- Ngưỡng quét là giả định vận hành: 1 mã >30% = Cao; tiền mặt <5% = mỏng; nợ 10–30% = TB.
- Chưa có hồ sơ khẩu vị rủi ro → đánh giá theo giả định thận trọng.
- Lãi/lỗ hôm nay là số toàn tài khoản; các số khác theo tiểu khoản thường.

## ➡️ 6. Bước tiếp theo
- Muốn top 3 rủi ro + CÁC HƯỚNG GIẢM: hỏi "review danh mục của tôi" (portfolio-review) —
  bản quét này cố ý không đưa khuyến nghị.
- Muốn hành động (giảm nợ, cơ cấu, huỷ lệnh treo): mở app Finhay.

*Thông tin mang tính tham khảo, không phải khuyến nghị đầu tư.*
```

## Checklist tự kiểm trước khi gửi (B5 — bắt buộc pass 100%)

- [ ] Đủ 6 phần; bảng phơi nhiễm có TẤT CẢ vị thế + tiền mặt + nợ + lệnh treo + sự kiện.
- [ ] Cả 5 nhóm R1–R5 đều xuất hiện — phát hiện hoặc "✓ đã kiểm — không phát hiện"; R5 chỉ mô tả.
- [ ] Mọi phát hiện: 📊 evidence + nguồn tool + severity + ngưỡng; phần 4 đếm đúng số phát hiện.
- [ ] Mục "chưa kiểm được" liệt kê trung thực kèm lý do.
- [ ] KHÔNG có câu khuyến nghị / "nên…" / hướng giảm nào; không ngôn ngữ hoảng loạn; sạch thì nói thẳng.
- [ ] Kết bằng handoff portfolio-review + app Finhay + disclaimer verbatim.
