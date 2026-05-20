# Commodities — Global Energy

## `GET /market/commodities/global/energy`

Spot prices for crude oil, Brent oil, and natural gas with daily change.

## `GET /market/commodities/global/energy/history`

Time-series for a specific energy commodity, descending by date.

---

### OpenAPI Spec

```yaml
/market/commodities/global/energy:
  get:
    summary: Global energy spot prices
    operationId: getGlobalEnergy
    tags:
      - Commodities
    parameters:
      - name: type
        in: query
        required: false
        schema:
          type: string
          enum: [crude-oil, brent-oil, natural-gas, all]
          default: all
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
                    $ref: '#/components/schemas/GlobalEnergySpot'

/market/commodities/global/energy/history:
  get:
    summary: Global energy price history
    operationId: getGlobalEnergyHistory
    tags:
      - Commodities
    parameters:
      - name: type
        in: query
        required: true
        schema:
          type: string
          enum: [crude-oil, brent-oil, natural-gas]
        description: Specific energy type (required — `all` not supported for history)
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
                  type: array
                  items:
                    $ref: '#/components/schemas/MarketData'
      '400':
        description: Unknown energy type
```

### Response Key

`data`

### Components

```yaml
components:
  schemas:
    GlobalEnergySpot:
      type: object
      properties:
        type:
          type: string
          enum: [crude-oil, brent-oil, natural-gas]
        price:
          type: object
          properties:
            value:
              type: number
              example: 78.42
            currency:
              type: string
              example: USD
            unit:
              type: string
              description: "crude-oil/brent-oil: barrel; natural-gas: MMBtu"
              example: barrel
        change_percent:
          type: number
          nullable: true
          description: Change vs previous record
        date:
          type: string
          example: "2026-05-19"

    MarketData:
      type: object
      properties:
        type:
          type: string
          enum: [CRUDE_OIL, BRENT_OIL, NATURAL_GAS]
        country:
          type: string
        date:
          type: string
          example: "2026-05-19"
        year:
          type: integer
        month:
          type: integer
        value:
          type: number
```

### Notes

- `type` mapping: `crude-oil` → `MarketDataType.CRUDE_OIL`, `brent-oil` → `BRENT_OIL`, `natural-gas` → `NATURAL_GAS`.
- Units: crude oil and Brent oil are priced per barrel (USD); natural gas per MMBtu (USD).
- History endpoint requires a specific `type` — `all` is not accepted.
- History results are ordered descending (most recent first).
