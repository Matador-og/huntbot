# Skills

Huntbot loads domain-specific methodology based on what's in your scope.

## Auto-detected

| Skill | Keywords |
|-------|----------|
| web-app | "web app", "website", "https://" |
| mobile-android | "android", "apk", "mobile app" |
| api-rest | "rest api", "api", "/api/", "swagger" |
| api-graphql | "graphql", "gql", "/graphql" |
| auth-oauth | "oauth", "openid", "sso", "saml" |
| account-registration | "register", "login", "signup" |
| crawl-usage-guide | "crawl", "browser automation" |
| finding-validation | Always loaded for stages 2+ |

## Explicit

Add to your `scope.md`:

```
skills: api-rest, auth-oauth, mobile-android
```

## What they do

- **web-app** — Browser crawling patterns, capture workflows, JS analysis
- **mobile-android** — ADB interaction, Frida hooks, SSL pinning bypass, APK analysis
- **api-rest** — REST endpoint testing, parameter fuzzing, auth token handling
- **api-graphql** — GraphQL introspection, mutation testing, batching attacks
- **auth-oauth** — OAuth flow testing, token leakage, state parameter checks
- **account-registration** — Test account creation, email verification, session management
- **finding-validation** — 4-gate validation before any finding gets written

## List available

```bash
huntbot skills
```
