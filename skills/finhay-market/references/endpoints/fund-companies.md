# Fund Companies

## `GET /fund-trading/public/fund-companies`

List all fund management companies (used for the `fund-company-id` filter on `/fund-certificates`).

---

### OpenAPI Spec

```yaml
/fund-trading/public/fund-companies:
  get:
    summary: Get all fund management companies
    operationId: getFundCompanies
    tags:
      - Funds
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
                    $ref: '#/components/schemas/FundCompany'
```

### Components

```yaml
components:
  schemas:
    FundCompany:
      type: object
      properties:
        id: {type: integer, example: 12}
        name: {type: string, example: "Công ty Quản lý quỹ Vietcombank"}
        short_name: {type: string, example: VCBF}
        image_url: {type: string, format: uri}
```

### Notes

- No parameters; full list returned in one call.
- `id` is the value to pass as `fund-company-id` on the fund list endpoint.
