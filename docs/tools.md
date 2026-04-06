# Tools Reference

## huntbot crawl — Browser Automation

Playwright-based headless browser. Always start a session first.

```bash
# Session management (keeps browser alive between commands)
huntbot crawl session start <name>
huntbot crawl session stop <name>
huntbot crawl session list

# Navigation
huntbot crawl navigate <url> --json
huntbot crawl describe --json              # List interactive elements (e0, e1...)
huntbot crawl click <ref> --json
huntbot crawl type <ref> "<text>" --json
huntbot crawl fill <form> --data '{"field":"value"}' --json
huntbot crawl submit <form> --json
huntbot crawl wait <ms|selector> --json
huntbot crawl screenshot [path]

# JavaScript
huntbot crawl evaluate "<expression>" --json

# Network capture
huntbot crawl capture start
huntbot crawl capture stop --json

# State
huntbot crawl cookies --json
huntbot crawl storage --json
huntbot crawl status

# Auth profiles
huntbot crawl auth

# Proxy
huntbot crawl proxy --start [--port 8080]
huntbot crawl proxy --stop
```

### Typical workflow

```bash
huntbot crawl session start myapp
huntbot crawl navigate https://app.target.com --json
huntbot crawl capture start
huntbot crawl describe --json
huntbot crawl click e3 --json
huntbot crawl type e5 "test@test.com" --json
huntbot crawl capture stop --json > ./capture.json
cat ./capture.json | huntbot ingestor ingest --target target.com --platform web
huntbot crawl session stop myapp
```

## huntbot ingestor — Attack Surface Graph

Neo4j-based graph of endpoints, parameters, auth state, and technologies.

```bash
# Ingest traffic
huntbot ingestor ingest --target DOMAIN --platform web    # From stdin (pipe capture JSON)

# Import files
huntbot ingestor import har <file> --target DOMAIN
huntbot ingestor import openapi <file> --target DOMAIN
huntbot ingestor import burp <file> --target DOMAIN

# Analyze
huntbot ingestor analyze idor --target DOMAIN              # IDOR candidates
huntbot ingestor analyze auth-gaps --target DOMAIN          # Auth inconsistencies
huntbot ingestor analyze hidden --target DOMAIN             # Admin/debug endpoints
huntbot ingestor analyze sensitive --target DOMAIN          # Payment/user data

# Query
huntbot ingestor query endpoints --target DOMAIN [--unauth]
huntbot ingestor query params --target DOMAIN [--type id]
huntbot ingestor query auth --target DOMAIN

# Management
huntbot ingestor stats
huntbot ingestor targets
huntbot ingestor export [--target DOMAIN]
huntbot ingestor clear --target DOMAIN --confirm
```

## huntbot matador — Android Testing

ADB + Frida + mitmproxy for Android app testing.

```bash
# Device management
huntbot matador devices
huntbot matador apps
huntbot matador launch <package>

# Interaction
huntbot matador describe --json
huntbot matador tap <ref>
huntbot matador type <ref> "<text>"
huntbot matador swipe <direction>
huntbot matador back
huntbot matador home
huntbot matador screenshot

# Traffic capture
huntbot matador capture start
huntbot matador capture stop --json

# SSL pinning bypass
huntbot matador xray start --app <package>
huntbot matador xray stop --json

# Recon
huntbot matador recon [package]             # Attack surface score
huntbot matador apk pull <package>
huntbot matador deeplink <package>
huntbot matador components <package>
```

## External Recon Tools

Installed by `huntbot setup`:

```bash
subfinder -d target.com -o subs.txt
httpx -l subs.txt -o live.txt
katana -u https://target.com -o endpoints.txt
gau target.com -o urls.txt
```
