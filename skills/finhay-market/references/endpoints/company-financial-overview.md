# Company Financial Overview

## `GET /market/company-financial/overview`

Retrieve key financial ratios and metrics for a stock symbol.

---

### OpenAPI Spec

```yaml
/market/company-financial/overview:
  get:
    summary: Get company financial overview
    operationId: getCompanyFinancialOverview
    tags:
      - Company Financial
    parameters:
      - name: symbol
        in: query
        required: true
        schema:
          type: string
          example: VNM
        description: Stock symbol (uppercase alphanumeric, e.g. `VNM`)
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
                  $ref: '#/components/schemas/FinancialOverview'
```

### Components

```yaml
components:
  schemas:
    FinancialOverview:
      type: object
      properties:
        pe:
          type: number
          nullable: true
          description: Price-to-Earnings ratio
        pb:
          type: number
          nullable: true
          description: Price-to-Book ratio
        ev_ebitda:
          type: number
          nullable: true
          description: EV/EBITDA ratio
        industry:
          type: object
          description: Industry average ratios
          properties:
            pe:
              type: number
              nullable: true
            pb:
              type: number
              nullable: true
            ev_ebitda:
              type: number
              nullable: true
        gross_margin:
          type: number
          nullable: true
          description: Gross profit margin
        roe:
          type: number
          nullable: true
          description: Return on Equity
        eps:
          type: number
          nullable: true
          description: Earnings per Share
        dividend_yield:
          type: number
          nullable: true
        nim:
          type: number
          nullable: true
          description: Net Interest Margin (banks only)
        margin_loan_to_equity_ratio:
          type: number
          nullable: true
          description: Margin loan to equity ratio (securities firms only)
        roa:
          type: number
          nullable: true
          description: Return on Assets
```

### Notes

- `symbol` is required and converted to uppercase.
- `industry` contains the sector-average values for the same ratios.
- `nim` and `margin_loan_to_equity_ratio` are only meaningful for banks and securities firms respectively.
