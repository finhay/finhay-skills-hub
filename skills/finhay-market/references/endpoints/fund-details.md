# Fund Details & Allocation

```yaml
/market/public/fund-certificates/{fundName}/portfolio:
  get:
    summary: Get fund portfolio holdings
    parameters:
      - name: fundName
        in: path
        required: true
        schema: {type: string}
    responses:
      '200':
        description: OK

/market/public/fund-certificates/{fundName}/asset-allocation:
  get:
    summary: Fund asset allocation
    parameters:
      - name: fundName
        in: path
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
                  type: object
                  properties:
                    bond: {type: integer}
                    stock: {type: integer}
                    others: {type: integer}

/market/public/fund-certificates/{fundName}/sector-allocation:
  get:
    summary: Fund sector allocation
    parameters:
      - name: fundName
        in: path
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
                      sector_name: {type: string}
                      percent: {type: number}

/market/public/fund-certificates/{fundName}/suggestions:
  get:
    summary: Suggested similar funds
    parameters:
      - name: fundName
        in: path
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
                      criteria: {type: string, enum: [NET_ASSET_EQUIVALENT, GROWTH_EQUIVALENT]}
```
