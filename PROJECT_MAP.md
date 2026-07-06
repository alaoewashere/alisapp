# PROJECT_MAP — Sello

Living architecture document for the Iraq Classifieds Marketplace.  
**Status:** MVP implemented — structure COMPLETE — May 2026  
**Bundle ID:** `com.iraq.marketplace.souqiq`

---

## PRODUCT

| Field | Value |
|---|---|
| **App name (AR)** | Sello |
| **App name (EN)** | Sello |
| **Target** | Android & iOS |
| **Locale** | ar (default), en, ku (Sorani), tr — ARB gen-l10n (`lib/l10n/`) |
| **Currency** | IQD (no decimals) |
| **Reference** | sahibinden.com |

---

## CONFIRMED DECISIONS

| Decision | Choice |
|---|---|
| Guest browsing | Yes |
| Listing moderation | Admin approval via Supabase Dashboard (status column) |
| Supabase | Migrations in `supabase/migrations/` |
| Chat | 1:1 per listing (buyer ↔ seller) |
| Auth | Phone OTP via Supabase (+964) |
| Admin UI | **Web dashboard** (Next.js 14) in `admin/` — `admin.souqiq.com` |

---

## TECH_STACK

| Layer | Tool | Version |
|---|---|---|
| Language | Dart | `^3.12.0` |
| Framework | Flutter | `3.44.x` stable |
| Backend | Supabase | PostgreSQL + Auth + Storage + Realtime |
| SDK | supabase_flutter | `^2.12.4` |
| Navigation | go_router | `^17.2.3` |
| State | flutter_riverpod + riverpod_annotation | `^3.3.1` / `^4.0.2` |
| Localization | flutter_localizations + intl | SDK + `^0.20.2` |
| Images | cached_network_image, image_picker, flutter_svg | latest |
| Maps / location | google_maps_flutter, geolocator, flutter_map, latlong2, flutter_map_marker_cluster | geo listings + clustered heat-map badges |
| UI polish | shimmer, timeago, url_launcher, country_picker | latest |
| Config | flutter_dotenv | `.env` (`SUPABASE_*`, `GOOGLE_MAPS_API_KEY`, `GROQ_API_KEY`, optional `ONESIGNAL_APP_ID`) |
| Testing | flutter_test, mocktail | SDK + `^1.0.5` |
| Integration (E2E) | patrol `^4.6.1` + patrol_cli | `patrol_test/` — guest home/search flows |

### Config (`.env` for local dev)
```bash
flutter run
```

### Tooling: Sello design skill

| Item | Value |
|---|---|
| **Location** | `.cursor/skills/ui-ux-pro-max/` (CLI path unchanged) |
| **Brand name** | Sello - Design Intelligence |
| **Generator** | `scripts/design_system.py` — BM25 search + reasoning |
| **Typography** | Always emits local Thmanyah fonts (`ThmanyahSans`, `ThmanyahSerifDisplay`, `ThmanyahSerifText`) with `@font-face` rules to `assets/fonts/` |
| **Run** | `python3 .cursor/skills/ui-ux-pro-max/scripts/search.py "<query>" --design-system -p "Sello" -f markdown` |
| **Tests** | `python3 .cursor/skills/ui-ux-pro-max/scripts/test_design_system.py` |

### Security posture (P0/P1 hardening — Jun 2026)

| Control | Implementation |
|---|---|
| **RLS column guards** | `20260720000000_security_rls_guards.sql` — triggers on `listings`, `profiles`, `messages`; `public_profiles` view (`security_invoker=true`, Jun 2026) |
| **Public listings** | `20260724000000_listings_public_approved_rls.sql` — public SELECT `status = approved`; `Admins read all listings`; app feeds use `.eq('status', 'approved')` in `ListingsRepository` + favorites inner join |
| **Storage** | `20260720000001_security_storage.sql` — owner-scoped writes for listing media; admin-only `brand-logos` |
| **OTP** | Rate limiting via `otp_throttle`; CORS allowlist in edge functions; `get_auth_user_id_by_phone` RPC |
| **RPC hardening** | `20260720000002_security_rpc.sql` — view/contact increments only on public listings; rating notification auth |
| **Purchases** | `verify-purchase` edge function + `pending_purchases`; client INSERT revoked on `listing_purchases`/`boosts` — **deployed** to remote (Jun 2026) |
| **Checkout (FuratPay)** | `furatpay-initiate` edge function + `orders.furatpay_invoice_id`; `FURATPAY_API_KEY` server-only; **deployed** (Jun 2026) |
| **Secrets** | No `.env` in release bundle; `groq-proxy` + `furatpay-initiate` edge functions; `env.json.example` for `--dart-define-from-file` |
| **Monitoring** | Optional `SENTRY_DSN` dart-define; `SecureLog` scrubs PII in logs |
| **Verification** | `supabase/tests/security_policies.sql`; `test/security_hardening_test.dart` |
| **Remote DB** | Security migrations `20260720000000`–`000003` + `phone_verification` (`phone_verifications`, `profiles.phone_verified`) applied to project `riaazqhgknsnymjzzjou` (Jun 2026) |
| **Remote Edge** | `send-whatsapp-otp` + `verify-whatsapp-otp` deployed to remote (Jun 2026); requires Twilio secrets (`TWILIO_ACCOUNT_SID`, `TWILIO_AUTH_TOKEN`, `TWILIO_WHATSAPP_FROM` for profile OTP) |
| **Client fallback** | `lib/core/supabase/public_profiles_query.dart` — `fetchPublicProfiles()` falls back to `profiles` if view missing |

### Performance optimizations (Jun 2026)

| Area | Change |
|---|---|
| **Favorites** | `toggleFavoriteProvider.select()` per card; no home feed refetch on heart tap |
| **Images** | `cachedListingImage()` with `memCacheWidth`/`memCacheHeight` on grid, carousel, gallery, bento |
| **Home** | Isolated sliver sections — category/featured/recent rebuild independently; recent listings horizontal scroll row; local PNG icons for all 8 root browse categories (المركبات، العقارات، الإلكترونيات، سوق المستعمل، دروس خصوصية، فرص العمل، الحيوانات، مساعدة منزلية) |
| **Detail** | View count once in `initState`; price history via `priceHistoryProvider`; favorite scoped to gallery `Consumer` |
| **Chat** | Removed build-time scroll callback; offline banner isolated; message `ValueKey`s; input `TextEditingController` owned locally in `_ChatInputBar` (not autoDispose provider); bounded `TextField` (`maxLines: 5`) fixes overflow |
| **Categories** | Removed drill-down `initState` invalidation; listings title from cached `allCategoriesProvider` |
| **Dead code** | Removed `category_browse_row`, `CategoryGridSection`, `favoriteOverridesProvider`, `legacyMyListingsProvider`, `descriptionExpandedProvider`, `isOwnerProvider` |

---

## ARCHITECTURE (COMPLETE)

```
lib/
├── main.dart                          # dotenv + Supabase init + runApp
├── app.dart                           # MaterialApp RTL, theme, GoRouter
├── core/
│   ├── constants/
│   │   ├── app_colors.dart
│   │   ├── app_strings.dart           # Arabic + English strings
│   │   ├── app_governorates.dart      # 18 Iraqi governorates
│   │   └── app_constants.dart         # bundle ID, redirect URI, limits
│   ├── theme/
│   │   ├── app_theme.dart             # Dark "fintech" theme (Deep Canvas / Field Carbon / Volt Green)
│   │   ├── app_decorations.dart       # Radii, shadows (dark), carbon card decoration
│   │   └── text_styles.dart           # Thmanyah Sans / Serif Text / Serif Display
│   ├── router/
│   │   └── app_router.dart            # GoRouter + AppRoutes
│   ├── utils/
│   │   ├── currency_formatter.dart
│   │   └── validators.dart
│   └── supabase/
│       └── supabase_client.dart       # init + Riverpod auth providers
├── features/
│   ├── auth/
│   │   ├── data/auth_repository.dart       # sendOTP, verifyOTP, signOut, createProfile, uploadAvatar
│   │   ├── domain/auth_result.dart
│   │   ├── presentation/phone_screen.dart
│   │   ├── presentation/otp_screen.dart
│   │   ├── presentation/profile_setup_screen.dart
│   │   ├── providers/auth_provider.dart    # AuthFlowState + authNotifierProvider
│   │   └── widgets/otp_input.dart
│   ├── home/
│   │   ├── presentation/home_screen.dart
│   │   ├── widgets/category_grid.dart
│   │   ├── widgets/listing_card.dart
│   │   ├── widgets/recent_listings_row.dart
│   │   └── providers/home_provider.dart
│   ├── listings/
│   │   ├── data/listings_repository.dart
│   │   ├── data/categories_repository.dart
│   │   ├── presentation/listings_screen.dart
│   │   ├── presentation/listing_detail_screen.dart
│   │   ├── presentation/edit_listing_screen.dart
│   │   ├── presentation/post_listing_screen.dart
│   │   ├── presentation/search_screen.dart
│   │   ├── widgets/filter_sheet.dart
│   │   ├── widgets/image_picker_grid.dart
│   │   ├── widgets/map_picker_sheet.dart
│   │   ├── widgets/listing_detail_gallery.dart
│   │   ├── widgets/listing_detail_bottom_bar.dart
│   │   ├── widgets/listing_map_preview.dart
│   │   ├── widgets/report_sheet.dart
│   │   ├── widgets/steps/step1_category.dart
│   │   ├── widgets/steps/step2_details.dart
│   │   ├── widgets/steps/step3_location.dart
│   │   ├── widgets/steps/step4_photos.dart
│   │   ├── widgets/steps/step5_review.dart
│   │   ├── providers/listings_provider.dart
│   │   ├── providers/post_listing_provider.dart
│   │   ├── providers/listing_detail_provider.dart
│   │   └── providers/edit_listing_provider.dart
│   ├── chat/
│   │   ├── data/chat_repository.dart
│   │   ├── presentation/conversations_screen.dart
│   │   ├── presentation/chat_screen.dart
│   │   ├── providers/chat_provider.dart
│   │   ├── widgets/conversation_tile.dart
│   │   ├── widgets/message_bubble.dart
│   │   └── widgets/onesignal_handler.dart
│   ├── favorites/
│   │   ├── data/favorites_repository.dart
│   │   ├── presentation/favorites_screen.dart
│   │   └── providers/favorites_provider.dart
│   └── profile/
│       ├── data/profile_repository.dart
│       ├── presentation/profile_screen.dart
│       ├── presentation/my_listings_screen.dart
│       ├── presentation/seller_profile_screen.dart
│       └── providers/profile_provider.dart
└── shared/
    ├── widgets/
    │   ├── custom_button.dart
    │   ├── custom_text_field.dart
    │   ├── loading_widget.dart
    │   ├── error_widget.dart
    │   ├── glass_container.dart       # BackdropFilter glass surface (blur 12, radius 20)
    │   ├── souqly_search_bar.dart     # Hero search bar (home mockup)
    │   ├── app_logo.dart              # Palm-tree brand logo + AppBrandHeader (home RTL header)
    │   └── app_bottom_nav.dart        # FloatingGlassNavBar + gradient center add
    └── models/
        ├── listing_model.dart
        ├── profile_model.dart
        ├── category_model.dart
        ├── message_model.dart
        └── conversation_model.dart
supabase/
├── migrations/
└── README.md
```

**State management:** Riverpod `Notifier` / `FutureProvider` only — no `setState`.  
**Navigation:** GoRouter exclusively via `core/router/app_router.dart`.

---

## SYSTEM_FLOW

### Launch
`main()` → `dotenv.load` → `initializeSupabase()` → `SouqIqApp` (RTL) → auth redirect → shell

### Auth (Phone OTP) — COMPLETE
`PhoneScreen` → `sendOTP` → `OtpScreen` → `verifyOTP` →  
  `[isNewUser]` → `ProfileSetupScreen` (avatar + name + governorate) → `HomeScreen`  
  `[returning user]` → `HomeScreen`

Router guards (`routerProvider`):
- No session → `/phone`
- Session + incomplete profile → `/profile-setup`
- Session + complete profile → `/` (home)

### Browse (auth required)
Home → category filter → listing grid → ListingDetail (gallery, contact, report, edit)

### Search (guest OK)
SearchScreen → category browse list (Sahibinden-style) OR text search (≥2 chars) → FilterSheet → results grid  
**No-match empty state:** `SearchResultsScreen` shows `لا توجد نتائج` + `لم يتم العثور على نتائج لـ «query»`; web injects screen-reader-only DOM text inside `<flutter-view>` for TestSprite/Playwright (`sello_dom_probe`).  
**Patrol E2E:** `patrol_test/guest_search_empty_state_test.dart` (search tab → no-match query → empty state); `./scripts/run_patrol_tests.sh` with `env.json` (`PLATFORM=ios|web|android`, not `--platform`).  
**Category drill-down:** tap العقارات or السيارات → `CategoryBrowseScreen` (`/categories/:id`) → nested branches → leaf → `ListingsScreen`. Children loaded via `fetchChildren(parent_id)` (not in-memory tree only); `fetchAll()` paginates past PostgREST 1000-row cap.

### Listing density heat map (guest OK) — COMPLETE
Home banner → `/heatmap` (`ListingHeatmapScreen`) → CartoDB dark tiles + Volt circle markers sized by `get_listing_density` RPC → tap area → bottom sheet → «عرض الإعلانات» pre-filters `FilterModel.areaName` (+ optional category) → `SearchResultsScreen`.  
**Area capture:** post/edit Step 3 optional neighborhood picker + GPS nearest-center suggestion; `listings.area_name` backfilled from `listing_area_centers` seed (29 neighborhoods).

### Auth
PhoneScreen → OTP (+964) → ProfileSetupScreen (if new) → Home

### Post listing (auth) — COMPLETE
BottomNav "+" → `PostListingScreen` (6 steps; 7 for vehicles incl. paint) → compress + upload images → INSERT `listings` + `listing_images` (status=`pending`) → `ListingDetailScreen`

Steps: category (recursive drill-down to leaf) → details → location (+ optional map pin) → photos (reorder, max 10) → contact preferences (profile name/phone + `contact_preference`) → review & publish / save draft

**Category pick (Step 1):** `CategoryDrillScreen` — `categoryDrillStack` in `PostListingState` (no GoRouter); `getDrillDownChildren` aliases سيارات للإيجار → سيارات brand tree (`effectiveBrowseParentId`, same as browse). AppBar/system back and breadcrumb pop one drill level; at root grid back exits the flow.

**Vehicle Step 2:** When `categoryPath` root is `cars` (المركبات), Step 2 shows `Step2VehicleDetails` — iOS-style grouped basic-info cards (trim, mileage, engine, cylinders); always `sale` (no rent toggle); specs chips in `metadata` JSONB; title/description auto-generated on advance.

**Real estate Step 2:** When `categoryPath` root is `real_estate` (العقارات), Step 2 shows `Step2RealEstateDetails` (property type, offer type, area, rooms, features, etc.) in `metadata` with `listing_kind: real_estate`.

**Electronics Step 2:** When `categoryPath` is under `electronics` and branch is `elec_smartphones` / `elec_laptops` / `elec_displays`, Step 2 shows `Step2ElectronicsDetails` with sub-form by kind (`listing_kind`: `phone` | `laptop` | `tv`); brand/model pre-filled from category drill path; other electronics branches use generic Step 2.

**General marketplace Step 2:** When `categoryPath` root is `buy_sell` (سوق المستعمل والجديد), Step 2 shows `Step2GeneralMarketplaceDetails` (item condition chips, brand, exchange/delivery toggles) in `metadata` with `listing_kind: general`.

**Tutoring / Jobs / Pets / Home help Step 2:** Roots `tutoring`, `jobs`, `pets`, `home_help` each show dedicated Step 2 forms with category-specific `metadata` (`listing_kind`: `tutoring` | `job` | `animal` | `home_service`).

### Edit listing (auth) — COMPLETE
My Listings / Listing detail owner bar → `/listing/edit/:listingId` → fetch listing → single-page `EditListingScreen` (read-only category banner, all fields pre-filled) → diff-only `patchListing` save; price change shows confirm dialog first (dialog pops before async save); photos add/remove; premium video replace optional

### Favorites (auth) — COMPLETE
ListingDetail ♥ → optimistic toggle → FavoritesScreen (grid, swipe-to-remove, pull-to-refresh)

### Profile + My Listings + Settings (auth) — COMPLETE
BottomNav "حسابي" → ProfileScreen (own/other user) → edit / my listings / settings / logout  
"إعلاناتي" → MyListingsScreen (4 tabs: active/pending/sold/deleted) → Field Carbon listing cards; edit/sold/delete/restore/repost; 🚀 boost sheet for برو/مميز posts when user tier is برو/مميز  
"الإعدادات" → SettingsScreen → language / notifications / about / logout / delete account

### Chat (auth) — COMPLETE
ListingDetail «راسل البائع» → `startChatFromListing` (create/find conversation + intro message) → `ChatScreen` with `ListingContextCard` → Supabase Realtime streams → unread badge on bottom nav

Push: OneSignal (optional `ONESIGNAL_APP_ID` in `.env`) saves `onesignal_player_id` to profiles; smart-alert matches fire OneSignal push via `notify_smart_alerts()` when listings are approved

### Smart Alerts (تنبيه ذكي) (auth) — COMPLETE
Search bell / profile «تنبيهاتي الذكية» / search-results banner → `MyAlertsScreen` → create/edit alerts → DB trigger `notify_smart_alerts()` on listing approval → OneSignal push → tap opens listing detail
  - First-time coachmark on Search screen (`smart_alerts_tutorial_seen` in SharedPreferences); shared `FeatureTutorialOverlay`

Free users: max 3 active alerts; Pro/Premium purchasers (`listing_purchases`): unlimited

### Marketplace checkout (FuratPay) — edge function ready; client TBD
Buyer creates row in `orders` (RLS: buyer insert/select) → app invokes `furatpay-initiate` with `{ order_id, payment_service_id }` + JWT → edge function:
1. `POST https://api.furatpay.com/invoice` (`x-api-key` from `FURATPAY_API_KEY` secret)
2. Persists `invoice.id` → `orders.furatpay_invoice_id`
3. `POST /public/invoice/pay` with client `payment_service_id`
4. Returns `{ redirect_url, invoice_id, order_id }` — API key never sent to client

Settings debug **Start payment** button remains disconnected until Flutter client is wired.

---

## DATA MODEL

See Supabase migrations (… `20260605000000_category_brand_logos`, `20260606000000_listing_type`). Tables: `profiles`, `categories` (`logo_url`), `listings` (`listing_type`: `sale`|`rent`), …

**Categories:** `categories.color_hex` (level-1 branch accent). **العقارات** (`real_estate`) — 6 level-1 + ~61 descendants (`re_*`). **السيارات** (`cars`) — 13 level-1 branches (`veh_*`) + **783 brand/model nodes** under سيارات / SUV / electric / commercial (`veh_auto_br_*`, icon `brand`/`model`). **سيارات تالفة** (`veh_damaged`) — mirror of سيارات tree (`veh_damaged_br_*`, re-synced from `veh_automobile`). **سيارات ذوي الاحتياجات الخاصة** (`veh_accessible`) — mirror of سيارات tree (`veh_accessible_br_*`). **مركبات بحرية** (`veh_marine`) — **15 brands + 115 models** (`veh_marine_br_*`; jet skis, outboards, fishing boats, traditional Iraqi boats). **كرفان** (`veh_caravan`) — **13 brands + 86 models** (`veh_caravan_br_*`; RVs, European caravans, local builds). **سيارات كلاسيكية** (`veh_classic`) — **20 brands + 154 models** (`veh_classic_br_*`; W123, Mustang, Land Cruiser FJ40, Opel Rekord, etc.). **مركبات جوية** (`veh_aircraft`) — **طائرات + مروحيات** → 16 brands + 108 models (`veh_aircraft_planes_*`, `veh_aircraft_helicopters_*`). **الإلكترونيات** (`electronics`) — **18 subcategories + 83 brands + 486 models/items** (`elec_*`; smartphones through medical devices; brand logos in Storage `elec-*.svg`). **سوق المستعمل والجديد** (`buy_sell`) — **19 subcategories + 185 listing types** (`souq_*`; phones, fashion, furniture, food, etc.). **دروس خصوصية** (`tutoring`) — **5 branches + 117 subjects** (`tutor_*`; school, university, languages, Quran, professional skills). **فرص العمل** (`jobs`) — **10 branches + 80 job types** (`jobs_*`; IT, engineering, medical, oil, trades, freelance, etc.). **الحيوانات** (`pets`) — **10 branches + 89 breeds/types** (`pets_*`; dogs, cats, birds, farm, accessories, services, lost/found). **مساعدة منزلية** (`home_help`) — **10 branches + 60 services** (`home_*`; cleaning, cooking, childcare, maintenance, moving, etc.). **دراجات** (`veh_motorcycle`) — **537 brand/model nodes** directly under دراجات (`veh_moto_br_*`, motorcycle logos from carlogos.org). Re-run safe via `ON CONFLICT (slug)`.

Listing moderation: `status` = `pending` | `approved` | `rejected`  
Lifecycle: `availability` = `active` | `sold` | `deleted`

---

## FEATURE STATUS

### COMPLETED
- **Home feature** — COMPLETE
  - `shared/models/category_model.dart` — id, nameAr/Ku/En, icon, parentId, displayName()
  - `shared/models/listing_model.dart` — ListingModel, FilterModel, images, formattedPrice, timeAgo
  - `features/listings/data/listings_repository.dart` — featured, recent, by category, search; package sort; RPC view/contact counts; **listing title/description translated in `_mapListings` before UI** (via `core/utils/listing_translation.dart` + `TranslationService` cache)
  - `core/utils/listing_package_utils.dart` — expiry, packageWeight, sortListingsByPackagePriority
  - `shared/widgets/pro_listing_badge.dart` — «بروفايل موثق» card + detail chip
  - `features/listings/widgets/listing_owner_package_panel.dart` — owner stats, auto-renew, expiry
  - `supabase/migrations/20260713000000_add_package_features.sql` — contact_count, auto_renew, increment RPCs
  - `features/listings/data/categories_repository.dart` — paginated fetchAll, fetchChildren (parent_id), fetchBySlug
  - `features/home/providers/home_provider.dart` — categories, featured, recent, favorites toggle
  - `features/home/widgets/category_grid.dart` — horizontal chips with shimmer
  - `features/home/widgets/listing_card.dart` — card with badges, favorite, optimistic toggle
  - `features/home/widgets/featured_listings_carousel.dart` — «إعلانات مميزة» horizontal premium carousel
  - `features/home/widgets/home_section_view_all_link.dart` — shared «عرض الكل» Volt link (matches تصفح الفئات)
  - `features/home/presentation/home_feed_screen.dart` — paginated full feeds from Home «عرض الكل»
  - `features/home/providers/home_feed_provider.dart` — featured + latest infinite-scroll providers
  - `latestHomeListingsProvider` — أحدث النشرات: برو + مجاني only (excludes مميز); `sortLatestHomeFeedListings` + `sliceLatestHomeFeedPage` shared by preview + `/feed/latest` pagination
  - Routes `/feed/featured`, `/feed/latest` (guest-allowed)
- **Content moderation + posting bans** — COMPLETE
  - `blocked_words` + `moderation_violations` tables; `profiles.moderation_violation_count`, `last_moderation_violation_at`
  - **30-day rolling window** for warn vs block (`effective_moderation_violation_count`); stored count does not auto-decrement
  - **Posting bans** on `profiles`: `is_banned`, `banned_until`, `ban_count` (lifetime), `ban_reason`, `banned_by`
  - Auto-ban on 2nd violation (block): 2 days if `ban_count == 0`, else 1 month; `record_moderation_block` RPC for client-side blocks
  - Bans block chat send + listing create/edit only (browse/login OK); expired bans ignored at enforcement time
  - `ContentModerationService` + Arabic normalizer (client); Postgres triggers + RPCs (server source of truth)
  - Admin: `/dashboard/blocked-words`, `/dashboard/moderation` (إدارة المخالفات — view/ban/unban)
  - Integrated: chat send, listing publish/edit title+description, profile name
  - **Client submits original text** on censored path (server triggers censor + persist); client-only `***` bypasses DB logging
  - `test/content_moderation_test.dart`, `test/moderation_warning_dialog_test.dart`, `test/posting_ban_utils_test.dart`, `test/moderation_server_write_path_test.dart`
  - `widgets/featured_listing_card.dart` — compact gold-border premium card
  - `features/home/presentation/home_screen.dart` — sliver layout, pull-to-refresh
  - `features/home/widgets/home_top_bar_icon_button.dart` — circular header icons (favorites + heat map)
  - `features/home/widgets/home_heatmap_tutorial.dart` — heat map coachmark wrapper (`heatmap_tutorial_seen`)
  - `shared/widgets/feature_tutorial_overlay.dart` — reusable dim + spotlight tutorial overlay
  - `features/home/widgets/home_heatmap_banner.dart` — `openHomeHeatmap` navigation helper → `/heatmap`
  - `features/listings/presentation/listing_heatmap_screen.dart` — dark map, category chips, area drill-down sheet
  - `features/listings/providers/listing_heatmap_provider.dart` — `listingDensityProvider`, category slug filter
  - `core/utils/listing_heatmap_utils.dart` — marker sizing, category-aware density copy
  - `core/constants/iraq_neighborhoods.dart` — 29 seeded area centers (mirrors `listing_area_centers`)
  - `supabase/migrations/20260726000000_listing_area_density.sql` — `area_name`, `get_listing_density` RPC, backfill
  - `test/listing_heatmap_utils_test.dart`, `test/home_heatmap_banner_test.dart`
  - `features/listings/presentation/listings_screen.dart` — category-filtered grid
  - `shared/widgets/shimmer_loading.dart` — shimmer placeholders
  - `core/utils/currency_formatter.dart` — formatIQD()
  - `shared/widgets/app_bottom_nav.dart` — 5-tab docked FAB nav
- **Post a Listing feature** — COMPLETE
  - `features/listings/providers/post_listing_provider.dart` — 5-step (6 for vehicles) state, validation, upload, publish, draft; `panelConditions` on vehicle metadata
  - `features/listings/presentation/post_listing_screen.dart` — step indicator (5 or 6 dots), AnimatedSwitcher, nav buttons
  - `features/listings/presentation/car_paint_condition_screen.dart` — vehicle-only step 3: 13-panel body/paint diagram (Sahibinden-style)
  - `assets/images/car_diagram.png` — top-down car diagram (316×394) for paint condition step
  - `features/listings/widgets/car_paint/car_paint_panel_layout.dart` — percentage panel hit regions on PNG
  - `features/listings/widgets/car_paint/car_paint_widget.dart` — image + overlay + picker UI
  - `features/listings/widgets/car_paint/car_paint_summary_widget.dart` — legend, read-only diagram, grouped condition summary
  - `core/constants/car_paint_panels.dart` — 13 panel keys/bounds, condition colors
  - `features/listings/widgets/steps/step1_category.dart` — embeds `CategoryDrillScreen` (root grid)
  - `features/listings/widgets/category_drill_screen.dart` — recursive post-listing category picker (2-col bento grid)
  - `features/listings/widgets/category_bento_grid.dart` — `CategoryBentoCard` / `CategoryBentoGrid` — 2-column white cards, Cairo title + muted subtitle, brand logos for vehicle browse
  - `shared/widgets/category_icon.dart` — category tile icon resolution; generic `category` placeholder (📦) → `assets/Navigation-Menu-Horizontal--Streamline-Ultimate.png` inside accent box; `tutor_*` subjects (`icon: model`) skip vehicle letter logo and use same fallback PNG; dedicated emojis/PNGs unchanged
  - `shared/widgets/package_badge.dart` — luxury metallic pill badges for listing tiers (مجاني / برو / مميز); used on cards, detail, package picker, owner panel
  - `features/listings/widgets/category_path_breadcrumb.dart` — horizontal tappable path chips
  - `features/listings/widgets/steps/step2_details.dart` — routes generic vs vehicle / real estate / electronics form
  - `features/listings/widgets/steps/step2_vehicle_details.dart` — vehicle listing fields (metadata); optional Groq AI price estimator for `veh_automobile` only
  - `features/listings/widgets/vehicle_price_estimator_section.dart` — «احسب السعر المقترح» helper card on car post step 2
  - `features/verification/data/verification_repository.dart` — upload ID docs + submit verification requests
  - `screens/verification/` — 4-step seller verification flow (intro → document type → upload → success)
  - `shared/widgets/verified_badge.dart` — blue checkmark for verified sellers
  - `admin/dashboard/verification` — admin review queue (approve/reject)
  - `models/price_estimate.dart` — min/max IQD range + confidence + reasoning
  - `features/listings/widgets/steps/step2_real_estate_details.dart` — real estate listing fields (metadata)
  - `features/listings/widgets/steps/step2_electronics_details.dart` — phone / laptop / TV listing fields (metadata)
  - `features/listings/widgets/steps/step2_general_marketplace_details.dart` — buy_sell marketplace fields (metadata)
  - `shared/models/general_listing_metadata.dart` — `listing_kind: general` JSONB schema
  - `core/utils/general_listing_utils.dart` — buy_sell detection, title/description, condition mapping
  - `shared/models/electronics_listing_metadata.dart` — `listing_kind: phone|laptop|tv` JSONB schema
  - `core/utils/electronics_listing_utils.dart` — branch detection, title/description, condition mapping
  - `theme/app_text_styles.dart` — Thmanyah typography system on dark (white/grey text, dark text on Volt buttons; headline, subheading, body, input, button, price, hint, counter)
  - `theme/app_form_fields.dart` — rounded (14px) carbon input decoration, carbon field groups, labels, char counters, section dividers
  - Dark "fintech" tokens live in `core/constants/app_colors.dart`: Deep Canvas `#131315` (scaffold), Field Carbon `#18181A` (cards/inputs/sheets/received bubble), Volt Green `#D4FF3A` (primary/active/focus/links/sent bubble), Pure White text. Premium gold badge stays `#F5A623`; verified badge = Volt Green. Bottom nav = floating carbon pill with circular Volt active highlight (dark icon).
  - `features/listings/widgets/steps/step2_title_description_fields.dart` — premium underline title/description group (no suggestion chips)
  - `features/listings/widgets/steps/step2_generic_details.dart` — price, condition
  - `features/listings/widgets/steps/step3_location.dart` — governorate, city, map picker
  - `features/listings/widgets/steps/step4_photos.dart` — photo grid step (dark canvas + Volt Green restyle)
  - `features/listings/widgets/image_picker_grid.dart` — Field Carbon thumbnails, RTL-aware remove badge
  - `features/listings/widgets/listing_video_upload_section.dart` — dark video upload card + muted Pro upsell
  - `features/listings/widgets/steps/step5_review.dart` — preview card, edit jumps, publish overlay
  - `features/listings/widgets/map_picker_sheet.dart` — GoogleMap + geolocator (Iraq bounds)
  - `features/listings/widgets/image_picker_grid.dart` — reorderable grid, compression on add
  - `core/utils/image_compression.dart` — flutter_image_compress (max 1MB, 1200px)
  - `features/listings/data/categories_repository.dart` — fetchAll, fetchChildren, getChildCategories, hasChildren
  - `features/listings/data/listings_repository.dart` — uploadListingImage, createListingRecord, saveDraft
- **Listing Detail feature** — COMPLETE
  - `features/listings/providers/listing_detail_provider.dart` — detail, isOwner, seller listings, actions
  - `features/listings/presentation/listing_detail_screen.dart` — sliver gallery, sections, bottom bar; vehicle stat cards + paint summary from `metadata.panel_conditions`
  - `features/listings/widgets/vehicle_stats_row.dart` — 4-card iqcars-style trim/mileage/engine/cylinders row
  - `features/listings/widgets/vehicle_listing_detail_section.dart` — vehicle details list + specs chips
  - `features/listings/widgets/listing_detail_gallery.dart` — PageView + photo_view pinch zoom
  - `features/listings/widgets/listing_detail_bottom_bar.dart` — buyer (WhatsApp share card / مراسلة / call / chat) + owner actions
  - `core/constants/deep_link_constants.dart` — sello.iq listing/seller URLs
  - `core/deep_links/deep_link_service.dart` — parse incoming app/universal links
  - `widgets/listing_share_card.dart` — off-screen 1080×1350 RepaintBoundary card + deep link pill
  - `widgets/profile_share_card.dart` — off-screen 1080×600 profile share card
  - `services/share_service.dart` — capture share card PNG + share_plus with deep links
  - `models/rating.dart` + `services/rating_service.dart` — post-deal ratings with anti-abuse rules
  - `widgets/rate_dialog.dart` — bottom sheet star rating UI
  - `widgets/star_display.dart` — reusable stars + count + listing card badge
  - `screens/ratings_screen.dart` — full profile ratings page with breakdown chart
  - `services/video_service.dart` — validate, thumbnail, upload listing videos (Pro/Premium)
  - `models/price_history.dart` + `services/price_history_service.dart` — price change timeline on listing detail
  - `widgets/price_history_widget.dart` — sparkline + timeline (cars & real estate only)
  - `supabase/migrations/20260718000000_price_history.sql` — price_history table, original_price, smart-alert price rematch
  - `widgets/listing_video_player.dart` — Chewie player on listing detail
  - `features/listings/widgets/listing_video_upload_section.dart` — video picker on post step 4
  - `features/listings/widgets/listing_map_preview.dart` — static map thumbnail
  - `features/listings/widgets/report_sheet.dart` — report to Supabase
  - `features/listings/presentation/edit_listing_screen.dart` — single-page edit at `/listing/edit/:id`; price confirm → save → pop
  - `features/listings/widgets/edit_listing_photos_section.dart` — existing images + add new on edit
  - `features/listings/widgets/edit_listing_video_section.dart` — existing video thumbnail + replace on edit
  - `features/listings/models/edit_listing_snapshot.dart` — snapshot diff for patch save
  - `features/listings/providers/edit_listing_provider.dart` — load/save edit, image merge, video upload
  - `features/profile/presentation/seller_profile_screen.dart` — seller listings grid
  - `shared/models/report_model.dart` — report reasons + insert model
  - `core/utils/share_listing.dart` — share_plus deep link text
  - `core/utils/phone_links.dart` — WhatsApp + tel url_launcher helpers
  - `features/listings/data/listings_repository.dart` — getListingById, update, markAsSold, soft delete, report
- **Search + Filters feature** — COMPLETE
  - `shared/models/filter_model.dart` — FilterModel, FilterCondition, SearchSortBy, activeFilterCount
  - `features/listings/providers/search_provider.dart` — query, filters, suggestions, results pagination, recent searches
  - `features/listings/presentation/search_screen.dart` — Sahibinden category list + search bar; deep-tree roots → drill-down
  - `features/listings/presentation/category_browse_screen.dart` — nested category browser (`CategoryBentoGrid`, `categoryBrowseChildrenProvider`)
  - `features/listings/widgets/category_browse_list.dart` — search tab top-level categories (`CategoryBrowseList` 2-col bento grid)
  - `features/listings/widgets/category_tree_row.dart` — ORPHANED (replaced by `CategoryBentoGrid`; may be removed)
  - `features/listings/widgets/category_browse_row.dart` — ORPHANED (removed Jun 2026; unused)
  - `core/utils/category_tree.dart` — `categoryBrowseRootSlugs`, `electronicsBrandListParentSlugs`, childrenOf, subtitleForCategory, parseCategoryColor
  - `core/utils/category_navigation.dart` — routes all 8 browse-root slugs (`real_estate`, `cars`, `electronics`, `buy_sell`, `tutoring`, `jobs`, `pets`, `home_help`) to browse screen
  - `core/constants/browse_categories.dart` — static styles for top-level browse rows
  - `features/listings/presentation/search_results_screen.dart` — grid/list, sort, filter chips, pagination
  - `features/listings/widgets/filter_sheet.dart` — full filter bottom sheet with live count
  - `features/listings/widgets/listing_list_tile.dart` — list view mode tile
  - `core/utils/arabic_number.dart` — Arabic-Indic numerals for result counts
  - `core/utils/search_analytics.dart` — fire-and-forget search_logs insert
  - `supabase/migrations/20260530000007_search_logs.sql`
  - `supabase/migrations/20260602000000_real_estate_categories.sql` — full العقارات Arabic tree
  - `supabase/migrations/20260603000000_vehicles_categories.sql` — full السيارات Arabic tree
  - `supabase/migrations/20260604000000_vehicle_brands_models.sql` — car brands + models (783 rows)
  - `supabase/migrations/20260605000000_category_brand_logos.sql` — `logo_url` + listing count RPC
  - `supabase/migrations/20260615000000_minivan_brands_models.sql` — minivan brands + models under `veh_minivan`
  - `supabase/migrations/20260616000000_brand_logos_storage.sql` — public `brand-logos` Storage bucket + RLS
  - `supabase/migrations/20260617000000_commercial_brands_models.sql` — 19 commercial brands + 116 models under `veh_commercial`
  - `supabase/migrations/20260618000000_commercial_brand_logos_fix.sql` — PNG logos for commercial brands without Wikipedia SVG
  - `supabase/migrations/20260619000000_suv_pickup_brands_models.sql` — 27 SUV/pickup brands + 207 models under `veh_suv_pickup`
  - `supabase/migrations/20260620000000_marine_brands_models.sql` — 15 marine brands + 115 models under `veh_marine` (applied)
  - `supabase/migrations/20260621000000_damaged_cars_brands_models.sql` — copies veh_automobile brand/model tree → `veh_damaged` (`veh_damaged_br_*`)
  - `supabase/migrations/20260622000000_caravan_brands_models.sql` — 13 caravan/RV brands + 86 models under `veh_caravan`
  - `supabase/migrations/20260623000000_classic_brands_models.sql` — 20 classic car brands + 154 models under `veh_classic`
  - `supabase/migrations/20260624000000_classic_brand_logos_fix.sql` — PNG logos in Storage for classic brands with stale Wikipedia SVG
  - `supabase/migrations/20260625000000_aerial_brands_models.sql` — aerial: 2 types + 16 brands + 108 models under `veh_aircraft`
  - `supabase/migrations/20260626000000_remove_atv_utv_categories.sql` — remove `veh_atv` / `veh_utv` (رباعي العجلات)
  - `supabase/migrations/20260627000000_accessible_cars_brands_models.sql` — copies veh_automobile tree → `veh_accessible` (`veh_accessible_br_*`)
  - `supabase/migrations/20260628000000_electronics_brands_models.sql` — 12 subcategories + 45 brands + 266 models under `electronics` (`elec_*`; applied)
  - `supabase/migrations/20260629000000_electronics_brand_logos_fix.sql` — Storage `elec-*.svg` logos (Wikipedia SVG 404 fix)
  - `supabase/migrations/20260629000001_electronics_extra_subcategories.sql` — +6 subcategories (appliances, AC, desktops, drones, projectors, medical)
  - `supabase/migrations/20260630000000_buy_sell_marketplace_categories.sql` — rename → سوق المستعمل والجديد + 19 subcategories + 185 items (`souq_*`; applied)
  - `supabase/migrations/20260701000000_tutoring_categories.sql` — 5 branches + 64 subjects under `tutoring` (`tutor_*`; applied)
  - `supabase/migrations/20260702000000_tutoring_university_extras.sql` — +53 university subjects under `tutor_university` (applied)
  - `supabase/migrations/20260703000000_jobs_categories.sql` — 10 branches + 80 job types under `jobs` (`jobs_*`; applied)
  - `supabase/migrations/20260704000000_pets_categories.sql` — 10 branches + 89 breeds/types under `pets` (`pets_*`; applied)
  - `supabase/migrations/20260705000000_home_help_categories.sql` — 10 branches + 60 services under `home_help` (`home_*`; applied)
  - `supabase/scripts/generate_buy_sell_categories_sql.py` — regen marketplace seed migration
  - `supabase/scripts/generate_commercial_brands_sql.py` — regen commercial seed migration
  - `supabase/scripts/generate_suv_pickup_brands_sql.py` — regen SUV/pickup seed migration
  - `supabase/scripts/generate_electronics_brands_sql.py` — regen electronics seed migration
  - `supabase/scripts/generate_caravan_brands_sql.py` — regen caravan seed migration
  - `supabase/scripts/generate_classic_brands_sql.py` — regen classic cars seed migration
  - `supabase/scripts/generate_aerial_brands_sql.py` — regen aerial seed migration
  - `scripts/upload_logos.dart` — download Wikipedia SVGs → `brand-logos` → update `categories.logo_url`
  - `supabase/migrations/20260607000000_motorcycle_darajat_brands.sql` — دراجات rename + 54 brands + 483 models
  - `features/listings/widgets/vehicle_brand_logo.dart` — SVG (Supabase) + PNG (CachedNetworkImage) + letter fallback
  - `test/category_tree_test.dart`, `test/browse_categories_test.dart`
- **Chat / Messaging feature** — COMPLETE
  - `shared/models/conversation_model.dart` — full model + otherUserId getter
  - `shared/models/message_model.dart` — content, isRead, imageUrl, isMine, optimistic pending
  - `features/chat/data/chat_repository.dart` — CRUD, Realtime streams, `ConversationCreateResult`, unread count
  - `features/chat/providers/chat_provider.dart` — `startChatFromListing` auto-sends intro on new conversation
  - `features/listings/widgets/listing_detail_bottom_bar.dart` — «راسل البائع» opens listing-scoped chat
  - `features/chat/presentation/conversations_screen.dart` — inbox with active-users strip + card list + delete long-press
  - `features/chat/presentation/chat_screen.dart` — Sello redesign + pinned `ListingContextCard`
  - `features/chat/widgets/listing_context_card.dart` — listing thumbnail, title, price, إعلان badge (tap → listing)
  - `features/chat/widgets/chat_user_avatar.dart` — DiceBear avatar + green online dot
  - `features/chat/widgets/conversation_tile.dart` — DiceBear avatar, listing thumb 36×36, unread count badge
  - `features/chat/widgets/message_bubble.dart` — gradient sent / white received bubbles, image support, read receipts
  - `test/chat_screen_redesign_test.dart`, `test/listing_context_card_test.dart`
  - `features/chat/widgets/onesignal_handler.dart` — push init + player id sync + deep link
  - `core/utils/chat_date_utils.dart` — localized today/yesterday/date separators; `formatConversationTime`, `formatMessageTime`
  - `supabase/migrations/20260530000000_initial_schema.sql` + `20260530000006_chat_enhancements.sql` — conversations/messages (no duplicate migration)
  - `shared/widgets/app_bottom_nav.dart` — unread badge on رسائلي tab
- **Auth feature (Phone OTP + Google + Guest)** — COMPLETE
  - `core/supabase/supabase_client.dart` — init, `supabase`, `currentUser`, stream providers
  - `core/utils/result.dart` — `Result` / `Success` / `Failure`
  - `features/auth/data/auth_repository.dart`
  - `features/auth/domain/auth_result.dart`
  - `features/auth/providers/auth_provider.dart`
  - `features/auth/presentation/login_screen.dart` — dark canvas login (`AuthDarkHeader`), email/password fields, Google + Apple OAuth, forgot-password link
  - `features/auth/presentation/otp_screen.dart` — dark canvas WhatsApp OTP verify (`AuthDarkHeader`)
  - `features/auth/presentation/phone_screen.dart` — legacy export alias → `LoginScreen` (`/phone` redirects to `/login`)
  - `features/auth/presentation/sign_up_screen.dart` — dark canvas sign-up (`AuthDarkHeader`), flat login-style fields, @username debounced availability → profile upsert → post-auth route
  - `screens/auth/forgot_password_screen.dart` — recovery method picker + email reset flow
  - `supabase/functions/send-whatsapp-otp` — auth: Twilio Verify; profile (`purpose=profile`): 6-digit OTP → `phone_verifications` + WhatsApp message
  - `supabase/functions/verify-whatsapp-otp` — auth: Twilio Verify + session; profile: validates OTP → `profiles.phone` + `phone_verified`
  - `screens/auth/phone_verify_screen.dart` — 4-digit WhatsApp OTP verify for login (Twilio Verify)
  - `screens/auth/email_verify_screen.dart` — email OTP verify → reset password
  - `screens/auth/reset_password_screen.dart` — new password after email OTP
  - `screens/auth/widgets/phone_login_bottom_sheet.dart` — country picker + WhatsApp OTP send
  - `supabase/functions/send-whatsapp-otp/index.ts` — Twilio Verify WhatsApp send
  - `supabase/functions/verify-whatsapp-otp/index.ts` — Twilio Verify check + Supabase session mint
  - `features/auth/providers/pending_signup_provider.dart` — pre-fill profile name after OTP
  - `features/auth/widgets/auth_hero_header.dart` — wave clipper + logo welcome header
  - `features/auth/widgets/auth_form_styles.dart` — pill field/button styles (`#F4F4F4`)
  - `screens/auth/username_setup_screen.dart` — one-time @username picker after auth (skip or save)
  - `features/auth/presentation/profile_setup_screen.dart` — name, governorate, custom photo or default avatar grid
  - `core/constants/default_avatars.dart` — 6 illustrated preset avatars (emoji + gradient)
  - `shared/widgets/avatar_selection_grid.dart` — selectable preset avatar picker
  - `shared/widgets/default_avatar_widget.dart` — circular illustrated preset avatar
  - `core/utils/avatar_render_utils.dart` — renders preset avatar to PNG for Supabase upload
  - `features/auth/widgets/otp_input.dart`
  - `shared/models/profile_model.dart` — fullName, avatarUrl, isVerified, copyWith, toJson
  - `supabase/migrations/20260530000004_avatars_storage.sql`
  - Router redirect guards in `routerProvider`
- **Profile + My Listings + Settings feature** — COMPLETE
  - `shared/models/profile_stats_model.dart` — total/active listings, views, member since
  - `features/profile/data/profile_repository.dart` — getProfile, updateProfile, updateAvatar, getProfileStats, deleteAccount
  - `features/profile/providers/profile_provider.dart` — myProfile, sellerProfile, profileStats, myListings (family), profileNotifier
  - `features/profile/presentation/profile_screen.dart` — centered header card (stats: إعلان/مشاهدة/متابع), vertical menu tiles for own profile; seller listings for others
  - `features/profile/widgets/profile_menu_tile.dart` — rounded RTL menu row with icon, badge, chevron
  - `widgets/user_avatar.dart` + `widgets/avatar_picker_sheet.dart` — DiceBear illustrated avatars (`profiles.avatar_seed`)
  - `screens/settings/edit_profile_screen.dart` — RTL profile editor (DiceBear, name, locked @username, verified phone via WhatsApp OTP)
  - `screens/settings/profile_phone_otp_screen.dart` — 6-digit profile phone OTP (10:00 timer)
  - `screens/settings/widgets/edit_profile_phone_sheet.dart` — phone entry bottom sheet for profile verification
  - `features/profile/presentation/my_listings_screen.dart` — 4-tab lazy-loaded listings manager
  - `screens/settings/settings_screen.dart` — RTL settings hub (profile card, account, about, delete)
  - `screens/settings/language_screen.dart` — full-screen language picker (ar/en/ku/tr), dark Sello theme
  - `features/profile/presentation/notifications_settings_screen.dart` — push/email toggles (shared_preferences)
  - `features/profile/widgets/my_listing_tile.dart` — Field Carbon card (Volt price, status pill, circular action icons); conditional 🚀 boost
  - `features/profile/widgets/listing_boost_sheet.dart` — «ترقية إعلانك» bottom sheet; package upgrade + `is_featured`/`is_boosted` via `applyListingBoost`
  - `features/profile/utils/listing_boost_utils.dart` — eligibility + upgrade options by user/post tier
  - `features/profile/providers/user_subscription_tier_provider.dart` — infers tier from `listing_purchases`
  - `features/profile/widgets/language_sheet.dart` — dark bottom sheet locale picker (ar/en/ku/tr)
  - `features/profile/widgets/settings_tile.dart` — reusable settings row
  - `core/providers/locale_provider.dart` — `LanguageNotifier` / `localeProvider`; persists to `app_locale` (fallback `app_language`); instant RTL/LTR switch
  - `core/providers/session_reset.dart` — invalidate all user providers on logout/delete
  - `shared/widgets/webview_screen.dart` — FAQ, privacy, terms (webview_flutter)
  - `supabase/migrations/20260530000008_profile_settings.sql` — profiles.is_deleted, RLS updates
- **Favorites feature** — COMPLETE
  - `features/favorites/data/favorites_repository.dart` — getFavorites, getFavoriteIds, add/remove
  - `features/favorites/providers/favorites_provider.dart` — favoritesIdsProvider, toggleFavoriteProvider (optimistic)
  - `features/favorites/presentation/favorites_screen.dart` — grid, dismissible, pull-to-refresh, empty CTA
- **Flutter project structure** — feature-first layout (COMPLETE)
- Supabase SQL migrations + setup README
- RTL app shell + bottom navigation (`AppBottomNav` — home, search, + post, chat, profile)
- Iraqi governorates, IQD formatter, Arabic strings
- Bundle ID: `com.iraq.marketplace.souqiq`
- Unit tests (validators, currency, constants)
- `.env` Supabase config via `flutter_dotenv`

### BUG FIXES (logged)
- **Profile setup "يجب تسجيل الدخول أولاً" after OTP** — FIXED
  - Root cause: `currentUserIdProvider` cached `null` because it did not watch `authStateProvider`
  - `verifyOTP()` now waits for session (3×500ms retry)
  - `createProfile()` uses session user id explicitly with upsert
  - Profile setup reads user from `currentSession` first; auth errors redirect to `/phone`
  - Migration `20260530000005_profiles_rls_fix.sql` recreates profiles RLS policies

### PENDING
- **Localization sweep (in progress Jun 2026)** — ARB + `appLocalizationsProvider` wired; home/auth/settings/chat/profile localized; ~500 Arabic literals remain in listing forms, legal bodies, verification, domain utils
- Run migration `20260602000000_real_estate_categories.sql` in Supabase (العقارات full tree)
- Run migration `20260603000000_vehicles_categories.sql` in Supabase (السيارات full tree)
- Run migration `20260606000000_listing_type.sql` in Supabase (`listing_type` + filtered counts RPC)
- Post listing category picker: 2-level only — does not expose full category tree depth yet
- Category listings query: exact `category_id` only (no descendant aggregation)
- Run migration `20260530000008_profile_settings.sql` if not applied
- Run migration `20260530000006_chat_enhancements.sql` if not applied
- Run migration `20260530000007_search_logs.sql` if not applied
- Add `ONESIGNAL_APP_ID` to `.env` for push notifications (optional)
- App Store / Play Store release assets

### FLAGGED (post-MVP)
- Remaining UI localization (listing post/edit step forms, filter sheet, search results, heatmap, legal document bodies, auth phone-login sheet, password-reset email screen, listing detail bottom bar)
- Light/dark theme toggle (app now ships a single dark "fintech" theme; no runtime switch)
- ~~Paid/promoted listings UI (boost sheet)~~ — **COMPLETE** (Jun 2026): My Listings 🚀 boost sheet
- Seller phone reveal

---

## ADMIN DASHBOARD (Web) — COMPLETE

Separate Next.js 14 app in `admin/` (App Router, TypeScript, Tailwind, Supabase,
TanStack Table, Recharts). Connects to the **same Supabase project**.

- **Theme (Jun 2026):** Dark Sello DNA — `admin/src/lib/theme/tokens.ts` mirrors Flutter
  `AppColors` (Deep Canvas, Field Carbon, Volt Green); ThmanyahSans + Inter; pill tabs,
  status badges, Volt primary CTAs, destructive outline buttons.
- **Listings UI (Jun 2026):** Status badges + filter pills use explicit contrast colors
  (Volt/dark, sold grey, pending Field Carbon + white border); sidebar active state via
  `isNavItemActive()` (overview exact-only); header logo `admin/public/app_logo.png`;
  listing detail التحكم panel — dark select, status chips, package tier radio group.
- **Free posts quota (Jun 2026):** 2 free standard-tier listings per calendar month per user;
  `profiles.free_posts_this_month` + RPCs; 3rd+ standard post charged via `standard` purchase.
- **Listing approval fix (Jun 2026):** `20260722000000_admin_service_role_listing_guard.sql`
  — `is_privileged_backend_caller()` allows service_role through column guards; server
  actions verify persisted `status` after update and surface Supabase errors in UI.

- **URL:** `admin.souqiq.com` (Vercel). Local: `http://localhost:3000`.
- **Auth:** Supabase email/password, restricted to rows in `admin_users`
  (`admin` / `super_admin`). Guarded by `admin/src/middleware.ts` + `requireAdmin()`.
  No self-registration — admins are created manually in Supabase (see `admin/README.md`).
- **Service role:** used only in Server Components / Server Actions
  (`admin/src/lib/supabase/admin.ts`, `import "server-only"`); never shipped to client.

### Pages (`admin/src/app/dashboard/`)
- `page.tsx` — overview: 4 stat cards (+ trend vs yesterday), 30-day listings/users
  line charts, recent listings + recent pending reports.
- `listings/` — TanStack table (server-side pagination 25, sort, filters by
  status/governorate/category/date/search), bulk approve/feature/delete, CSV export;
  `[id]` detail with gallery, status select, feature/boost switches, suspend/warn/delete,
  and the listing's reports.
- `users/` — table (search name/phone, governorate/verified/date filters), verify/
  suspend/delete; `[id]` profile with stats, recent listings, reports made/received.
- `reports/` — table with expandable rows + quick actions (resolve/dismiss/delete
  listing/warn seller/suspend account), status + date filters, bulk resolve/dismiss.
  **Sidebar + topbar show a live pending-reports badge.**
- `categories/` — two-panel parent/sub manager, inline rename, add, delete (guarded),
  drag-to-reorder (`display_order`).
- `analytics/` — 7/30/90-day range: listings & users over time, listings by category &
  governorate, condition pie, top search queries, most-viewed listings.
- `settings/` — app settings, featured pricing, Arabic notification templates
  (`app_settings`), and admin management (super_admin only).

### Server actions (`admin/src/app/actions/`)
`listings.ts`, `users.ts`, `reports.ts`, `categories.ts`, `settings.ts`, `auth.ts` —
all mutations run with the service role and `revalidatePath`. Listing/user "delete" is
a soft delete (reversible), matching the mobile app lifecycle.

### Backend additions — `supabase/migrations/20260601000000_admin_dashboard.sql`
- New tables: `admin_users`, `app_settings` (seeded), `notifications`.
- New columns: `reports.status|resolved_at|resolved_by|admin_note`,
  `profiles.is_suspended|suspended_reason|suspended_at`, `categories.display_order`.
- Helpers `is_admin()` / `is_super_admin()` + RLS for the new tables.

### Legacy quick moderation (still works)
Supabase Table Editor → `listings`: set `status` = `approved`/`rejected`, optionally
`rejection_reason` + `reviewed_at = now()`.
