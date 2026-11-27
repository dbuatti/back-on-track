# Back on Track — release checklist

## Every release

- [ ] Core smoke test: open, toggle a task, log wake, log bed, add note.
- [ ] Sync test: change on one device, pull on the other, confirm no data loss.
- [ ] Fresh-device test: sign in on a clean install and confirm remote state loads.
- [ ] Empty-state test: no empty local state overwrites populated remote state.
- [ ] Accessibility: Dynamic Type, VoiceOver labels, contrast, Reduce Motion.
- [ ] Copy review: no shame, streaks, scores or catch-up language.
- [ ] Shared ids and JSON shape still match `DATA-CONTRACT.md`.

## Web / PWA

- [ ] Bump `VERSION` in `index.html`.
- [ ] Bump `CACHE_VERSION` in `sw.js`.
- [ ] Verify manifest icons and `start_url`.
- [ ] Deploy GitHub Pages.
- [ ] Test install / update on Android Chrome and iPhone Safari.

## iPhone

- [ ] Bump `CFBundleVersion` and keep `CFBundleShortVersionString` stable.
- [ ] Build for a physical iPhone, not only unsigned simulator/device compile.
- [ ] Test magic-link callback in the `backontrack` URL scheme.
- [ ] Test local-only and account modes.
- [ ] Verify app icon and launch screen.
- [ ] When paid account is enabled: TestFlight build, HealthKit entitlement,
      privacy descriptions and Health permission denial flow.

## Version alignment

The web footer and native build should identify the same release family, e.g.
web `v67` and iPhone build `67`. Platform-specific hotfixes may increment one
track independently, but the parity checklist must record the difference.
