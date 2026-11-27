# Back on Track — iPhone app

SwiftUI app with Supabase sync. Generated with `xcodegen` from `project.yml`;
edit the YAML, not the `.xcodeproj` directly.

## Build without a phone

```bash
../scripts/ios.sh build   # unsigned device compile
../scripts/ios.sh test    # unit tests in iOS Simulator
```

## Install on the connected iPhone

Requires the iPhone unlocked, trusted, and plugged in.

```bash
../scripts/ios.sh install
```

## Update paths when devices are away

| Path | Needs phone plugged in? | Notes |
|---|---:|---|
| Source work + tests | No | This is what we do while phones are away |
| Free Apple team install | Yes | Cable required; profile expires after ~7 days |
| TestFlight | No, after upload | Requires paid Apple Developer account |
| App Store | No, after upload | Requires paid account and review |
| AltStore / Sideloadly | Once, then Wi-Fi | Free re-signing, but still weekly and fragile |

The practical plan is to keep improving and testing the source now, then use
`archive` + TestFlight once the paid account is available. That lets the phone
update itself over the air with no cable.

## Distribution options

- **Now:** share the web/PWA link: https://dbuatti.github.io/back-on-track/
- **Paid account:** TestFlight build from `../scripts/ios.sh archive`.
- **Google sign-in:** enabled through Supabase OAuth; no client secret in the app.

## Capabilities

- Supabase: magic link, Google OAuth, email/password, sync key.
- HealthKit: code ready but disabled; enable `HealthKitConfig.enabled` and attach
  `BackOnTrack-HealthKit.entitlements` after adding the paid capability.
- iCloud/CloudKit and Sign in with Apple: intentionally not used because free
  personal teams do not support them.
