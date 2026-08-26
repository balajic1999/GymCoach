# Security

## Principles

1. **Never commit secrets** to version control
2. **Never hard-code API keys** in Flutter application code
3. **Validate on the server**, not just the client
4. **Minimize data collection** — only collect what is needed
5. **Encrypt in transit** — all API calls over HTTPS
6. **Principle of least privilege** — RLS policies restrict data access

## Secret Management

### Environment Variables

Managed via the `envied` package with `.env` files:

```
mobile/.env                 # Local development (git-ignored)
mobile/.env.example         # Template with placeholder values (committed)
```

Required secrets:

| Variable | Location | Purpose |
|----------|----------|---------|
| SUPABASE_URL | .env | Supabase project URL |
| SUPABASE_ANON_KEY | .env | Supabase anonymous key (safe for client) |
| REVENUECAT_API_KEY | .env | RevenueCat public API key |
| GEMINI_API_KEY | Supabase secrets | AI provider key (server-side only) |

### Server-Side Secrets

AI API keys and webhook secrets are stored as Supabase Edge Function secrets:

```bash
supabase secrets set GEMINI_API_KEY=your-key
supabase secrets set REVENUECAT_WEBHOOK_SECRET=your-secret
```

These are **never** sent to or accessible from the mobile app.

## Authentication Security

- Supabase Auth handles JWT token management
- Tokens are stored securely in platform keychain
- Row-Level Security (RLS) enforces data isolation per user
- Email verification required before full access
- OAuth (Google/Apple) for passwordless options

## Row-Level Security (RLS)

Every user-data table has RLS enabled. Example policy:

```sql
-- Users can only read their own profile
CREATE POLICY "Users can view own profile"
ON profiles FOR SELECT
USING (auth.uid() = id);

-- Users can only update their own profile
CREATE POLICY "Users can update own profile"
ON profiles FOR UPDATE
USING (auth.uid() = id);
```

## Subscription Security

- Subscription status is validated server-side via RevenueCat webhooks
- Client-side entitlement checks are supplementary, not authoritative
- Pro-only content access is gated at both client and API level
- Receipt validation happens through RevenueCat (not custom implementation)

## Input Validation

- All user input is validated before database insertion
- SQL injection is prevented by Supabase's parameterized queries
- AI prompts are sanitized and length-limited
- File uploads are type-checked and size-limited

## Data Privacy

- Minimal data collection (see Privacy Policy)
- No unnecessary tracking
- Account deletion fully removes user data
- Data export available on request
- Analytics are aggregated and anonymized where possible

## Dependency Security

- Use pub.dev verified packages only
- Regular `flutter pub outdated` checks
- Review changelogs before major version updates
- No unnecessary native permissions

## .gitignore Requirements

```
# Secrets
.env
*.env
!.env.example

# Platform-specific
*.jks
*.keystore
google-services.json
GoogleService-Info.plist

# IDE
.idea/
.vscode/
*.iml

# Build
build/
.dart_tool/
```
