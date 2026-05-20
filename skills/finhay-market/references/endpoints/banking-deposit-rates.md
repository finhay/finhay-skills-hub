# Banking Deposit Rates

## `GET /market/banking/deposit-rates`

Current bank deposit interest rates from major Vietnamese banks.

---

### OpenAPI Spec

```yaml
/market/banking/deposit-rates:
  get:
    summary: Get bank deposit interest rates
    operationId: getBankingDepositRates
    tags:
      - Banking
    parameters: []
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
                  description: Bank interest rate records (shape from upstream provider)
                  oneOf:
                    - type: array
                      items:
                        $ref: '#/components/schemas/BankInterestRate'
                    - type: object
```

### Response Key

`data`

### Components

```yaml
components:
  schemas:
    BankInterestRate:
      type: object
      description: Interest rate record from a bank
      properties:
        bank:
          type: string
          description: Bank name or code
          example: Vietcombank
        term:
          type: string
          description: Deposit term (e.g. 1 month, 6 months, 12 months)
          example: "12 tháng"
        rate:
          type: number
          description: Annual interest rate (percentage)
          example: 5.8
        updated_at:
          type: string
          format: date-time
          nullable: true
```

### Notes

- No parameters — returns all available bank deposit rate records.
- The exact shape of `data` depends on the upstream source stored in `financial_data`; the schema above is approximate.
- Rates are in percentage per year (e.g. `5.8` = 5.8% p.a.).
