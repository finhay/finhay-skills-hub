# Authentication

All requests require HMAC-SHA256 signed headers. Use `request.sh` — it handles signing automatically. Do not construct signed requests manually.

## Credentials

File: `~/.finhay/credentials/.env`

```bash
FINHAY_API_KEY=ak_test_...
FINHAY_API_SECRET=64_char_hex_secret
FINHAY_BASE_URL=https://open-api.fhsc.com.vn
```

| Variable | Required | Description |
|----------|----------|-------------|
| `FINHAY_API_KEY` | Yes | Sent as `X-FH-APIKEY` header |
| `FINHAY_API_SECRET` | Yes | HMAC-SHA256 signing key |
| `FINHAY_BASE_URL` | No | Defaults to `https://open-api.fhsc.com.vn` |

## Request Headers

| Header | Value |
|--------|-------|
| `X-FH-APIKEY` | `FINHAY_API_KEY` |
| `X-FH-TIMESTAMP` | `Date.now()` in milliseconds |
| `X-FH-NONCE` | 16 random bytes, hex-encoded |
| `X-FH-SIGNATURE` | HMAC-SHA256 of signing input, hex-encoded |

## Signing Input

```
{TIMESTAMP}\n{METHOD}\n{REQUEST_PATH}\n
```

## Rate Limits
On `429`: wait until the time specified in `X-RateLimit-Reset` before retrying.
