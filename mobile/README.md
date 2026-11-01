# Teatro AlSaeed Android App

Flutter application for Teatro AlSaeed and Minya International Theatre Festival.

## Architecture
- Flutter / Dart mobile client.
- Supabase project: `cusdjhfdhimoucjvxsmr`.
- Shared content database for the website and Android app.
- Arabic-first UI with an English language toggle.
- Public app access is read-only. Content editing belongs in the secured admin dashboard (separate workstream).

## Local setup
Install Flutter stable (Dart 3.9 or newer), then:

```bash
cd mobile
flutter create --platforms=android --org org.teatroalsaeed .
flutter pub get
flutter run \
  --dart-define=SUPABASE_URL=https://cusdjhfdhimoucjvxsmr.supabase.co \
  --dart-define=SUPABASE_PUBLISHABLE_KEY=YOUR_PUBLISHABLE_KEY
```

The publishable key is intended for client applications, but it is only safe when every exposed table is protected by RLS. Never put a Supabase secret or service_role key in the app.

## Android release
```bash
flutter build apk --release \
  --dart-define=SUPABASE_URL=https://cusdjhfdhimoucjvxsmr.supabase.co \
  --dart-define=SUPABASE_PUBLISHABLE_KEY=YOUR_PUBLISHABLE_KEY
```

APK output:
`build/app/outputs/flutter-apk/app-release.apk`

## Current first milestone
- Home screen with latest published news, productions and festival edition.
- News list.
- Productions archive.
- Festival editions.
- More links to the existing website.
- Arabic / English UI toggle.
- Read-only Supabase access using the publishable key.

## Next milestones
1. Admin account bootstrap and protected content management dashboard.
2. Migrate verified website content into Supabase without deleting the static archive.
3. Add event schedule, workshops and open-call detail pages.
4. Add Firebase Cloud Messaging push notifications.
5. Add deep links, app icons, privacy/terms screens and accessibility polish.
6. Test on Android devices, generate signed release bundle (AAB), and publish to Google Play.

## Configuration
The GitHub Actions workflow expects repository secrets:
- `SUPABASE_URL`
- `SUPABASE_PUBLISHABLE_KEY`

The workflow builds an APK artifact; it does not publish to Google Play automatically.
