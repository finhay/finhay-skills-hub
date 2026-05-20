# Ticker Statements

## `GET /market/tickers/:ticker/statements`

Retrieve financial statements (income statement, balance sheet, or cash flow) for a stock.

---

### OpenAPI Spec

```yaml
/market/tickers/{ticker}/statements:
  get:
    summary: Get financial statements for a ticker
    operationId: getTickerStatements
    tags:
      - Tickers
    parameters:
      - name: ticker
        in: path
        required: true
        schema:
          type: string
          example: HPG
      - name: statement
        in: query
        required: true
        schema:
          type: string
          enum: [income-statement, balance-sheet, cash-flow]
      - name: period
        in: query
        required: true
        schema:
          type: string
          enum: [annual, quarterly]
      - name: limit
        in: query
        required: false
        schema:
          type: integer
          default: 5
        description: Number of periods to return (max 20)
    responses:
      '200':
        description: Successful response
        content:
          application/json:
            schema:
              type: object
              properties:
                status:
                  type: integer
                  example: 200
                data:
                  description: Statement data (shape varies by statement type)
                  type: object
      '400':
        description: statement or period is missing or invalid
```

### Response Key

`data`

### Notes

- `statement` is required. Valid values: `income-statement`, `balance-sheet`, `cash-flow`.
- `period` is required. Valid values: `annual`, `quarterly`.
- `limit` defaults to 5 (most recent periods), max 20.
- The shape of `data` varies by `statement` type.
