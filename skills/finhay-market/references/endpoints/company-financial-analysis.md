# Company Financial Analysis

## `GET /market/company-financial/analysis`

Retrieve historical financial metrics for a stock by period (annual or quarterly).

---

### OpenAPI Spec

```yaml
/market/company-financial/analysis:
  get:
    summary: Get company financial analysis over time
    operationId: getCompanyFinancialAnalysis
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
      - name: period
        in: query
        required: false
        schema:
          type: string
          enum: [annual, quarterly]
          example: annual
        description: Reporting period. Defaults to annual if omitted.
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
                    $ref: '#/components/schemas/FinancialAnalysisEntry'
```

### Components

```yaml
components:
  schemas:
    FinancialAnalysisEntry:
      type: object
      description: >
        Financial metrics for one period. Contains `year` always;
        `quarter` is present only when period=quarterly.
        All other fields are dynamic metric codes (e.g. pe, roe, eps, pb) with numeric or null values.
      properties:
        year:
          type: integer
          example: 2023
        quarter:
          type: integer
          nullable: true
          description: Present only for quarterly period (1–4)
          example: 2
      additionalProperties:
        type: number
        nullable: true
```

### Notes

- `period` values: `annual` or `quarterly`.
- Annual response: array of `{ year, <metricCode>: number | null, ... }`.
- Quarterly response: array of `{ year, quarter, <metricCode>: number | null, ... }`.
- Metric codes vary by company type (e.g. banks have `nim`, manufacturing has `gross_margin`).
