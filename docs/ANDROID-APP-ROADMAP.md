# Teatro AlSaeed — Android App Delivery Plan

## Guiding architecture
The existing GitHub Pages website remains online and keeps its historical URLs. The new Flutter Android app and the existing website will consume one separate Supabase project: `Teatro AlSaeed Digital Platform` (`cusdjhfdhimoucjvxsmr`). The existing `Arts of Upper Egypt` database and its artist directory remain untouched.

## Delivery stages

### Stage 1 — Foundation (started)
- Create isolated Git branch for the app work.
- Create the dedicated Supabase project.
- Create bilingual content tables and public-media storage.
- Enable Row Level Security and least-privilege policies.
- Add a Flutter Android client skeleton.
- Add a GitHub Actions APK build workflow.

### Stage 2 — Content model and migration
- Audit the current website pages and identify authoritative content.
- Map news, productions, festival editions, events, workshops and open calls.
- Migrate only verified content; preserve old static pages and URLs.
- Compare record counts and sample records before enabling live reads on the website.
- Add a single admin CMS so content is entered once.

### Stage 3 — App feature completion
- Add detailed news and production pages.
- Add festival calendar, workshop and open-call details.
- Add search, share actions, bookmarks and offline-friendly caching.
- Add app privacy, terms, contact and accessibility support.

### Stage 4 — Administration and security
- Create the first owner account through Supabase Auth.
- Add the owner UUID to `public.admin_members` using the SQL editor.
- Build authenticated content management screens.
- Test RLS with anonymous, normal authenticated and admin sessions.
- Keep service-role/secret keys out of all client code.

### Stage 5 — Notifications and release
- Set up Firebase project and Android app registration.
- Implement device-token registration and server-side push sending.
- Configure deep links and Android app signing.
- Run device, network, security and performance tests.
- Build signed Android App Bundle (AAB), then submit to Google Play after owner approval.

## Current scope boundaries
- No changes to `admin-artists.html` or the Arts of Upper Egypt Supabase project.
- No deletion or replacement of existing website pages or media.
- No public write access to content tables.
- No Google Play publication, signing-key creation, or paid service activation without explicit approval.

## Current database
Project ref: `cusdjhfdhimoucjvxsmr`

Tables:
- `admin_members`
- `news_posts`
- `productions`
- `festival_editions`
- `festival_events`
- `workshops`
- `open_calls`
- `app_announcements`

Storage bucket:
- `public-media` (public read, admin-only writes)

## Acceptance criteria
- Website and app display the same published records.
- A content editor creates or edits a story once, and both clients show the update.
- Anonymous users cannot create, edit or delete published content.
- Draft content is invisible to public clients.
- Existing artist-directory data and integration remain unchanged.
- APK build is reproducible from GitHub Actions.
