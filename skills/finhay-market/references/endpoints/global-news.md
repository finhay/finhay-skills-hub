# Global News

## `GET /market/financial-data/global-news`

Retrieve a paginated list of global financial news articles, optionally filtered by category.

---

### OpenAPI Spec

```yaml
/market/financial-data/global-news:
  get:
    summary: List global financial news
    operationId: getGlobalNewsList
    tags:
      - Financial Data
    parameters:
      - name: category
        in: query
        required: false
        description: Filter by news category
        schema:
          type: string
          enum:
            - forex
            - commodities
            - economic-indicators
            - stock-market
            - cryptocurrency
          example: stock-market
      - name: page
        in: query
        required: false
        description: Page number (min 1, default 1)
        schema:
          type: integer
          minimum: 1
          default: 1
          example: 1
      - name: page_size
        in: query
        required: false
        description: Number of items per page (min 1, max 50, default 20)
        schema:
          type: integer
          minimum: 1
          maximum: 50
          default: 20
          example: 20
    responses:
      '200':
        description: Successful response
        content:
          application/json:
            schema:
              type: object
              properties:
                error_code:
                  type: string
                  example: "0"
                message:
                  type: string
                  example: success
                data:
                  $ref: '#/components/schemas/GlobalNewsPage'
```

### Response Key

`data`

### Components

```yaml
components:
  schemas:
    GlobalNewsPage:
      type: object
      properties:
        results:
          type: array
          items:
            $ref: '#/components/schemas/GlobalNewsListItem'
        page_total:
          type: integer
          description: Number of items in the current page
        total:
          type: integer
          description: Total number of matching articles
        current_page:
          type: integer
        next_page:
          type: integer
          nullable: true
        previous_page:
          type: integer
          nullable: true

    GlobalNewsListItem:
      type: object
      properties:
        id:
          type: integer
          description: Article ID (use for detail lookup)
        title:
          type: string
        url:
          type: string
          description: Original article URL
        description:
          type: string
          nullable: true
          description: Short summary of the article
        provider:
          type: string
          nullable: true
          description: News source/provider name
        published_at:
          type: string
          format: date-time
          description: Publication timestamp (ISO 8601)
        category:
          type: string
          enum:
            - forex
            - commodities
            - economic-indicators
            - stock-market
            - cryptocurrency
```

### Notes

- All query parameters are optional.
- `category` must be one of the enum values exactly (lowercase, hyphenated).
- Default page size is 20; maximum is 50.
- Use the `id` field from list items to fetch full article content via the detail endpoint.

---

## `GET /market/financial-data/global-news/:id`

Retrieve full details of a single global news article by its ID.

---

### OpenAPI Spec

```yaml
/market/financial-data/global-news/{id}:
  get:
    summary: Get global news article detail
    operationId: getGlobalNewsDetail
    tags:
      - Financial Data
    parameters:
      - name: id
        in: path
        required: true
        description: Article ID (from list endpoint)
        schema:
          type: integer
          example: 12
    responses:
      '200':
        description: Successful response
        content:
          application/json:
            schema:
              type: object
              properties:
                error_code:
                  type: string
                  example: "0"
                message:
                  type: string
                  example: success
                data:
                  $ref: '#/components/schemas/GlobalNewsDetail'
      '404':
        description: Article not found
        content:
          application/json:
            schema:
              type: object
              properties:
                error_code:
                  type: string
                  example: "404"
                message:
                  type: string
                  example: Global news not found
                data:
                  nullable: true
```

### Response Key

`data`

### Components

```yaml
components:
  schemas:
    GlobalNewsDetail:
      allOf:
        - $ref: '#/components/schemas/GlobalNewsListItem'
        - type: object
          properties:
            content:
              type: string
              nullable: true
              description: Full article body/content
```

### Notes

- Returns `404` with `error_code: "404"` if the article ID does not exist.
- `content` contains the full article body; `description` is a short summary (both also present from list).
