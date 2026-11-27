# Back on Track — feature parity checklist

Legend: ✅ shipped · 🟡 partial · ⬜ planned · 🍎 native-only

| Feature | Web/PWA | iPhone | Notes |
|---|---:|---:|---|
| Home, Morning, anchors | ✅ | ✅ | Shared task ids and smallest-step copy |
| Wind down sleep logging | ✅ | ✅ | One-tap log + adjust on iPhone |
| Mood and waking note | ✅ | ✅ | |
| Instead of gaming | ✅ | ✅ | |
| Focus mode | ✅ | ✅ | Live task lists, smallest steps, Sunday rest, program section |
| Personal links | ✅ | 🟡 | iPhone read/open/copy; editing planned |
| Shelves and borrowing | ✅ | ✅ | On-loan state shown |
| Task add/remove | ✅ | ✅ | Removal moves to Keep close |
| Quiet program | ✅ 60 days | ✅ 60 days | Both adaptive with phases, pace and focus substitution |
| Sleep trend / week view | ✅ | ✅ | Soft 14-night pattern, last 7 shown; no score |
| Import / export JSON | ✅ | ✅ | Native share sheet + file importer; imports fill gaps only |
| Supabase sync | ✅ | ✅ | Same table and RLS |
| Google / Gmail sign-in | ✅ | ✅ | Native uses Google OAuth; Gmail link in Links |
| Local-only use | ✅ | ✅ | |
| Personalised focus / support onboarding | ⬜ | ✅ | Native-first; can be ported to PWA later |
| Dynamic “Right now” suggestion | ✅ | ✅ | Time, mood, sleep log, program gap and focus aware |
| Daily quiet line | ✅ | ✅ | Stable gentle wording per day |
| Done for today | ✅ | ✅ | Hides edit controls and reverts task taps; reversible |
| Coding pause | ⬜ | 🍎 | Optional native enhancement |
| HealthKit summary | ⬜ | 🍎 | Paid capability required |
| Share web app | ✅ | 🍎 | Native share sheet |
| Dark mode | ✅ | ✅ | Dynamic colour tokens adapt to device appearance |
| App icon / PWA icon | ✅ | ✅ | Shared artwork |

## Release rule

Before calling the tracks “in parity”, all core rows above must be ✅ on both.
Native-only rows may remain 🍎, but they must not change the shared data shape
or make the PWA feel broken.
