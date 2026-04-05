# huntbot

Open-source autonomous offensive security pipeline. Spawns AI agents to find real vulnerabilities in bug bounty programs, pentests, and red team engagements.

Huntbot automates the full offensive workflow: reconnaissance, application mapping, attack testing, triage, and report writing — through AI agents that iteratively build on each other's findings.

## Install

```bash
curl -fsSL https://matador.indiesecurity.com/huntbot/install.sh | sh
```

Then install all dependencies:

```bash
huntbot setup
```

**Supported platforms:** macOS (Apple Silicon, Intel) · Linux (x64, ARM64) · WSL

**Requirements:** [Claude Code](https://claude.ai/code) with a Claude Max subscription.

### Update

```bash
huntbot update
```

## Usage

The recommended way to use huntbot is through **Claude Code with the huntbot plugin**. This gives Claude full knowledge of every huntbot command, tool, and workflow.

### 1. Install the plugin

Open Claude Code and run:

```
/plugin marketplace add Matador-og/huntbot
/plugin install huntbot@huntbot
```

### 2. Talk to Claude

```bash
claude
```

```
> Set up a new target for PayPal's bug bounty program and start hunting
> Run recon only on *.staging.company.com
> What did the agents find so far?
> Focus the next run on the payment API
> Show me the monitor dashboard
> Write up finding-001 for submission
```

Claude knows every huntbot command, tool, and workflow. It creates workspaces, writes scopes, runs pipelines, interprets results, and helps you submit findings.

### Direct CLI

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

# Check results
cat ~/.huntbot/programs/paypal/findings.md
ls ~/.huntbot/programs/paypal/reports/
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

## Workspace

All huntbot data lives at `~/.huntbot/`. Each target gets its own workspace:

```
~/.huntbot/
├── config.yaml                     # Global configuration
├── programs/                       # All target workspaces
│   └── <slug>/                     # One directory per target
│       ├── scope.md                # YOU write this — defines what to test
│       ├── app-context.md          # Agents build this — accumulated knowledge
│       ├── findings.md             # Agents write this — validated vulnerabilities
│       ├── reports/                # Submission-ready write-ups
│       │   └── finding-001-*.md    # One report per finding
│       ├── inbox.md                # Messages you send via huntbot chat
│       ├── CLAUDE.md               # Auto-generated per run — DO NOT EDIT
│       └── runs/                   # Run logs and agent output
│           ├── s0-r001.json        # Run metadata (timing, efficiency, deltas)
│           └── s0-r001-output.md   # Full agent conversation
└── neo4j/                          # Local Neo4j installation (if installed via setup)
```

### scope.md — What to test

You write this. It defines the target, what's in scope, and what skills to load. A detailed scope = better results.

```markdown
# PayPal — HackerOne

## Platform
HackerOne

## In-Scope
- *.paypal.com
- api.paypal.com
- venmo.com

## Out of Scope
- *.paypalobjects.com
- Third-party CDNs

## Skills
skills: api-rest, auth-oauth

## Focus Areas
1. Payment flow manipulation
2. IDOR in merchant endpoints
3. OAuth token handling
```

### app-context.md — What agents know

Agents build this file across runs. It accumulates everything discovered: subdomains, endpoints, tech stack, auth patterns, features, API behavior, and observations. Each agent reads it before starting and appends new findings. This is the collective memory of the pipeline.

### findings.md — Validated vulnerabilities

When an agent discovers a vulnerability, it writes it here after passing a 4-gate validation:

1. **So What?** — Does this have real security impact?
2. **Cross-User Proof** — Can it affect other users, not just the attacker?
3. **Alternative Explanations** — Is there a non-vuln explanation?
4. **Impact** — What's the worst case?

Only findings that pass all 4 gates get written. Stages 3 and 4 re-validate everything and kill false positives.

### reports/ — Submission-ready write-ups

Each validated finding gets a full report with: title, severity, description, steps to reproduce, impact, and evidence. Ready to submit to bug bounty platforms.

### runs/ — Agent logs

Every agent run produces two files:
- **`s{stage}-r{run}.json`** — Metadata: timing, efficiency (bytes/sec), whether context or findings changed, file sizes before/after
- **`s{stage}-r{run}-output.md`** — The full agent conversation (what it did, what it found, tool calls)

Use `huntbot monitor <slug> -v` to see the efficiency curve across all runs.

### inbox.md — Live guidance

When you send messages via `huntbot chat <slug> "message"`, they queue here. On the next agent run, unread messages get injected at the top of the agent's instructions — above skills and stage instructions — so they take priority.

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

| Signal | Meaning |
|--------|---------|
| PRODUCTIVE | Finding new data fast (>20 b/s) |
| OK | Normal efficiency |
| DECLINING | Slowing down |
| LOW EFF | Likely repeating itself (<2 b/s) |
| STALE | Multiple low-efficiency runs — needs human input |
| EXHAUSTED | No new data — stage done |

The pipeline auto-stops stages when agents stop producing new data.

## Flags

| Flag | Default | Recommended |
|------|---------|-------------|
| `--max-runs` | 3 | 5 for complex apps |
| `--timeout` | 1800 | 7200 (2 hours) |
| `-v` | off | Always on |
| `--max-stage` | 4 | 1 for recon-only |

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

## Configuration

```bash
huntbot config show
huntbot config set neo4j.uri bolt://localhost:7687
huntbot config set email.gmail_account you@gmail.com
```

Config lives at `~/.huntbot/config.yaml`. All values can also be set via environment variables.

## Commands

| Command | Description |
|---------|-------------|
| `huntbot init <slug>` | Create target workspace |
| `huntbot run <slug> --stage N` | Run one stage |
| `huntbot auto <slug>` | Run full pipeline (S0-S4) |
| `huntbot monitor [slug]` | Health dashboard |
| `huntbot status <slug>` | Target status |
| `huntbot chat <slug> "msg"` | Send live guidance |
| `huntbot inbox <slug>` | View messages |
| `huntbot skills` | List available skills |
| `huntbot setup` | Install dependencies |
| `huntbot update` | Update to latest version |
| `huntbot config show\|set\|get` | Manage configuration |
| `huntbot neo4j start\|stop\|status` | Manage Neo4j |
| `huntbot crawl <cmd>` | Browser automation |
| `huntbot ingestor <cmd>` | Attack surface graph |
| `huntbot matador <cmd>` | Android testing |

## Author

Created by **Mohamed Amine Ait Ouchebou** ([@mrecho](https://github.com/amine123ait))

Built by [IndieSecurity](https://indiesecurity.com) — making offensive security tooling accessible.

- [GitHub](https://github.com/Matador-og)
- [LinkedIn](https://linkedin.com/company/indiesecurity)

## License

BSD 3-Clause. See [LICENSE](LICENSE) for details.

Binary is free for personal use and authorized security testing. See LICENSE for full terms.
