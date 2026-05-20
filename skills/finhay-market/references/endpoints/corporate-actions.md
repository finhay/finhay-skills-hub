# Corporate Actions (VN)

## `GET /market/tickers/:ticker/corporate-actions`

Returns VN corporate actions for a specific ticker: dividends, AGM, rights issues, and other exchange announcements.

> For global financial news, use `GET /market/global-news` instead.

---

### OpenAPI Spec

```yaml
/market/tickers/{ticker}/corporate-actions:
  get:
    summary: Get VN corporate actions for a ticker
    operationId: getCorporateActions
    tags:
      - Securities
    parameters:
      - name: ticker
        in: path
        required: true
        description: Stock ticker symbol
        schema:
          type: string
          example: VNM
      - name: from_date
        in: query
        required: false
        description: Start date (DD/MM/YYYY)
        schema:
          type: string
          example: "01/01/2025"
      - name: to_date
        in: query
        required: false
        description: End date (DD/MM/YYYY)
        schema:
          type: string
          example: "31/12/2025"
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
                    $ref: '#/components/schemas/StockEvent'
```

### Response Key

`data`

### Components

```yaml
components:
  schemas:
    StockEvent:
      type: object
      properties:
        path:
          type: string
        title:
          type: string
        stock:
          type: string
          example: VNM
        body:
          type: string
          description: Event detail text
        createdDate:
          type: string
          description: Formatted "DD/MM - HH:mm"
          example: "15/05 - 09:30"
        actionDate:
          type: string
          description: Event effective date
        gdkhqDate:
          type: string
          description: Ex-dividend / record date
        eventType:
          type: string
        eventTypeName:
          type: string
        createdAt:
          type: string
          format: date-time
        updatedAt:
          type: string
          format: date-time
        url:
          type: string
          description: Full article URL
        id:
          type: integer
```

### Notes

- `:ticker` is required in path — returns corporate actions for that specific stock only.
- `from_date` / `to_date` are optional, format `DD/MM/YYYY`.
