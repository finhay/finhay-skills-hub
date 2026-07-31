# Finhay Remote-MCP Plugins

Plugin Claude (Code + Desktop) trỏ tới Finhay Remote MCP server (vnsc-mcp-server).
KHÔNG chứa nghiệp vụ — workflows/guardrails/tools nằm ở server; đây chỉ là lớp khai báo cài đặt.

- `portfolio-analyst/` → `<BASE>/mcp/portfolio-analyst-agent` (read-only, OAuth)
- `market-briefing/` → `<BASE>/mcp/market-briefing-agent` (read-only, OAuth)

## Cấu hình môi trường

`<BASE>` đọc từ biến môi trường qua cú pháp `${FINHAY_MCP_BASE:-<default>}` trong `.mcp.json`:

| Môi trường | BASE | Cách dùng |
|---|---|---|
| Dev/staging (**mặc định hiện tại**) | `https://dev-mcp.finhay.com.vn` | không cần set gì |
| Production | `https://mcp.fhsc.com.vn` | `export FINHAY_MCP_BASE=https://mcp.fhsc.com.vn` trước khi mở Claude |

> ⚠️ **Trước khi publish marketplace cho khách hàng:** khách cài từ kệ KHÔNG set env var → họ nhận
> giá trị **default**. Khi release phải FLIP default trong 2 file `.mcp.json` sang prod
> (`https://mcp.fhsc.com.vn`); từ đó dev override ngược bằng
> `export FINHAY_MCP_BASE=https://dev-mcp.finhay.com.vn`.

## Cài (khách hàng)

1. `/plugin marketplace add finhay/finhay-skills-hub` (hoặc Claude Desktop: **+ → Plugins → Add plugin**)
2. `/plugin install finhay-portfolio-analyst@finhay-skills-hub`
3. Lần đầu dùng → Claude tự mở OAuth Finhay → đăng nhập & đồng ý quyền ĐỌC.

## Test local (dev)

```bash
claude --plugin-dir ./remote-plugins/portfolio-analyst
```

hoặc `/plugin marketplace add ./remote-plugins` (marketplace nội bộ của folder này).

## Tách repo sau này

Copy toàn bộ RUỘT folder này sang gốc repo mới → xong (marketplace nội bộ thành marketplace gốc,
`source` tương đối vẫn đúng). Rồi xoá 2 entry `remote-plugins/*` khỏi marketplace gốc skills-hub.

## Sửa đổi

Đổi URL/mô tả → bump `version` trong plugin.json + CẢ HAI marketplace.json (gốc repo + nội bộ folder này).
