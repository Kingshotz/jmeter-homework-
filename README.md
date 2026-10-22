# JMeter + SQL Server homework

`sql-reqres-users-test.jmx` reads users from SQL Server and checks each of them against https://reqres.in.

## Files

| File | What it is |
|---|---|
| `sql-reqres-users-test.jmx` | Test plan |
| `results.csv` | Results of the non-GUI run |
| `cli-nongui-run.png` | Screenshot of the non-GUI run in the console |
| `jmeter.log` | Log of the same run, contains the If Controller warning |
| `setup-testusers.sql` | Creates the `JMeterHomework` database, `TestUsers` table and the read-only `jmeter_user` login |
| `run-nongui.cmd` | Runs the plan in non-GUI mode and writes `results.csv` |

## Test plan

1. **SQL Server (JDBC Request)**: `JDBC Connection Configuration` connects to `localhost\SQLEXPRESS` (TCP 1433).
   `Step 1 - Fetch TestUsers` runs `SELECT id, first_name, last_name, email FROM dbo.TestUsers` and stores the
   columns as JMeter variables `id_1..id_N`, `first_name_1..`, `last_name_1..`, `email_1..` (`id_#` = row count).
2. **Parameterization & correlation**: `Step 2 - GET /api/users/${userId}` uses the id from the database and is sent
   without an API key. A JSON Extractor takes `$.error` into `errorMessage`, and a Response Assertion with
   *Ignore Status* checks that it equals `Missing API Key`.
3. **Email pattern**: `Step 3 - GET /api/users?per_page=12` is sent with the `x-api-key` header (classic API key from
   the reqres docs). A JSON Extractor picks the current user's `email`, `first_name` and `last_name`, and a Response
   Assertion checks `email == lowercase(first_name.last_name)@reqres.in`.
4. **Controllers**:
   - *Loop Controller* runs `${id_#}` times, once per database row. A Counter (`idx`) and User Parameters
     select the current row (`userId`, `firstName`, `lastName`, `concatEmail`).
   - *If Controller* compares the email concatenated from the database names with the API email. On mismatch a
     JSR223 Sampler writes `log.warn(...)` to `jmeter.log`.
5. **Non-GUI**: `run-nongui.cmd` executes
   `jmeter -n -t sql-reqres-users-test.jmx -l results.csv -j jmeter.log -Jjmeter.save.saveservice.output_format=csv`.

## Results

- Step 1: 6 users fetched from `TestUsers`.
- Step 2: fails for every user. reqres.in no longer returns `Missing API Key` when the key is missing: it returns
  `200` with the user data, so `$.error` is absent and the extractor falls back to `NO_ERROR_IN_RESPONSE`.
- Step 3: passes for every user. reqres emails use a dot between the names (`george.bluth@reqres.in`).
- Step 4: user 5 is stored in the database as `Charlie Morris`, while the API has `Charles Morris`, so the If
  Controller logs a warning for that user only.

## Running it

Requirements: JMeter 5.6.3, SQL Server with TCP enabled, and the Microsoft JDBC driver
(`mssql-jdbc-12.8.1.jre11.jar`). The plan loads the driver from the path in *Test Plan > Add directory or jar to
classpath*; change it if the jar is elsewhere.

```
sqlcmd -S localhost\SQLEXPRESS -E -C -i setup-testusers.sql
run-nongui.cmd
```

Connection settings can be overridden with `-JdbUrl=...`, `-JdbUser=...`, `-JdbPassword=...`, and the API key with
`-JapiKey=...`.
