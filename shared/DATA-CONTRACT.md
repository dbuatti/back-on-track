# Back on Track — shared data contract

Both release tracks use the same Supabase table and JSON shape.

## Table

`public.back_on_track_state`

| Column | Meaning |
|---|---|
| `user_id` | Supabase auth user id; RLS restricts access to the owner |
| `state` | JSON app state |
| `updated_at` | Database write timestamp, ISO timestamp |

The app-level ordering timestamp is `state.settings.updatedAt`, a numeric
Unix milliseconds value.

## State shape

```json
{
  "settings": {
    "lists": {
      "morning": [{ "id": "m_breakfast", "text": "Breakfast outside, quiet", "small": "..." }],
      "anchors": [{ "id": "a_walk", "text": "Walk", "small": "..." }],
      "instead": [{ "id": "i_read", "text": "Read one page", "small": "..." }]
    },
    "targetBed": "22:30",
    "myLinks": [{ "id": "fnh-study-hub", "text": "FNH Study Hub", "url": "https://..." }],
    "shelves": [{ "id": "sh_notfeeling", "name": "Not feeling it", "items": [] }],
    "loans": [{ "id": "ln_g_nick_morning", "itemId": "g_nick", "shelfId": "sh_notfeeling", "list": "morning" }],
    "program30": { "loaded": false, "step": 0, "done": {}, "notes": {}, "reflection": "" },
    "updatedAt": 0,
    "doneForToday": ""
  },
  "days": {
    "2026-11-27": {
      "date": "2026-11-27",
      "checks": { "a_walk": true },
      "intention": "",
      "readingMinutes": null,
      "bedTime": "23:10",
      "wakeTime": "07:20",
      "mood": "okay",
      "note": "",
      "codingNextStep": null
    }
  }
}
```

Unknown fields must be preserved by imports and merges. Missing fields are
filled with defaults; an empty incoming value must not erase a meaningful
local value. The Swift models decode every key with `decodeIfPresent`, so older
exports and partial remote states must load without throwing. Unit tests cover
missing `intentionIndex`, `notes`, `personalization` and `codingNextStep`.

## Stable ids

Task, shelf and loan ids are shared across platforms. Never regenerate an id
when changing wording. New custom tasks use a `custom_` prefix.

## Merge rules

- Days are unioned by `YYYY-MM-DD`.
- Checklist marks are unioned by task id.
- Lists, shelves and links are merged by id.
- Deletion tombstones prevent removed rows returning from another device.
- Program marks and notes are unioned.
- A newer empty reflection cannot erase an existing one.
- A fresh device must pull remote state even when both timestamps are zero.
- An empty fresh install must never overwrite a populated cloud record.

## Authentication

- Web/PWA: Supabase email magic link.
- iPhone: Supabase magic link, Google OAuth via `ASWebAuthenticationSession`,
  email/password, or one-time web sync key. All paths land on the same
  `backontrack://auth-callback` URL scheme.
- Android PWA: same web magic-link flow.
- HealthKit is local/read-only and is not part of the shared JSON contract.
