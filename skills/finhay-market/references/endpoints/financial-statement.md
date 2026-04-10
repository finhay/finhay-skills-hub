# Financial Statement V2

## `GET /market/v2/financial-statement/statement`

Retrieve financial statement data in a normalized metric-value format. Each row represents one metric for one period, suitable for charting and comparison.

---

### OpenAPI Spec

```yaml
/market/v2/financial-statement/statement:
  get:
    summary: Get financial statement (v2 — metric-value format)
    operationId: getFinancialStatementV2
    tags:
      - Company Financial
    parameters:
      - name: symbol
        in: query
        required: true
        schema:
          type: string
          example: VNM
        description: Stock symbol (uppercase alphanumeric)
      - name: type
        in: query
        required: true
        schema:
          type: string
          enum: [income-statement, balance-sheet, cash-flow]
          example: income-statement
        description: Statement type
      - name: period
        in: query
        required: false
        schema:
          type: string
          enum: [annual, quarterly]
          example: annual
        description: Reporting period
      - name: limit
        in: query
        required: false
        schema:
          type: integer
          minimum: 1
          maximum: 5
          default: 5
          example: 5
        description: Number of periods to return (1–5, default 5)
    responses:
      '200':
        description: Successful response
        content:
          application/json:
            schema:
              type: object
              properties:
                error_code:
                  type: string
                  example: "0"
                message:
                  type: string
                  example: success
                data:
                  type: array
                  items:
                    $ref: '#/components/schemas/FinancialMetricValue'
```

### Components

```yaml
components:
  schemas:
    FinancialMetricValue:
      type: object
      description: One metric value for one period.
      properties:
        symbol:
          type: string
          example: VNM
        metricCode:
          type: string
          description: Metric identifier (e.g. "tongDoanhThu", "lnst")
          example: tongDoanhThu
        metricValue:
          type: number
          example: 12500000000000
        timeType:
          type: string
          description: Period type identifier
          example: annual
        year:
          type: integer
          example: 2023
        quarter:
          type: integer
          description: "0 for annual records"
          example: 0
```

### Notes

- Same parameters as `GET /financial-statement/statement` but different response shape.
- V1 returns one object per period with all fields; V2 returns one row per metric per period.
- V2 is better suited for time-series queries (e.g. "show me net profit over 5 years").
- `quarter` is `0` for annual records.
