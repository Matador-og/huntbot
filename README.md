# huntbot

Offensive security harness for bug bounty, pentesting, and red teaming. Runs recon, maps the app, tests for vulnerabilities, validates findings, and writes reports.

## Install

```bash
curl -fsSL https://matador.indiesecurity.com/huntbot/install.sh | sh
huntbot setup
```

**Platforms:** macOS · Linux · WSL
**Requires:** [Claude Code](https://claude.ai/code) (Claude Max)

## Quick Start

Install the Claude Code plugin, then just talk:

```
/plugin marketplace add Matador-og/huntbot
/plugin install huntbot@huntbot
```

```
> Set up PayPal's bug bounty and start hunting
> Run recon on *.staging.company.com
> What findings do we have?
> Focus on the payment API
```

Or use the CLI directly:

```bash
huntbot init paypal --scope "PayPal bug bounty"
huntbot auto paypal --max-runs 5 --timeout 7200 -v
huntbot monitor
huntbot chat paypal "focus on IDOR in /api/users/{id}"
```

## How It Works

```
S0 Recon          → Subdomains, endpoints, tech stack
S1 App Mapping    → Use the app, document features and APIs
S2 Attack Testing → Find vulnerabilities
S3 Triage         → Validate, kill false positives, write reports
S4 Final Review   → Last gate before submission
```

Each stage runs multiple passes. When a pass finds nothing new, the stage advances.

## Commands

```bash
huntbot init <slug>                # Create target
huntbot auto <slug>                # Full pipeline (S0-S4)
huntbot run <slug> --stage N       # Single stage
huntbot monitor                    # Dashboard
huntbot chat <slug> "msg"          # Guide mid-run
huntbot status <slug>              # Target info
huntbot update                     # Self-update
huntbot setup                      # Install deps
```

## Built-in Tools

```bash
huntbot crawl       # Browser automation (Playwright)
huntbot ingestor    # Attack surface graph (Neo4j)
huntbot matador     # Android testing (ADB + Frida)
```

## Docs

See [docs/](docs/) for:
- [Workspace structure](docs/workspace.md) — what lives in `~/.huntbot/programs/`
- [Configuration](docs/configuration.md) — config, flags, environment variables
- [Tools reference](docs/tools.md) — crawl, ingestor, matador commands
- [Monitor & signals](docs/monitor.md) — dashboard, health signals, efficiency
- [Skills](docs/skills.md) — auto-loaded methodology per target type

## Author

**Mohamed Amine Ait Ouchebou** ([@mrecho](https://github.com/amine123ait))
[IndieSecurity](https://indiesecurity.com) · [GitHub](https://github.com/Matador-og) · [LinkedIn](https://linkedin.com/company/indiesecurity)

## License

BSD 3-Clause. See [LICENSE](LICENSE).
