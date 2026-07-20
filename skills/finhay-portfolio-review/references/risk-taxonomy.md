# Risk taxonomy — 5 nhóm rủi ro danh mục (TÀI SẢN DÙNG CHUNG)

> **Dùng chung bởi 2 workflow:** `finhay-portfolio-review` (B3 — chọn top 3) và `finhay-risk-exposure` (B3 — quét đủ mọi phát hiện, ngưỡng quét mã ≥10%, bổ sung dữ kiện lệnh treo vào R1/R2). Sửa taxonomy/ngưỡng tại đây → cả hai skill + renders cập nhật theo.
>
> Mỗi rủi ro báo cáo phải có: **evidence** (con số + tool nguồn) và **severity** (Cao / Trung bình / Thấp + lý do). Mọi ngưỡng dưới đây là **giả định vận hành (assumption)** — chưa phải chuẩn được Legal/PM phê duyệt — và phải được khai báo trong output khi dùng đến.

## R1. Rủi ro tập trung (concentration)

**Câu hỏi:** một mã / một nhóm ngành chiếm tỷ trọng quá lớn so với tổng giá trị chứng khoán của tiểu khoản?

| Evidence | Nguồn |
|---|---|
| Tỷ trọng mã = giá trị thị trường của mã / tổng giá trị CK tiểu khoản | `get_portfolio_positions` |
| Tỷ trọng nhóm ngành (nếu nhận diện được ngành của các mã lớn) | positions + kiến thức mã |

**Ngưỡng gợi ý (assumption):**
- 1 mã > 30% → **Cao**; 20–30% → **Trung bình**; ≤20% → Thấp.
- Nhóm cùng ngành > 50% → **Cao** (chỉ chấm khi xác định ngành đủ tự tin; không chắc → ghi chú, không suy diễn).

**Lưu ý:** danh mục chỉ có 1–2 mã với giá trị nhỏ (tài khoản mới) → nêu như *đặc điểm* kèm ngữ cảnh, tránh giật tít "rủi ro Cao" thuần cơ học.

## R2. Rủi ro tiền mặt & thanh khoản

**Câu hỏi:** buffer tiền mặt có đủ mỏng để thành vấn đề không? Vị thế có khó thoát khi cần không?

| Evidence | Nguồn |
|---|---|
| Tỷ lệ tiền mặt = `balance` / (`balance` + giá trị CK tiểu khoản) | `get_account_summary` + positions |
| KL nắm giữ so với KLGD bình quân của mã (ước từ lịch sử giá) | positions + `get_price_history` |

**Ngưỡng gợi ý (assumption):**
- Tiền mặt < 5% → đáng nêu (buffer mỏng — không còn dư địa mua/không có đệm khi cần tiền); 5–15% → bình thường; > 40% → nêu theo hướng ngược lại (tiền nhàn rỗi lớn — thuộc phạm vi nhận định, không phải "rủi ro" trừ khi user hỏi).
- Vị thế > ~20 phiên KLGD bình quân → thanh khoản kém (thoát vị thế lớn sẽ tự ép giá).

**Lưu ý:** chỉ gọi `get_price_history` để chấm thanh khoản khi vị thế đó lớn (thuộc nhóm ≥15%); không cần chấm cho mã nhỏ.

## R3. Rủi ro nợ margin / đòn bẩy

**Câu hỏi:** danh mục có đang dùng đòn bẩy khiến thua lỗ bị khuếch đại / có nguy cơ bị xử lý tài sản?

| Evidence | Nguồn |
|---|---|
| `total_debt_amt`, `margin_amt`, các field nợ liên quan | `get_account_summary` |
| Tỷ lệ nợ = `total_debt_amt` / (giá trị CK + `balance`) của tiểu khoản | tính từ trên |

**Ngưỡng gợi ý (assumption):**
- Nợ > 0 → **luôn phải nêu** (ít nhất trong snapshot).
- Nợ / tổng tài sản tiểu khoản > 30% → **Cao**; 10–30% → **Trung bình**; < 10% → Thấp.
- Nợ > 0 **và** tiền mặt < 5% **và** có vị thế tập trung Cao → nêu tổ hợp này như một rủi ro khuếch đại (đòn bẩy + không đệm + tập trung).

**Lưu ý ngôn ngữ:** mô tả cơ chế ("nếu giá giảm thêm X% thì ..."), không phán đoán margin call chắc chắn; không dùng từ gây hoảng loạn (Guardrail #4).

## R4. Rủi ro sự kiện theo mã (symbol/event)

**Câu hỏi:** các mã tỷ trọng lớn có tin / sự kiện trọng yếu gần đây hoặc sắp tới không?

| Evidence | Nguồn |
|---|---|
| Tin trọng yếu ~7 ngày gần nhất của các mã lớn | `get_stock_news` |
| Sự kiện quyền sắp tới (cổ tức, quyền mua, họp ĐHCĐ) | `get_user_rights` |
| Biến động giá bất thường trong ngày/tuần | `get_stock_quote`, `get_price_history` |

**Xếp mức (assumption):** sự kiện đã xác nhận + ảnh hưởng trực tiếp mã tỷ trọng lớn → **Trung bình/Cao** tuỳ quy mô vị thế; tin chưa xác nhận/đồn đoán → chỉ nêu ở watch-list với nhãn "chưa xác nhận", không tính vào top 3.

**Lưu ý:** trích tin phải kèm ngày đăng + tiêu đề; không suy diễn quá nội dung tin.

## R5. Bối cảnh thị trường (market context)

**Câu hỏi:** môi trường chung (phiên, chỉ số, vĩ mô) có đang bất lợi cho cấu trúc danh mục này không?

| Evidence | Nguồn |
|---|---|
| Trạng thái phiên | `get_market_session` |
| Diễn biến VNINDEX/VN30 trong ngày | `get_index_quote` |
| Chỉ báo vĩ mô nổi bật (khi liên quan) | `get_macro_data` |

**Quy tắc cứng:** R5 **chỉ được mô tả như bối cảnh** ("VNINDEX đang giảm x% phiên hôm nay") — **cấm dự báo hướng** ("thị trường sẽ tiếp tục giảm"). R5 hiếm khi tự đứng trong top 3; thường dùng để tăng/giảm severity của R1–R4 (vd: tập trung cao *trong bối cảnh chỉ số biến động mạnh* → severity tăng).

---

## Quy tắc chọn TOP 3

1. Xếp mọi rủi ro đã chấm theo severity (Cao > Trung bình > Thấp). Lấy 3 rủi ro cao nhất.
2. **Đồng hạng thì ưu tiên:** (a) rủi ro có thể hiện thực hoá nhanh nhất (margin/nợ, sự kiện đã có lịch) → (b) rủi ro ảnh hưởng phần tài sản lớn nhất (% giá trị) → (c) rủi ro user có thể chủ động xử lý được.
3. Nếu tổng thể danh mục lành mạnh (không có rủi ro Cao/Trung bình): nói thẳng điều đó — top 3 khi đó là "3 điểm đáng theo dõi nhất", đặt nhãn rõ ràng, không thổi phồng Thấp thành Cao cho đủ 3.
4. Các rủi ro ngoài top 3 nhưng đã chấm ≥ Trung bình → liệt kê 1 dòng ở cuối mục 3 ("Ngoài ra: …") để không mất thông tin.

## Giới hạn dữ liệu phải khai báo (khi liên quan)

- Không có **risk profile** của user → mọi đánh giá theo giả định thận trọng (Guardrail #5).
- `get_asset_summary` + `get_pnl_today` là số **toàn user**; phân tích chi tiết chỉ trên **tiểu khoản đã chọn**.
- Không nhận diện được ngành đủ tin cậy → bỏ chấm tỷ trọng ngành, ghi chú.
- Dữ liệu ngoài giờ giao dịch → giá theo phiên gần nhất.
