# Workspace

All data lives at `~/.huntbot/`. Each target gets its own directory.

```
~/.huntbot/
├── config.yaml
├── programs/
│   └── <slug>/
│       ├── scope.md              # You write this
│       ├── app-context.md        # Accumulated recon and mapping data
│       ├── findings.md           # Validated vulnerabilities
│       ├── reports/              # Submission-ready write-ups
│       │   └── finding-001-*.md
│       ├── inbox.md              # Messages sent via huntbot chat
│       ├── CLAUDE.md             # Auto-generated per run — don't edit
│       └── runs/
│           ├── s0-r001.json      # Run metadata
│           └── s0-r001-output.md # Full run output
└── neo4j/                        # Local Neo4j (if installed via setup)
```

## scope.md

Defines the target. You write this before running anything.

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

A detailed scope produces better results. Include the platform, in/out of scope, skills to load, and focus areas.

## app-context.md

Built across runs. Contains everything discovered: subdomains, endpoints, tech stack, auth patterns, features, API behavior, observations. Each run reads it first and appends new data.

## findings.md

Vulnerabilities that passed 4-gate validation:

1. **So What?** — Real security impact?
2. **Cross-User Proof** — Affects other users?
3. **Alternative Explanations** — Non-vuln explanation?
4. **Impact** — Worst case?

Stages 3 and 4 re-validate everything and remove false positives.

## reports/

One report per finding. Title, severity, steps to reproduce, impact, evidence. Ready to submit.

## runs/

Two files per run:
- `s{stage}-r{run}.json` — Timing, efficiency (bytes/sec), file size deltas
- `s{stage}-r{run}-output.md` — Full run output

## inbox.md

Messages from `huntbot chat` queue here. Delivered to the next run with highest priority.
