# Fund Companies

## `GET /market/public/fund-companies`
Retrieve a list of all fund management companies.

```yaml
/market/public/fund-companies:
  get:
    summary: Get all fund companies
    responses:
      '200':
        description: OK
        content:
          application/json:
            schema:
              type: object
              properties:
                data:
                  type: array
                  items:
                    type: object
                    properties:
                      id: {type: integer}
                      name: {type: string}
                      short_name: {type: string}
                      image_url: {type: string}
```
