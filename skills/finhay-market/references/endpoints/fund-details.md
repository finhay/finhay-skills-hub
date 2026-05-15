# Fund Details

Per-fund detail endpoint under `/fund-trading/public/fund-certificates/{fundName}/...`. Takes a single path param `fundName`.

---

## `GET /fund-trading/public/fund-certificates/{fundName}/suggestions`

Similar funds suggested by criteria (NAV size or growth).

```yaml
/fund-trading/public/fund-certificates/{fundName}/suggestions:
  get:
    summary: Get suggested similar funds
    operationId: getFundSuggestions
    tags:
      - Funds
    parameters:
      - name: fundName
        in: path
        required: true
        schema: {type: string, example: VESAF}
        description: Fund short name.
    responses:
      '200':
        description: Successful response
        content:
          application/json:
            schema:
              type: object
              properties:
                error_code: {type: string, example: "0"}
                message: {type: string, example: success}
                data:
                  type: array
                  items:
                    $ref: '#/components/schemas/SuggestedFund'
```

### Components

```yaml
components:
  schemas:
    SuggestedFund:
      type: object
      properties:
        fund_name: {type: string, example: DCDS}
        criteria:
          type: string
          enum: [NET_ASSET_EQUIVALENT, GROWTH_EQUIVALENT]
          description: |
            How the fund was matched:
            - `NET_ASSET_EQUIVALENT`: similar AUM size.
            - `GROWTH_EQUIVALENT`: similar historical growth profile.
```

### Notes

- `SuggestedFund.criteria` indicates which similarity heuristic produced each entry; results may include both criteria.
