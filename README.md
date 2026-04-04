# huntbot

Open-source autonomous offensive security pipeline. Spawns AI agents to find real vulnerabilities in bug bounty programs, pentests, and red team engagements.

Huntbot automates the full offensive workflow: reconnaissance, application mapping, attack testing, triage, and report writing — through AI agents that iteratively build on each other's findings.

## Install

```bash
curl -fsSL https://matador.indiesecurity.com/huntbot/install.sh | sh
```

Then run setup to install all dependencies:

```bash
huntbot setup
```

**Supported platforms:** macOS (Apple Silicon, Intel) · Linux (x64, ARM64) · WSL

**Requirements:** [Claude Code](https://claude.ai/code) with a Claude Max subscription.

## Usage

The recommended way to use huntbot is through **Claude Code with the huntbot skill loaded**. This gives Claude full knowledge of every huntbot command, tool, and workflow.

### 1. Load the skill

```bash
claude --skill https://raw.githubusercontent.com/Matador-og/huntbot/master/HUNTBOT.md
```

### 2. Talk to Claude

```
> Set up a new target for PayPal's bug bounty program and start hunting
> Run recon only on *.staging.company.com
> What did the agents find so far?
> Focus the next run on the payment API
> Show me the monitor dashboard
> Write up finding-001 for submission
```

Claude handles everything — creates the workspace, writes the scope, runs the pipeline, interprets results, and helps you submit findings.

### Direct CLI (advanced)

You can also use huntbot directly:

```bash
# Create target
huntbot init paypal --scope "PayPal bug bounty"
vim ~/.huntbot/programs/paypal/scope.md

# Hunt
huntbot auto paypal --max-runs 5 --timeout 7200 -v

# Monitor
huntbot monitor

# Guide agents mid-run
huntbot chat paypal "focus on IDOR in /api/users/{id}"
```

## How It Works

```
S0 Recon          → Map subdomains, endpoints, tech stack
S1 App Mapping    → Use the app, document every feature and API
S2 Attack Testing → Find vulnerabilities across the mapped surface
S3 Triage         → 4-gate validation, kill false positives, write reports
S4 Final Review   → Senior review — last gate before submission
```

Each stage runs multiple AI agents. Each agent reads what previous agents found, looks for what they missed, and adds new discoveries. When no new data is found, the stage advances automatically.

## Built-in Tools

Huntbot bundles three offensive security tools:

- **huntbot crawl** — Headless browser automation with network capture (Playwright-based)
- **huntbot ingestor** — Neo4j attack surface graph with IDOR, auth-gap, and hidden endpoint analysis
- **huntbot matador** — Android app testing with ADB, Frida, and mitmproxy

Plus automatic integration with recon tools: subfinder, httpx, katana, gau.

## Monitor

```bash
huntbot monitor
```

```
Program              Stage  Runs     ctx    find  rpt      eff     status signal
───────────────────────────────────────────────────────────────────────────────────
paypal                  S2     8    145K     12K    3  24.5b/s       IDLE  PRODUCTIVE
uber                    S1     3     67K      0K    0   8.2b/s    RUNNING  OK
hackerone               S2     5     89K      4K    1   1.1b/s      STALE  LOW EFF
```

Auto-detects diminishing returns and stops wasting compute.

## Skills

Domain-specific skills are auto-loaded based on your scope:

| Skill | Triggers on |
|-------|------------|
| web-app | Web targets |
| mobile-android | Android apps |
| api-rest / api-graphql | API endpoints |
| auth-oauth | OAuth/SSO flows |
| finding-validation | Always for stages 2+ |

Or set explicitly in scope.md: `skills: api-rest, auth-oauth`

## Community

Built by [IndieSecurity](https://indiesecurity.com) — making offensive security tooling accessible.

- [GitHub](https://github.com/Matador-og)
- [LinkedIn](https://linkedin.com/company/indiesecurity)

## License

Source: proprietary. Binary: free for personal and authorized security testing use.
