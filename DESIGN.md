---
name: Landholders Law
description: Architectural warmth for public counsel and precise transaction operations.
colors:
  ink: "#191815"
  charcoal: "#20201d"
  limestone: "#ded5c6"
  paper: "#f7f3eb"
  old-gold: "#d0a84f"
  old-gold-deep: "#6f501b"
  warm-white: "#fffdf8"
  public-error: "#7a1f1a"
  public-success: "#275436"
  operations-ink: "#1a1916"
  operations-charcoal: "#23231f"
  operations-charcoal-deep: "#171714"
  operations-paper: "#f8f5ef"
  operations-gold: "#c5a052"
  operations-gold-deep: "#73561f"
  operations-line: "#d4cdc1"
  operations-muted: "#625f58"
  critical: "#982f27"
  critical-soft: "#faece9"
  warning: "#855b13"
  warning-soft: "#fbf0d4"
  success: "#315e42"
  success-soft: "#e5f1e9"
  info: "#315c72"
  info-soft: "#e5eef2"
typography:
  public-display:
    fontFamily: '"Palatino Linotype", "Book Antiqua", Palatino, Georgia, serif'
    fontSize: "clamp(3.15rem, 7.2vw, 6rem)"
    fontWeight: 400
    lineHeight: 0.96
    letterSpacing: "-0.035em"
  working-title:
    fontFamily: '"Segoe UI", Tahoma, Geneva, Verdana, sans-serif'
    fontSize: "2rem"
    fontWeight: 700
    lineHeight: 1.16
    letterSpacing: "-0.025em"
  body:
    fontFamily: '"Segoe UI", Tahoma, Geneva, Verdana, sans-serif'
    fontSize: "1rem"
    fontWeight: 400
    lineHeight: 1.5
  operations-body:
    fontFamily: '"Segoe UI", Tahoma, Geneva, Verdana, sans-serif'
    fontSize: "15px"
    fontWeight: 400
    lineHeight: 1.5
  label:
    fontFamily: '"Segoe UI", Tahoma, Geneva, Verdana, sans-serif'
    fontSize: "0.72rem"
    fontWeight: 750
    lineHeight: 1.5
    letterSpacing: "0.035em"
rounded:
  square: "0"
  status-dot: "50%"
  count-pill: "999px"
spacing:
  xs: "0.5rem"
  sm: "0.75rem"
  md: "1rem"
  lg: "1.5rem"
  xl: "2rem"
  section: "3rem"
components:
  public-button-primary:
    backgroundColor: "{colors.ink}"
    textColor: "{colors.paper}"
    typography: "{typography.body}"
    rounded: "{rounded.square}"
    padding: "0.75rem 1.1rem"
    height: "3rem"
  public-button-secondary:
    backgroundColor: "transparent"
    textColor: "{colors.ink}"
    typography: "{typography.body}"
    rounded: "{rounded.square}"
    padding: "0.75rem 1.1rem"
    height: "3rem"
  operations-button-primary:
    backgroundColor: "{colors.operations-ink}"
    textColor: "{colors.warm-white}"
    typography: "{typography.operations-body}"
    rounded: "{rounded.square}"
    padding: "0.65rem 0.9rem"
    height: "2.8rem"
  field:
    backgroundColor: "{colors.warm-white}"
    textColor: "{colors.ink}"
    typography: "{typography.body}"
    rounded: "{rounded.square}"
    padding: "0.75rem 0.85rem"
    height: "3.25rem"
  operations-panel:
    backgroundColor: "{colors.warm-white}"
    textColor: "{colors.operations-ink}"
    typography: "{typography.operations-body}"
    rounded: "{rounded.square}"
    padding: "0"
---

# Design System: Landholders Law

## Overview

**Creative North Star: "Chicago Threshold"**

Landholders Law feels like crossing a carefully made architectural threshold: charcoal structure, limestone mass, warm paper, and restrained old gold establish a personal but authoritative place for consequential property decisions. The public experience is spacious and persuasive, using long ruled planes, large Palatino-family statements, and direct calls to action instead of generic corporate-law polish.

The internal operations interface is a precise working extension of that architecture. It keeps the same materials, square geometry, and gold restraint while shifting all working text to a familiar system sans, increasing density, and making status, ownership, and controlling dates immediately scannable. It is calmer than the public site, not visually separate from it.

The system avoids anonymous courthouse imagery, interchangeable navy-and-gold law-firm styling, rounded dashboard chrome, and decorative effects that compete with the work.

**Key Characteristics:**

- Architectural charcoal, limestone, warm paper, and old gold.
- Square controls, flat ruled panels, and precise one-pixel divisions.
- Palatino-family display type for public persuasion and the brand name only.
- System sans for body copy and every piece of operations working text.
- Semantic status colors reinforced by text, icons, or both.
- Responsive layouts that preserve task order and reading hierarchy.

## Colors

The palette is warm, mineral, and highly controlled: neutrals build the architecture, gold marks emphasis, and semantic colors are reserved for state.

### Primary

- **Architectural Charcoal** (`charcoal`, `operations-charcoal`): public bands, the operations rail, table headers, and the strongest structural contrast.
- **Old Gold** (`old-gold`, `operations-gold`): focus visibility, icons, active navigation details, and scarce moments of emphasis.
- **Deep Old Gold** (`old-gold-deep`, `operations-gold-deep`): links, selected rules, field focus, and primary-button hover states on light surfaces.

### Secondary

- **Limestone** (`limestone`): warm public-section mass and a bridge between dark charcoal and paper.

### Neutral

- **Near-Black Ink** (`ink`, `operations-ink`): primary text, button fills, and decisive rules.
- **Warm Paper** (`paper`, `operations-paper`): page fields and quiet hover fills.
- **Warm White** (`warm-white`): form controls, panels, drawers, and elevated working surfaces.
- **Mortar Line** (`operations-line`): operations borders, dividers, and chronological connectors.
- **Working Gray** (`operations-muted`): metadata and supporting text that remains readable but subordinate.

### Semantic

- **Critical Brick** (`critical`, `critical-soft`): overdue deadlines, blockers, and urgent attention. The soft tone is a contained background, never the only signal.
- **Warning Ochre** (`warning`, `warning-soft`): due-today, pending, active-phase, and approval states.
- **Resolved Green** (`success`, `success-soft`): completed, active, scheduled, and ready states.
- **Informational Blue** (`info`, `info-soft`): normal-priority and informational states.
- **Public Feedback** (`public-error`, `public-success`): consultation-form error and success messaging.

### Named Rules

**The Rare Gold Rule.** Gold identifies focus, active state, and important action; it does not become a broad decorative wash.

**The Redundancy Rule.** A semantic color never communicates status alone. Pair it with explicit text, a symbol, or both.

## Typography

**Display Font:** Palatino Linotype, with Book Antiqua, Palatino, Georgia, and serif fallbacks  
**Body Font:** Segoe UI, with Tahoma, Geneva, Verdana, and sans-serif fallbacks

**Character:** Public display type is humanist, established, and deliberately sparse. The system sans is direct and familiar; in Operate mode it carries every working title, label, value, table, and control so information stays quick to scan.

### Hierarchy

- **Public Display** (`public-display`): oversized public hero statements and major persuasive headings, with tight line height and tracking.
- **Working Title** (`working-title`): compact operations page titles, sentence case, and a controlled maximum measure.
- **Body** (`body`): public explanations, form copy, and general reading text.
- **Operations Body** (`operations-body`): the default working interface density, with tabular numerals where dates and counts need alignment.
- **Label** (`label`): compact state and metadata labels; uppercase is reserved for status language already implemented that way.

### Named Rules

**The Brand Reserve Rule.** In the operations interface, Palatino appears only in the Landholders Law brand name. All task content remains in the system sans.

**The Short Display Rule.** Use the display face for concise statements and names, not dense instructions, tables, filters, or status content.

## Layout

Public pages sit inside a centered shell with a maximum width of 96rem. Sections are assembled from bordered twelve-column grids that collapse to one column, retaining their dividing rules and generous padding. Public spacing ranges from compact 0.75rem control gaps to 3–6rem section fields, with responsive clamps where the viewport should carry the decision.

Operations uses a fixed 16.5rem charcoal rail beside a centered 96rem workspace and a sticky top bar. The main content uses compact ruled ledgers and asymmetric working grids: a dominant task or matter column with a narrower status column. At 1120px, major two-column work areas stack and secondary summaries may form two columns. At 960px, the fixed rail becomes an off-canvas menu with a scrim. At 760px and below, controls and summaries stack, tables become labeled record blocks, and metadata grids reduce to two columns. At 620px, the top bar and main padding tighten; at 500px, spine metadata and dense rows reflow without hiding primary information.

The chronological deadline spine is the signature of the transaction-operations prototype. Use it where controlling dates genuinely organize the task—attention queues, matter directories, and matter overviews. It is not a mandatory pattern for unrelated future surfaces.

### Named Rules

**The Ruled Architecture Rule.** Prefer grids, borders, and alignment to floating containers or ornamental whitespace.

**The Task Order Rule.** Responsive changes preserve urgency, ownership, and next action before secondary metadata.

## Elevation & Depth

The system is flat by default. Public depth comes from adjacent material fields and borders, while operations depth comes from tonal layering and precise rules. Shadows are reserved for transient overlays: search results use a downward ambient shadow and the detail drawer uses a lateral shadow against its scrim. Field focus uses an inset bottom rule rather than a glow.

### Shadow Vocabulary

- **Search Overlay** (`0 16px 32px rgba(26, 25, 22, 0.16)`): search-result surfaces that must sit above the sticky workspace.
- **Drawer Edge** (`-16px 0 40px rgba(23, 23, 20, 0.18)`): the right-side detail drawer only.
- **Field Focus Rule** (`inset 0 -2px 0` in operations; `inset 0 -3px 0` on the public form): reinforces focus within square fields.

### Named Rules

**The Flat-at-Rest Rule.** Ordinary sections, panels, cards, controls, and table rows do not cast shadows.

## Shapes

Square corners are the default and most important form rule. Buttons, inputs, panels, filters, tabs, date blocks, icon buttons, and drawers use zero radius with one-pixel borders. Circular geometry is limited to tiny status dots and the notification count pill, where the shape carries a compact state function rather than a friendly-card aesthetic. The brand mark and deadline markers are rectilinear, reinforcing the architectural language.

## Components

### Buttons

- **Shape:** square, compact, and bordered (`rounded.square`); public buttons have a 3rem minimum height and operations buttons a 2.8rem minimum height.
- **Primary:** near-black fill on warm light surfaces with bold sans text. Hover shifts to deep old gold without changing geometry.
- **Secondary:** transparent with an ink border; hover introduces warm paper or warm white.
- **Text:** deep old gold with a single underline whose offset increases on hover.
- **Focus:** a three-pixel old-gold outline with visible offset. Disabled states keep their label legible and use opacity plus cursor treatment.

### Inputs / Fields

- **Style:** warm-white fill, square corners, one-pixel neutral rule, and comfortably dense padding.
- **Focus:** border changes to deep old gold and gains an inset bottom rule; no rounded halo.
- **Error:** a clear error-colored border plus adjacent error copy. Public form status messages use ruled bands rather than toast styling.

### Navigation

- **Public:** charcoal header, Palatino brand name, compact sans links, and a gold telephone action. Links reveal an underline and gold color on hover.
- **Operations:** persistent charcoal rail with icon-and-label rows, a thin gold active border and fill, and explicit disabled labels. Below 960px it becomes an off-canvas menu controlled by a square menu button and scrim.

### Cards / Containers

- **Corner Style:** square (`rounded.square`).
- **Background:** warm white for working panels; paper, limestone, or charcoal for larger public fields.
- **Shadow Strategy:** none at rest.
- **Border:** one-pixel mortar or low-opacity ink/paper rules.
- **Internal Padding:** commonly 1–1.2rem in operations; public section padding is substantially more generous.

### Status Labels

Status labels use semantic text color with an adjacent dot or icon and a written state. Soft semantic fills belong to bounded symbols and date markers, not broad panel backgrounds. Counts and dates use tabular numerals where alignment helps comparison.

### Deadline Spine

The operations prototype connects chronological markers with a one-pixel mortar line. Each row presents severity and due language first, then the action title, matter context, owner, and next action. Critical and warning markers combine border, soft fill, icon, color, and explicit text. Compact variants retain the same logic in directory cells and matter summaries.

### Detail Drawer

The drawer is a right-side, warm-white modal surface with a dim charcoal scrim, a ruled header, a square close control, trapped focus, Escape dismissal, and focus return. Its 180ms entrance uses a short lateral translation and opacity change; reduced-motion preferences collapse that duration.

## Do's and Don'ts

### Do:

- **Do** preserve charcoal, limestone, warm paper, and restrained old gold as the shared public and internal material world.
- **Do** use Palatino-family type sparingly for public persuasion and the Landholders Law brand.
- **Do** keep all operations working text in the system sans and use tabular numerals for operational counts and dates.
- **Do** pair status color with explicit text, icons, or both.
- **Do** build hierarchy with square geometry, one-pixel rules, alignment, and tonal fields.
- **Do** transform dense tables into labeled record blocks on narrow screens when horizontal scanning would fail.
- **Do** respect visible focus, keyboard navigation, reduced motion, and WCAG 2.2 AA contrast.

### Don't:

- **Don't** introduce rounded cards, pill-shaped controls, broad drop shadows, gradients, or glass effects into the core system.
- **Don't** use Palatino for operations headings, filters, tables, task lists, or status language.
- **Don't** use gold as a large decorative background when charcoal, limestone, or paper can establish the field.
- **Don't** rely on red, ochre, green, or blue alone to communicate state.
- **Don't** force the deadline spine onto surfaces that are not meaningfully organized by controlling dates.
- **Don't** drift toward anonymous courthouse imagery or interchangeable navy-and-gold law-firm styling.
