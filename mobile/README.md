# Teatro AlSaeed Android App

Flutter application for Teatro AlSaeed and Minya International Theatre Festival.

## Architecture
- Flutter / Dart mobile client.
- Dedicated Supabase project: `cusdjhfdhimoucjvxsmr`.
- Website and app will consume the same published content.
- Arabic-first interface with an Arabic / English toggle.
- Public mobile client is read-only. Editing will be handled by a secured admin CMS.

## Local setup
Install Flutter stable with Dart 3.9 or newer:

```bash
cd mobile
flutter create --platforms=android --org org.teatroalsaeed .
flutter pub get
flutter run
```

The Supabase project URL and **publishable** key are configured in the app. A publishable key is intended for client-side use; Row Level Security is the access boundary. Never add a Supabase secret or service_role key to Flutter, HTML, or any other public client.

## Android release
```bash
flutter build apk --release
```

APK output:
`build/app/outputs/flutter-apk/app-release.apk`

## Implemented first milestone
- Home screen with latest published news, productions and festival edition.
- News list.
- Productions archive.
- Festival editions.
- Links to the existing official website.
- Arabic / English UI toggle.
- Live, read-only Supabase queries.

## Remaining delivery milestones
1. Build a protected admin CMS and bootstrap the first owner account.
2. Audit and migrate verified website content into Supabase without deleting the static archive.
3. Add event schedules, workshop and open-call details.
4. Add Firebase Cloud Messaging push notifications.
5. Add deep links, app icons, privacy/terms screens and accessibility polish.
6. Test on Android devices, generate a signed Android App Bundle (AAB), then submit to Google Play after owner approval.

## Automation
GitHub Actions runs Flutter analysis, widget tests and a release APK build on changes to this branch. The APK is uploaded as a workflow artifact; the workflow does not publish to Google Play.
