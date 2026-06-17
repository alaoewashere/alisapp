# Sello App — Design System Reference
*Last updated: June 16, 2026*

---

## 1. Brand Identity

**App Name:** Sello
**Type:** Arabic RTL Classifieds Marketplace
**Tagline:** YOUR MARKET, YOUR TRUST
**Platform:** iOS (iPhone 17, iOS 26.5)
**Language:** Arabic (RTL) primary

---

## 2. Color Palette

### Base Theme (Dark)
| Token | Name | Hex | Usage |
|-------|------|-----|-------|
| `--color-canvas` | Deep Canvas | `#131315` | Scaffold/page background |
| `--color-field` | Field Carbon | `#18181A` | Cards, input fields, bottom sheets, received chat bubbles |
| `--color-kyvo-volt` | Volt Green | `#D4FF3A` | Primary accent — buttons, active nav, highlights, focus rings |
| `--color-white` | Pure White | `#FFFFFF` | Primary text on dark surfaces |
| `--color-secondary-text` | Muted White | `#FFFFFF99` | Secondary/hint text (~60% opacity) |

### Brand Accent Colors (kept from original palette)
| Name | Hex | Usage |
|------|-----|-------|
| Verdun Green | `#48521C` | Legacy primary (used in gradients, pro badge) |
| Green Smoke | `#999F54` | بروفايل موثق verified badge, pro accents |
| Orinoco | `#DBDAAF` | Tinted chat background `#F0EFE0` |
| Eggshell | `#FCFFF5` | Surface/received chat bubble (light mode remnant) |
| Charcoal Grey | `#3C3C3C` | Legacy text |
| Gold | `#F5A623` | مميز premium badge accent |

### Subscription / Package Badge Gradients
Each uses a `LinearGradient` at ~135° diagonal for a metallic/luxury sheen:

| Tier | Arabic | Gradient From → To | Text Color |
|------|--------|--------------------|------------|
| Free | مجاني | `#9A9A9E` → `#4A4A4E` | `#FFFFFF` |
| Pro | برو | `#B8C27A` → `#48521C` | `#FFFFFF` |
| Premium | مميز | `#F5D77A` → `#C9921E` | `#131315` dark |

---

## 3. Typography

### Font Families
| Family | Weights | Role |
|--------|---------|------|
| ThmanyahSerifDisplay | 400 / 700 / 900 | Headlines, hero text, logo wordmark |
| ThmanyahSans | 400 / 500 / 700 / 900 | UI labels, buttons, inputs, hints, body default |
| ThmanyahSerifText | 300 / 400 / 700 | Body copy, descriptions |
| Inter (GoogleFonts) | kept for prices | Latin numerals, prices (e.g. 6,567,565 د.ع) |

### Text Style Roles
| Style | Font | Weight | Usage |
|-------|------|--------|-------|
| `headline` | ThmanyahSerifDisplay | 900 | Page titles, hero sections |
| `subheading` | ThmanyahSans | 700 | Section headers |
| `button` | ThmanyahSans | 700 | CTA buttons |
| `body` | ThmanyahSerifText | 400 | Descriptions, listing body text |
| `input` | ThmanyahSans | 400 | Text field content |
| `hint` | ThmanyahSans | 400 | Placeholder text |
| `price` | Inter | 600 | Listing prices (Latin numeral rendering) |
| `label` | ThmanyahSans | 500 | Tags, chips, secondary labels |

### Contrast Rule
All text on Deep Canvas (`#131315`) or Field Carbon (`#18181A`) must be Pure White or light grey. Dark text on dark backgrounds is forbidden. Exception: text inside Volt Green elements uses `#131315`.

---

## 4. Spacing & Corner Radius

### Border Radius
| Element | Radius |
|---------|--------|
| Listing cards, featured cards, chat context card | 16–20px |
| Primary CTA buttons | pill-shaped (999px) or 14–16px |
| Secondary buttons | 12–14px |
| Input fields | 12–14px |
| Bottom sheets / modals | 24px top corners only |
| Package/subscription badge pills | 12–16px |
| OTP digit boxes | 12px |
| Category icon cards | 16px |
| Avatar containers | circular (50%) |
| Bottom navigation bar | 28–32px (floating capsule) |

### Borders & Elevation
- No harsh borders; use `1px` white at `8–10% opacity` for subtle separation on Field Carbon surfaces
- Floating elements (bottom nav, modals, featured cards) use soft dark box-shadow, low spread
- Input fields: `1px` border, Field Carbon fill; on focus: Volt Green border highlight

---

## 5. Bottom Navigation Bar

**Style:** Floating pill/capsule, does not span full width, has horizontal margin from screen edges

| Property | Value |
|----------|-------|
| Background | Field Carbon `#18181A` |
| Shape | Rounded capsule, 28–32px radius |
| Margin from edges | ~16px horizontal, positioned close to bottom safe area |
| Active tab | Circular Volt Green `#D4FF3A` background behind icon; icon color `#131315` |
| Inactive tabs | White/grey icon, no background |
| Bottom offset | Uses `SafeArea` bottom inset — no large fixed margin |

### Tabs (RTL order, right to left)
| Icon | Label |
|------|-------|
| 🏠 | الرئيسية |
| 🔍 | بحث |
| ➕ | (center FAB — raised Volt Green circle) |
| 💬 | الرسائل |
| 👤 | حسابي |

**Center FAB:** Raised Volt Green (`#D4FF3A`) circular button, dark icon, sits slightly above the pill nav bar.

---

## 6. Component Library

### Listing Cards
- Background: Field Carbon `#18181A`
- Border radius: 16–20px
- Image aspect ratio: 1:1 for Pro/Premium tiers, standard for عادي
- Package badge: `PackageBadge` widget (gradient pill, see Section 2)
- Price: Inter font, Volt Green color `#D4FF3A`
- Favourite heart icon: top-left corner (RTL)

### Featured Listings Carousel (إعلانات مميزة ★)
- Section header: Gold star icon `#F5A623` + bold label
- Card width: 160px, horizontal scrolling
- Card border: 1px gold accent
- مميز badge: gradient pill (gold tier, see Section 2)
- Hidden entirely when no premium listings exist
- Shimmer loading state

### Package Badge (`PackageBadge` widget)
- Shape: Rounded rectangle pill, 12–16px radius
- Fill: LinearGradient at 135° (per tier colors in Section 2)
- Text: Bold Arabic tier name, centered
- Applied on: listing cards, listing detail page, manage-listing screen, package selection

### Chat Bubbles
| Type | Background | Text | Tail |
|------|-----------|------|------|
| Sent | Volt Green `#D4FF3A` OR Field Carbon with volt accent | `#131315` dark | Bottom-right 6px corner |
| Received | Field Carbon `#18181A` | Pure White | Top-left 6px corner |

- Corner radius: 20px with 6px "tail" corner
- Chat background: softened Orinoco tint `#F0EFE0` (or dark equivalent)
- Message grouping: 3px gap for consecutive messages from same sender
- Read receipts: Mint Green `#8FD9B0` icons

### Listing Context Card (in chat)
- Pinned at top of chat screen when replying to a listing
- Shows: thumbnail + title + price + "إعلان" label
- Field Carbon background, 16px radius, subtle border

### Conversation List Rows
- Avatar (DiceBear glyphs style) + listing thumbnail + last message + unread badge
- Unread badge: Volt Green background, dark count text
- Field Carbon background rows, 1px separator at 8% white opacity

### Input Fields
- Background: Field Carbon `#18181A`
- Border: 1px white at 8% opacity at rest; Volt Green `#D4FF3A` on focus
- Border radius: 12–14px
- Text: Pure White
- Hint/placeholder: Muted White (~60% opacity)
- Country code picker (phone): flag + code in a separate pill, same Field Carbon style

### OTP Verification Screen (صفحة رمز التحقق)
- 6 individual digit boxes, 12px radius, Field Carbon fill
- Active box: Volt Green border
- Countdown timer displayed below boxes
- "إعادة الإرسال" re-send button, enabled only after timer expires

### Buttons
| Type | Background | Text | Radius |
|------|-----------|------|--------|
| Primary CTA (e.g. ابدأ الآن, التالي, تأكيد) | Volt Green `#D4FF3A` | `#131315` dark bold | pill or 14–16px |
| Secondary | Field Carbon `#18181A` | Pure White | 14px |
| Destructive | Transparent + red border | Red | 14px |
| Text-only links | Transparent | Volt Green | — |

### Avatar System
- Style: DiceBear **glyphs** (geometric abstract)
- URL: `https://api.dicebear.com/9.x/glyphs/svg?seed=$seed`
- 30 preset seeds
- Selection state: Volt Green border + scale 1.08 + shadow
- Edit badge: small Volt Green circular icon bottom-right of avatar
- Applied: profile setup, edit profile, chat screen, conversation list

### Verified Seller Badge (بروفايل موثق)
- Color: Volt Green `#D4FF3A` (changed from Green Smoke)
- Icon: verified checkmark
- Shown on Pro and Premium listings

---

## 7. Screen Inventory & Key Design Notes

### Splash Screen
- 20 PNG frames (1080×1920), `intro_001.png` → `intro_020.png`
- Background: Orinoco `#DBDAAF`
- Sequence: green circle → shatter → Sello wordmark → tagline reveal
- Frame timing: ~4000ms total
- Tagline: **YOUR MARKET, YOUR TRUST**

### Home Screen (الرئيسية)
- Header: palm tree logo + "اشتري و بيع بسهولة" headline + subtitle
- Search bar: Field Carbon pill, 24px radius
- Category chips: horizontal scroll, Field Carbon cards with emoji/icon + Arabic label
- Featured carousel: gold-accented, horizontal scroll
- Regular listings grid: 2-column, Field Carbon cards
- Bottom content padding: scroll-only (invisible until end of list)

### Search Screen (بحث)
- AppBar with search field (Volt Green focus border)
- Category grid for browsing
- Results list: listing cards, same style as home

### Listing Detail Screen
- Hero image: full-width, no border radius (edge to edge)
- Tab bar: إعلان / الوصف / الموقع (Volt Green active underline)
- Price: Inter bold, Volt Green
- Package badge: gradient pill (PackageBadge widget)
- Attribute chips: Field Carbon, 12px radius (e.g. 4 أسطوانة, 9,000 كم)
- Detail rows: label right, value left, 1px separator
- Stats (views/contacts): shown for Pro & Premium owners only
- "راسل البائع" button: primary CTA style

### Create Listing Flow
- Step indicator: dots, Volt Green active dot
- Category picker: 2-column grid, Field Carbon cards
- "لا يوجد أيقونة" fallback: `Navigation-Menu-Horizontal--Streamline-Ultimate.png` asset
- Package selection: tier cards with PackageBadge + feature list
- Primary button: Volt Green pill (التالي / نشر الإعلان)

### Chat Screen (الرسائل)
- AppBar: avatar + online indicator + name + "متصل الآن" + call/more icons
- Bubble styles: see Component Library above
- Date separators: centered muted label
- Input bar: mic + emoji when empty; send button (Volt Green) when text present
- Listing context card pinned at top if chat started from listing

### Edit Profile Screen (تعديل الملف الشخصي)
- Avatar: 90px circle, Volt Green edit badge, "تغيير الصورة" link below
- Fields: الاسم الكامل (editable), البريد الإلكتروني (read-only display), رقم الهاتف (verified flow)
- Username: read-only display with 🔒 lock icon + "لا يمكن تغيير اسم المستخدم"
- Phone: shows verified number or "لم يتم التحقق" + "تحقق من الرقم" button
- حفظ save: top-left (RTL), Volt Green text

### Sign Up Screen
- Fields: الاسم الكامل, اسم المستخدم (with real-time availability check), البريد الإلكتروني, كلمة المرور
- Username validation: ✓ متاح (Volt Green) / ✗ مستخدم بالفعل (red), debounced
- Username is set once at signup and locked permanently

### Phone Verification Screen (صفحة رمز التحقق)
- Title: "أدخل رمز التحقق"
- Subtitle: number the WhatsApp OTP was sent to
- 6-box OTP input, Volt Green active border
- 10:00 countdown, "إعادة الإرسال" after expiry
- "تأكيد" primary CTA button

---

## 8. Iconography

- **Navigation icons:** custom PNG assets (Streamline Ultimate set)
- **Category icons:** per-category PNG/SVG assets in `assets/[category]-icons/`
- **Fallback icon:** `assets/Navigation-Menu-Horizontal--Streamline-Ultimate.png`
- **Package badge star:** ★ inline in مميز badge text
- **Verified badge:** system checkmark icon, Volt Green
- **Read receipts:** done / done_all Material icons, Mint Green `#8FD9B0`

---

## 9. Supabase Schema Reference

### Tables
| Table | Key Columns |
|-------|-------------|
| `profiles` | id, name, username (unique, locked), email, phone, phone_verified, avatar_seed, governorate, is_verified_seller |
| `listings` | id, title, price, images, category, listing_package, expires_at, auto_renew, view_count, contact_count, status, availability |
| `conversations` | id, buyer_id, seller_id, listing_id, last_message, last_message_at |
| `messages` | id, conversation_id, sender_id, text, image_url, is_read, created_at |
| `phone_verifications` | id, user_id, phone, otp, expires_at, used, created_at |

### Package Tiers
| Value | Weight | Duration | Carousel | Badge Color |
|-------|--------|----------|----------|-------------|
| مجاني / null | 1 | 30 days | ✗ | Silver gradient |
| برو | 2 | 60 days | ✗ | Green gradient |
| مميز / premium | 3 | 90 days | ✓ | Gold gradient |

---

## 10. RTL Rules

- All layouts use `TextDirection.rtl`
- Leading elements (back arrows, avatars in lists) appear on the right
- Text alignment: `TextAlign.right` default
- Bubble tails: sent = bottom-right, received = top-left
- Price always LTR inside RTL context (use `TextDirection.ltr` wrapper for Inter price text)
- All Arabic strings remain unchanged across all theme/styling passes

---

*This document covers design decisions only. For feature logic, Supabase queries, RLS policies, and routing, refer to the development session log.*