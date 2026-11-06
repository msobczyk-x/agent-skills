# App-level checklist (Node API + web apps)

Read the code before judging — grep for the auth middleware, env loading, HTTP
clients, logger/telemetry setup, and payment webhooks. Each finding names the
file and line.

## Node API

- [ ] **Auth fails closed.** A missing/invalid token is rejected by default. Any
      bypass is an explicit opt-in flag (e.g. `AUTH_DISABLED=true`) and the app
      **refuses to boot** with it set when `NODE_ENV=production`.
- [ ] **Env validated at boot** with a schema (zod, envalid, …); the process exits
      on missing or malformed values instead of failing later.
- [ ] **External IDs validated and allowlisted** (format + known set) before they
      reach file paths, URLs, or queries — prevents path traversal and SSRF.
- [ ] **Telemetry scrubbed.** Sentry `beforeSend` / logger redaction removes
      tokens, cookies, auth headers, and PII. Auth headers are never logged.
- [ ] **Timeouts on every outbound call** (OpenAI and other APIs, DB, webhooks):
      `AbortSignal.timeout(ms)` or the client's timeout option.
- [ ] **Rate limits** on abuse-prone endpoints: auth, signup, password reset,
      expensive AI/LLM calls, file uploads.
- [ ] **Payments bound to the authenticated user** (e.g. Stripe
      `client_reference_id` = user id), not matched by email. Webhook signatures
      verified.
- [ ] Error responses don't leak stack traces or internal messages in production.
- [ ] Serverless runtimes (Lambda, Cloud Functions) on a supported Node version.

## Web frontend

- [ ] The auth token is attached in **one** HTTP interceptor/client, not
      sprinkled across calls; it never goes into URLs or `localStorage` if a
      cookie-based session is an option.
- [ ] **Redirects allowlisted** (`?next=`/`returnTo` only to known paths/origins).
- [ ] Security headers set at the host/CDN or server (Amplify `customHttp.yml`,
      `vercel.json`, Netlify `_headers`, nginx, helmet):
      - `Strict-Transport-Security: max-age=63072000; includeSubDomains`
      - `X-Content-Type-Options: nosniff`
      - `X-Frame-Options: DENY` (or CSP `frame-ancestors 'none'`)
      - `Referrer-Policy: strict-origin-when-cross-origin`
      - `Permissions-Policy` denying unused features (camera, microphone, geolocation, …)
- [ ] **CSP** starts as `Content-Security-Policy-Report-Only` with a report
      endpoint, then moves to enforcing once reports are clean. Don't ship an
      enforcing CSP you haven't observed.
- [ ] No secrets in client bundles (`NEXT_PUBLIC_*`, `VITE_*`, `EXPO_PUBLIC_*`
      values are public by definition).
