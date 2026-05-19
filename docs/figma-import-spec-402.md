# Glug & Poop Figma Import Spec (402 Width)

Last updated: 2026-05-14

This spec is derived from the current SwiftUI implementation in `GlugPoop/GlugPoop/ContentView.swift`.

## Delivery Scope

- Target canvas width: `402`
- Recommended mobile frame height for static mockups:
  - Main pages: `402 x 874`
  - Bottom sheets:
    - Water: `402 x 600`
    - Drink: `402 x 620`
    - Food: `402 x 720`
    - Poop: `402 x 760`
- Target pages in Figma:
  - `01 Foundations`
  - `02 Components`
  - `03 Home`
  - `04 Input Sheets`
  - `05 Dashboard`
  - `06 Calendar`

## Foundations

### Color Tokens

- `App/Black`: `#1C1C1E`
- `App/LightGray`: `#F2F2F7`
- `App/White`: `#FFFFFF`
- `Type/Water`: `#007AFF`
- `Type/Drink`: `#AF52DE`
- `Type/Food`: `#FF2D55`
- `Type/Poop`: `#FFCC00`
- `Vibe/Level1`: `#FF2D55` at `80%`
- `Vibe/Level2`: `#FFCC00` at `80%`
- `Vibe/Level3`: `#AF52DE` at `60%`
- `Vibe/Level4`: `#34C759` at `80%`
- `Vibe/Level5`: `#007AFF` at `80%`

### Typography

- Hero title: `34 / Black / Rounded`
- Sheet title: `26 / Black / Rounded`
- Page section title: `20 / Bold / Rounded`
- Primary value: `28 / Black / Rounded`
- Primary button: `17 / Bold`
- Card title: `17 / Bold`
- Small label: `11-13 / Bold`
- Supporting text: `12-17 / Medium or Semibold`

### Radius

- Hero/action cards: `32`
- Bottom sheet shell: `28`
- Water panel: `24`
- Large record cards: `28`
- Medium cards: `18`
- Small controls: `12-16`
- Pill buttons: `100`

### Shadow

- Floating AI card: black `8%`, blur `20`, y `10`
- Standard card shadow: black `5%`, blur `10`, y `10`

## Layout Rules For 402 Width

- Outer page horizontal padding: `24`
- Home/content usable width: `354`
- Two-column card grid gap: `20`
- Two-column card width: `167`
- Bottom dual-button gap: `15`
- Bottom dual-button width: `169.5`
- Sheet internal vertical spacing: `16`
- Sheet quick-grid gap: `10`
- Calendar side padding: `16`
- Calendar records panel side padding: `24`

## Home

Frame:

- `402 x 874`

Structure:

- White background
- Light gray grid pattern background
- Hero block top padding: `50`
- Hero block text gap: `5`
- Main section vertical gap: `30`
- Four quick-entry cards in a `2 x 2` grid
- Bottom action row with `Dashboard` and `Calendar`
- Bottom padding: `40`

Exact card sizing:

- Grid width: `354`
- Each quick-entry card: `167 x 167`
- Card padding: `20`
- Top-right emoji size: `40`
- Bottom title: `20 / Bold / Rounded`

Card labels:

- `WATER`
- `DRINKS`
- `FOOD`
- `POOP`

Bottom actions:

- Height: about `56`
- `Dashboard`: black fill, white text
- `Calendar`: light gray fill, black text

## Shared Bottom Sheet Shell

Frame:

- Width `402`
- Height follows per-sheet values from code

Structure:

- White background
- Top title padding: `40`
- Main stack gap: `16`
- Submit button height: `56`
- Camera button size: `50 x 50`
- Note field height: `50`
- Thumbnail size: `54 x 54`
- Thumbnail radius: `13`

Meta panel:

- Outer light gray container
- Internal field radius: `16`
- Internal horizontal padding: `14`
- Internal vertical padding: `12`

Primary CTA:

- Text: `LOG IT` or `UPDATE IT`
- Black fill
- White text
- Radius: `100`

## Water Log Sheet

Frame:

- `402 x 600`

Title:

- `HYDRATE!`

Quick amount row:

- Five pills: `100ml`, `300ml`, `500ml`, `750ml`, `1000ml`
- Pill height: `38`
- Gap: `10`
- Selected fill: water blue
- Unselected fill: light gray

Water wave panel:

- Height: `168`
- Radius: `24`
- Horizontal padding: `18`
- Top padding: `18`
- Bottom padding: `14`
- Inner top label row:
  - left `0ml`
  - right `1500ml`
- Main center value: `28 / Black / Rounded`
- Center indicator line:
  - width `3`
  - height `68`
- Wave bars align to bottom and fade toward edges
- Background is a subtle blue left-to-right gradient using water blue at low opacity

## Drink Log Sheet

Frame:

- `402 x 620`

Title:

- `CHOOSE POISON`

Option grid:

- Two columns
- Gap: `10`
- Cell height: `50`
- Radius: `16`
- Emoji at left, label text `15 / Bold`
- Selected fill: drink purple
- Unselected fill: light gray

Options:

- `Coffee`
- `Boba`
- `Soda`
- `Matcha`
- `Wine`
- `Beer`

## Food Log Sheet

Frame:

- `402 x 720`

Title:

- `FEED ME`

Option grid:

- Two columns
- Gap: `10`
- Cell height: `46`
- Radius: `100`
- Label text `15 / Bold`
- Selected fill: food pink
- Unselected fill: light gray

Options:

- `Burger🍔`
- `Salad🥗`
- `Pizza🍕`
- `Sushi🍣`
- `Tacos🌮`
- `Ramen🍜`
- `Meat🥩`
- `Sweet🍩`

Extra field:

- Duration block appears in the meta panel

## Poop Log Sheet

Frame:

- `402 x 760`

Title:

- `CAPTAIN'S LOG`

Shape selector:

- Four columns
- Gap: `10`
- Square cells
- Radius: `16`
- Selected fill: poop yellow
- Unselected fill: light gray
- Asset padding inside tile: `8`

Color selector:

- Label: `COLOR`
- Grid: `4 x 2`
- Gap: `10`
- Cell height: `52`
- Radius: `14`
- Swatch circle: `26 x 26`
- Selected state:
  - light yellow background using poop theme at `24%`
  - `2px` poop yellow stroke

Poop assets:

- `poop_1.png`
- `poop_2.png`
- `poop_3.png`
- `poop_4.png`
- `poop_5.png`
- `poop_6.png`
- `poop_7.png`
- `poop_8.png`

Asset source:

- `GlugPoop/GlugPoop/BristolStoolScale`

## Dashboard

Frame:

- `402 x 874`

Structure:

- White background
- Top bar horizontal padding: `24`
- Back button:
  - circular
  - icon size about `20`
  - padding `14`
  - fill light gray
- Title block:
  - `TODAY!`
  - subtitle `今天过得像个人样吗？`
- Section title:
  - `TODAY'S LOGS`
- Record list bottom safe area allowance: about `150`
- Floating AI card bottom padding: `40`

Large record card:

- Radius: `28`
- Internal padding: `16`
- Header row:
  - left icon in white `30%` chip
  - title `17 / Bold`
  - time `12 / Medium`
- Standard detail pill:
  - white background
  - horizontal padding `15`
  - vertical padding `8`
- Poop detail pill:
  - white background
  - image `46 x 32`
  - color dot `14 x 14`
- Optional image:
  - full width
  - height `150`
  - radius `16`

## Calendar

Frame:

- `402 x 874`

Top area:

- Horizontal padding: `24`
- Top padding: `10`
- Back button matches Dashboard
- Month switcher center width: `120`
- Chevron group gap: `20`
- Month title: `20 / Black / Rounded`

Weekday row:

- Horizontal padding: `16`
- Label text: `12 / Bold`

Month grid:

- Seven columns
- Gap: `10`
- Horizontal padding: `16`
- Day cell:
  - square
  - radius `12`
  - selected fill black
  - vibe day fill uses vibe colors
  - empty fill light gray
  - text `17 / Bold / Rounded`

## Calendar Records Panel

Header:

- Horizontal padding: `24`
- Title `RECORDS`
- Date text: `18 / Black / Rounded`
- Count badge:
  - `34 x 34`
  - black fill
  - white text
  - circle

Add button row:

- Horizontal padding: `24`
- Gap: `10`
- Button height: `46`
- Radius: `14`
- Fill uses each type color at reduced opacity

Daily cards zone:

- Two columns
- Gap: `14`
- Horizontal padding: `24`
- Bottom padding: `30`

## Calendar Record Card

- Responsive two-column card
- Radius: `18`
- Minimum visual height: about `118`
- Background uses record type tint
- Time pinned top-right
- Icon pinned top-left
- Optional note under detail
- Optional image thumbnail at lower area

## Suggested Component Set In Figma

- `Quick Entry Card`
- `Primary Pill Button`
- `Secondary Pill Button`
- `Meta Panel`
- `Date Time Field`
- `Image Thumbnail`
- `Drink Option Pill`
- `Food Option Pill`
- `Poop Shape Tile`
- `Poop Color Tile`
- `Dashboard Log Card`
- `Calendar Day Cell`
- `Calendar Add Action`
- `Calendar Record Card`

## Import Workflow

1. Create `01 Foundations` and add color, text, radius, and shadow tokens above.
2. Create `02 Components` and build reusable mobile components from the shared sheet shell and card patterns.
3. Build `03 Home` first at `402 x 874`.
4. Build the four sheets in `04 Input Sheets` using the exact heights from code.
5. Build `05 Dashboard` and reuse the large log card component.
6. Build `06 Calendar`, then nest the records panel and card variants.

## Current Constraint

This workspace currently has no connected Figma MCP server, so the frames cannot be written directly into the target Figma file from this session.

Once Figma MCP is connected, this spec is ready to be applied frame-by-frame into:

- `https://www.figma.com/design/g9DbEKBWbtinQgMPtJtDkv/Untitled?node-id=0-1&t=XOSzcK45uL1Zt3l3-1`
