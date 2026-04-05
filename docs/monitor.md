# Monitor

```bash
huntbot monitor              # All targets
huntbot monitor <slug>       # One target
huntbot monitor <slug> -v    # Per-run efficiency curve
```

## Dashboard

```
Program              Stage  Runs     ctx    find  rpt      eff     status signal
───────────────────────────────────────────────────────────────────────────────────
paypal                  S2     8    145K     12K    3  24.5b/s       IDLE  PRODUCTIVE
uber                    S1     3     67K      0K    0   8.2b/s    RUNNING  OK
hackerone               S2     5     89K      4K    1   1.1b/s      STALE  LOW EFF
```

## Signals

| Signal | Meaning | Action |
|--------|---------|--------|
| PRODUCTIVE | >20 b/s new data | Let it run |
| OK | Normal | Healthy |
| DECLINING | Slowing down | Consider redirecting |
| LOW EFF | <2 b/s | Likely stuck — use `huntbot chat` to redirect |
| STALE | Multiple low runs | Blocked — check auth, WAF, credentials |
| EXHAUSTED | No new data | Stage done |

## Diminishing Returns

The pipeline auto-stops a stage after 2 consecutive runs below 3 bytes/sec. Prevents wasting compute on runs that keep repeating themselves.

## Verbose Mode

```bash
huntbot monitor paypal -v
```

Shows per-run breakdown: duration, context delta, findings delta, efficiency, and flags for stale/rewrite runs.
