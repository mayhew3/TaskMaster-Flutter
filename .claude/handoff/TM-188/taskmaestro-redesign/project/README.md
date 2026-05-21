# Maestro Design System

A dark, brand-blue + magenta-accent design language extracted from the TaskMaestro app redesign. Built around a confident dark blue surface, soft white type, color-coded date semantics, and a single magenta highlight reserved for primary actions and completion states.

## Source

This system was distilled from the **TaskMaestro Flutter** redesign work in this project:
- `cards.jsx` — task card components (V8/V9 are canonical)
- `edit.jsx` — full-screen task editor + popup pickers
- `assets/TaskMaestro_Logo.jpg` — brand logo

The original Flutter app lives at `mayhew3/TaskMaster-Flutter` on GitHub.

## Index

- `README.md` — this file
- `colors_and_type.css` — design tokens (CSS variables) for color, type, spacing, radii, shadows
- `assets/` — logo + brand images
- `preview/` — small specimen cards rendered in the Design System tab
- `ui_kits/taskmaestro/` — high-fidelity recreation of the TaskMaestro mobile screens
- `SKILL.md` — Agent Skill manifest for Claude Code compatibility

## Content fundamentals

**Voice.** Direct, second-person, sentence-case. The product talks to you like a calm, unfussy assistant — never marketing-speak, never gamified.

**Examples that fit.**
- "No dates set"
- "Tap to edit · all optional"
- "Add new context..."
- "All contexts are already selected."

**Examples that don't fit.**
- "🎉 Awesome! You've crushed it!" — no emoji rewards, no exclamation
- "Your tasks, supercharged." — no marketing copy
- "PRIORITY:" / "CONTEXTS:" — labels are sentence-case, not screaming caps

**Casing.**
- Field labels: ALL CAPS, 11–12px, letter-spacing 0.4–0.5 (the only place caps appear)
- Section labels in popups, e.g. "ADD A DATE": same caps treatment
- Everything else: sentence case
- Dates: `May 6` (no leading zero), relative strings `in 2d`, `3d ago`

**Tone.** Quietly confident. Status messages prefer fact over praise. Empty states use italics: *"No dates set"*, *"No contexts selected"*.

**Emoji.** Not used. Pictograms are inline SVG only.

## Visual foundations

### Color
Two anchors carry the entire system:
- **Brand blue** `#2C74C5` — the brand mark and basis for every surface
- **Card surface** `#296BB5` — brand blue darkened 8%; the actual color used on cards
- **Brand magenta** `#D83AFF` — primary actions, completion checkbox fill, "Save" CTA, recurring-task indicator

Text is white at three levels of opacity (95% / 70% / 50%). No pure-black or pure-gray ramps — everything is alpha-on-blue.

**Date semantics** are color-coded and reused everywhere a date appears:
- Start: lavender `#B3B5DD`
- Target: gold `#EFE0A0`
- Urgent: warm peach `#F4C8A8`
- Due: rose `#F4B0B0`

Each tone has matched fg / bg-tint / border colors so a date can render as a chip, a marker, a row tint, or a calendar accent without retuning.

**Area** colors are pastel-warm and used as ~10–12px dots, never as fills. They identify a task's life-area (Family, Maintenance, etc.) without competing with the date palette.

### Type
- **Display / titles**: 22–24px, weight 500, letter-spacing -0.2
- **Body**: 13.5–15px, weight 500, default line height
- **Labels (caps)**: 10.5–12px, weight 600–700, letter-spacing 0.4–0.5, uppercase
- **Tabular numerics**: any number in a card metadata row uses `font-variant-numeric: tabular-nums` so columns line up across cards.

System sans (`-apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, …`) is the default — the brand reads "calm, native, dark mode" rather than typographically distinctive.

### Surface, radius, shadow
- Cards: 12px corner radius, 1px inner highlight border `rgba(255,255,255,0.06)` on top edge for a subtle bevel
- Popups / sheets: 16px top radius, slide up from bottom with a backdrop-blurred overlay
- Pills / chips: fully-pill (999px radius)
- Buttons: 10–12px radius
- Shadows are sparing: only on the magenta CTA (`0 4px 14px rgba(216,58,255,0.4)`) and on selected timeline markers (color-matched glow)

### Spacing
- Card internal padding: 14px horizontal, 10–12px vertical
- Form field gap: 16px
- Pill gap: 6px
- Section gap inside popups: 14px with a top hairline

### Borders
- Hairlines: `rgba(255,255,255,0.06–0.10)` — almost invisible, used to separate sections inside popups
- Field borders: `rgba(255,255,255,0.10–0.18)` solid; dashed `1px` for "+ Add new..." inline fields and unset-date pills
- Selected state: the relevant accent color at 0.4–0.6 alpha

### Animation
Subtle. The only motion is a 20px rise + opacity fade-in for the editor (`tm-rise` keyframes). No bounces, no parallax. Hover/press states are color-shift only (e.g. background opacity bumps from 0.04 to 0.08).

### Iconography
- Inline SVG, 1.5–2.4px stroke weight, round line caps and joins, 12–22px sizing
- The closest CDN match for the system's stroke style is **Lucide** (lucide.dev) — the redesign's icons follow Lucide's geometry conventions
- Recurring tasks use a small circular-arrow glyph inside the checkbox itself
- Context icons (email, phone, computer, …) are minimal monochrome SVG, sized 12–16px

### Imagery
The brand logo is the only photographic / raster asset. There is no stock photography or illustration system. Surfaces stay color-tonal.

## Caveats
- **Type** uses system sans — there's no custom display font, so designs lean on weight + scale for hierarchy. If a future app wants more typographic personality, choose one geometric sans (e.g. Inter, Geist, or Söhne) and pin it in `colors_and_type.css`.
- **Iconography** is inline SVG drawn ad-hoc per component. If this system grows, adopt Lucide as the canonical pack.
- **Light mode** is not designed. The system is dark-only by intent.
