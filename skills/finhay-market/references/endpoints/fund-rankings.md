# Fund Rankings

Four ranking endpoints share the `/fund-trading/public/fund-certificates/top-*` prefix. The first three filter by `fund-type`; `top-holding-symbols` aggregates across all funds.

---

## `GET /fund-trading/public/fund-certificates/top-aum`

Top funds by AUM.

```yaml
/fund-trading/public/fund-certificates/top-aum:
  get:
    summary: Top funds by AUM
    operationId: getTopAum
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
        description: Fund category to rank.
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
                    $ref: '#/components/schemas/FundAum'
```

---

## `GET /fund-trading/public/fund-certificates/top-investor`

Top funds by number of investors.

```yaml
/fund-trading/public/fund-certificates/top-investor:
  get:
    summary: Top funds by investor count
    operationId: getTopInvestor
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
        description: Fund category to rank.
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
                    $ref: '#/components/schemas/FundInvestor'
```

---

## `GET /fund-trading/public/fund-certificates/top-fund-flow`

Top funds by net fund flow.

```yaml
/fund-trading/public/fund-certificates/top-fund-flow:
  get:
    summary: Top funds by net fund flow
    operationId: getTopFundFlow
    tags:
      - Funds
    parameters:
      - name: fund-type
        in: query
        required: true
        schema:
          type: string
          enum: [STOCK_FUND, BOND_FUND, BALANCE_FUND]
          example: BOND_FUND
        description: Fund category to rank.
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
                    $ref: '#/components/schemas/FundFlow'
```

---

## `GET /fund-trading/public/fund-certificates/top-holding-symbols`

Most-held symbols across all funds (no filter).

```yaml
/fund-trading/public/fund-certificates/top-holding-symbols:
  get:
    summary: Top symbols held across all funds
    operationId: getTopHoldingSymbols
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
                    $ref: '#/components/schemas/TopHoldingSymbol'
```

### Components

```yaml
components:
  schemas:
    FundAum:
      type: object
      properties:
        fund_name: {type: string, example: VESAF}
        month: {type: string, example: "2025-04"}
        aum: {type: integer, description: AUM in VND, example: 1500000000000}
    FundInvestor:
      type: object
      properties:
        fund_name: {type: string, example: VESAF}
        month: {type: string, example: "2025-04"}
        investors: {type: integer, example: 12450}
    FundFlow:
      type: object
      properties:
        fund_name: {type: string, example: VESAF}
        month: {type: string, example: "2025-04"}
        fund_flow:
          type: integer
          description: Net flow (VND) = inflow − outflow.
          example: 25000000000
        fund_inflow: {type: integer, example: 80000000000}
        fund_outflow: {type: integer, example: 55000000000}
    TopHoldingSymbol:
      type: object
      properties:
        symbol: {type: string, example: VNM}
        number_of_funds: {type: integer, example: 17}
```

### Notes

- `fund-type` is required for `top-aum`, `top-investor`, `top-fund-flow`.
- `top-holding-symbols` aggregates across all fund types.
- `month` is `YYYY-MM`; values are reported per-month, not real-time.
- `fund-type` enum: `STOCK_FUND` (Quỹ cổ phiếu), `BOND_FUND` (Quỹ trái phiếu), `BALANCE_FUND` (Quỹ cân bằng).
