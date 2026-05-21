---
name: maestro-design
description: Use this skill to generate well-branded interfaces and assets for products using the Maestro Design System — a dark, brand-blue surface with magenta accents, color-coded date semantics, and pastel area dots. Suitable for production code or throwaway prototypes/mocks.
user-invocable: true
---

Read the README.md file within this skill, and explore the other available files.

If creating visual artifacts (slides, mocks, throwaway prototypes, etc), copy assets out and create static HTML files for the user to view. Pull tokens from `colors_and_type.css` (CSS variables for colors, type, spacing, radii, shadows). For high-fidelity recreations, look at the components in `ui_kits/taskmaestro/`.

If working on production code, copy assets and read the rules in `README.md` to become an expert designing with this system.

Key things to remember:

- **Two color anchors only**: brand blue `#2C74C5` for surfaces and the brand mark, brand magenta `#D83AFF` reserved for primary action and completion states. Don't introduce new accent colors.
- **Dark only.** No light mode. Backgrounds derive from the brand blue + a darkness multiplier (`--bg-darkness`).
- **Date semantics are color-coded** with start (green), target (blue), urgent (amber), due (rose). Reuse these tones any time a date appears — chip, marker, row tint, calendar accent.
- **Type is system sans, weight 500–700.** Display 24px, body 13.5px, caps labels 11px with letter-spacing 0.5. Tabular numerics on any metadata row.
- **Iconography is inline SVG** at 1.5–2.4px stroke. Lucide is the closest CDN match if you need a pack.
- **Voice is direct, sentence-case, second-person.** Empty states are italicized factual statements ("No dates set"). No emoji, no exclamations.
- **Shadows are sparing.** Only the magenta CTA and selected timeline markers carry color-matched glows. Cards use an inset top highlight, not a drop shadow.

If the user invokes this skill without other guidance, ask them what they want to build, ask follow-up questions about audience and surface type, then act as an expert designer who outputs HTML artifacts or production code as appropriate.
