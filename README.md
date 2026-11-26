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
  `state.settings.targetBed`. Named shelves live in `state.settings.shelves`, and
  temporary "borrowings" in `state.settings.loans`, so a shelf item can be used in
  the day without being deleted from the shelf. Export writes the same shape and
  Import merges it, so it's easy to fold into an anchor planner later.
- **Rendering** — `renderAll()` and friends rebuild each section from state.
- **Edit mode** — toggled by *Edit lists*; reveals add / remove / reorder (↑↓ and drag).
  In edit mode a Home row also gets **↧ Shelf**, which moves it to a named shelf
  (with Undo) instead of deleting it. *My links* is always editable. Shelf editing
  is its own deliberate mode (**Edit shelves**); reorder, rename, add or remove with
  a five-second Undo, so a stray ✕ never quietly clears a shelf.

## Screens

The bottom menu keeps each screen light:

- **Home** — the default until 7pm; from 7pm through the night the app opens on
  Wind down instead. A "last night" banner (bedtime, wake and duration, with a
  small ✎ to correct the time), greeting with a quiet today count, a little
  italic note for the day, one optional small idea from a shelf, a soft progress
  strip, **Start focus mode**, **Log wake**, morning checklist, daily anchors.
  Borrowed shelf items appear in the relevant list with a quiet "from …" tag.
- **Wind down** — "instead of gaming", bedtime/wake + mood (with gentle word
  captions), a sleep-trend strip (21 clearly-labelled nights with an average and
  usual wake time), a short note on waking, and the soft-dot week. All log buttons
  open a small time picker, prefilled with *now* but editable, so a late log can
  still record the real time. Cancel (or Escape) closes it without saving.
- **Focus** — one section at a time; `‹ / › / Done` steps through. Follows the card
  onto its screen, and skips hidden sections on Sunday.
- **Links** — The Door (`https://danieles-mac-mini.tailab1fd5.ts.net:8451/`); direct
  links to FNH Study Hub and Comm Analytics (URLs from `~/Projects/the-door/apps.yaml`,
  so they open in the browser on this device rather than launching on the mini);
  a `?search=fnh` shortcut for everything else; device sync; the ⛈️ Tool kit button
  (`thecalmafter.vercel.app`); and Export/Import. Every link has a small **⧉** button
  to copy its URL to the clipboard (with a fallback for older browsers). A **My links**
  card holds your own sites — add, remove, reorder (**≡**) and copy any URL there. From the iPhone
  home-screen app, external links use iOS's `x-safari-` hand-off so they open in
  real Safari and iCloud Keychain autofill works (notably for Kajabi).
- **More** — the fifth bottom tab. Named shelves, not one dumping drawer:
  **Not feeling it** (Sangha, Kriya, sun movements, Nick Moss and the functional
  neuro check-in) and **Keep close** for good things you don't want to withdraw,
  just aren't pulling into the day right now. Rename shelves, add another, or move
  a Home item here with **↧ Shelf** in edit mode. Tap an item for a much smaller
  version, then **Borrow** it into *Daily anchors* or *Morning* like taking a book
  out of a library — it stays on its shelf and can be returned. **Back on morning**
  / **Back on anchors** permanently reinstates things that came from Home. A quiet
  stats panel sits below: average sleep, days with one gentle step in the last 30,
  most-often done item and a soft dot grid — patterns, not scores. Home or Escape
  takes you back.

  Note: The Door's `?app=<id>` asks the server to open the app on its own Mac, which
  doesn't show anything on an iPhone. That's why the useful shortcuts here use the
  registry's `url` field instead. Apps with no `url` in the registry are reached via
  The Door's search. Apps hosted on the MacBook Pro need it awake.

## Design notes

The interface is intentionally quiet: warm clay/oat colours, sage for "done", and a
slow shift to ochre in the morning or dusk lavender at night. The iPhone status bar
follows that phase colour. The date sits under the title, the bottom menu is centred
on wide screens, and controls are at least 44px tall so they are easy to hit one-handed.
Nothing pulses or slides for anyone who has asked iOS to reduce motion. Text meets
WCAG AA contrast in every time-of-day phase; checklist items are real buttons whose
spoken name matches the visible label. Mood buttons and *Edit lists* expose their
on/off state to screen readers, sync and focus status announce quietly, keyboard
users get a clear focus ring, small trend labels stay at 11px, the Home count and
wake prompt update in place, sleep bars carry readable night labels, the Safari
hand-off note has calmer spacing, and every small link, field and drag handle now
has a 44px tap target. A Lighthouse run
scores 100 for accessibility and best practices. Desktop gets a gentle hover tint;
touch devices keep only the instant press feedback.

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
- Sunday is a protected rest day: morning/anchors/"instead of gaming" and the
  progress/edit controls are hidden, leaving a soft "rest is the practice" card
  with one **Log sleep** button, plus the bedtime log and week view.
- Reduced-motion is respected; tiny haptics only fire after a real tap.
- Everything editable: add, remove, reorder any list. Undo is offered on delete.
- Export / Import JSON for backup and merging into the anchor planner. Imports
  fill in missing fields, keep any settings the export didn't know about, and
  never erase local data. Export/import feedback uses the calm in-app snackbar
  rather than a native alert.

## Merging into your anchor planner

Use **Export** to get a dated JSON. Each day is keyed `YYYY-MM-DD` with checklist
items by id, bedtime/wake, mood and note — map those fields onto your planner's schema.