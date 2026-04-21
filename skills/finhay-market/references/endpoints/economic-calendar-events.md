# Economic Calendar Events

## `GET /market/financial-data/economic-calendar-events`

Retrieve upcoming economic calendar events (CPI releases, FOMC meetings, NFP, GDP prints, etc.) within the next N weeks.

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
        description: Look-ahead window in weeks from today (00:00). Defaults to 1.
        schema:
          type: integer
          minimum: 1
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
          description: Event ID
          example: 12345
        date:
          type: string
          description: Event datetime in `YYYY-MM-DD HH:mm:ss` format
          example: "2026-04-25 19:30:00"
        country:
          type: string
          description: Country code or name of the issuing economy
          example: US
        event:
          type: string
          description: Event name
          example: "CPI YoY"
        actual:
          type: string
          description: Actual reported value (empty string if event has not occurred yet)
          example: "3.2%"
        previous:
          type: string
          description: Previous period value
          example: "3.1%"
        consensus:
          type: string
          description: Market consensus estimate
          example: "3.3%"
        forecast:
          type: string
          description: Forecast value
          example: "3.3%"
        impact:
          type: integer
          description: Expected market impact (e.g. 1 = low, 2 = medium, 3 = high)
          example: 3
        category:
          type: string
          description: Event category (e.g. "Inflation", "Employment", "Central Bank")
          example: "Inflation"
```

### Notes

- `weeks` defaults to `1`. Window starts at today 00:00 and ends `weeks * 7` days later.
- Results are sorted by `date` ascending.
- `actual` is typically empty for future events and populated after release.
- `impact` is returned as a number; values come from the source feed.
- Cached server-side for 60 minutes per `weeks` value.
