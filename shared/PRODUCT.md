# Back on Track — shared product contract

The web/PWA and native iPhone app are separate release tracks, but one product.
This file is the source of truth for keeping them recognisably the same.

## Core promise

- Calm, low-pressure daily rhythm.
- No streaks, scores, shame or catch-up.
- Every task can shrink to a smallest version.
- Sunday remains a protected rest day.
- One clear primary action per screen.
- Offline-first; sync is optional and quiet.

## Navigation

| Order | Web/PWA | iPhone | Purpose |
|---|---|---|---|
| 1 | Home | Home | Greeting, intention, Morning, anchors, gentle extras |
| 2 | Wind down | Wind down | Bed/wake, mood, evening alternatives |
| 3 | Focus | Focus | One section at a time |
| 4 | Links | Links | Personal links, sharing, sync |
| 5 | Shelves | Shelves | Borrowable library, not a dumping drawer |

The optional **quiet 30 days** lives inside Home and Wind down, not as a sixth tab.

## Shared visual language

- Warm cream surface, terracotta action colour, sage support, lavender evening.
- Rounded cards, soft borders, restrained shadows.
- Large tap targets and clear focus states.
- Rounded, friendly headings with readable body text.
- Light and dark mode must both pass WCAG AA.
- Motion is optional and respects Reduce Motion.

Platform-specific polish is welcome, but colour, hierarchy, spacing and wording
should remain consistent.

## Shared interactions

- Tapping a task toggles it; no separate confirm step.
- Every task offers **Even smaller**.
- Borrowed shelf items remain on the shelf and show **On Home / In Anchors**.
- Removing a Home task moves it to **Keep close**.
- Sleep and wake can be logged in one tap, then adjusted.
- Undo is offered for destructive or accidental actions.
- Empty states explain the next small step, never blame the user.

## Platform-specific additions

These may exist only on native iPhone, but must not change the core rhythm:

- HealthKit steps, walking and mindful minutes (read-only).
- Native share sheet.
- Coding-pause timer and next-step note.
- Haptics and native authentication.

## Tone rules

Use: “if you want”, “one small thing”, “nothing to catch up on”, “that is enough”.
Avoid: “failed”, “streak broken”, “you should have”, “productivity score”, “must”.
