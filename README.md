# jmeter-homework

JMeter load-testing homework against the public https://reqres.in API.

## Test plan

`reqres-users-load-test.jmx` sends `GET https://reqres.in/api/users?page={1|2}` under four traffic models.
Thread groups run one after another (Run Thread Groups consecutively), so each scenario can be analysed on its own.

| Scenario | Thread Group | Load shape |
|---|---|---|
| Regular Users | Ultimate Thread Group | Two overlapping waves: 20 users ramp up over 60s, 10 more join at 60s, hold at the 30-user peak, then ramp down to zero |
| Peak-Time Users | Concurrency Thread Group (burst) | 50 users start with no ramp-up and are released together by a Synchronizing Timer, one spike every ~10s for 90s |
| Long-Term Users | Thread Group + Constant Throughput Timer | 10 users for 600s (configurable), throughput capped at 60 requests/min shared across the group |
| Users Simulating Failures | Stepping Thread Group (Step-Up) | +10 users every 20s up to 200; the test stops on the first failed sample, so this group runs last |

Assertions on every request:

- **Response Assertion - JSON keys**: body contains `"data"`, `"total_pages"`, `"page"`, `"per_page"` and `"total"`
- **Response Assertion - Status 200**: response code equals 200

## Requirements

- Apache JMeter 5.6.3
- [JMeter Plugins Manager](https://jmeter-plugins.org/wiki/PluginsManager/) with **Custom Thread Groups** (`jpgc-casutg`), which provides the Ultimate, Concurrency and Stepping thread groups

Without the plugin JMeter refuses to open the plan. If `lib/ext` is not writable (JMeter under `Program Files`),
put `jmeter-plugins-casutg-3.1.1.jar` and `jmeter-plugins-cmn-jmeter-0.7.jar` from Maven Central into any folder
and point JMeter at it:

```
jmeter -Jsearch_paths=C:/path/to/plugins-folder -t reqres-users-load-test.jmx
```

## Running

GUI:

```
jmeter -t reqres-users-load-test.jmx
```

Non-GUI with an HTML report:

```
jmeter -n -t reqres-users-load-test.jmx -l results/results.jtl -e -o results/report
```

Optional properties:

- `-JlongTermDuration=<seconds>` - length of the Long-Term Users run (default 600)
- `-JapiKey=<key>` - value of the `x-api-key` header (default `reqres-free-v1`)
