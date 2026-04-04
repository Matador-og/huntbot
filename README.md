# huntbot

Autonomous bug bounty hunting pipeline. Spawns Claude Code agents in iterative depth loops to find real vulnerabilities.

huntbot runs the full bug bounty workflow: reconnaissance, app mapping, attack testing, triage, and report writing — all automated through AI agents that build on each other's findings.

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/Matador-og/huntbot/master/install.sh | GITHUB_TOKEN=ghp_xxx sh
```

> Requires a GitHub access token. [Request access](https://github.com/Matador-og) to get one.

**Supported platforms:** macOS (Apple Silicon, Intel), Linux (x64, ARM64), WSL

After installing, run setup to install dependencies:

```bash
huntbot setup
```

This installs Neo4j, Playwright browsers, and recon tools (subfinder, httpx, katana, gau) automatically.

### Requirements

- [Claude Code](https://claude.ai/code) with a Claude Max subscription
- macOS, Linux, or WSL

### Custom install location

```bash
HUNTBOT_INSTALL_DIR=/usr/local/bin curl -fsSL ... | GITHUB_TOKEN=ghp_xxx sh
```

### Update

Re-run the install command. It overwrites the existing binary.

## Quick Start

```bash
# 1. Create a target workspace
huntbot init paypal --scope "PayPal bug bounty program"

# 2. Edit the scope file (important — defines what to test)
vim ~/.huntbot/programs/paypal/scope.md

# 3. Run the full pipeline
huntbot auto paypal --max-runs 5 --timeout 7200 -v
```

## How It Works

```
Stage 0: Recon           Map subdomains, endpoints, tech stack
Stage 1: App Mapping     Use the app, document every feature and API call
Stage 2: Attack Testing  Find vulnerabilities using the mapped attack surface
Stage 3: Triage          Validate findings, kill false positives, write reports
Stage 4: Final Review    Senior review — last gate before submission
```

Each stage runs multiple AI agents. Each agent reads what previous agents found, looks for what they missed, and adds new discoveries. When an agent finds nothing new, the stage advances automatically.

## Commands

### Pipeline

```bash
huntbot init <target> --scope "description"     # Create workspace
huntbot run <target> --stage 0                   # Run one stage
huntbot auto <target>                            # Run full pipeline (S0-S4)
huntbot auto <target> --max-stage 1              # Recon only (S0+S1)
huntbot monitor                                  # Health dashboard
huntbot monitor <target> -v                      # Per-run efficiency curve
huntbot status <target>                          # Target status
```

### Live Guidance

Send messages to agents while they're running:

```bash
huntbot chat <target> "focus on the payment endpoint"
huntbot chat <target> "here is the JWT: Bearer eyJ..."
huntbot inbox <target>                           # View messages
```

Messages are injected at the top of the next agent's instructions, above everything else.

### Built-in Tools

huntbot bundles three security testing tools:

```bash
# Browser automation (like Burp, but for agents)
huntbot crawl navigate https://target.com --json
huntbot crawl describe --json
huntbot crawl click <ref> --json
huntbot crawl capture start
huntbot crawl capture stop --json

# Android app testing
huntbot matador devices
huntbot matador launch com.target.app
huntbot matador xray start --app com.target.app

# Attack surface graph (Neo4j)
huntbot ingestor analyze idor --target target.com
huntbot ingestor analyze auth-gaps --target target.com
huntbot ingestor query endpoints --target target.com --unauth
```

### Configuration

```bash
huntbot config show                              # View config
huntbot config set neo4j.uri bolt://host:7687    # Set a value
huntbot setup                                    # Install dependencies
huntbot neo4j start                              # Start local Neo4j
```

Config lives at `~/.huntbot/config.yaml`.

## Pipeline Flags

| Flag | Default | Description |
|------|---------|-------------|
| `--max-runs` | 3 | Agent runs per stage. Use 5+ for complex apps. |
| `--timeout` | 1800 | Seconds per run. Use 7200 for thorough testing. |
| `--max-stage` | 4 | Stop after this stage (0-4). |
| `--model` | default | Override Claude model. |
| `-v` | off | Stream agent reasoning to terminal. |

## Workspace Structure

```
~/.huntbot/programs/<target>/
  scope.md          You edit this — program scope, targets, rules
  app-context.md    Agents build this — accumulated knowledge
  findings.md       Agents write this — validated vulnerabilities
  reports/          Submission-ready write-ups
  runs/             Agent logs and metadata
```

## Monitor Dashboard

```bash
huntbot monitor
```

```
Program              Stage  Runs     ctx    find  rpt      eff     status signal
───────────────────────────────────────────────────────────────────────────────────
paypal                  S2     8    145K     12K    3  24.5b/s       IDLE  PRODUCTIVE
mercury                 S1     3     67K      0K    0   8.2b/s    RUNNING  OK
itv                     S2     5     89K      4K    1   1.1b/s      STALE  LOW EFF
```

The pipeline auto-stops stages when agents stop producing new data (diminishing returns detection).

## Skills

huntbot loads domain-specific skills based on what's in your `scope.md`:

- **web-app** — Web application testing with crawl
- **mobile-android** — Android testing with matador
- **api-rest** / **api-graphql** — API-specific attack patterns
- **auth-oauth** — OAuth/SSO flow testing
- **finding-validation** — Mandatory for stages 2+, prevents false positives

Skills are auto-detected from scope keywords, or set explicitly:

```markdown
# In scope.md
skills: api-rest, auth-oauth, mobile-android
```

## Operational Tips

- **Scope matters.** A detailed `scope.md` = better agent performance.
- **Stage 1 is crucial.** Rich app context = better attacks in stage 2.
- **Use `--max-runs 5`** for complex apps, 3 is fine for simple ones.
- **Check `huntbot monitor -v`** to see where agents are most productive.
- **Send guidance via `huntbot chat`** to redirect agents mid-run.
- **Review `findings.md`** and `reports/` after the pipeline completes.

## License

Proprietary. All rights reserved.
