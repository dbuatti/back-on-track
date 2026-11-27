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

The optional **quiet 60 days** lives inside Home and Wind down, not as a sixth tab. It is adaptive: six phases, pace settings, focus-area substitutions and a gentle re-entry after gaps.

## Shared visual language

- Warm cream surface, terracotta action colour, sage support, lavender evening.
- Rounded cards, soft borders, restrained shadows.
- Large tap targets and clear focus states.
- Rounded, friendly headings with readable body text.
- Light and dark mode must both pass WCAG AA; iPhone uses dynamic colour tokens.
- Motion is optional and respects Reduce Motion.
- The background shifts gently with the time of day: morning sun, daytime sage,
  evening lavender, night terracotta.
- A quiet **Small win** card reflects back that something is done, or that an
  empty day is still okay.
- Gentle haptics and a quiet one-word whisper (“good.”, “that counts.”) confirm
  real taps. They never appear for passive events or with a score.

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

## Personalisation

New users choose what tends to pull them in (coding, gaming, scrolling,
shopping, food, something else, or nothing specific), which support cards they
want, and whether to begin with a gentle starter set or an empty slate. This is
a preference, never a diagnosis or label. It can be changed later from Links →
Make it yours.

## Dynamic suggestion

Home opens with a quiet **Right now** card. It reacts to time of day, whether
sleep was logged, mood, program gaps and the chosen focus. It suggests exactly
one small next action — log wake, log bed, pause, set an intention or pick an
anchor. It never adds a score or pressure.

## Self-regulation

Piano improvisation and shaking on the spot are first-class, shame-free
self-regulation options. They live on the **Ways to settle** shelf, in the
Focus screen, in onboarding, and as a grounding step in the pause sheet. They
are not framed as symptoms, treatment or tasks to complete.

## Platform-specific additions

These may exist only on native iPhone, but must not change the core rhythm:

- HealthKit steps, walking and mindful minutes (read-only).
- Native share sheet.
- Coding-pause timer and next-step note.
- Haptics and native authentication.

## Tone rules

Use: “if you want”, “one small thing”, “nothing to catch up on”, “that is enough”.
Avoid: “failed”, “streak broken”, “you should have”, “productivity score”, “must”.
