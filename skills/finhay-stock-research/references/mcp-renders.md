# MCP renders — `stock-research-brief` (workflow thứ 3 → kích hoạt Tier B)

> **Nguồn sự thật là [SKILL.md](../SKILL.md) + output-template.md.** Từ workflow này, INSTRUCTIONS của `vnsc-mcp-server` chuyển **Tier B**: phần workflow chỉ còn **router**, bản đầy đủ của MỌI workflow được model tự kéo qua tool **`get_workflow_guide(workflow)`** — tool này serve thẳng nội dung từ `PromptService.generate(name)`, tức **prompt và guide là MỘT văn bản, không có bề mặt sync riêng**.

## Render 1 — Toàn bộ phần WORKFLOWS của INSTRUCTIONS (Tier B — thay cho các block chi tiết cũ)

```
WORKFLOWS PHÂN TÍCH — nếu câu hỏi khớp một workflow dưới đây, BẮT BUỘC gọi
get_workflow_guide(workflow) để lấy quy trình đầy đủ và LÀM THEO, rồi mới trả lời:
- portfolio-review: review/đánh giá danh mục, rủi ro, sức khoẻ tài khoản của tôi.
- market-briefing: "hôm nay có gì ảnh hưởng danh mục tôi", tin tức theo danh mục.
- stock-research-brief: phân tích/đánh giá MỘT mã cụ thể (vd "phân tích FPT").
```

> Các block chi tiết `PHÂN TÍCH DANH MỤC` và `MARKET BRIEFING` trước đây trong INSTRUCTIONS đã được gỡ — nội dung đầy đủ giờ nằm trong prompt của từng workflow (đồng thời là body của guide). Khối nền tảng (PHẠM VI/TÀI KHOẢN/GIAO DỊCH/ĐƠN VỊ) và COMPLIANCE giữ nguyên.

## Render 2 — MCP prompt `stock-research-brief`

**arguments:** `symbol` (bắt buộc — mã cổ phiếu), `period` (tuỳ chọn — khung lịch sử giá, mặc định ~6 tháng).

**description:** `"Bản phân tích 1 mã cổ phiếu: giá & xu hướng, nền tảng tài chính (kèm kỳ báo cáo), tin tức, khuyến nghị CTCK (ý kiến bên thứ ba). Không kết luận mua/bán."`

**generate({symbol, period}) trả về** (khi guide gọi không có args: `symbol` → `<MÃ CẦN PHÂN TÍCH — hỏi người dùng nếu chưa rõ>`, `period` → `6 tháng`):

```
Hãy làm bản phân tích (research brief) cổ phiếu ${symbol}, khung tham chiếu ${period}.

## Quy trình lấy dữ liệu (theo thứ tự, chỉ dùng tools read-only)
0. Chưa rõ mã → HỎI; tên công ty mơ hồ → xác nhận mã trước khi gọi tool.
1. get_market_session — phiên & mốc thời gian.
2. get_stock_quote (symbol) — giá, ±%, khối lượng hiện tại.
3. get_price_history — xu hướng giá & thanh khoản trong ${period} (resolution phù hợp;
   from/to là Unix timestamp tính bằng GIÂY).
4. get_company_overview + get_financial_analysis (thêm get_financial_statement khi cần đào sâu
   nợ/dòng tiền) — ghi lại KỲ BÁO CÁO của từng con số.
5. get_stock_news (~14 ngày gần nhất) + get_recommendation_reports — tin tức & báo cáo CTCK.
6. Tuỳ chọn: get_index_quote (tương quan VNINDEX cùng kỳ); nếu tôi đang nắm giữ mã này và đã
   cấp quyền tài khoản: get_portfolio_positions để nêu vị thế (không bắt buộc, thiếu quyền thì bỏ qua).

## Khung phân tích
- Mọi nhận xét gắn SỐ LIỆU + KỲ BÁO CÁO ("biên gộp Q1/2026: 38,2%") — số không rõ kỳ thì không dùng.
- Báo cáo CTCK là DỮ KIỆN VỀ Ý KIẾN BÊN THỨ BA: "CTCK X (dd/mm): khuyến nghị Y, giá mục tiêu Z".
  KHÔNG tính trung bình giá mục tiêu, KHÔNG biến thành kết luận của bạn, KHÔNG chọn lọc một chiều;
  báo cáo cũ hơn ~3 tháng phải ghi rõ tuổi.
- Xu hướng giá mô tả bằng dữ kiện (±% theo kỳ, khối lượng) — không dán nhãn xu hướng tương lai.
- Điểm mạnh / điểm cần lưu ý: mỗi bên 2–4 ý, BẮT BUỘC có cả hai phía, mỗi ý một con số dẫn chứng.
- Chỉ so sánh ngành/mã khác khi có số liệu lấy được trong phiên này.
- Mã ít thanh khoản / mới niêm yết / dữ liệu mỏng → nêu như đặc điểm cần lưu ý ĐẦU TIÊN.

## Trình bày kết quả — đúng 6 phần
1. 🕐 Thời điểm & nguồn (giờ VN, phiên, tools, kỳ BCTC mới nhất có được)
2. 📊 Snapshot giá (giá + thời điểm, ±% ngày/tuần/${period}, khối lượng vs bình quân, tương quan
   chỉ số nếu có — chỉ mô tả)
3. 🏢 Nền tảng doanh nghiệp (bảng: doanh thu, LN/biên, nợ/VCSH, ROE… — MỖI SỐ MỘT KỲ)
4. 📰 Tin tức & khuyến nghị bên thứ ba (tin kèm ngày/nguồn; báo cáo kèm tên CTCK + ngày; không có
   → nói thẳng "chưa có trong dữ liệu")
5. ⚖️ Điểm mạnh / Điểm cần lưu ý (facts-grounded, tách 📊/💡)
6. 📌 Giả định & thiếu dữ liệu + ➡️ bước tiếp theo (câu hỏi tự đánh giá: khẩu vị rủi ro, tỷ trọng
   dự kiến, thời hạn; đang nắm giữ → gợi ý "phân tích rủi ro danh mục"; muốn giao dịch → mở app
   Finhay, tôi không đặt lệnh trong workflow này)

## Ràng buộc bắt buộc
- Tách rõ 📊 dữ kiện / 💡 nhận định. KHÔNG đưa giá mục tiêu của riêng bạn; KHÔNG dự báo hướng giá;
  KHÔNG cam kết lợi nhuận; KHÔNG kết luận "nên mua/bán" — kể cả khi tôi hỏi thẳng (khi đó: đưa câu
  hỏi tự đánh giá + handoff app Finhay).
- Thiếu dữ liệu mảng nào → nói rõ, không suy đoán, không lấy số liệu từ trí nhớ.
- Kết thúc bằng đúng 1 dòng: "Thông tin mang tính tham khảo, không phải khuyến nghị đầu tư."
```

## Ghi chú test khi sync sang code (Tier B)

- Tool mới `get_workflow_guide`: enum động từ `PROMPT_DEFINITIONS` (5 giá trị); trả text = `PromptService.generate(name, {})`; annotations readOnly, không destructive, openWorld=false.
- `PromptService.test.ts`: 5 prompts; stock-research-brief render với `{symbol:'FPT'}` chứa "FPT", "6 phần", "bên thứ ba", "không phải khuyến nghị đầu tư"; render không args chứa placeholder hỏi mã.
- `mcpServer.integration.test.ts`: instructions chứa "WORKFLOWS", "get_workflow_guide", 3 tên workflow, "COMPLIANCE", "GIAO DỊCH = TIỀN THẬT" và KHÔNG còn block chi tiết cũ; tools/list chứa `get_workflow_guide`; callTool guide('portfolio-review') trả text chứa "7 phần".
- Ngân sách INSTRUCTIONS sau Tier B: ~25–30 dòng.
