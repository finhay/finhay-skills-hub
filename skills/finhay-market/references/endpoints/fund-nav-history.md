# Fund NAV History

## `GET /fund-trading/public/fund-certificates/{fundName}/nav-histories`

Historical NAV time series for a single fund, returned alongside the matching benchmark index series for charting.

---

### OpenAPI Spec

```yaml
/fund-trading/public/fund-certificates/{fundName}/nav-histories:
  get:
    summary: Get fund NAV history with benchmark
    operationId: getFundNavHistories
    tags:
      - Funds
    parameters:
      - name: fundName
        in: path
        required: true
        schema:
          type: string
          example: VESAF
        description: Fund short name.
      - name: period
        in: query
        required: false
        schema:
          type: string
          enum: [BEGIN_THE_YEAR, ONE_MONTH, THREE_MONTHS, SIX_MONTHS, ONE_YEAR, THREE_YEARS, FIVE_YEARS, SEVEN_YEARS, TEN_YEARS, ALL_TIME]
          default: ALL_TIME
          example: ONE_YEAR
        description: Time window. Defaults to `ALL_TIME` when omitted.
    responses:
      '200':
        description: Successful response
        content:
          application/json:
            schema:
              type: object
              properties:
                error_code: {type: string, example: "0"}
                message: {type: string, example: success}
                data:
                  $ref: '#/components/schemas/NavHistories'
```

### Components

```yaml
components:
  schemas:
    NavHistories:
      type: object
      properties:
        nav_histories:
          type: array
          items:
            type: object
            properties:
              date: {type: string, example: "2025-04-30"}
              nav: {type: number, example: 18234.56}
              benchmark_value:
                type: number
                description: Benchmark index value on the same date.
                example: 1284.91
        benchmark_name:
          type: string
          description: Benchmark name (e.g. `VN-INDEX` for stock funds).
          example: VN-INDEX
```

### Notes

- `BEGIN_THE_YEAR` = year-to-date.
- `ALL_TIME` ≈ 20 years; use only when a long history is genuinely needed.
- The server returns NAV records and the benchmark series clipped to the same date range so they can be charted on a shared X axis.
