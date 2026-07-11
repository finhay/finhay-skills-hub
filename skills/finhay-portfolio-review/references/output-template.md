# Output template — khuôn 7 mục (bắt buộc)

> Dùng ở bước B4. Đúng thứ tự 7 mục, đúng tinh thần từng mục. Toàn bộ bằng tiếng Việt đời thường. Quy tắc trình bày số liệu: VND viết gọn (216,5 triệu ₫ / 1,2 tỷ ₫), phần trăm 1 chữ số thập phân, mọi con số phải truy được về tool nguồn.

## Khuôn

```
## 🕐 1. Thời điểm & nguồn dữ liệu
- Thời điểm: <giờ VN, ngày> — <trạng thái phiên từ get_market_session>
- Tiểu khoản review: <thường (.1) | ký quỹ (.6) | OpenAPI (.4)>
- Dữ liệu từ: <liệt kê tools đã gọi>

## 📊 2. Snapshot danh mục
📊 Dữ kiện:
- Tổng tài sản Finhay (mọi sản phẩm, toàn tài khoản): <X> — tiểu khoản này: CK <A> + tiền mặt <B> (<b>%)
- Nợ margin: <C> (<c>% tài sản tiểu khoản)   ← chỉ hiện khi > 0
- Số mã nắm giữ: <n>. Top vị thế: <MÃ1 x%>, <MÃ2 y%>, <MÃ3 z%>
- Lãi/lỗ hôm nay (toàn tài khoản): <+/-P> (<p>%)

## ⚠️ 3. Top 3 rủi ro
1. <Tên rủi ro — nhóm Rx> — mức **<Cao|Trung bình|Thấp>**
   📊 Bằng chứng: <con số + nguồn tool>
   Vì sao mức này: <1 câu, gắn với ngưỡng — ngưỡng là giả định, xem mục 6>
2. …
3. …
(Ngoài ra: <rủi ro ≥ Trung bình ngoài top 3, mỗi cái 1 dòng — nếu có>)

## 💬 4. Giải thích dễ hiểu
<Mỗi rủi ro 2–3 câu, ngôn ngữ đời thường, không thuật ngữ khó. Trả lời câu "điều này
nghĩa là gì với tôi?" — cơ chế tác động, không phán đoán tương lai.>

## 🧭 5. Các hướng giảm rủi ro (lựa chọn để cân nhắc — không phải khuyến nghị)
💡 Nhận định — mỗi hướng kèm trade-off:
- Hướng A: <mô tả> · Đổi lại: <trade-off>
- Hướng B: <mô tả> · Đổi lại: <trade-off>
- Hướng C (giữ nguyên + theo dõi): <điều kiện gì thì nên xem lại>

## 📌 6. Dữ liệu thiếu & giả định
- Chưa có hồ sơ khẩu vị rủi ro → đánh giá theo giả định thận trọng.
- Ngưỡng đánh giá (tập trung >30%, tiền mặt <5%, nợ >30%…) là giả định vận hành, không phải chuẩn tư vấn.
- <PnL/tổng tài sản là số toàn tài khoản; phân tích chi tiết trên tiểu khoản đã chọn>
- <Dữ liệu thiếu do lỗi tool / ngoài giờ — nếu có>

## ➡️ 7. Bước tiếp theo
- <1–2 câu hỏi user nên tự trả lời (khẩu vị rủi ro, thời hạn đầu tư, nhu cầu tiền mặt)>
- Muốn hành động (mua/bán/tái cơ cấu): mở app Finhay — trợ lý này không đặt lệnh trong workflow review.
- Có thể hỏi tiếp: "phân tích riêng mã <X>", "xem sự kiện quyền sắp tới", "so sánh với thị trường hôm nay".

*Thông tin mang tính tham khảo, không phải khuyến nghị đầu tư.*
```

## Golden example (dữ liệu giả lập — để eval đối chiếu giọng điệu & cấu trúc)

Bối cảnh giả lập: tiểu khoản thường; CK 480 triệu ₫ gồm HPG 45% (216tr), SSI 25% (120tr), VNM 18% (86tr), NVL 12% (58tr); tiền mặt 12tr; nợ margin 85tr; PnL hôm nay −3,2tr; NVL có tin tái cấu trúc nợ (đã xác nhận, 3 ngày trước); phiên liên tục, VNINDEX −0,8%.

```
## 🕐 1. Thời điểm & nguồn dữ liệu
- 10:45 11/07/2026 — phiên khớp lệnh liên tục (HOSE).
- Tiểu khoản review: tài khoản thường (.1).
- Dữ liệu từ: market_session, asset_summary, account_summary, portfolio_positions,
  pnl_today, stock_quote, stock_news.

## 📊 2. Snapshot danh mục
📊 Dữ kiện:
- Tiểu khoản này: cổ phiếu 480 triệu ₫ + tiền mặt 12 triệu ₫ (2,4%).
- Nợ margin: 85 triệu ₫ (≈17,3% tài sản tiểu khoản).
- 4 mã: HPG 45,0% · SSI 25,0% · VNM 17,9% · NVL 12,1%.
- Lãi/lỗ hôm nay (toàn tài khoản): −3,2 triệu ₫ (−0,65%).

## ⚠️ 3. Top 3 rủi ro
1. Đòn bẩy trong khi đệm tiền mặt rất mỏng — nhóm R3+R2 — mức **Cao**
   📊 Bằng chứng: nợ margin 85tr (17,3%) trong khi tiền mặt chỉ 12tr (2,4%) — account_summary.
   Vì sao mức này: nợ ở mức trung bình nhưng kết hợp buffer <5% nên khả năng chống chịu khi
   thị trường giảm là thấp (ngưỡng là giả định — xem mục 6).
2. Tập trung cao vào HPG — nhóm R1 — mức **Cao**
   📊 Bằng chứng: HPG chiếm 45,0% giá trị cổ phiếu (216tr) — portfolio_positions.
   Vì sao mức này: vượt ngưỡng giả định 30% cho một mã.
3. Sự kiện tại NVL — nhóm R4 — mức **Trung bình**
   📊 Bằng chứng: tin tái cấu trúc nợ đăng 08/07 (stock_news); NVL chiếm 12,1% danh mục.
   Vì sao mức này: sự kiện đã xác nhận, ảnh hưởng trực tiếp nhưng quy mô vị thế vừa phải.

## 💬 4. Giải thích dễ hiểu
- (1) Bạn đang vay để đầu tư trong khi gần như không còn tiền mặt dự phòng. Nếu danh mục
  giảm giá, bạn vừa lỗ trên phần vốn vay, vừa không có sẵn tiền để xử lý — dễ rơi vào thế
  phải bán lúc bất lợi.
- (2) Gần một nửa danh mục nằm ở một mã duy nhất. Chuyện riêng của doanh nghiệp đó (ngành
  thép, giá nguyên liệu, tin nội bộ) sẽ quyết định phần lớn kết quả của bạn, thay vì được
  phân tán ra nhiều nơi.
- (3) NVL vừa có thông tin tái cấu trúc nợ — loại sự kiện thường khiến giá biến động mạnh
  hai chiều trong thời gian ngắn.

## 🧭 5. Các hướng giảm rủi ro (lựa chọn để cân nhắc — không phải khuyến nghị)
💡 Nhận định — mỗi hướng có đánh đổi riêng:
- Hướng A — giảm đòn bẩy trước: ưu tiên đưa nợ margin về mức thấp hơn để tăng sức chịu đựng.
  · Đổi lại: giảm quy mô vị thế, có thể bỏ lỡ nhịp hồi nếu thị trường tăng lại.
- Hướng B — hạ dần mức tập trung ở vị thế lớn nhất (HPG) qua nhiều phiên, đưa về gần ngưỡng
  bạn thấy thoải mái. · Đổi lại: phát sinh phí giao dịch; nếu HPG tiếp tục tích cực thì phần
  lợi nhuận trên tỷ trọng đã giảm sẽ nhỏ hơn.
- Hướng C — giữ nguyên + đặt điều kiện theo dõi: hẹn mốc cụ thể (vd. nợ margin vượt 20%,
  HPG vượt 50% danh mục, hoặc NVL ra thông tin mới) thì review lại ngay.
  · Đổi lại: chấp nhận trạng thái rủi ro hiện tại trong lúc chờ.

## 📌 6. Dữ liệu thiếu & giả định
- Chưa có hồ sơ khẩu vị rủi ro của bạn → đánh giá theo giả định thận trọng.
- Ngưỡng dùng để xếp mức (1 mã >30% = tập trung cao; tiền mặt <5% = mỏng; nợ/tài sản >30% =
  cao) là giả định vận hành, không phải chuẩn tư vấn.
- Lãi/lỗ hôm nay là số toàn tài khoản; phân tích chi tiết chỉ trên tiểu khoản thường.
- Chưa đánh giá thanh khoản từng mã (chưa cần thiết ở quy mô vị thế hiện tại).

## ➡️ 7. Bước tiếp theo
- Bạn dự định nắm giữ trong bao lâu, và mức sụt giảm tối đa bạn chấp nhận được là bao nhiêu?
  Trả lời 2 câu này sẽ giúp lần review sau chính xác hơn.
- Muốn hành động (giảm nợ, cơ cấu danh mục): mở app Finhay — mình không đặt lệnh trong
  workflow review này.
- Có thể hỏi tiếp: "phân tích riêng HPG", "NVL có sự kiện quyền nào sắp tới không?".

*Thông tin mang tính tham khảo, không phải khuyến nghị đầu tư.*
```

## Checklist tự kiểm trước khi gửi (B5 — bắt buộc pass 100%)

- [ ] Đủ 7 mục, đúng thứ tự; có timestamp + trạng thái phiên + tên tiểu khoản.
- [ ] Mỗi rủi ro top 3: có con số + tool nguồn + severity + lý do xếp mức.
- [ ] Có nhãn 📊/💡 tách dữ kiện và nhận định; không trộn lẫn.
- [ ] KHÔNG có: cam kết/ám chỉ lợi nhuận · dự báo chắc chắn hướng thị trường · mệnh lệnh "nên mua/bán X khối lượng Y" · từ ngữ gây hoảng loạn.
- [ ] Mục 5 là các lựa chọn + trade-off (có phương án "giữ nguyên + theo dõi").
- [ ] Mục 6 khai báo: thiếu risk profile, ngưỡng là giả định, phạm vi số liệu user-level vs tiểu khoản, dữ liệu thiếu (nếu có).
- [ ] Kết bằng handoff app Finhay + dòng disclaimer.
