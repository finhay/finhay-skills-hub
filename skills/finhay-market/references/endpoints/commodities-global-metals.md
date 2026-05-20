# Commodities — Global Metals

## `GET /market/commodities/global/metals`

International gold, silver, and copper spot prices with daily price change. Uses the `market_data` table (`GOLD`, `SILVER`, `COPPER` types).

## `GET /market/commodities/global/metals/history`

Time-series for global gold, silver, or copper prices, descending by date.

---

### OpenAPI Spec

```yaml
/market/commodities/global/metals:
  get:
    summary: Global metals spot price
    operationId: getGlobalMetals
    tags:
      - Commodities
    parameters:
      - name: type
        in: query
        required: true
        schema:
          type: string
          enum: [gold, silver, copper]
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
                  nullable: true
                  allOf:
                    - $ref: '#/components/schemas/GlobalMetalSpot'
      '404':
        description: No data available for the requested type

/market/commodities/global/metals/history:
  get:
    summary: Global metals price history
    operationId: getGlobalMetalsHistory
    tags:
      - Commodities
    parameters:
      - name: type
        in: query
        required: true
        schema:
          type: string
          enum: [gold, silver, copper]
      - name: limit
        in: query
        required: false
        schema:
          type: integer
          default: 30
        description: Number of most recent records
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
                  type: object
                  properties:
                    type:
                      type: string
                      example: GOLD
                    currency:
                      type: string
                      example: USD
                    unit:
                      type: string
                      example: ounce
                      description: "ounce for gold/silver; pound for copper"
                    points:
                      type: array
                      items:
                        type: object
                        properties:
                          date:
                            type: string
                            example: "2026-05-01"
                          value:
                            type: number
                            example: 3230.5
```

### Response Key

`data`

### Components

```yaml
components:
  schemas:
    GlobalMetalSpot:
      type: object
      properties:
        type:
          type: string
          enum: [GOLD, SILVER, COPPER]
        price:
          type: object
          properties:
            value:
              type: number
              example: 3230.5
            currency:
              type: string
              example: USD
            unit:
              type: string
              description: "ounce for gold/silver; pound for copper"
              example: ounce
        change_percent:
          type: number
          nullable: true
          description: Change vs previous record
        date:
          type: string
          example: "2026-05-19"
```

### Notes

- `type` is required. Valid values: `gold`, `silver`, `copper`.
- Uses `MarketDataType.GOLD`, `MarketDataType.SILVER`, `MarketDataType.COPPER` from the `market_data` table.
- These are distinct from the VN metal endpoints which use the `financial_data` table.
- `change_percent` in the spot response is computed from the two most recent records.
- History `points` are ordered ascending (oldest first).
- Units: gold and silver are priced per **ounce**; copper is priced per **pound**.
- `data` is `null` if no record exists for the requested type.
