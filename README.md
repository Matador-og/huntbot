<p align="center">
  <img width="1390" height="477" alt="huntbot" src="https://github.com/user-attachments/assets/83c006f6-3dd1-4ab1-a4d5-9d42f9322c8d" />
</p>

<p align="center">
  <a href="https://github.com/Matador-og/huntbot/releases"><img src="https://img.shields.io/github/v/release/Matador-og/huntbot?style=flat-square&color=red" alt="version"></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-BSD--3-blue?style=flat-square" alt="license"></a>
  <img src="https://img.shields.io/badge/platform-macOS%20%C2%B7%20Linux%20%C2%B7%20WSL-black?style=flat-square" alt="platform">
</p>

<p align="center">
  Offensive security harness for bug bounty, pentesting, and red teaming.<br>
  Runs recon, maps the app, tests for vulns, validates findings, writes reports.
</p>

---

> Huntbot is a force multiplier, not a replacement for expertise. With the current state of frontier LLMs, expect huntbot to do ~80% of the work — recon, mapping, initial testing, report drafting. The remaining 20% is on you: You just need to ask the right logical questions 
 
## Real Results

Vulnerabilities found by using huntbot, reported by [@mrecho]().

| CVE | Target | Vulnerability | Severity |
|-----|--------|--------------|----------|
| [CVE-2026-33728](https://nvd.nist.gov/vuln/detail/CVE-2026-33728) | Datadog `dd-trace-java` | Unsafe deserialization in RMI instrumentation — remote code execution | **Critical** (CVSS 9.3) |
| [CVE-2026-1035](https://nvd.nist.gov/vuln/detail/CVE-2026-1035) | Red Hat Keycloak | Refresh token reuse bypass via TOCTOU race condition | Low (CVSS 3.1) |



## Why huntbot?

Most security tools find things. Huntbot **understands** things.

- **Accumulates context** — Run 5 knows everything Runs 1-4 discovered. 211KB+ of knowledge per target.
- **Knows when to stop** — Efficiency tracking (bytes/sec) detects when a stage is exhausted vs productive.
- **Tests like a human** — Registers accounts, fills forms, clicks through SPAs with a real browser.
- **Validates before reporting** — 4-gate triage kills false positives so you don't waste program time.
- **Writes the report** — Submission-ready markdown with title, severity, steps to reproduce, impact.
- **You can steer it** — `huntbot chat` redirects agents mid-run. "Focus on the payment API."

## Install

```bash
curl -fsSL https://matador.indiesecurity.com/huntbot/install.sh | sh
huntbot setup
```

> [View the install script source](install.sh) before running.

**Requires:** [Claude Code](https://claude.ai/code) with Claude Max subscription. Huntbot uses Claude as its reasoning engine — each run consumes ~50K-150K tokens.

<details>
<summary>Alternative install methods</summary>

**Direct download:**

Download the binary for your platform from [Releases](https://github.com/Matador-og/huntbot/releases), make it executable, and move to your PATH.

**Custom location:**

```bash
curl -fsSL https://matador.indiesecurity.com/huntbot/install.sh | HUNTBOT_INSTALL_DIR=/usr/local/bin sh
```
</details>

## Quick Start

### With Claude Code (recommended)

Install the plugin, then talk:

```
/plugin marketplace add Matador-og/huntbot
/plugin install huntbot@huntbot
```

```
> Set up PayPal's bug bounty and start hunting
> Run recon on *.staging.company.com
> What findings do we have?
> Focus on the payment API
> Write up finding-001 for submission
```

### CLI

```bash
# Create target
huntbot init paypal --scope "PayPal bug bounty"
vim ~/.huntbot/programs/paypal/scope.md

# Hunt
huntbot auto paypal --max-runs 5 --timeout 7200 -v

# Monitor
huntbot monitor

# Steer mid-run
huntbot chat paypal "focus on IDOR in /api/users/{id}"

# Check results
cat ~/.huntbot/programs/paypal/findings.md
```

## How It Works

```
S0 Recon          Runs subfinder, httpx, katana, gau. Crawls JS bundles.
                  Maps the full attack surface. 18-44 b/s efficiency.

S1 App Mapping    Registers accounts, logs in, clicks through every feature
                  with a real browser. Captures all HTTP traffic. Feeds
                  everything into the attack surface graph.

S2 Attack Testing Queries the graph for IDOR candidates, auth gaps, hidden
                  endpoints. Tests each one. Every finding passes 4-gate
                  validation before being written.

S3 Triage         Re-validates every finding. Reproduces 3/3 times. Kills
                  false positives. Writes submission-ready reports.

S4 Final Review   Senior reviewer. Destroys anything that doesn't hold up.
                  Last gate before you submit.
```

Each stage runs multiple passes. Each pass reads what previous passes found and looks for what they missed. When a pass finds nothing new, the stage advances automatically.

## Monitor

```bash
huntbot monitor
```

```
Program              Stage  Runs     ctx    find  rpt      eff     status signal
───────────────────────────────────────────────────────────────────────────────────
target-1                S2     8    145K     12K    3  24.5b/s       IDLE  PRODUCTIVE
target-2                S1     3     67K      0K    0   8.2b/s    RUNNING  OK
target-3                S2     5     89K      4K    1   1.1b/s      STALE  LOW EFF
```

Auto-detects diminishing returns and stops wasting compute.

## Built-in Tools

| Tool | What it does |
|------|-------------|
| `huntbot crawl` | Playwright browser — navigate, click, fill forms, capture traffic, execute JS |
| `huntbot ingestor` | Neo4j attack surface graph — IDOR detection, auth-gap analysis, endpoint classification |
| `huntbot matador` | Android testing — ADB, Frida SSL bypass, mitmproxy capture |

Plus recon tools: subfinder, httpx, katana, gau (installed by `huntbot setup`).

## Commands

| Command | Description |
|---------|-------------|
| `huntbot init <slug>` | Create target workspace |
| `huntbot auto <slug>` | Run full pipeline (S0-S4) |
| `huntbot run <slug> --stage N` | Run one stage |
| `huntbot monitor [slug]` | Health dashboard |
| `huntbot chat <slug> "msg"` | Steer agents mid-run |
| `huntbot status <slug>` | Target info |
| `huntbot update` | Self-update |
| `huntbot setup` | Install dependencies |

| Flag | Default | Recommended |
|------|---------|-------------|
| `--max-runs` | 3 | 5+ for complex apps |
| `--timeout` | 1800 | 7200 (2 hours) |
| `-v` | off | Always on |
| `--max-stage` | 4 | 1 for recon-only |

## Docs

- [Workspace structure](docs/workspace.md) — what lives in `~/.huntbot/programs/`
- [Configuration](docs/configuration.md) — config, flags, environment variables
- [Tools reference](docs/tools.md) — crawl, ingestor, matador full command list
- [Monitor & signals](docs/monitor.md) — dashboard, health signals, efficiency tracking
- [Skills](docs/skills.md) — auto-loaded methodology per target type


## Author

**Mohamed Amine Ait Ouchebou** ([@mrecho](https://github.com/amine123ait))

[IndieSecurity](https://indiesecurity.com) · [GitHub](https://github.com/Matador-og) · [LinkedIn](https://linkedin.com/company/indiesecurity)

## License

BSD 3-Clause. See [LICENSE](LICENSE).
