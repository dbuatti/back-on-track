# Back on Track

A small, calm daily rhythm app. One self-contained `index.html`, no build step,
no backend. Data lives in your browser's `localStorage`.

## Run it

- **Easiest:** open `index.html` directly in a browser. Everything works.
- **For the PWA / home-screen install** (service worker needs http), serve the folder:
  ```bash
  cd back-on-track
  python3 -m http.server 8000
  # then visit http://localhost:8000
  ```
  On iPhone/iPad: open that URL in Safari → Share → *Add to Home Screen*.
- **Host on GitHub Pages:** push this folder to a repo, enable Pages on the branch.
  The relative paths (`./index.html`, `./sw.js`, icons) work under a subpath too.

## Files

| File | What |
|------|------|
| `index.html` | The whole app: markup, CSS, JS. Start here. |
| `manifest.webmanifest` | PWA manifest (name, icons, colours). |
| `sw.js` | Minimal offline cache. Bump `CACHE_VERSION` when you edit files. |
| `icon-192.png`, `icon-512.png` | Home-screen icons (sage circle + check). |

## How it's put together (for tweaking)

The JS is organised in labelled sections inside one `<script>`:

- **DEFAULT_LISTS** — the starter morning / anchors / instead items. Edit here to
  change defaults for a fresh browser.
- **State** — `load()` / `save()` wrap `localStorage` in try/catch. Key is `bot.v1`.
- **Data model** — one dated record per day:
  ```js
  state.days["2026-11-26"] = {
    checks: { m_sangha: true, a_walk: true }, // item id -> done
    intention: "be gentle",
    readingMinutes: 15,
    bedTime: "23:05",
    wakeTime: "06:40",
    mood: "good",        // "low" | "okay" | "good" | null
    note: "long day, good walk"
  }
  ```
  Lists live in `state.settings.lists.{morning,anchors,instead}`; target bedtime in
  `state.settings.targetBed`. This shape is what Export writes and Import reads, so
  it's easy to merge into your anchor planner later.
- **Rendering** — `renderAll()` and friends rebuild each section from state.
- **Edit mode** — toggled by *Edit lists*; reveals add / remove / reorder (↑↓ and drag).

## Screens

The bottom menu keeps each screen light:

- **Home** — a "last night" banner (bedtime, wake and duration), greeting, a little
  italic note for the day, a soft progress strip, **Start focus mode**, **Log wake**,
  morning checklist, daily anchors.
- **Wind down** — "instead of gaming", bedtime/wake + mood, a sleep-trend strip
  (last 21 nights with an average and usual wake time), a short note on waking,
  and the soft-dot week. All log buttons open a small time picker, prefilled with
  *now* but editable, so a late log can still record the real time.
- **Focus** — one section at a time; `‹ / › / Done` steps through. Follows the card
  onto its screen, and skips hidden sections on Sunday.
- **Links** — The Door (`https://danieles-mac-mini.tailab1fd5.ts.net:8451/`); direct
  links to FNH Study Hub and Comm Analytics (URLs from `~/Projects/the-door/apps.yaml`,
  so they open in the browser on this device rather than launching on the mini);
  a `?search=fnh` shortcut for everything else; device sync; the ⛈️ Tool kit button
  (`thecalmafter.vercel.app`); and Export/Import. Every link has a small **⧉** button
  to copy its URL to the clipboard (with a fallback for older browsers). A **My links**
  card holds your own sites — add, remove and copy any URL there.

- **Not feeling it** — reached by the **☰** button in the header, not a bottom tab.
  A shelf for good things you're not in the mood for: Sangha meditation (*not feeling
  it*), Kriya meditation (*never feeling it*), sun movements and Nick Moss. Tap a name
  for a much smaller version ("one breath, eyes closed"). Editable like the other
  lists. Sangha has been removed from the Home checklist. The page also holds a quiet
  stats panel: average sleep, days with one gentle step in the last 30, most-often
  done item and a soft dot grid — patterns, not scores. Hide the bottom nav while
  here; **← Back to today** or Escape returns.

  Note: The Door's `?app=<id>` asks the server to open the app on its own Mac, which
  doesn't show anything on an iPhone. That's why the useful shortcuts here use the
  registry's `url` field instead. Apps with no `url` in the registry are reached via
  The Door's search. Apps hosted on the MacBook Pro need it awake.

## Sync across devices

The Links screen can keep devices in step using a **private GitHub Gist**:

1. On one device, make a classic GitHub token with only `gist` scope
   (the link on the Sync card opens the right page) and paste it in.
2. Tap **Set up**. The app creates a secret gist and shows its ID.
3. On each other device, paste the same token and gist ID. After that you can
   forget about it — syncing happens on its own.

The token and gist ID live only in that browser's `localStorage` (`bot.sync.v1`),
never in exports or the app source. Once configured, the app pulls once on open
and pushes quietly about 1.5 seconds after any real change, and flushes pending
changes when you leave the app. **Sync now** just does it immediately. Sync is
last-change-wins using `settings.updatedAt`; cosmetic touches like the daily note
use a quiet save so opening the app never claims to be newer data. Sleep and mood
trends are computed from the shared records on each device. If GitHub is offline,
the sync fails silently and the Links card still shows the last successful time.

## Design notes

- Warm clay / oat colours instead of white, with a gentle morning → dusk shift.
- Kind by default: missed days render as empty dots, never red X's or streaks.
- Big tap targets, few choices per screen, collapsible-by-done morning items.
- Swipe a row right to tick it, left to untick; a plain tap still works.
- Sunday is a protected rest day: morning/anchors/"instead of gaming" are hidden,
  leaving the bedtime log and a "rest is the practice" note.
- Reduced-motion is respected; tiny haptics only fire after a real tap.
- Everything editable: add, remove, reorder any list. Undo is offered on delete.
- Export / Import JSON for backup and merging into the anchor planner. Imports
  fill in missing fields and keep any settings the export didn't know about.

## Merging into your anchor planner

Use **Export** to get a dated JSON. Each day is keyed `YYYY-MM-DD` with checklist
items by id, bedtime/wake, mood and note — map those fields onto your planner's schema.