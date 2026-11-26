# Back on Track

A small, calm daily rhythm app. One self-contained `index.html`, no build step
and no backend required to run it. Your working copy lives in the browser's
`localStorage`; if device sync is set up, a private copy is also kept in a Gist.

**v33** keeps the whole-page reset from v32 and adds a quieter Home, a **Small
starts** shelf, a **Movement** shelf (push-ups, walks, stairs, stretching) with
an optional gradual walking sketch, device dark mode, named-shelf swipe-to-delete
with Undo, and sleep details derived only from times you already logged. No new
tracking, scores or clinical claims.

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
  the day without being deleted from the shelf. `state.settings.walkStartMinutes`
  only feeds the optional walking sketch — it is not a target or a log. Export
  writes the same shape and Import merges it, so it's easy to fold into an anchor
  planner later.
- **Rendering** — `renderAll()` and friends rebuild each section from state.
- **Edit mode** — toggled by *Edit lists*; reveals add / remove / reorder (↑↓ and drag).
  In edit mode a Home row also gets **↧ Shelf**, which moves it to a named shelf
  (with Undo) instead of deleting it. *My links* is always editable. Shelf editing
  is its own deliberate mode (**Edit shelves**); reorder, rename, add or remove with
  a five-second Undo, so a stray tap never quietly clears a shelf.

## Screens

The bottom menu keeps each screen light:

- **Home** — the default until 7pm; from 7pm through the night the app opens on
  Wind down instead. A "last night" banner (bedtime, wake and duration, with a
  small ✎ to correct the time), the date, a single quiet line for the day, one
  optional **Small starts** idea with *Another / Not now / See the shelf*,
  **Start focus mode**, **Log wake**, morning checklist and daily anchors. No
  count, progress strip or edit controls on Home; borrowed shelf items appear in
  the relevant list with a quiet "from …" tag.
- **Wind down** — "instead of gaming", bedtime/wake + mood (with gentle word
  captions), and a sleep-trend strip (21 clearly-labelled nights). The latest
  logged bed, wake and approximate duration sit above it with **Adjust times**;
  the summary keeps only a soft median/middle-half note in its tooltip, never a
  score. A short note on waking and the soft-dot week follow. All log buttons open
  a small time picker, prefilled with *now* but editable, so a late log can still
  record the real time. Cancel (or Escape) closes it without saving.
- **Focus** — one section at a time; `‹ / › / Done` steps through. Follows the card
  onto its screen, and skips hidden sections on Sunday.
- **Links** — one calm repeated row pattern. The Door
  (`https://danieles-mac-mini.tailab1fd5.ts.net:8451/`) leads; **More links** opens
  FNH Study Hub, Comm Analytics (URLs from `~/Projects/the-door/apps.yaml`, so they
  open on this device rather than launching on the mini), a `?search=fnh` shortcut
  and the Tool kit (`thecalmafter.vercel.app`). Sync, My links and data controls
  sit behind their own quiet disclosures. Every row has a **Copy** button (with a
  fallback for older browsers). A **My links** card holds your own sites — add,
  remove, reorder by drag and copy any URL there. From the iPhone home-screen app,
  external links use iOS's `x-safari-` hand-off so they open in real Safari and
  iCloud Keychain autofill works (notably for Kajabi).
- **More** — the fifth bottom tab. Named shelves, not one dumping drawer:
  **Not feeling it** (Sangha, Kriya, sun movements, Nick Moss and the functional
  neuro check-in), **Keep close**, **Movement** (push-ups, walks, stairs, a long
  stretch) and **Small starts** (small pleasant openings, including a wall
  push-up and a short walk). Rename shelves, add another, or move a Home item here
  with **↧ Shelf** in edit mode. Tap an item for a much smaller version, then
  **Borrow** it into *Daily anchors* or *Morning* like taking a book out of a
  library — it stays on its shelf and can be returned. Swipe a shelf row either
  way to remove it, with a five-second **Undo**; the explicit **Remove** button is
  there in Edit shelves mode. On the Movement shelf, **Gradual movement, if you
  want** sketches a walking ladder from one comfortable starting point, with
  "a little further when that feels right" and no dates, targets or logging.
  **Back on morning** / **Back on anchors** permanently reinstates things that
  came from Home. Home or Escape takes you back.

  Note: The Door's `?app=<id>` asks the server to open the app on its own Mac, which
  doesn't show anything on an iPhone. That's why the useful shortcuts here use the
  registry's `url` field instead. Apps with no `url` in the registry are reached via
  The Door's search. Apps hosted on the MacBook Pro need it awake.

## Design notes

The interface is intentionally quiet: one warm surface, one ink hierarchy, one
action colour, and flat cards with no shadows or gradients. The day shifts softly
between morning ochre and dusk lavender; dark mode follows the device, with no
manual switch. The iPhone status bar follows the phase colour. Controls are at
least 44px tall, the bottom menu is text-only and centred on wide screens, and
links, fields and drag handles all have generous tap targets. Nothing pulses or
slides for anyone who has asked iOS to reduce motion. Text meets WCAG AA contrast
in light and dark; checklist and mood buttons are real buttons whose spoken name
matches the visible label; sync and focus status announce quietly; keyboard users
get a clear focus ring. A Lighthouse run scores 100 for accessibility and best
practices. Desktop gets a gentle hover tint; touch devices keep only the instant
press feedback.

## Sync across devices

The Links screen keeps devices in step through a **private GitHub Gist** behind a
small Vercel bridge (`../back-on-track-sync/`). Sync is automatic and needs no
account in the app:

- The GitHub token lives only in the Vercel function's encrypted env, never in
  the browser, the app source or an export.
- Each device holds a low-value random pairing key plus the gist id in
  `localStorage` (`bot.sync.v1`). A new device pairs once with a **six-character
  code** typed into *Set up sync*, or by opening
  `https://dbuatti.github.io/back-on-track/#pair=CODE`. The app consumes the hash
  and cleans the address bar. A home-screen app has its own storage, so type the
  same code there too. Pairing QR and link artefacts are local and gitignored.
- The older token + gist id fields still work for a manual setup, behind
  *Using a token instead*, but are hidden when automatic sync is configured.

Once configured, the app pulls once on open and pushes quietly about 1.5 seconds
after any real change, and flushes pending changes when you leave the app.
**Sync now** just does it immediately. Sync is last-change-wins using
`settings.updatedAt`; cosmetic touches like the daily note use a quiet save so
opening the app never claims to be newer data. Sleep and mood trends are computed
from the shared records on each device. If the bridge or GitHub is offline, sync
fails silently and the Links card still shows the last successful time.

## Rhythm notes

- Kind by default: missed days render as empty dots, never red X's or streaks.
- Big tap targets, few choices per screen, collapsible-by-done morning items.
- Swipe a Home row right to tick it, left to untick; a plain tap still works.
  Swipe a shelf row either way to remove it, with Undo.
- The optional movement ladder is a sketch, not a schedule: start from a
  comfortable walk, change it whenever you like, and stay at any step.
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