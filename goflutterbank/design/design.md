# Lumo — Design Document (Flutter Frontend)

> **Lumo · Your digital bank**
> Mobile banking app prototype — 7 screens.
> This document is the single source of truth for the **Flutter frontend** implementation (UI only, no backend). Every measurement, color, type style and behavior was extracted from the reference screens and must be reproduced faithfully.

---

## 1. Overview

Lumo is a digital banking app with a **clean, modern, rounded** aesthetic: light background, floating white cards, and a vibrant **magenta/pink brand color** used in CTAs and highlights. The tone is friendly and direct ("Your digital bank", "Takes less than 2 minutes").

### 1.1 Screens (flow)

| # | Screen | Suggested route | Type |
|---|--------|-----------------|------|
| 01 | Login | `/login` | Auth |
| 02 | Sign up | `/signup` | Auth |
| 03 | Home | `/home` | Main navigation (tab) |
| 04 | Transfer | `/transfer` | Tab |
| 05 | Charges | `/charges` | Tab |
| 06 | New charge | `/charges/new` | Push |
| 07 | Loan | `/loan` | Tab |

> **Prototype note:** the app is *frontend only*. There are no network calls. Buttons should navigate/animate and show simulated success states ("Tap the buttons to navigate and see the success confirmations"). Data is *mocked* (hardcoded).

### 1.2 Target platform
- **Flutter** (Material 3 as a base, heavily customized).
- **Mobile-first**, phone layout (reference: iPhone with notch/Dynamic Island, status bar `9:41`).
- **Portrait** orientation only.
- Safe area support (top and bottom home indicator).

---

## 2. Design System

### 2.1 Color palette

#### Brand / Primary
| Token | Hex | Usage |
|-------|-----|-------|
| `primary` | **`#EC0B5A`** | Brand color. Primary buttons, logo, active icons, highlight links, balance card gradient. |
| `primaryDark` | `#C50A4D` | End of the balance card gradient / pressed state. |
| `primaryLight` | `#FCE4EC` | Selected side-menu item background, highlight chips/avatars, action icon backgrounds. |
| `primarySoft` | `#FDECEF` | Info banner background (New charge screen). |
| `onPrimary` | `#FFFFFF` | Text/icons on primary. |

> The real color in the images is a **vibrant magenta-pink**. Use `#EC0B5A` as the canonical value. The balance card gradient runs from `#EC0B5A` (top-left) to `#C50A4D` (bottom-right), roughly 135°.

#### Neutrals
| Token | Hex | Usage |
|-------|-----|-------|
| `background` | `#EDEFF2` | App background (very light bluish gray). |
| `surface` | `#FFFFFF` | Cards, fields, sheets, app bar. |
| `surfaceAlt` | `#F4F5F7` | Filled input background (Amount, CPF in some fields), soft dividers. |
| `border` | `#E6E8EC` | Input and card border (1px). |
| `textPrimary` | `#16181D` | Titles and values (near black). |
| `textSecondary` | `#6B7280` | Subtitles, labels, descriptions. |
| `textTertiary` | `#9CA3AF` | Placeholders, metadata, disabled text. |
| `iconMuted` | `#9CA3AF` | Inactive bottom-bar icons and icons inside inputs. |

#### Semantic
| Token | Hex | Usage |
|-------|-----|-------|
| `success` | `#16A34A` | "Approve" button, received amounts (`+ R$ 45.90`), "Approved" badge. |
| `successBg` | `#DCFCE7` | "Approved" badge background. |
| `warning` | `#B45309` (text) / `#FEF3C7` (bg) | "Pending" badge. |
| `danger` | `#DC2626` | Reserved for validation errors (not shown in screens, but standardize). |
| `incomeGreen` | `#16A34A` | Received-Pix avatar/icon (background `#D1FAE5`). |

#### Avatar helper colors
- Initials avatars use `#F1F2F4` background with `textSecondary` text, **except** in a highlight context (Transfer → contacts) where they use `primaryLight` background with `primary` text.

### 2.2 Typography

Font: **Inter** (or similar geometric grotesque). Fallback: system. Headings use a strong weight and slightly *tight letter-spacing*.

| Style | Size | Weight | Color | Usage |
|-------|------|--------|-------|-------|
| `displayLarge` | 40 sp | 700 | textPrimary | Loan value "R$ 5,000", large balance. |
| `headlineLarge` | 34 sp | 700 | textPrimary | Balance "R$ 1,250.00". |
| `titleScreen` | 26 sp | 700 | textPrimary | Screen titles ("Create your account", "Transfer", "Charges", "New charge", "Loan"). |
| `titleBrand` | 24 sp | 700 | textPrimary | "Lumo" under the logo. |
| `titleM` | 17 sp | 700 | textPrimary | Names in lists (Bruno Carvalho), "Transfer sent". |
| `body` | 15 sp | 400 | textPrimary | Filled field text. |
| `label` | 14 sp | 600 | textSecondary | Form labels ("Email", "Password", "Amount"). |
| `caption` | 13 sp | 400 | textSecondary | Subtitles, metadata ("Today · 09:12"). |
| `overline` | 12 sp | 700 | textSecondary | Caps sections ("RECENT ACTIVITY", "SEND TO"), `letter-spacing: 0.8`, UPPERCASE. |
| `button` | 16 sp | 700 | onPrimary | Button text. |
| `link` | 14 sp | 600 | primary | "Forgot password", "See all", "Sign in". |

> Currency values: use `intl` with `en_US` locale → `R$ 1,250.00` (thousands separator `,`, decimal `.`). Keep `R$` as the currency symbol for the Brazilian-bank theme.

### 2.3 Spacing and grid

- 4px base scale: `4, 8, 12, 16, 20, 24, 32`.
- **Screen horizontal padding:** `24px` (content gutter).
- Vertical spacing between form blocks: `20px`.
- Label → input gap: `8px`.

### 2.4 Radii (border radius)

| Token | Value | Usage |
|-------|-------|-------|
| `radiusInput` | 14 | Text fields. |
| `radiusCard` | 20 | Cards (balance, lists, form blocks). |
| `radiusButton` | 16 | Large buttons / CTA pills. |
| `radiusChip` | 12 | Value chips (loan), tabs. |
| `radiusBadge` | 8 | Status badges. |
| `radiusLogo` | 18 | Logo square. |
| `radiusFull` | 999 | Avatars, "New" button, notification FAB. |

### 2.5 Shadows / Elevation

```dart
// Default card (white on light background)
shadowCard: BoxShadow(
  color: Color(0x0F16181D), // ~6% black
  blurRadius: 24,
  offset: Offset(0, 8),
)

// Primary button (subtle pink glow)
shadowPrimary: BoxShadow(
  color: Color(0x33EC0B5A), // ~20% primary
  blurRadius: 24,
  offset: Offset(0, 10),
)

// Balance card (gradient) — stronger pink shadow
shadowBalance: BoxShadow(
  color: Color(0x40EC0B5A),
  blurRadius: 30,
  offset: Offset(0, 14),
)
```

Inputs have a 1px `border`, **no** shadow. Cards have a soft diffuse shadow.

### 2.6 Iconography

**Outline, thin stroke (~1.8px), rounded corners** set (Lucide / Feather style). Default size `20–24px`.

Icons used:
- `mail` (envelope) — email field
- `lock` — password field
- `eye` — password toggle
- `user` — full name
- `id-card` / `credit-card` — CPF (tax ID)
- `arrow-left` — back
- `bell` — notifications (with red dot)
- `eye` — hide balance
- `send` / `navigation` (paper plane) — Transfer
- `hand-coins` — Charge / charge banner
- `landmark` (columned building) — Loan
- `arrow-up-right` — transfer sent
- `arrow-down-left` — Pix received
- `message-square` / `receipt` — bill payment / Charges (tab)
- `home` — Home
- `shield` / `shield-check` — security ("Protected with end-to-end encryption")
- `chevron-right` (▶) — active item indicator in the side menu

---

## 3. Reusable Components

### 3.1 `PrimaryButton`
- Height: `56px`, full width (`double.infinity`).
- Background: `primary`, text `onPrimary` 16/700, centered.
- Radius: `radiusButton (16)`. Shadow: `shadowPrimary`.
- States: pressed → `primaryDark`, scale 0.98; disabled → `primary` 40% opacity, no shadow.
- **success** variant (`Approve`): `success` background, no pink glow (light neutral shadow).

### 3.2 `SecondaryButton` / `OutlineButton`
- Same `56px` height. `surface` background, 1px `border`, text `textPrimary` 16/700.
- Used in "Create account" (Login) and "Decline" (Charges).

### 3.3 `AppTextField`
- Height `56px`, `surface` background, 1px `border`, radius `14`, horizontal padding `16`.
- Leading icon `iconMuted` (20px) + `12` gap.
- Placeholder `textTertiary 15/400`.
- Optional trailing (e.g. `eye` in the password field).
- Focus: `primary` 1.5px border (background unchanged).
- **filled** variant (highlighted Amount / CPF in Transfer and New charge): `surfaceAlt` background, same border.

### 3.4 `AmountField`
- Large value field: `R$` prefix in `textTertiary 20/700` + value `0.00` in `textPrimary 22/700`.
- `surfaceAlt` background, radius 14, height ~64px.
- Currency mask while typing (en_US).

### 3.5 `FormCard`
- White container with `radiusCard (20)`, padding `20`, `shadowCard`.
- Groups related fields (e.g. the "CPF + Amount" block in Transfer and New charge).

### 3.6 `ActionTile` (Home shortcuts)
- Square white card, radius `20`, `shadowCard`, padding `16`.
- Top: `48px` circle with `primaryLight` background and `primary` icon (22px).
- Bottom: label `13/600 textPrimary`, centered.
- 3 per row, `12` gap.

### 3.7 `TransactionRow` (activity)
- Row: circular `40px` avatar (directional icon) + texts (title 15/700 + subtitle 12/400) + value on the right.
- Value: neutral for outgoing (`- R$ 120.00` in textPrimary), green for incoming (`+ R$ 45.90` in success).
- Avatar icons:
  - Sent: `arrow-up-right`, background `#F1F2F4`.
  - Received: `arrow-down-left`, background `#D1FAE5`, green icon.
  - Payment: `message-square`/`receipt`, background `#F1F2F4`.
- 1px `border` divider between rows (inside a single white card).

### 3.8 `StatusBadge`
- Pill `radiusBadge (8)`, padding `4×8`, text `12/700`.
- `Pending`: `#FEF3C7` background, `#B45309` text.
- `Approved`: `successBg` background, `success` text.

### 3.9 `Avatar`
- Circle `radiusFull`. Centered initials `14/700`.
- Default: `#F1F2F4` background, `textSecondary` text.
- Highlight: `primaryLight` background, `primary` text.
- Sizes: `40` (rows/home header), `56` (Transfer contacts).

### 3.10 `BottomNavBar`
- Height `64px` + safe area. `surface` background, 1px top `border`.
- 4 items: **Home**, **Transfer**, **Charges**, **Loan**.
- 24px icon + 11/600 label. Active: `primary` (filled icon + label). Inactive: `iconMuted`.
- Selection indicator: color only (no background pill).

### 3.11 `ScreenAppBar`
- Inner screens (push): circular `back` button (40px, `#F1F2F4` background, `arrow-left` icon) + `titleScreen` to the right of the button.
- Home: greeting row (avatar + "Welcome back / Hi, Marina") + notification bell on the right.

### 3.12 `StatusBar` (mock)
- Reproduce the `9:41` bar on the left + signal/wifi/battery icons on the right. (In a real build, use the system status bar; in the prototype the frame already includes it.)

### 3.13 `SideMenu` (presentation mockup only)
> The left-hand panel in the images (numbered list 01–07 "Lumo · Prototype · 7 screens") is the **design-tool prototype navigator (Figma-like), NOT part of the app**. **Do not implement** it in Flutter. It only serves as a screen index.

---

## 4. Screen-by-screen spec

### Screen 01 — Login

**Layout (vertically centered, padding 24):**
1. Logo: `64px` square, `primary` background, radius `18`, centered white dot (`20px` circle). Pink shadow.
2. `Lumo` — `titleBrand` (24/700), centered, top margin 12.
3. `Your digital bank` — `caption textSecondary`, centered.
4. Spacer 32.
5. `Email` label → `AppTextField` (`mail` icon, placeholder `you@email.com`).
6. `Password` label → `AppTextField` (`lock` icon, placeholder `Enter your password`, trailing `eye`).
7. `Forgot password?` — `link`, **right**-aligned, top margin 8.
8. `PrimaryButton` **Sign in** (top margin 20).
9. "or" divider: `border` line + centered `or` text (`caption textTertiary`).
10. `SecondaryButton` **Create account** → navigates to Sign up.
11. Footer: `shield` icon + `Protected with end-to-end encryption` (`caption textTertiary`, centered), anchored to the bottom.

**Actions:** Sign in → Home. Create account → Sign up. Forgot password → (in the prototype, snackbar or no-op).

---

### Screen 02 — Sign up ("Create your account")

**AppBar:** `back` button (returns to Login).
**Header:** `Create your account` (titleScreen) + `Takes less than 2 minutes.` (caption).

**Fields (gap 20, label + field):**
1. `Full name` — `user` icon, placeholder `As on your ID`.
2. `Email` — `mail` icon, placeholder `you@email.com`.
3. `CPF` — `id-card` icon, placeholder `000.000.000-00` (CPF mask).
4. `Password` — `lock` icon, placeholder `At least 8 characters`, trailing `eye`.
5. **Checkbox** (square `radius 6`, `border`, checked = `primary`) + text: `I have read and accept the ` **`Terms of use`** ` and the Privacy Policy.` (links in `primary`, rest in `caption textSecondary`).
6. `PrimaryButton` **Sign up** (top margin 24).
7. Centered below: `Already have an account? ` **`Sign in`** (`primary` link) → back to Login.

**Validation (UI only):** highlight empty fields in red when submitting; checkbox required. Sign up → Home (or a simulated success screen).

---

### Screen 03 — Home

**Header (no traditional app bar):**
- `MA` avatar (40px) + column: `Welcome back` (caption textSecondary) / `Hi, Marina` (titleM 17/700).
- Right: white circular `48px` button with `bell` + red dot (notification).

**Balance card (gradient):**
- Full-width container, radius `20`, padding `20`, `primary → primaryDark` gradient (135°), `shadowBalance`.
- Decoration: translucent white circles on the right edge (subtle overlay, ~8–12% opacity).
- `Available balance` (white 13/600, ~80% opacity) + `eye` icon (hide toggle) on the right.
- `R$ 1,250.00` — `headlineLarge` in white.
- Pill chip: 18% white background + `Checking account · ••••2841` (white 12/600), full radius.

**Shortcuts (3 `ActionTile`):** `Transfer` (send), `Charge` (hand-coins), `Loan` (landmark). Tap → respective screens.

**Activity:**
- Section row: `RECENT ACTIVITY` (overline) on the left + `See all` (link) on the right.
- Single white card with 3 `TransactionRow` + dividers:
  1. `Transfer sent` · `To Bruno Carvalho · Today · 09:12` · `- R$ 120.00`.
  2. `Pix received` · `From Helena Souza · Yesterday · 18:40` · `+ R$ 45.90` (green).
  3. `Bill payment` · `Electricity · Jun 22 · 14:03` · `- R$ 134.70`.

**Bottom nav:** Home active.

---

### Screen 04 — Transfer

**AppBar:** `back` + `Transfer`.

**Contacts section:**
- `SEND TO` (overline).
- Horizontal row of 3 contacts (highlight Avatar `56px` + name below `caption`): `BC Bruno C.`, `HS Helena S.`, `DM Diego M.`. (Tap fills the recipient's CPF.) Horizontally scrollable.

**`FormCard`:**
- `Recipient's CPF` label → filled `AppTextField`, `id-card` icon, placeholder `000.000.000-00`.
- `Amount` label → `AmountField` `R$ 0.00`.
- Card footer: `wallet` icon + `Available balance: R$ 1,250.00` (caption textTertiary).

**CTA:** `PrimaryButton` **Transfer** (outside the card, top margin 24).

**Action:** Transfer → simulated success modal/screen ("Transfer completed").

**Bottom nav:** Transfer active.

---

### Screen 05 — Charges

**AppBar (row):** `Charges` (titleScreen) on the left + **`New`** pill button (`primary` background, white text 14/700, full radius, padding 8×16) on the right → navigates to New charge.

**Tabs (segmented):**
- Container `surfaceAlt` background, radius `12`, padding 4.
- Two tabs: **Received** (active: white background, light shadow, textPrimary 600) / **Sent** (inactive: textTertiary).

**Charge list (white cards, radius 20, shadow, gap 16):**

*Card with actions (Pending):*
- Row: Avatar (initials) + column (Name titleM / formatted CPF caption) + right column (value `titleM 17/700` + `StatusBadge Pending`).
- Button row: `OutlineButton` **Decline** (50%) + gap + `PrimaryButton`(success) **Approve** (50%), height ~48px.
- Contents:
  1. `Bruno Carvalho` · `182.557.640-08` · `R$ 120.00` · Pending.
  2. `Helena Souza` · `305.119.872-44` · `R$ 45.90` · Pending.

*Resolved card (no buttons):*
  3. `Diego Martins` · `774.203.158-90` · `R$ 300.00` · **Approved** badge (green).

**Actions:** Approve/Decline → updates the badge locally (in-memory state) and removes the buttons. New → screen 06.

**Bottom nav:** Charges active.

---

### Screen 06 — New charge ("Create charge")

**AppBar:** `back` + `New charge`.

**Info banner:**
- `primarySoft` background container, radius `16`, padding `16`.
- `hand-coins` icon (primary) + text: `Create a charge and send it via Pix to whoever needs to pay you.` (`caption`, `#9B2A4D`/dark-primary text on the light pink background).

**`FormCard`:**
- `Payer's CPF` label → filled `AppTextField`, `id-card` icon, placeholder `000.000.000-00`.
- `Charge amount` label → `AmountField` `R$ 0.00`.

**CTA:** `PrimaryButton` **Charge** (top margin 24).

**Action:** Charge → success screen/modal (e.g. "Charge created · share Pix") and back to Charges.

**Bottom nav:** Charges active (stays in the charges context).

---

### Screen 07 — Loan

**AppBar:** `back` + `Loan`.

**Value selector (centered):**
- `How much do you need?` (caption textSecondary, centered).
- `R$ 5,000` — `displayLarge` (40/700), centered (reflects the selected chip).
- `Pre-approved credit · up to R$ 10,000` (caption textTertiary, centered).

**Value chips:**
- Row of 4 chips (`radiusChip 12`, height ~44, `border`): `R$ 1,000`, `R$ 3,000`, **`R$ 5,000`** (selected: `primary` background, white text), `R$ 10,000`.
- Selecting one updates the large value and the simulation below.

**Simulation card (`FormCard`, 3 rows with dividers):**
| Left (textSecondary) | Right (textPrimary 700) |
|---|---|
| Interest rate | 2.9% / month |
| Installments | 12x of R$ 499.32 |
| 1st installment | in 30 days |

> The simulation (installment) should recompute based on the selected value. Loan payment formula (Price/amortizing): `PMT = PV · i / (1 − (1+i)^−n)`, with `i = 0.029`, `n = 12`. (You may use mocked per-chip values for simplicity.)

**CTA:** `PrimaryButton` **Request loan** (top margin 24).

**Footer:** `shield` icon + `Subject to credit analysis · APR 38.4% per year` (caption textTertiary, centered).

**Action:** Request → simulated success.

**Bottom nav:** Loan active.

---

## 5. Navigation and state

### 5.1 Structure
- `MaterialApp` with named routes.
- **Shell with `BottomNavBar`** wrapping: Home, Transfer, Charges, Loan (4 tabs). Use `IndexedStack` or `go_router` `StatefulShellRoute` to preserve state across tabs.
- Login and Sign up are **outside** the shell (no bottom bar).
- New charge is **pushed** over the shell (shows back, keeps the Charges tab active).

### 5.2 State management
- Since it is frontend only, use simple local state: `setState` / `ValueNotifier` / lightweight `Provider`.
- Mocked data in `mock_data.dart` (user "Marina", balance, contacts, activity, charges).
- Required mutable state:
  - Password visibility toggle (Login, Sign up).
  - Hide-balance toggle (Home) → shows `R$ ••••••`.
  - Selected tab in Charges (Received/Sent).
  - Charge status (Pending → Approved/Declined).
  - Selected loan chip.
  - Active bottom-bar tab.

### 5.3 Success feedback (prototype)
Per the mockup note ("see the success confirmations"), each primary CTA should show a **bottom sheet / dialog** with:
- A check icon in a `primary` or `success` circle.
- Title (e.g. "Transfer completed!").
- A "Done" button that returns to Home.

---

## 6. Flutter implementation notes

### 6.1 Theme (`ThemeData`)
```dart
final theme = ThemeData(
  useMaterial3: true,
  scaffoldBackgroundColor: const Color(0xFFEDEFF2),
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFFEC0B5A),
    primary: const Color(0xFFEC0B5A),
    surface: Colors.white,
    background: const Color(0xFFEDEFF2),
  ),
  fontFamily: 'Inter',
  // override textTheme, inputDecorationTheme, etc.
);
```

### 6.2 Suggested packages
- `intl` — currency/date formatting (register `en_US` locale).
- `google_fonts` (Inter) or a bundled font in `assets/fonts`.
- `lucide_icons` or `flutter_feather_icons` for the outline set (or custom SVGs via `flutter_svg`).
- `go_router` (optional) for declarative navigation with a shell.
- `mask_text_input_formatter` — CPF and currency masks.

### 6.3 Suggested folder structure
```
lib/
  main.dart
  theme/
    app_colors.dart
    app_typography.dart
    app_theme.dart
  data/
    mock_data.dart
    models/ (user, transaction, charge, contact)
  widgets/
    primary_button.dart
    secondary_button.dart
    app_text_field.dart
    amount_field.dart
    form_card.dart
    action_tile.dart
    transaction_row.dart
    status_badge.dart
    avatar.dart
    bottom_nav_bar.dart
    screen_app_bar.dart
    success_sheet.dart
  screens/
    login_screen.dart
    signup_screen.dart
    home_screen.dart
    transfer_screen.dart
    charges_screen.dart
    new_charge_screen.dart
    loan_screen.dart
  shell/
    main_shell.dart
```

### 6.4 Responsiveness and accessibility
- Content inside `SafeArea`; CTAs respect the bottom home indicator.
- Form screens: `SingleChildScrollView` to avoid overflow with the keyboard open; the CTA may "rise" with the keyboard or stay fixed.
- Minimum touch targets `48×48`. AA contrast for text on primary (white) and gray text.
- `Semantics` on action icons (back, bell, eye).
- Support text scaling (do not fix heights that would clip text; use min-height).

### 6.5 Micro-interactions
- Buttons: scale `0.98` + slight color change on pressed (`AnimatedScale` / custom `InkWell`).
- Balance card: fade animation when hiding/showing the value.
- Charges tabs: `AnimatedContainer` sliding the white indicator.
- Loan chips: color transition `200ms easeOut`; large value with `AnimatedSwitcher`.
- Screen transitions: `300ms` slide (push) / fade (tabs).

---

## 7. Mocked content / data

```dart
// User
name: "Marina", initials: "MA"
balance: 1250.00, accountMask: "Checking account · ••••2841"

// Contacts (Transfer)
[ {BC, "Bruno C."}, {HS, "Helena S."}, {DM, "Diego M."} ]

// Activity (Home)
[
  {type: sent,     title: "Transfer sent", sub: "To Bruno Carvalho · Today · 09:12", value: -120.00},
  {type: received, title: "Pix received",  sub: "From Helena Souza · Yesterday · 18:40", value: +45.90},
  {type: payment,  title: "Bill payment",  sub: "Electricity · Jun 22 · 14:03", value: -134.70},
]

// Charges (Received)
[
  {name: "Bruno Carvalho", cpf: "182.557.640-08", value: 120.00, status: pending},
  {name: "Helena Souza",   cpf: "305.119.872-44", value: 45.90,  status: pending},
  {name: "Diego Martins",  cpf: "774.203.158-90", value: 300.00, status: approved},
]

// Loan
options: [1000, 3000, 5000, 10000], selected: 5000
monthlyRate: 0.029, installments: 12, firstInstallmentDays: 30
preApprovedUpTo: 10000, apr: "38.4% per year"
```

---

## 8. Fidelity checklist (Definition of Done)

- [ ] Primary color `#EC0B5A` applied to CTAs, logo, active icons, balance gradient.
- [ ] General background `#EDEFF2`; white cards with a soft diffuse shadow.
- [ ] Inter typography with the weights and sizes from section 2.2; en_US currency formatting.
- [ ] Radii: inputs 14, cards 20, buttons 16, badges 8, avatars/chips round.
- [ ] 7 screens implemented per section 4 (without the mockup side menu).
- [ ] 4-item bottom nav with the correct active state per screen.
- [ ] Interactive states: password toggle, hide balance, charges tabs, charge status, loan chips.
- [ ] Success sheets when triggering primary CTAs.
- [ ] CPF and currency masks working.
- [ ] SafeArea, scroll-with-keyboard and accessibility contrast verified.
- [ ] Micro-interactions (pressed, tabs, chips) present.

---

*Document generated from the 7 reference screens of the Lumo prototype. Implementation: Flutter frontend only.*
