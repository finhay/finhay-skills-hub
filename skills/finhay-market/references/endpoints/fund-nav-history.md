# Fund NAV History

```yaml
/market/public/fund-certificates/{fundName}/nav-histories:
  get:
    summary: Historical NAV data
    parameters:
      - name: fundName
        in: path
        required: true
        schema: {type: string}
      - name: period
        in: query
        schema: {type: string, enum: [BEGIN_THE_YEAR, ONE_MONTH, THREE_MONTHS, SIX_MONTHS, ONE_YEAR, THREE_YEARS, FIVE_YEARS, SEVEN_YEARS, TEN_YEARS, ALL_TIME]}
    responses:
      '200':
        description: OK
        content:
          application/json:
            schema:
              type: object
              properties:
                data:
                  type: object
                  properties:
                    nav_histories:
                      type: array
                      items:
                        type: object
                        properties:
                          date: {type: string}
                          nav: {type: number}
                          benchmark_value: {type: number}
                    benchmark_name: {type: string}
```
