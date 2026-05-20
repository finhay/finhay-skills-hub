# Global News

## `GET /market/global-news`

Returns paginated global financial news. Use `category` to filter by topic.

## `GET /market/global-news/:id`

Returns full content for a single global news article.

---

### OpenAPI Spec

```yaml
/market/global-news:
  get:
    summary: Get global financial news
    operationId: getMarketNews
    tags:
      - News
    parameters:
      - name: category
        in: query
        required: false
        description: News category filter
        schema:
          type: string
          enum: [forex, commodities, economic-indicators, stock-market, cryptocurrency]
      - name: page
        in: query
        required: false
        description: Page number (default 1)
        schema:
          type: integer
          default: 1
      - name: page_size
        in: query
        required: false
        description: Items per page (default 20, max 50)
        schema:
          type: integer
          default: 20
          maximum: 50
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
                  $ref: '#/components/schemas/GlobalNewsPagination'

/market/global-news/{id}:
  get:
    summary: Get global news article detail
    operationId: getMarketNewsDetail
    tags:
      - News
    parameters:
      - name: id
        in: path
        required: true
        schema:
          type: integer
          example: 42
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
                  $ref: '#/components/schemas/GlobalNewsDetail'
      '400':
        description: id is not a valid integer
      '404':
        description: Article not found
```

### Response Key

`data`

### Components

```yaml
components:
  schemas:
    GlobalNewsListItem:
      type: object
      properties:
        id:
          type: integer
        title:
          type: string
        url:
          type: string
        description:
          type: string
          nullable: true
        provider:
          type: string
          nullable: true
        published_at:
          type: string
          format: date-time
        category:
          type: string
          enum: [forex, commodities, economic-indicators, stock-market, cryptocurrency]

    GlobalNewsDetail:
      allOf:
        - $ref: '#/components/schemas/GlobalNewsListItem'
        - type: object
          properties:
            content:
              type: string
              nullable: true
              description: Full HTML/text article body

    GlobalNewsPagination:
      type: object
      properties:
        results:
          type: array
          items:
            $ref: '#/components/schemas/GlobalNewsListItem'
        total:
          type: integer
        current_page:
          type: integer
        next_page:
          type: integer
          nullable: true
        previous_page:
          type: integer
          nullable: true
        page_size:
          type: integer
```

### Notes

- `/market/global-news` returns global financial news only. VN corporate events (sự kiện quyền) are at `/stock-events`.
- `GET /market/global-news/:id` returns full article content; id must be an integer.
- `category` is optional — omit to get all categories.
