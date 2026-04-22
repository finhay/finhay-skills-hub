# Economic Calendar Events

## `GET /market/financial-data/economic-calendar-events`

Retrieve upcoming global economic events (CPI releases, Fed meetings, PMI announcements, etc.).

---

### OpenAPI Spec

```yaml
/market/financial-data/economic-calendar-events:
  get:
    summary: Get upcoming economic calendar events
    operationId: getEconomicCalendarEvents
    tags:
      - Financial Data
    parameters:
      - name: weeks
        in: query
        required: false
        description: Number of weeks ahead to fetch events (default 1)
        schema:
          type: integer
          default: 1
          example: 2
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
    EconomicCalendarEvent:
      type: object
      properties:
        id:
          type: integer
          example: 1
        date:
          type: string
          description: Event date in `YYYY-MM-DD` format
          example: "2026-04-25"
        country:
          type: string
          description: Country name
          enum:
            - China
            - Euro Area
            - Japan
            - United States
            - United Kingdom
            - Vietnam
          example: "United States"
        event:
          type: string
          description: Event name
          example: "Fed Interest Rate Decision"
        actual:
          type: string
          description: Actual value (empty if not yet released)
          example: "5.50%"
        previous:
          type: string
          description: Previous period value
          example: "5.25%"
        consensus:
          type: string
          description: Market consensus forecast
          example: "5.50%"
        forecast:
          type: string
          description: Analyst forecast
          example: "5.50%"
        impact:
          type: integer
          description: Impact level (1 = low, 2 = medium, 3 = high)
          example: 3
        category:
          type: string
          description: Event category
          example: "Interest Rate"
```

### Notes

- `weeks` defaults to 1 — returns events from today through the next 7 days.
- Results are sorted ascending by `date`.
- Data is cached with a TTL of 1 hour.
- `actual` is empty string if the event has not yet occurred.
- Only events for the following countries are available: China, Euro Area, Japan, United States, United Kingdom, Vietnam.
