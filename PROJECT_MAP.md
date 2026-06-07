# PROJECT_MAP — سوق العراق (Souq IQ)

Living architecture document for the Iraq Classifieds Marketplace.  
**Status:** MVP implemented — structure COMPLETE — May 2026  
**Bundle ID:** `com.iraq.marketplace.souqiq`

---

## PRODUCT

| Field | Value |
|---|---|
| **App name (AR)** | سوق العراق |
| **App name (EN)** | Souq IQ |
| **Target** | Android & iOS |
| **Locale** | Arabic RTL (`ar_IQ`) |
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
| Maps / location | google_maps_flutter, geolocator | latest (ready for geo listings) |
| UI polish | shimmer, timeago, url_launcher | latest |
| Config | flutter_dotenv | `.env` |
| Testing | flutter_test, mocktail | SDK + `^1.0.5` |

### Config (`.env` for local dev)
```bash
flutter run
```

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
│   │   ├── app_theme.dart
│   │   └── text_styles.dart
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
    │   └── app_bottom_nav.dart        # bottom nav + FAB
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
**Category drill-down:** tap العقارات or السيارات → `CategoryBrowseScreen` (`/categories/:id`) → nested branches → leaf → `ListingsScreen`. Children loaded via `fetchChildren(parent_id)` (not in-memory tree only); `fetchAll()` paginates past PostgREST 1000-row cap.

### Auth
PhoneScreen → OTP (+964) → ProfileSetupScreen (if new) → Home

### Post listing (auth) — COMPLETE
BottomNav "+" → `PostListingScreen` (5 steps) → compress + upload images → INSERT `listings` + `listing_images` (status=`pending`) → `ListingDetailScreen`

Steps: category → details → location (+ optional map pin) → photos (reorder, max 10) → review & publish / save draft

### Favorites (auth) — COMPLETE
ListingDetail ♥ → optimistic toggle → FavoritesScreen (grid, swipe-to-remove, pull-to-refresh)

### Profile + My Listings + Settings (auth) — COMPLETE
BottomNav "حسابي" → ProfileScreen (own/other user) → edit / my listings / settings / logout  
"إعلاناتي" → MyListingsScreen (4 tabs: active/pending/sold/deleted) → edit/sold/delete/restore/repost  
"الإعدادات" → SettingsScreen → language / notifications / about / logout / delete account

### Chat (auth) — COMPLETE
ListingDetail "تواصل" → `getOrCreateConversation` (dedupe by listing+buyer+seller) → `ChatScreen` → Supabase Realtime streams → unread badge on bottom nav

Push: OneSignal (optional `ONESIGNAL_APP_ID` in `.env`) saves `onesignal_player_id` to profiles

---

## DATA MODEL

See Supabase migrations (… `20260605000000_category_brand_logos`, `20260606000000_listing_type`). Tables: `profiles`, `categories` (`logo_url`), `listings` (`listing_type`: `sale`|`rent`), …

**Categories:** `categories.color_hex` (level-1 branch accent). **العقارات** (`real_estate`) — 6 level-1 + ~61 descendants (`re_*`). **السيارات** (`cars`) — 13 level-1 branches (`veh_*`) + **783 brand/model nodes** under سيارات / SUV / electric / commercial (`veh_auto_br_*`, icon `brand`/`model`). **سيارات تالفة** (`veh_damaged`) — mirror of سيارات tree (`veh_damaged_br_*`, re-synced from `veh_automobile`). **سيارات ذوي الاحتياجات الخاصة** (`veh_accessible`) — mirror of سيارات tree (`veh_accessible_br_*`). **مركبات بحرية** (`veh_marine`) — **15 brands + 115 models** (`veh_marine_br_*`; jet skis, outboards, fishing boats, traditional Iraqi boats). **كرفان** (`veh_caravan`) — **13 brands + 86 models** (`veh_caravan_br_*`; RVs, European caravans, local builds). **سيارات كلاسيكية** (`veh_classic`) — **20 brands + 154 models** (`veh_classic_br_*`; W123, Mustang, Land Cruiser FJ40, Opel Rekord, etc.). **مركبات جوية** (`veh_aircraft`) — **طائرات + مروحيات** → 16 brands + 108 models (`veh_aircraft_planes_*`, `veh_aircraft_helicopters_*`). **الإلكترونيات** (`electronics`) — **18 subcategories + 83 brands + 486 models/items** (`elec_*`; smartphones through medical devices; brand logos in Storage `elec-*.svg`). **سوق المستعمل والجديد** (`buy_sell`) — **19 subcategories + 185 listing types** (`souq_*`; phones, fashion, furniture, food, etc.). **دراجات** (`veh_motorcycle`) — **537 brand/model nodes** directly under دراجات (`veh_moto_br_*`, motorcycle logos from carlogos.org). Re-run safe via `ON CONFLICT (slug)`.

Listing moderation: `status` = `pending` | `approved` | `rejected`  
Lifecycle: `availability` = `active` | `sold` | `deleted`

---

## FEATURE STATUS

### COMPLETED
- **Home feature** — COMPLETE
  - `shared/models/category_model.dart` — id, nameAr/Ku/En, icon, parentId, displayName()
  - `shared/models/listing_model.dart` — ListingModel, FilterModel, images, formattedPrice, timeAgo
  - `features/listings/data/listings_repository.dart` — featured, recent, by category, search
  - `features/listings/data/categories_repository.dart` — paginated fetchAll, fetchChildren (parent_id), fetchBySlug
  - `features/home/providers/home_provider.dart` — categories, featured, recent, favorites toggle
  - `features/home/widgets/category_grid.dart` — horizontal chips with shimmer
  - `features/home/widgets/listing_card.dart` — card with badges, favorite, optimistic toggle
  - `features/home/widgets/featured_banner.dart` — PageView auto-scroll banner
  - `features/home/presentation/home_screen.dart` — sliver layout, pull-to-refresh
  - `features/listings/presentation/listings_screen.dart` — category-filtered grid
  - `shared/widgets/shimmer_loading.dart` — shimmer placeholders
  - `core/utils/currency_formatter.dart` — formatIQD()
  - `shared/widgets/app_bottom_nav.dart` — 5-tab docked FAB nav
- **Post a Listing feature** — COMPLETE
  - `features/listings/providers/post_listing_provider.dart` — 5-step state, validation, upload, publish, draft
  - `features/listings/presentation/post_listing_screen.dart` — step indicator, AnimatedSwitcher, nav buttons
  - `features/listings/widgets/steps/step1_category.dart` — parent grid + subcategory chips
  - `features/listings/widgets/steps/step2_details.dart` — title, description, price, condition
  - `features/listings/widgets/steps/step3_location.dart` — governorate, city, map picker
  - `features/listings/widgets/steps/step4_photos.dart` — photo grid step
  - `features/listings/widgets/steps/step5_review.dart` — preview card, edit jumps, publish overlay
  - `features/listings/widgets/map_picker_sheet.dart` — GoogleMap + geolocator (Iraq bounds)
  - `features/listings/widgets/image_picker_grid.dart` — reorderable grid, compression on add
  - `core/utils/image_compression.dart` — flutter_image_compress (max 1MB, 1200px)
  - `features/listings/data/listings_repository.dart` — uploadListingImage, createListingRecord, saveDraft
- **Listing Detail feature** — COMPLETE
  - `features/listings/providers/listing_detail_provider.dart` — detail, isOwner, seller listings, actions
  - `features/listings/presentation/listing_detail_screen.dart` — sliver gallery, sections, bottom bar
  - `features/listings/widgets/listing_detail_gallery.dart` — PageView + photo_view pinch zoom
  - `features/listings/widgets/listing_detail_bottom_bar.dart` — buyer (WhatsApp/call/chat) + owner actions
  - `features/listings/widgets/listing_map_preview.dart` — static map thumbnail
  - `features/listings/widgets/report_sheet.dart` — report to Supabase
  - `features/listings/presentation/edit_listing_screen.dart` — multi-step edit flow
  - `features/listings/widgets/edit_step4_photos.dart` — existing URL images + new uploads
  - `features/listings/providers/edit_listing_provider.dart` — load/save edit, image merge
  - `features/profile/presentation/seller_profile_screen.dart` — seller listings grid
  - `shared/models/report_model.dart` — report reasons + insert model
  - `core/utils/share_listing.dart` — share_plus deep link text
  - `core/utils/phone_links.dart` — WhatsApp + tel url_launcher helpers
  - `features/listings/data/listings_repository.dart` — getListingById, update, markAsSold, soft delete, report
- **Search + Filters feature** — COMPLETE
  - `shared/models/filter_model.dart` — FilterModel, FilterCondition, SearchSortBy, activeFilterCount
  - `features/listings/providers/search_provider.dart` — query, filters, suggestions, results pagination, recent searches
  - `features/listings/presentation/search_screen.dart` — Sahibinden category list + search bar; deep-tree roots → drill-down
  - `features/listings/presentation/category_browse_screen.dart` — nested category tree browser (`categoryBrowseChildrenProvider`)
  - `features/listings/widgets/category_tree_row.dart` — 72px text-only row (RTL name + chevron; `VehicleBrandLogo` for vehicle/electronics brands only)
  - `features/listings/widgets/category_browse_row.dart` — search tab top-level browse row (48px colored icon circle + text + chevron)
  - `core/utils/category_tree.dart` — `categoryBrowseRootSlugs`, `electronicsBrandListParentSlugs`, childrenOf, subtitleForCategory, parseCategoryColor
  - `core/utils/category_navigation.dart` — routes `real_estate` / `cars` / `electronics` / `buy_sell` slugs to browse screen
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
  - `shared/models/message_model.dart` — content, isRead, isMine, optimistic pending
  - `features/chat/data/chat_repository.dart` — CRUD, Realtime streams, unread count, OneSignal player id
  - `features/chat/providers/chat_provider.dart` — conversationsStream, messagesStream, unreadCount, chatNotifier
  - `features/chat/presentation/conversations_screen.dart` — inbox + empty state + delete long-press
  - `features/chat/presentation/chat_screen.dart` — bubbles, date separators, input bar, reconnect banner
  - `features/chat/widgets/conversation_tile.dart` — avatar, preview, unread badge, listing thumb
  - `features/chat/widgets/message_bubble.dart` — grouped bubbles, read receipts
  - `features/chat/widgets/onesignal_handler.dart` — push init + player id sync + deep link
  - `core/utils/chat_date_utils.dart` — اليوم / أمس / Arabic date separators
  - `supabase/migrations/20260530000006_chat_enhancements.sql` — last_message, delete policy, onesignal_player_id
  - `shared/widgets/app_bottom_nav.dart` — unread badge on رسائلي tab
- **Auth feature (Phone OTP + Google + Guest)** — COMPLETE
  - `core/supabase/supabase_client.dart` — init, `supabase`, `currentUser`, stream providers
  - `core/utils/result.dart` — `Result` / `Success` / `Failure`
  - `features/auth/data/auth_repository.dart`
  - `features/auth/domain/auth_result.dart`
  - `features/auth/providers/auth_provider.dart`
  - `features/auth/presentation/phone_screen.dart`
  - `features/auth/presentation/otp_screen.dart`
  - `features/auth/presentation/profile_setup_screen.dart`
  - `features/auth/widgets/otp_input.dart`
  - `shared/models/profile_model.dart` — fullName, avatarUrl, isVerified, copyWith, toJson
  - `supabase/migrations/20260530000004_avatars_storage.sql`
  - Router redirect guards in `routerProvider`
- **Profile + My Listings + Settings feature** — COMPLETE
  - `shared/models/profile_stats_model.dart` — total/active listings, views, member since
  - `features/profile/data/profile_repository.dart` — getProfile, updateProfile, updateAvatar, getProfileStats, deleteAccount
  - `features/profile/providers/profile_provider.dart` — myProfile, sellerProfile, profileStats, myListings (family), profileNotifier
  - `features/profile/presentation/profile_screen.dart` — unified own/other profile, stats, listings grid, quick actions
  - `features/profile/presentation/edit_profile_screen.dart` — avatar upload, name/governorate/city edit
  - `features/profile/presentation/my_listings_screen.dart` — 4-tab lazy-loaded listings manager
  - `features/profile/presentation/settings_screen.dart` — account, support, version, logout, delete account
  - `features/profile/presentation/notifications_settings_screen.dart` — push/email toggles (shared_preferences)
  - `features/profile/widgets/my_listing_tile.dart` — image, status chip, edit/sold/delete/restore/repost actions
  - `features/profile/widgets/language_sheet.dart` — Arabic / Kurdish / English locale picker
  - `features/profile/widgets/settings_tile.dart` — reusable settings row
  - `core/providers/locale_provider.dart` — persisted locale, instant RTL/LTR switch
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
- Full Kurdish/English UI translations (locale switch works; strings remain Arabic)
- Dark mode theme
- Paid/promoted listings UI (boost sheet)
- Seller phone reveal

---

## ADMIN DASHBOARD (Web) — COMPLETE

Separate Next.js 14 app in `admin/` (App Router, TypeScript, Tailwind, Supabase,
TanStack Table, Recharts). Connects to the **same Supabase project**.

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
