# Back on Track — feature parity checklist

Legend: ✅ shipped · 🟡 partial · ⬜ planned · 🍎 native-only

| Feature | Web/PWA | iPhone | Notes |
|---|---:|---:|---|
| Home, Morning, anchors | ✅ | ✅ | Shared task ids and smallest-step copy |
| Wind down sleep logging | ✅ | ✅ | One-tap log + adjust on iPhone |
| Mood and waking note | ✅ | ✅ | |
| Instead of gaming | ✅ | ✅ | |
| Focus mode | ✅ | 🟡 | iPhone needs live task content |
| Personal links | ✅ | 🟡 | iPhone read/open/copy; editing planned |
| Shelves and borrowing | ✅ | ✅ | On-loan state shown |
| Task add/remove | ✅ | ✅ | Removal moves to Keep close |
| Quiet 30 days | ✅ | ✅ | Shared card on Home and Wind down; marks and reflection sync |
| Sleep trend / week view | ✅ | ✅ | Soft 14-night pattern, last 7 shown; no score |
| Import / export JSON | ✅ | ⬜ | Needed for backup and recovery |
| Supabase sync | ✅ | ✅ | Same table and RLS |
| Local-only use | ✅ | ✅ | |
| Personalised focus / support onboarding | ⬜ | ✅ | Native-first; can be ported to PWA later |
| Coding pause | ⬜ | 🍎 | Optional native enhancement |
| HealthKit summary | ⬜ | 🍎 | Paid capability required |
| Share web app | ✅ | 🍎 | Native share sheet |
| Dark mode | ✅ | ⬜ | iPhone currently forces light |
| App icon / PWA icon | ✅ | ✅ | Shared artwork |

## Release rule

Before calling the tracks “in parity”, all core rows above must be ✅ on both.
Native-only rows may remain 🍎, but they must not change the shared data shape
or make the PWA feel broken.
