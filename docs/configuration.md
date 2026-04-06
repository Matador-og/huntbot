# Configuration

Config lives at `~/.huntbot/config.yaml`.

```bash
huntbot config show
huntbot config set <key> <value>
huntbot config get <key>
```

## Flags

| Flag | Default | Description |
|------|---------|-------------|
| `--max-runs` | 3 | Passes per stage. Use 5+ for complex apps. |
| `--timeout` | 1800 | Seconds per run. Use 7200 for thorough testing. |
| `-v` | off | Stream run output to terminal. |
| `--max-stage` | 4 | Stop after this stage (0-4). Use 1 for recon-only. |
| `--model` | default | Override model. |

## Config Keys

| Key | Env Var | Description |
|-----|---------|-------------|
| `neo4j.uri` | `NEO4J_URI` | Neo4j connection |
| `neo4j.user` | `NEO4J_USER` | Neo4j username |
| `neo4j.password` | `NEO4J_PASSWORD` | Neo4j password |
| `claude.bin` | `CLAUDE_BIN` | Path to claude binary |
| `email.gmail_account` | `HUNTBOT_GMAIL` | Gmail for reading confirmation emails |
| `email.user` | `HUNTBOT_EMAIL_USER` | Email prefix for registration |
| `email.password_pattern` | `HUNTBOT_PASSWORD_PATTERN` | `{Slug}` replaced with target |
| `gog.keyring_password` | `GOG_KEYRING_PASSWORD` | gog CLI keyring password |
| `indiesecurity.auth_key` | `ISK_AUTH_KEY` | IndieSecurity API key |
| `indiesecurity.research_key` | `ISK_RESEARCH_KEY` | Research vault key |

Environment variables override config file values.

## Neo4j

```bash
huntbot neo4j start
huntbot neo4j stop
huntbot neo4j status
huntbot neo4j reset    # Wipe and recreate database
```

Installed automatically by `huntbot setup`. Or point to an existing instance:

```bash
huntbot config set neo4j.uri bolt://my-server:7687
```
