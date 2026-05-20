# Commodities — VN Metals

## `GET /market/commodities/vn/metals`

Current spot price for a single metal type (gold or silver) — returns one record. For prices across all providers use `GET /market/commodities/vn/metals/providers`.

## `GET /market/commodities/vn/metals/history`

N-day price history series per provider and product.

## `GET /market/commodities/vn/metals/providers`

List of distinct providers available for gold/silver.

---

### OpenAPI Spec

```yaml
/market/commodities/vn/metals:
  get:
    summary: VN metals spot price (single record)
    operationId: getVnMetals
    tags:
      - Commodities
    parameters:
      - name: type
        in: query
        required: true
        schema:
          type: string
          enum: [gold_bar, gold_ring, silver_bar]
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
                    - $ref: '#/components/schemas/VnMetalSpot'

/market/commodities/vn/metals/history:
  get:
    summary: VN metals price history
    operationId: getVnMetalsHistory
    tags:
      - Commodities
    parameters:
      - name: type
        in: query
        required: true
        schema:
          type: string
          enum: [gold_bar, gold_ring, silver_bar]
      - name: days
        in: query
        required: false
        schema:
          type: integer
          default: 30
        description: Number of past days to include
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
                      example: GOLD_RING
                    provider:
                      type: string
                      nullable: true
                      example: DOJI
                    currency:
                      type: string
                      example: VND
                    unit:
                      type: string
                      example: chi
                    scale:
                      type: integer
                      example: 1000
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
                            example: 16600

/market/commodities/vn/metals/providers:
  get:
    summary: VN metals spot prices across all providers
    operationId: getVnMetalsProviders
    tags:
      - Commodities
    parameters:
      - name: type
        in: query
        required: true
        schema:
          type: string
          enum: [gold_bar, gold_ring, silver_bar]
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
                    type: string
                  example: [SJC, PNJ, DOJI, BTMC]
```

### Response Key

`data`

### Components

```yaml
components:
  schemas:
    VnMetalSpot:
      type: object
      properties:
        provider:
          type: string
          example: SJC
        product:
          type: string
          description: Internal product key
          example: GOLD_BAR
        name:
          type: string
          description: Display name
          example: Vàng SJC 1L
        buy_price:
          type: object
          properties:
            value:
              type: number
              example: 9250
            currency:
              type: string
              example: VND
            unit:
              type: string
              example: chi
            scale:
              type: integer
              example: 1000
              description: Multiply value × scale to get actual VND amount
        sell_price:
          type: object
          properties:
            value:
              type: number
              example: 9450
            currency:
              type: string
              example: VND
            unit:
              type: string
              example: chi
            scale:
              type: integer
              example: 1000
        change_percent:
          type: object
          properties:
            buy:
              type: number
              nullable: true
              description: Buy price change % vs previous record
            sell:
              type: number
              nullable: true
        date:
          type: string
          example: "2026-05-19"
        updated_at:
          type: string
          format: date-time

    VnMetalSeries:
      type: object
      properties:
        provider:
          type: string
          example: SJC
        product:
          type: string
          example: GOLD_BAR
        points:
          type: array
          description: Daily price points ascending
          items:
            type: object
            properties:
              date:
                type: string
                example: "2026-05-01"
              buy:
                type: number
                example: 91000000
              sell:
                type: number
                example: 93000000
```

### Notes

- `type` is required for all three endpoints. Valid values: `gold_bar`, `gold_ring`, `silver_bar`.
- `/metals` returns the first available record — use `/metals/providers` to get prices across all providers (SJC, PNJ, DOJI, BTMC…).
- Only VN domestic providers are included (`GLOBAL_*` indexes excluded).
- `data` is `null` if no record exists for the requested type.
- Price unit: `value` is in **nghìn đồng/chỉ** (1 chỉ = 3.75g). Multiply `value × scale (1000)` to get actual VND. Example: `value: 9250, scale: 1000` → 9,250,000 VND/chỉ.
