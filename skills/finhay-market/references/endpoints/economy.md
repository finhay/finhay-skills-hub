# Economy

## `GET /market/economy/snapshot`

Current value for a macro indicator (CPI, PMI, interest rate, GDP growth…).

## `GET /market/economy/indicators`

Historical economic indicators by country and category (GDP, Labour, Trade…).

## `GET /market/economy/calendar`

Upcoming economic events (CPI releases, Fed meetings, trade balance…).

---

### OpenAPI Spec

```yaml
/market/economy/snapshot:
  get:
    summary: Get current macro indicator value
    operationId: getEconomySnapshot
    tags:
      - Economy
    parameters:
      - name: type
        in: query
        required: true
        description: Macro data type
        schema:
          type: string
          enum:
            - IIP
            - CPI
            - PMI
            - PCE
            - CORE_PCE
            - NFP
            - FED_FUNDS_RATE
            - INTERBANK_RATE
            - GOVERNMENT_10Y_BOND_YIELD
            - UNEMPLOYMENT_RATE
      - name: country
        in: query
        required: true
        description: Country code
        schema:
          type: string
          enum: [VN, US, JP, DE]
          description: JP and DE are only available for GOVERNMENT_10Y_BOND_YIELD
      - name: period
        in: query
        required: false
        schema:
          type: string
          description: Period filter (optional, endpoint-specific)
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
                    $ref: '#/components/schemas/MacroDataPoint'

/market/economy/indicators:
  get:
    summary: Get historical economic indicators by country/category
    operationId: getEconomyIndicators
    tags:
      - Economy
    parameters:
      - name: country
        in: query
        required: true
        schema:
          type: string
          enum: [China, "Euro Area", Japan, "United States", "United Kingdom", Vietnam]
      - name: category
        in: query
        required: true
        schema:
          type: string
          enum: [GDP, Labour, Prices, Money, Trade, Government, Business, Consumer, Housing]
      - name: year
        in: query
        required: false
        schema:
          type: integer
          example: 2025
      - name: limit
        in: query
        required: false
        schema:
          type: integer
          default: 50
      - name: offset
        in: query
        required: false
        schema:
          type: integer
          default: 0
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
                    $ref: '#/components/schemas/TradingEconomicsData'

/market/economy/calendar:
  get:
    summary: Get upcoming economic events
    operationId: getEconomyCalendar
    tags:
      - Economy
    parameters:
      - name: weeks
        in: query
        required: false
        schema:
          type: integer
          default: 1
        description: Number of upcoming weeks to fetch events for
      - name: country
        in: query
        required: false
        schema:
          type: string
          example: "United States"
        description: Full country name (e.g. China, Vietnam, United States, Japan)
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
                    $ref: '#/components/schemas/EconomicCalendarEvent'
```

### Response Key

`data`

### Components

```yaml
components:
  schemas:
    MacroDataPoint:
      type: object
      properties:
        type:
          type: string
          example: CPI
        country:
          type: string
          example: VN
        month:
          type: string
          description: "YYYY-MM format"
          example: "2026-04"
        value:
          type: number
          example: 3.84
        date:
          type: string
          nullable: true
          description: Exact date (YYYY-MM-DD) if available

    TradingEconomicsData:
      type: object
      description: Shape mirrors the underlying trading economics records
      properties:
        country:
          type: string
          example: Vietnam
        category:
          type: string
          example: GDP
        title:
          type: string
        value:
          type: number
        unit:
          type: string
        date:
          type: string
        year:
          type: integer

    EconomicCalendarEvent:
      type: object
      description: Upcoming economic event
      properties:
        country:
          type: string
          example: "United States"
        event:
          type: string
          example: "Non Farm Payrolls"
        date:
          type: string
          format: date-time
        importance:
          type: string
          enum: [Low, Medium, High]
        actual:
          type: string
          nullable: true
        previous:
          type: string
          nullable: true
        forecast:
          type: string
          nullable: true
```

### Notes

- `type` and `country` are required for `/snapshot`; invalid values throw 500 (enum parse error — treat as 400).
- `country` for `/snapshot`: `JP` and `DE` are valid only for `GOVERNMENT_10Y_BOND_YIELD`.
- `/indicators`: all params are optional — omitting both `country` and `category` returns all records up to `limit`.
- `/calendar` `country` param is a full name string, not a code: `China`, `Vietnam`, `United States`, `Japan`, `United Kingdom`, `Euro Area`.
