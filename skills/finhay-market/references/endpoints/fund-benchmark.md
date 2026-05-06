# Fund Benchmark

```yaml
/market/public/fund-certificates/benchmark/growth:
  get:
    summary: Compare fund growth
    parameters:
      - name: fund-names
        in: query
        required: true
        schema: {type: string}
      - name: amount
        in: query
        required: true
        schema: {type: integer}
      - name: period
        in: query
        required: true
        schema: {type: string, enum: [BEGIN_THE_YEAR, ONE_MONTH, THREE_MONTHS, SIX_MONTHS, ONE_YEAR, THREE_YEARS, FIVE_YEARS, SEVEN_YEARS, TEN_YEARS, ALL_TIME]}
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
                      profit_percent: {type: number}
                      current_amount: {type: integer}

/market/public/fund-certificates/benchmark/nav:
  get:
    summary: Compare fund NAV trends
    parameters:
      - name: fund-names
        in: query
        required: true
        schema: {type: string}
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
                      nav_records:
                        type: array
                        items:
                          type: object
                          properties:
                            date: {type: string}
                            navpf: {type: number}
                            change_percent: {type: number}
```
