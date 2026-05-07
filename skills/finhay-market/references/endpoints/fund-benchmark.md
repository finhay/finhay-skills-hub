# Fund Benchmark

Three endpoints for comparing multiple funds side-by-side: investment growth simulation, NAV time series, and operational metrics.

---

## `GET /fund-trading/public/fund-certificates/benchmark/growth`

Simulate the projected return of a fixed VND investment across multiple funds over a period.

```yaml
/fund-trading/public/fund-certificates/benchmark/growth:
  get:
    summary: Simulate growth of a VND investment across funds
    operationId: getGrowthBenchmark
    tags:
      - Funds
    parameters:
      - name: fund-names
        in: query
        required: true
        schema:
          type: string
          example: VESAF,DCDS
        description: Comma-separated fund short names.
      - name: amount
        in: query
        required: true
        schema:
          type: integer
          format: int64
          example: 10000000
        description: Investment amount in VND.
      - name: period
        in: query
        required: true
        schema:
          type: string
          enum: [BEGIN_THE_YEAR, ONE_MONTH, THREE_MONTHS, SIX_MONTHS, ONE_YEAR, THREE_YEARS, FIVE_YEARS, SEVEN_YEARS, TEN_YEARS, ALL_TIME]
          example: ONE_YEAR
        description: Time window over which to simulate growth.
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
                  type: array
                  items:
                    $ref: '#/components/schemas/GrowthBenchmark'
```

---

## `GET /fund-trading/public/fund-certificates/benchmark/nav`

Compare NAV time series across funds (for charting on a shared axis).

```yaml
/fund-trading/public/fund-certificates/benchmark/nav:
  get:
    summary: Compare NAV time series across funds
    operationId: getNavBenchmark
    tags:
      - Funds
    parameters:
      - name: fund-names
        in: query
        required: true
        schema:
          type: string
          example: VESAF,DCDS
        description: Comma-separated fund short names.
      - name: period
        in: query
        required: false
        schema:
          type: string
          enum: [BEGIN_THE_YEAR, ONE_MONTH, THREE_MONTHS, SIX_MONTHS, ONE_YEAR, THREE_YEARS, FIVE_YEARS, SEVEN_YEARS, TEN_YEARS, ALL_TIME]
          example: ONE_YEAR
        description: Either `period` OR both `from-month` + `to-month` must be provided.
      - name: from-month
        in: query
        required: false
        schema:
          type: string
          example: "2024-01"
        description: Start month (`yyyy-MM`). Required if `period` omitted.
      - name: to-month
        in: query
        required: false
        schema:
          type: string
          example: "2024-12"
        description: End month (`yyyy-MM`). Required if `period` omitted.
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
                  type: array
                  items:
                    $ref: '#/components/schemas/NavBenchmark'
```

---

## `GET /fund-trading/public/fund-certificates/benchmark/operation`

Compare operational metrics (AUM, investor count, fund-flow) across funds.

```yaml
/fund-trading/public/fund-certificates/benchmark/operation:
  get:
    summary: Compare operational metrics across funds
    operationId: getOperationBenchmark
    tags:
      - Funds
    parameters:
      - name: fund-names
        in: query
        required: true
        schema:
          type: string
          example: VESAF,DCDS
        description: Comma-separated fund short names.
      - name: period
        in: query
        required: false
        schema:
          type: string
          enum: [BEGIN_THE_YEAR, ONE_MONTH, THREE_MONTHS, SIX_MONTHS, ONE_YEAR, THREE_YEARS, FIVE_YEARS, SEVEN_YEARS, TEN_YEARS, ALL_TIME]
          example: ONE_YEAR
        description: Either `period` OR both `from-month` + `to-month` must be provided.
      - name: from-month
        in: query
        required: false
        schema:
          type: string
          example: "2024-01"
        description: Start month (`yyyy-MM`). Required if `period` omitted.
      - name: to-month
        in: query
        required: false
        schema:
          type: string
          example: "2024-12"
        description: End month (`yyyy-MM`). Required if `period` omitted.
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
                  type: array
                  items:
                    $ref: '#/components/schemas/OperationBenchmark'
```

### Components

```yaml
components:
  schemas:
    GrowthBenchmark:
      type: object
      properties:
        fund_name: {type: string, example: VESAF}
        profit_percent: {type: number, example: 18.4}
        current_amount:
          type: integer
          description: Projected portfolio value in VND.
          example: 11840000

    NavBenchmark:
      type: object
      properties:
        fund_name: {type: string, example: VESAF}
        nav_records:
          type: array
          items:
            type: object
            properties:
              date: {type: string, example: "2024-12-31"}
              navpf: {type: number, example: 18234.56}
              change_percent: {type: number, example: 1.24}

    OperationBenchmark:
      type: object
      properties:
        fund_name: {type: string, example: VESAF}
        image_url: {type: string, format: uri}
        aum: {type: integer, description: Current AUM (VND).}
        changed_aum: {type: integer, description: AUM delta over the period (VND).}
        changed_aum_percent: {type: number}
        investors: {type: integer, description: Current investor count.}
        changed_investors: {type: integer}
        changed_investors_percent: {type: number}
        total_fund_flow: {type: integer, description: Net fund flow over the period (VND).}
        fund_flows:
          type: array
          items:
            $ref: '#/components/schemas/FundFlow'
    FundFlow:
      type: object
      properties:
        fund_name: {type: string}
        month: {type: string, example: "2024-12"}
        fund_flow: {type: integer}
        fund_inflow: {type: integer}
        fund_outflow: {type: integer}
```

### Notes

- `fund-names` is a comma-separated string parsed via `split(",")`. No repeated-query syntax.
- `benchmark/growth`: `period` is **required**; does not accept `from-month`/`to-month`.
- `benchmark/nav` and `benchmark/operation`: must provide either `period` OR both `from-month` AND `to-month`. Server returns 400 otherwise.
- `period` semantics: `BEGIN_THE_YEAR` = year-to-date; `ALL_TIME` ≈ 20 years.
- All monetary fields are in VND.
