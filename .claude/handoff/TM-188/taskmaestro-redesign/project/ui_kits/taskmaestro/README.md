# TaskMaestro UI Kit

A high-fidelity recreation of the TaskMaestro mobile app rendered with the Maestro Design System tokens. Click-thru demo:

- **Tasks list** — colored area dots, time bar, priority pips, points circle, magenta checkboxes for completion
- **Double-tap a card** to open the **full-screen editor** with all popup pickers (area, contexts, dates timeline)
- **Editor "Done"** returns you to the list

## Files

- `index.html` — entrypoint, click-thru demo
- `cards.jsx` — task card components. `CardV9` is the canonical task card. `CardV1`–`CardV8` are exploration variants kept for reference.
- `edit.jsx` — full-screen task editor + popup pickers (`EditorFullScreen`, `AreaPicker`, `ContextPicker`, `DateTimelinePopup`)
- `ios-frame.jsx` — iPhone bezel (status bar, home indicator)
- `colors_and_type.css` — design tokens

## Component map

| Component | What it is | When to use |
|---|---|---|
| `CardV9` | Task card with expand/collapse, area dot, time bar, priority + points | Any list-of-tasks surface |
| `EditorFullScreen` | Top-bar + scrolling form + popups | Editing or creating a task |
| `IOSDevice` | iPhone bezel for full-screen demos | Embedding screens in a frame |

## Sources
- Original Flutter code: `mayhew3/TaskMaster-Flutter`
- Design system tokens: `../../colors_and_type.css`
