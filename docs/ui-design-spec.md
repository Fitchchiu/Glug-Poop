# Glug & Poop UI Design Spec

Last updated: 2026-05-13

This document summarizes the current in-app UI so it can be rebuilt cleanly in Figma.

## 1. Page Map

Use these names in Figma to match the current product structure:

1. `Home`
2. `Water Log Sheet`
3. `Drink Log Sheet`
4. `Food Log Sheet`
5. `Poop Log Sheet`
6. `Dashboard`
7. `Calendar`
8. `Calendar Records Panel`
9. `Calendar Record Card`

Optional legacy page:

1. `Daily Detail Sheet`

## 2. Design Direction

- Overall style: playful iOS utility app with rounded cards and bold typography
- Base background: white with faint gray grid pattern on the home page
- Core interaction model: bottom sheets for data entry, full-page navigation for dashboard and calendar
- Visual language: large rounded corners, high-contrast pill buttons, soft shadows, color-coded activity types

## 3. Color Tokens

### Foundation

- `App/Black`: `#1C1C1E`
- `App/LightGray`: `#F2F2F7`
- `App/White`: `#FFFFFF`

### Record Type Colors

- `Type/Water`: `#007AFF`
- `Type/Drink`: `#AF52DE`
- `Type/Food`: `#FF2D55`
- `Type/Poop`: `#FFCC00`

### Vibe Colors

- `Vibe/Level1`: `#FF2D55` at 80% opacity
- `Vibe/Level2`: `#FFCC00` at 80% opacity
- `Vibe/Level3`: `#AF52DE` at 60% opacity
- `Vibe/Level4`: `#34C759` at 80% opacity
- `Vibe/Level5`: `#007AFF` at 80% opacity

### Poop Color Options

- `Poop/LightTan`: `#E4D7B4`
- `Poop/Yellow`: `#FFCC33`
- `Poop/Tan`: `#CFA766`
- `Poop/Coffee`: `#7B4308`
- `Poop/DarkBrown`: `#5A3217`
- `Poop/Green`: `#005A21`
- `Poop/Black`: `#000000`
- `Poop/Red`: `#C70000`

## 4. Typography

System font is used throughout with rounded design in headline-heavy areas.

### Headlines

- App hero title: `34 / Black / Rounded`
- Sheet title: `26 / Black / Rounded`
- Dashboard date/title blocks: `34 / Black / Rounded`
- Main numeric emphasis: `28-30 / Black / Rounded`

### Section Labels

- Section label: `13 / Bold`
- Small field title: `11 / Bold`
- Weekday label: `12 / Bold`

### Body

- Standard button text: `17 / Bold`
- Card titles: `17 / Bold`
- Supporting text: `12-14 / Medium or Semibold`

## 5. Spacing and Shape Rules

### Global

- Major page horizontal padding: `24`
- Large vertical section spacing: `20-30`
- Sheet internal stack spacing: `16`

### Radius

- Primary cards: `32`
- Input sheets: `28`
- Medium cards: `22-24`
- Small controls: `12-18`
- Pill buttons: `100`

### Shadows

- Card shadow: black at 5% opacity, blur about `10`, y-offset about `10`
- Floating panel shadow: black at 8% opacity, blur about `20`, y-offset about `10`

## 6. Component Library

### A. Home Quick Entry Card

- Shape: square card, 1:1 ratio
- Radius: `32`
- Padding: `20`
- Content:
  - top-right large emoji icon
  - bottom-left category title
- Colors:
  - water blue
  - drink purple
  - food pink
  - poop yellow with dark text

### B. Primary Pill Button

- Height: about `56`
- Radius: full pill
- Fill: black or light gray depending on hierarchy
- Text: `17 / Bold`

### C. Meta Panel

- Outer container: light gray card
- Inner fields: white rounded rectangles
- Contains:
  - date picker
  - time picker
  - optional duration stepper block

### D. Inline Image Thumbnail

- Photo preview size: `46-54`
- Radius: `12-13`
- White stroke when used in record cards

### E. Calendar Day Cell

- Shape: rounded square
- Radius: `12`
- States:
  - empty: light gray
  - selected: black
  - active mood day: vibe color

## 7. Per-Page Specs

## 7.1 Home

Purpose:
- Main launcher page for four record flows plus dashboard and calendar

Structure:
- White grid background
- Top hero block
- 2x2 quick-entry card grid
- Bottom row with `Dashboard` and `Calendar`

Layout:
- Top padding around `50`
- Grid columns: `2`
- Grid gap: `20`
- Bottom action row gap: `15`

Figma frame suggestion:
- `393 x 852`

## 7.2 Water Log Sheet

Purpose:
- Log water amount with a custom swipe-based wave picker

Structure:
- Sheet title `HYDRATE!`
- Quick amount pills: `100 / 300 / 500 / 750 / 1000 ml`
- Blue wave amount panel
- Time panel
- Note + camera row
- Submit pill button

Water panel behavior:
- Value range: `0-1500 ml`
- Horizontal drag interaction
- Center value emphasized
- Left and right bars fade toward edges
- End labels `0ml` and `1500ml` inside the blue panel

Water panel look:
- Height around `168`
- Large top radius around `24`
- Soft blue gradient background
- Vertical wave bars anchored to bottom edge

## 7.3 Drink Log Sheet

Purpose:
- Select one beverage type and save with time and optional note/photo

Structure:
- Sheet title `CHOOSE POISON`
- 2-column grid of drink options
- Time panel
- Note + camera row
- Submit button

Drink options:
- Coffee
- Boba
- Soda
- Matcha
- Wine
- Beer

Selection style:
- Selected pill uses drink purple
- Unselected pill uses light gray

## 7.4 Food Log Sheet

Purpose:
- Select a food type and log eating duration

Structure:
- Sheet title `FEED ME`
- 2-column grid of food options
- Time and Duration panel
- Note + camera row
- Submit button

Food options:
- Burger
- Salad
- Pizza
- Sushi
- Tacos
- Ramen
- Meat
- Sweet

Selection style:
- Selected pill uses food pink
- Unselected pill uses light gray

## 7.5 Poop Log Sheet

Purpose:
- Log stool shape and stool color with optional duration and note

Structure:
- Sheet title `CAPTAIN'S LOG`
- Shape selector grid, 4 columns
- Color selector grid, 4 columns x 2 rows
- Time and Duration panel
- Note row
- Submit button

Shape options:
- `poop_1` to `poop_8`

Color options:
- 8 color swatches, two rows

Selection style:
- Selected state uses poop theme color, not black

## 7.6 Dashboard

Purpose:
- Browse today's records as large colored cards

Structure:
- Back button
- Title block: `TODAY!`
- Section title: `TODAY'S LOGS`
- Vertical list of large record cards
- Floating AI message card at bottom

Card behavior:
- Tap card opens edit sheet

Card content:
- top-left type icon
- title and time
- right-side detail pill or poop asset + color dot
- optional duration
- optional image
- optional note

## 7.7 Calendar

Purpose:
- Monthly overview plus inline day records below the calendar

Structure:
- Top bar with back button and month switcher
- Weekday row
- 7-column month grid
- Below-grid records panel

Month grid behavior:
- Selecting a day only updates the lower records panel
- No extra pop-up card required for day switch

## 7.8 Calendar Records Panel

Purpose:
- Inline record area under the month grid

Structure:
- Header:
  - `RECORDS`
  - full date
  - record count badge
- Row of 4 add buttons using log type icons
- Swipeable daily content area

Behavior:
- Horizontal swipe changes date page
- Vertical scroll inside current day record list

## 7.9 Calendar Record Card

Purpose:
- Compact card for a single record inside the calendar day panel

Structure:
- top-left icon
- top-right time
- main detail block or poop image + color dot
- optional duration
- optional note
- optional photo thumbnail at bottom-right

Visual style:
- 2-column responsive grid
- min height around `118`
- tinted background based on record type at reduced opacity
- rounded rectangle radius `18`

## 8. Asset List

Poop shape images currently used from:

- `GlugPoop/GlugPoop/BristolStoolScale/poop_1.png`
- `GlugPoop/GlugPoop/BristolStoolScale/poop_2.png`
- `GlugPoop/GlugPoop/BristolStoolScale/poop_3.png`
- `GlugPoop/GlugPoop/BristolStoolScale/poop_4.png`
- `GlugPoop/GlugPoop/BristolStoolScale/poop_5.png`
- `GlugPoop/GlugPoop/BristolStoolScale/poop_6.png`
- `GlugPoop/GlugPoop/BristolStoolScale/poop_7.png`
- `GlugPoop/GlugPoop/BristolStoolScale/poop_8.png`

## 9. Recommended Figma Setup

Pages:

1. `01 Foundations`
2. `02 Components`
3. `03 Home`
4. `04 Input Sheets`
5. `05 Dashboard`
6. `06 Calendar`

Suggested component groups:

1. Buttons
2. Cards
3. Input fields
4. Calendar cells
5. Log chips
6. Poop assets
7. Water wave panel

Suggested variables:

1. Color tokens
2. Corner radius tokens
3. Spacing tokens
4. Text style tokens

## 10. Export Status

Current limitation:

- I can map and document every page from code.
- I cannot reliably auto-export true page screenshots on this machine right now because the local iOS Simulator runtime is unavailable.

Fastest workaround:

1. Open each page in the simulator on your side
2. Take screenshots
3. Import them into Figma as tracing references
4. Use this document as the rebuild spec
