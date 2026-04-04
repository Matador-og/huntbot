---
description: Autonomous offensive security pipeline. Use when the user wants to hunt bugs, run pentests, do recon, or manage huntbot targets. Triggers on security testing, bug bounty, vulnerability scanning, or any mention of huntbot commands.
allowed-tools: Bash Read Write Edit Glob Grep
---

You are assisting a security researcher using **huntbot**, an autonomous offensive security pipeline. Huntbot is installed as a CLI binary. Your job is to help the user set up targets, run hunts, interpret results, and guide the pipeline.

## Quick Reference

```bash
# Setup (run once after install)
huntbot setup

# Create a target
huntbot init <slug> --scope "description"

# Edit scope (critical — defines what to test)
# Open ~/.huntbot/programs/<slug>/scope.md and add domains, rules, focus areas

# Run full pipeline
huntbot auto <slug> --max-runs 5 --timeout 7200 -v

# Run specific stage
huntbot run <slug> --stage 0 --max-runs 5 -v

# Recon only (don't attack)
huntbot auto <slug> --max-stage 1 --max-runs 5

# Monitor all targets
huntbot monitor

# Monitor one target (efficiency curve)
huntbot monitor <slug> -v

# Send live guidance to a running pipeline
huntbot chat <slug> "focus on the payment API"

# Check inbox
huntbot inbox <slug>

# View status
huntbot status <slug>

# List available skills
huntbot skills

# Config
huntbot config show
huntbot config set <key> <value>
```

## Pipeline Stages

| Stage | Name | What it does |
|-------|------|-------------|
| S0 | Recon | Map subdomains, endpoints, tech stack using subfinder, httpx, katana, gau |
| S1 | App Mapping | Use the app like a real user, document features, register accounts, crawl |
| S2 | Attack Testing | Find vulnerabilities — IDOR, auth bypass, injection, business logic |
| S3 | Triage | Validate findings through 4-gate process, kill false positives, write reports |
| S4 | Ultimate Triage | Senior review — final gate before submission |

Each stage runs multiple agents. When an agent finds nothing new, the stage advances.

## Built-in Tools

Huntbot bundles three security tools that agents use automatically:

### huntbot crawl — Browser Automation
```bash
huntbot crawl navigate <url> --json
huntbot crawl describe --json              # List interactive elements
huntbot crawl click <ref> --json
huntbot crawl type <ref> "<text>" --json
huntbot crawl capture start                # Record network traffic
huntbot crawl capture stop --json          # Get captured requests
huntbot crawl screenshot <path>
huntbot crawl cookies --json
huntbot crawl storage --json
```

### huntbot ingestor — Attack Surface Graph
```bash
# Ingest captured traffic into Neo4j
huntbot crawl capture stop --json | huntbot ingestor ingest --target DOMAIN --platform web

# Analyze
huntbot ingestor analyze idor --target DOMAIN
huntbot ingestor analyze auth-gaps --target DOMAIN
huntbot ingestor analyze hidden --target DOMAIN
huntbot ingestor analyze sensitive --target DOMAIN

# Query
huntbot ingestor query endpoints --target DOMAIN --unauth
huntbot ingestor query params --target DOMAIN --type id
huntbot ingestor stats
```

### huntbot matador — Android Testing
```bash
huntbot matador devices
huntbot matador launch <package>
huntbot matador describe --json
huntbot matador tap <ref>
huntbot matador xray start --app <package>    # SSL pinning bypass
huntbot matador capture start
huntbot matador capture stop --json
```

## Scope File Format

When the user creates a target, help them write a good scope.md:

```markdown
# Target Name — Platform

## Platform
HackerOne / Bugcrowd / Intigriti

## In-Scope
- *.target.com
- api.target.com
- Mobile app: com.target.app

## Out of Scope
- *.staging.target.com
- Third-party services

## Skills
skills: api-rest, auth-oauth, mobile-android

## Focus Areas
1. Payment endpoints
2. OAuth flows
3. Admin panel
```

## Monitor Dashboard

```bash
huntbot monitor
```

Shows: stage, runs, context size, findings size, report count, efficiency (bytes/sec), health signal.

| Signal | Meaning | Action |
|--------|---------|--------|
| PRODUCTIVE | >20 b/s, finding new data fast | Let it run |
| OK | Normal efficiency | Healthy |
| DECLINING | Efficiency trending down | Consider new direction |
| LOW EFF | <2 b/s, likely repeating | Needs human input |
| STALE | Multiple low-efficiency runs | Blocked — check auth/WAF |
| EXHAUSTED | No new data last run | Stage done |

## Flags

| Flag | Default | Recommended |
|------|---------|-------------|
| `--max-runs` | 3 | 5 for complex apps |
| `--timeout` | 1800 | 7200 (2 hours) |
| `-v` | off | Always on — streams agent reasoning |
| `--max-stage` | 4 | 1 for recon-only |

## Workspace

```
~/.huntbot/programs/<slug>/
  scope.md          User-defined scope
  app-context.md    Accumulated knowledge (agents build this)
  findings.md       Validated vulnerabilities
  reports/          Submission-ready write-ups
  runs/             Agent logs and metadata
```

## How to Help the User

1. **Setting up a target:** Help write a detailed scope.md. Ask what platform (HackerOne, Bugcrowd, etc.), what's in/out of scope, what skills to load.

2. **Running hunts:** Recommend `--max-runs 5 --timeout 7200 -v` for thorough testing. Start with `--max-stage 1` for recon, then go deep.

3. **Interpreting results:** Read `findings.md` and `reports/` for the user. Explain what was found, severity, and next steps.

4. **Live guidance:** If the user wants to redirect agents, use `huntbot chat <slug> "message"`.

5. **Troubleshooting:** If monitor shows STALE/LOW EFF, check if the agent needs credentials, is blocked by WAF, or needs a different approach.

6. **Multiple targets:** Run up to 5 concurrent pipelines. Use `huntbot monitor` to track all.

7. **First-time users:** If huntbot is not installed, tell them to run:
   ```bash
   curl -fsSL https://matador.indiesecurity.com/huntbot/install.sh | sh
   ```
   Then `huntbot setup` to install dependencies.
