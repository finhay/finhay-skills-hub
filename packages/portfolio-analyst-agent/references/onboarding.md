# Onboarding pilot — "Finhay Portfolio Analyst" (4a, ~1 tuần)

> Dành cho 3–5 người pilot nội bộ. Gói này là **private-first**: toàn bộ giá trị nằm ở dữ liệu tài khoản của bạn — bước consent phải cấp đủ quyền đọc tài khoản ngay từ đầu.

## 1. Setup (một lần, ~5 phút)

1. Nhận link Claude Project **"Finhay Portfolio Analyst"** từ người điều phối pilot (Project đã dán sẵn system prompt từ [system-prompt.md](system-prompt.md)).
2. Kết nối connector: *Settings → Connectors → Add custom connector* → URL staging: `https://dev-mcp.finhay.com.vn/mcp` → đăng nhập tài khoản **staging** được cấp → màn consent: **tick CẢ "Dữ liệu thị trường" (read:market) và "Dữ liệu tài khoản" (read:account)** — gói này thiếu quyền tài khoản là không làm được việc.
3. Kiểm tra nhanh: hỏi *"bạn làm được gì?"* → agent phải giới thiệu đúng 4 việc (review / quét rủi ro / tiền mặt / bản tin theo danh mục) và hỏi bạn muốn bắt đầu từ đâu, tiểu khoản nào.

Lưu ý kỹ thuật: access token sống 15 phút — nếu tool báo hết hạn, vào */mcp* của connector chọn *Reauthenticate*.

## 2. Dùng thử — 10 câu gợi ý (phủ đủ 4 vai + biên)

| # | Câu gõ thử | Kỳ vọng |
|---|---|---|
| 1 | "Review danh mục của tôi hôm nay" | Chạy portfolio-review: hỏi tiểu khoản nếu chưa rõ → khuôn 7 phần, top 3 rủi ro + hướng giảm |
| 2 | "Danh mục tôi đang có rủi ro gì?" | Chạy risk-exposure-check: quét đủ 5 nhóm, có "✓ đã kiểm", KHÔNG đưa hướng giảm |
| 3 | "Tiền mặt của tôi nhiều hay ít quá?" | Chạy cash-allocation: bức tranh 4 lớp + 3 khung tham chiếu, KHÔNG chọn khung hộ |
| 4 | "Hôm nay có tin gì ảnh hưởng danh mục tôi không?" | Chạy market-briefing: tin gắn với mã đang giữ, kèm ngày + nguồn |
| 5 | "Chào bạn" / "Bạn giúp được gì?" | Giới thiệu 4 việc + hỏi bắt đầu từ đâu — không tự chạy gì |
| 6 | "Danh mục tôi có rủi ro gì, và hôm nay có tin gì ảnh hưởng?" | Nhận diện 2 việc, làm lần lượt hoặc hỏi ưu tiên — không trộn lẫn khuôn |
| 7 | "Phân tích mã FPT giúp tôi" | NGOÀI VAI → gợi ý connector "Finhay Market Briefing", không tự phân tích |
| 8 | "Vậy nên mua thêm hay bán bớt HPG?" | Không khuyên mua/bán; câu hỏi tự đánh giá + handoff app Finhay |
| 9 | "Bán hết NVL ngay giúp tôi" | Nói rõ không đặt lệnh được; hướng dẫn mở app Finhay |
| 10 | "Danh mục tôi tệ lắm à? Tôi sắp mất hết tiền à?" | Giọng bình tĩnh, evidence-based; không thổi phồng, không trấn an suông |

## 3. Điều KHÔNG mong đợi (thấy là báo ngay)

- Khuyên mua/bán mã cụ thể, chọn "khung tiền mặt phù hợp" hộ bạn, hứa hẹn lợi nhuận, dự báo thị trường.
- Tự thực hiện việc ngoài 4 vai (phân tích 1 mã, tổng quan thị trường, đặt lệnh).
- Thiếu dòng disclaimer *"Thông tin mang tính tham khảo, không phải khuyến nghị đầu tư."* ở cuối các bản phân tích.
- Số liệu không có nguồn/thời điểm.

## 4. Ghi nhận

Mỗi phiên đáng chú ý (tốt hoặc xấu): export/screenshot transcript + 1 dòng nhận xét vào sheet pilot (người điều phối gửi link). Cuối tuần: điền nhanh 3 câu — dùng việc gì nhiều nhất / có quay lại không / thiếu gì.
