# Output template — khuôn 5 phần (bắt buộc)

> Dùng ở bước B4. Toàn bộ tiếng Việt đời thường; VND viết gọn; % 1 chữ số thập phân; mọi tin kèm ngày đăng + nguồn, mọi giá kèm thời điểm. Bản tin NGẮN: tối đa ~5 item chính.

## Khuôn

```
## 🕐 1. Thời điểm & phạm vi
- <giờ VN, ngày> — <trạng thái phiên>. Tiểu khoản: <thường|ký quỹ|OpenAPI> (hoặc: "bản tin chung —
  chưa kết nối danh mục").
- Dữ liệu từ: <tools đã gọi>.

## 📈 2. Bối cảnh thị trường (tối đa 2–3 dòng)
📊 <VNINDEX/VN30 hiện tại ± % — thời điểm; 1 ý thanh khoản/vĩ mô nếu nổi bật. CHỈ mô tả.>

## 📰 3. Tin & sự kiện theo mã nắm giữ   ← MỤC CHÍNH
1. <MÃ (x% danh mục)> — 📊 <fact 1–2 dòng, NGÀY ĐĂNG, nguồn/tool>
   💡 <vì sao đáng chú ý với vị thế này — cơ chế, không phán đoán tương lai>
2. …  (xếp theo: tỷ trọng × mức trọng yếu; tin "chưa xác nhận" xếp cuối + ghi nhãn)
(Không có tin trọng yếu → viết thẳng: "Trong ~7 ngày qua không có tin trọng yếu với các mã
bạn nắm giữ." — không độn tin chung.)

## 👀 4. Watch-items sắp tới (mỗi cái 1 dòng)
- <sự kiện quyền: mã — loại — ngày (get_user_rights)>
- <lịch kinh tế liên quan: sự kiện — ngày (get_economic_calendar)>
- <mốc theo dõi khác: vd "NVL dự kiến công bố X ngày dd/mm">

## 📌 5. Giả định & thiếu dữ liệu · ➡️ Bước tiếp theo
- <chế độ/tiểu khoản; dữ liệu thiếu do lỗi tool nếu có; "tin lọc trong ~7 ngày" là giả định phạm vi>
- Có thể hỏi tiếp: "phân tích rủi ro danh mục" (portfolio-review) · "chi tiết mã <X>".
- Muốn hành động: mở app Finhay — trợ lý không đặt lệnh trong workflow này.

*Thông tin mang tính tham khảo, không phải khuyến nghị đầu tư.*
```

## Golden example (dữ liệu giả lập — đối chiếu giọng điệu & cấu trúc)

Bối cảnh giả lập: tiểu khoản thường; nắm HPG 45%, SSI 25%, VNM 18%, NVL 12%; NVL có tin tái cấu trúc nợ (08/07, đã xác nhận); HPG +2,1% trong phiên kèm báo cáo khuyến nghị mới (10/07); VNM sắp chốt quyền cổ tức 25/07; VNINDEX −0,8%; CPI Mỹ công bố 15/07.

```
## 🕐 1. Thời điểm & phạm vi
- 10:45 11/07/2026 — phiên khớp lệnh liên tục (HOSE). Tiểu khoản: thường (.1).
- Dữ liệu từ: market_session, portfolio_positions, stock_news, stock_quote, index_quote,
  user_rights, economic_calendar.

## 📈 2. Bối cảnh thị trường
📊 VNINDEX 1.285 điểm (−0,8% lúc 10:45); thanh khoản nhỉnh hơn trung bình tuần. VN30 −0,9%.

## 📰 3. Tin & sự kiện theo mã nắm giữ
1. HPG (45,0% danh mục) — 📊 +2,1% trong phiên (10:45); báo cáo khuyến nghị mới của CTCK X
   ngày 10/07 (stock_news).
   💡 Mã chiếm tỷ trọng lớn nhất của bạn đang đi ngược chỉ số — biến động của riêng HPG hôm nay
   ảnh hưởng tới danh mục nhiều hơn cả thị trường chung.
2. NVL (12,1%) — 📊 Tin tái cấu trúc nợ đăng 08/07 (stock_news, đã xác nhận).
   💡 Loại sự kiện thường kéo theo biến động mạnh hai chiều trong ngắn hạn; đáng theo dõi sát
   dù tỷ trọng vị thế ở mức vừa.
3. VNM (17,9%) — 📊 Chốt quyền cổ tức tiền mặt ngày 25/07 (user_rights).
   💡 Giá tham chiếu sẽ điều chỉnh tại ngày chốt quyền — nếu thấy giá "giảm" hôm đó thì một
   phần là do điều chỉnh kỹ thuật, không hẳn là tin xấu.

## 👀 4. Watch-items sắp tới
- VNM — chốt quyền cổ tức: 25/07 (user_rights).
- CPI Mỹ công bố 15/07 (economic_calendar) — có thể ảnh hưởng tâm lý chung phiên đầu tuần.
- NVL — chờ thông tin tiếp theo về phương án tái cấu trúc (tin 08/07 chưa nêu lịch cụ thể).

## 📌 5. Giả định & thiếu dữ liệu · ➡️ Bước tiếp theo
- Tin được lọc trong ~7 ngày gần nhất; SSI (25,0%) không có tin trọng yếu trong khoảng này.
- Muốn đánh giá cấu trúc rủi ro (tập trung HPG, nợ margin…): hỏi "phân tích rủi ro danh mục".
- Muốn hành động: mở app Finhay — mình không đặt lệnh trong workflow này.

*Thông tin mang tính tham khảo, không phải khuyến nghị đầu tư.*
```

## Checklist tự kiểm trước khi gửi (bắt buộc pass 100%)

- [ ] Đúng 5 phần; có timestamp + phiên + tiểu khoản/chế độ; mục 2 ≤ 3 dòng.
- [ ] Mọi item mục 3: có mã + tỷ trọng + ngày đăng/nguồn + nhãn 📊/💡; ≤5 item; tin đồn có nhãn "chưa xác nhận" và không đứng đầu.
- [ ] Không tin chung chung độn bản tin; không có tin trọng yếu thì nói thẳng.
- [ ] KHÔNG có: dự báo hướng giá/thị trường · cam kết lợi nhuận · mệnh lệnh mua/bán · suy diễn quá nội dung tin.
- [ ] Chế độ bản tin chung (nếu áp dụng) được nói rõ + có lời mời kết nối danh mục.
- [ ] Kết bằng bước tiếp theo + handoff app Finhay + disclaimer.
