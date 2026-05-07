# Fund Details

Per-fund detail endpoints sharing the `/fund-trading/public/fund-certificates/{fundName}/...` prefix. All take a single path param `fundName`.

---

## `GET /fund-trading/public/fund-certificates/{fundName}/portfolio`

Holdings breakdown for a fund.

```yaml
/fund-trading/public/fund-certificates/{fundName}/portfolio:
  get:
    summary: Get fund portfolio holdings
    operationId: getFundPortfolio
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
                    $ref: '#/components/schemas/FundPortfolioItem'
```

---

## `GET /fund-trading/public/fund-certificates/{fundName}/asset-allocation`

Asset allocation: bond/stock/others percentages.

```yaml
/fund-trading/public/fund-certificates/{fundName}/asset-allocation:
  get:
    summary: Get fund asset allocation
    operationId: getFundAssetAllocation
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
                  $ref: '#/components/schemas/AssetAllocation'
```

---

## `GET /fund-trading/public/fund-certificates/{fundName}/sector-allocation`

Sector exposure of the fund's holdings.

```yaml
/fund-trading/public/fund-certificates/{fundName}/sector-allocation:
  get:
    summary: Get fund sector allocation
    operationId: getFundSectorAllocation
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
                    $ref: '#/components/schemas/SectorAllocation'
```

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
    FundPortfolioItem:
      type: object
      description: One holding line (schema varies by fund type — stock, bond, cash).

    AssetAllocation:
      type: object
      properties:
        bond: {type: integer, description: "Bond percentage."}
        stock: {type: integer, description: "Stock percentage."}
        others: {type: integer, description: "Cash and other instruments."}

    SectorAllocation:
      type: object
      properties:
        sector_name: {type: string, example: "Banking"}
        percent: {type: number, example: 18.4}

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

- `asset-allocation` returns `null` (under `data`) for funds with no allocation record.
- `AssetAllocation` percentages are integers and sum to 100.
- `SuggestedFund.criteria` indicates which similarity heuristic produced each entry; results may include both criteria.
