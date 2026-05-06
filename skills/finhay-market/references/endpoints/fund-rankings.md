# Fund Rankings

```yaml
/market/public/fund-certificates/top-aum:
  get:
    summary: Top funds by AUM
    parameters:
      - name: fund-type
        in: query
        required: true
        schema: {type: string, enum: [STOCK_FUND, BOND_FUND, BALANCE_FUND]}
    responses:
      '200':
        description: OK
        content:
          application/json:
            schema:
              type: object
              properties:
                data:
                  type: array
                  items:
                    type: object
                    properties:
                      fund_name: {type: string}
                      month: {type: string}
                      aum: {type: integer}

/market/public/fund-certificates/top-holding-symbols:
  get:
    summary: Top holding symbols across funds
    responses:
      '200':
        description: OK
        content:
          application/json:
            schema:
              type: object
              properties:
                data:
                  type: array
                  items:
                    type: object
                    properties:
                      symbol: {type: string}
                      number_of_funds: {type: integer}
```
