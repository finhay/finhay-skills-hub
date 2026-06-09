# Index Realtime

## `GET /market/index-realtime`

Retrieve realtime market **index** data (VNINDEX, HNX30, …). Accepts `index` — one or more index codes, comma-separated.

---

### OpenAPI Spec

```yaml
/market/index-realtime:
  get:
    summary: Get realtime market index data
    operationId: getIndexRealtime
    tags:
      - Stock
    parameters:
      - name: index
        in: query
        description: >
          Index code(s), comma-separated. Pass one (`VNINDEX`) or many
          (`VNINDEX,HNX30`). One result entry is returned per code.
        required: true
        schema:
          type: string
          enum: [VNINDEX, HNXINDEX, UPCOMINDEX, VN30, HNX30]
          example: VNINDEX
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
                result:
                  description: Array of `IndexRealtime` — one entry per requested index code.
                  type: array
                  items:
                    $ref: '#/components/schemas/IndexRealtime'
      '400':
        description: Invalid request
```

### Response Key

`result` (array). Along with `stock-realtime`, one of only two market endpoints that use `result` instead of `data`.

### Components

```yaml
components:
  schemas:
    IndexRealtime:
      type: object
      properties:
        index:
          type: string
          example: VNINDEX
          description: Index code (echoes the requested `index`).
        indexValue:
          type: number
          example: 1792.6
          description: Current index points value.
        change:
          type: number
          example: 2.07
          description: Point change from reference.
        changePercent:
          type: number
          example: 0.12
          description: Percent change from reference (already in percent units, e.g. 0.12 = 0.12%).
        reference:
          type: number
          example: 1790.53
          description: Reference value — previous session close.
        allQuantity:
          type: integer
          format: int64
          example: 248009131
          description: Total matched volume across the market (shares).
        allValue:
          type: number
          description: Total matched trading value across the market (VND).
        advances:
          type: integer
          description: Number of advancing symbols.
        declines:
          type: integer
          description: Number of declining symbols.
        nochanges:
          type: integer
          description: Number of unchanged symbols.
        ceiling:
          type: integer
          description: Number of symbols at ceiling price.
        floor:
          type: integer
          description: Number of symbols at floor price.
        values:
          type: array
          items:
            type: number
          description: Intraday index point series (index-aligned with times/volumes).
        volumes:
          type: array
          items:
            type: number
          description: Intraday volume series (index-aligned with times/values).
        times:
          type: array
          items:
            type: integer
            format: int64
          description: Intraday timestamp series — Unix ms.
        advancesArr:
          type: array
          items:
            type: integer
          description: Intraday advancing-symbol series. KRX indices only.
        declinesArr:
          type: array
          items:
            type: integer
          description: Intraday declining-symbol series. KRX indices only.
        nochangesArr:
          type: array
          items:
            type: integer
          description: Intraday unchanged-symbol series. KRX indices only.
        ceilings:
          type: array
          items:
            type: integer
          description: Intraday ceiling-count series. KRX indices only.
        floors:
          type: array
          items:
            type: integer
          description: Intraday floor-count series. KRX indices only.
        sessionInExchange:
          type: string
          description: Current trading session state of the exchange.
        name:
          type: string
          example: VNINDEX
          description: Index name (currently same as `index`).
```

### Notes

- `result` is **always an array** — one entry per requested code; a single `index=VNINDEX` still returns a 1-element array. Unknown/invalid codes are silently skipped (shorter array, possibly empty).
- `indexValue` / `change` / `reference` are in **index points**, not VND.
- `changePercent` is already in **percent** units (e.g. `0.12` = 0.12%), not a 0–1 ratio.
- Breadth fields (`advances` / `declines` / `nochanges` / `ceiling` / `floor`) and intraday series (`values` / `volumes` / `times`) are only present in full mode.
- The `*Arr` / `ceilings` / `floors` intraday series apply to **KRX-system indices only**.
