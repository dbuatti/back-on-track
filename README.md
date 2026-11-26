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

## Design notes

- Kind by default: missed days render as empty dots, never red X's or streaks.
- Big tap targets, few choices per screen, collapsible-by-done morning items.
- Everything editable: add, remove, reorder any list.
- Export / Import JSON for backup and merging into the anchor planner.

## Merging into your anchor planner

Use **Export** to get a dated JSON. Each day is keyed `YYYY-MM-DD` with checklist
items by id, bedtime/wake, mood and note — map those fields onto your planner's schema.