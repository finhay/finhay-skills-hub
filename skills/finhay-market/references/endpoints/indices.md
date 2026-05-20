# Indices

## `GET /market/global-indices/:code/history`

Historical price series for a single global index.

---

### OpenAPI Spec

```yaml
/market/global-indices/{code}/history:
  get:
    summary: Get historical prices for a specific global index
    operationId: getIndexHistory
    tags:
      - Indices
    parameters:
      - name: code
        in: path
        required: true
        schema:
          type: string
          enum:
            - sp500
            - nasdaq
            - dow-jones
            - russell2000
            - vix
            - dxy
            - kospi
            - hangseng
            - shanghai
            - nikkei
        description: Index code (lowercase, kebab-case)
      - name: limit
        in: query
        required: false
        schema:
          type: integer
          default: 50
        description: Number of most recent records to return
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
                  type: array
                  items:
                    $ref: '#/components/schemas/IndexPoint'
      '400':
        description: Unknown index code
```

### Response Key

`data`

### Components

```yaml
components:
  schemas:
    IndexPoint:
      type: object
      properties:
        type:
          type: string
          example: SP500
        date:
          type: string
          example: "2026-05-19"
        value:
          type: number
          example: 5820.4
```

### Notes

- Valid `:code` values: `sp500`, `nasdaq`, `dow-jones`, `russell2000`, `vix`, `dxy`, `kospi`, `hangseng`, `shanghai`, `nikkei`. Returns `400` for any other value.
- Results are ordered descending by date (most recent first).
- For Mag7 stocks use `GET /market/tickers/global/:ticker/history`. For commodity prices use `GET /market/commodities/global/metals` or `GET /market/commodities/global/energy`.
