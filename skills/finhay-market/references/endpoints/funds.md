# Funds

## `GET /fund-trading/public/fund-certificates`

List funds filtered by type (and optionally by management company), sorted by 1-year average profit (descending).

---

### OpenAPI Spec

```yaml
/fund-trading/public/fund-certificates:
  get:
    summary: Get fund list
    operationId: getFundCertificates
    tags:
      - Funds
    parameters:
      - name: fund-type
        in: query
        required: true
        schema:
          type: string
          enum: [STOCK_FUND, BOND_FUND, BALANCE_FUND]
          example: STOCK_FUND
        description: Fund category.
      - name: fund-company-id
        in: query
        required: false
        schema:
          type: integer
          format: int64
          example: 12
        description: Filter by management company ID. See `/fund-trading/public/fund-companies`.
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
                    $ref: '#/components/schemas/FundCertificate'
```

### Components

```yaml
components:
  schemas:
    FundCertificate:
      type: object
      properties:
        id: {type: integer, example: 21}
        name: {type: string, example: VESAF}
        type:
          type: string
          enum: [STOCK_FUND, BOND_FUND, BALANCE_FUND]
        aum:
          type: integer
          description: Assets under management in VND.
          example: 1500000000000
        rating: {type: number, example: 4.5}
```

### Notes

- `fund-type` is **required**.
- Manulife fund (`id=36`) is filtered server-side and never appears.
- Results sorted by 1-year average profit (desc).
