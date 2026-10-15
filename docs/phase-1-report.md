# Phase 1 Implementation Report — Foundation

Branch: `feature/phase-1-foundation` (from `main` @ `d42f5b0`). Nothing has
been committed yet; all changes are in the working tree for review.

## 1. Decision record

### Confirmed product decisions

| Decision | Source |
| --- | --- |
| Authentication is Supabase phone OTP only (no passwords, no password recovery). | Phase 1 brief |
| The existing Supabase database holds disposable development/test data. | Phase 1 brief |
| Separate development and production Supabase projects. | Phase 1 brief |
| Offline sync will use PowerSync Cloud (Phase 2). | Phase 1 brief |
| Customer phone numbers are optional; matching numbers produce a warning, never a rejection or a silent merge. | Phase 1 brief |
| Bottom navigation is Home, Calendar, Insights, Profile; the bell lives in the app bar. Services is reached from Profile. | Master spec §18 |

### Technical decisions made in Phase 1

| Decision | Rationale |
| --- | --- |
| Keep the single app at the repo root plus `packages/`. | Restructuring to `apps/vendor_app` costs churn with no MVP benefit. |
| Config via `--dart-define-from-file=config/<env>.json`, validated at startup by the `env` package. No defaults. | A build without its config cannot silently reach another environment. |
| Repurpose the existing `env` package instead of deleting it. `envied` removed. | Nothing in the app used it; `envied` obfuscation gave no real protection, and its staging mapping pointed at production values. Repurposing keeps the package name and gives the config logic a testable home. |
| Remove `AppFlavor` from `shared`. | It was unused, depended on `envied`, and mapped staging to production keys. |
| New `authentication_client` package (pure Dart, wraps `GoTrueClient`). | The only code that talks to Supabase Auth; maps errors to UI-safe reasons. |
| Session expiry detected through Supabase's `SignOutReason`. | Avoids string-matching errors; distinguishes user sign-out from revoked/expired refresh tokens. |
| `AppBloc` owns auth + onboarding status; `go_router` redirects are a pure function of `AppBloc.state` (`appRedirect`). | Single source of truth, unit-testable, provably loop-free (tested). |
| Onboarding is complete when a profile and a business both exist, checked on every sign-in. | Previously only the profile was checked, so a user killed between steps reached Home without a business. |
| `StatefulShellRoute.indexedStack` for the four tabs. | Each tab keeps its own stack and state. |
| The vendor profile is loaded once by the shell (`ProfileCubit`) and shared by Home and Profile. | Removes Home's direct repository call in `initState` (the root cause of the two failing tests). |
| `go_router` 18.0.2 and `bloc_concurrency` 0.3.0 added. | Latest versions compatible with Flutter 3.44.8 / Dart 3.12.2. No other dependency upgraded. |
| Dark mode forced off (`ThemeMode.light`). | Screens hard-code light colours; under a dark system theme the app rendered half dark. Re-enable once screens use theme tokens. **Behaviour change.** |

### Assumptions

- Migrations `0000`–`0002` are applied to the development database. Their
  application status could not be verified: there is no Supabase CLI link or
  `supabase/config.toml`.
- Vendor sign-in is limited to Indian mobile numbers (+91, 10 digits starting
  6–9) until a country picker exists. The existing UI only offered +91.
- Customer phone validation is lenient: optional, 7–15 digits, `+`, spaces,
  dashes and brackets allowed. A bare 10-digit Indian mobile is stored as
  `+91…`.

### Open questions (not blocking Phase 2 start)

1. Which Supabase project should staging builds use: its own project, or the
   development project?
2. SMS provider for production OTP (Twilio, MSG91, etc.) and DLT
   registration owner.

### Deferred to Phase 2 or later

See §9.

## 2. Environment configuration

Files:

| File | Committed | Purpose |
| --- | --- | --- |
| `config/development.example.json` | yes | Placeholder template |
| `config/staging.example.json` | yes | Placeholder template |
| `config/production.example.json` | yes | Placeholder template |
| `config/<env>.json` | **no** (gitignored) | Real values |

Each file contains:

```json
{
  "EVENTLY_ENV": "development",
  "SUPABASE_URL": "https://<project-ref>.supabase.co",
  "SUPABASE_PUBLISHABLE_KEY": "<publishable-key>"
}
```

Setup:

1. Copy the example: `cp config/development.example.json config/development.json`.
2. Fill in the project URL and the **publishable** key (Supabase dashboard →
   Project Settings → API Keys). Never use a secret or service-role key.
3. Run with the matching flavor, entry point and file:

   ```sh
   flutter run --flavor development -t lib/main_development.dart --dart-define-from-file=config/development.json
   flutter run --flavor staging     -t lib/main_staging.dart     --dart-define-from-file=config/staging.json
   flutter run --flavor production  -t lib/main_production.dart  --dart-define-from-file=config/production.json
   ```

   The VS Code (`.vscode/launch.json`) and IntelliJ/Android Studio
   (`.idea/runConfigurations/*.xml`) run configurations already pass these
   flags.

Startup validation (`AppConfig.fromEnvironment`) rejects:

- missing values (a build run without `--dart-define-from-file`);
- an `EVENTLY_ENV` that does not match the entry point, e.g. a production
  build given `development.json`;
- placeholder values copied from an example file;
- invalid URLs, and `http` outside development;
- `sb_secret_…` keys and legacy JWTs whose role is `service_role`.

When validation fails, the app shows a "This build is not configured" screen
listing the problems and never initializes Supabase.

Local state on this machine:

- `config/development.json` was created from the values previously
  hard-coded in `bootstrap.dart` (the existing development project). It is
  gitignored.
- No `staging.json` or `production.json` exists, so those builds stop at the
  configuration screen until the projects exist.
- The root `.env.dev` and `.env.prod` were removed from git tracking. They
  only ever contained placeholder values (`example.supabase.co`).
- The gitignored `packages/env/.env.dev` and `.env.prod` files (old `envied`
  inputs) are no longer used and can be deleted locally.
- The development **publishable** key remains in git history because it was
  hard-coded in `bootstrap.dart`. Publishable keys are designed to be public
  and are protected by Row Level Security, so rotating it is optional.

## 3. Authentication flow

```
LoginPage ── Continue ──▶ MobileNumberPage ── send OTP ok ──▶ OtpPage
                              │ failure: stays, shows reason       │
                              ▼                                    ▼ verify ok
                          (snackbar)                    Supabase session created
                                                                   │
                         AuthenticationClient.changes ◀────────────┘
                                   │
                                AppBloc ──▶ router redirect
```

- `AuthenticationClient` (`packages/authentication_client`) wraps
  `sendOtp`, `verifyOtp`, `signOut` and a `changes` stream.
- Errors become `SendOtpFailure`, `VerifyOtpFailure` or `SignOutFailure`,
  each with an `AuthFailureReason`: `invalidPhoneNumber`,
  `invalidOrExpiredCode`, `rateLimited`, `network`, `smsUnavailable` or
  `unknown`. The UI shows only fixed messages per reason
  (`lib/auth/shared/auth_failure_message.dart`). Raw backend errors are never
  shown.
- `MobileNumberCubit` validates the number and ignores repeat submits while a
  request is in flight. It navigates to OTP **only** after a successful send.
- `OtpCubit` verifies and resends. While busy it ignores repeat verify and
  resend calls. A wrong or expired code shows an inline error, clears the
  boxes and allows another attempt. Network and rate-limit failures show
  their own messages.
- After a successful verification nothing navigates directly; the auth
  stream updates `AppBloc` and the router moves on.
- **Session restoration:** Supabase restores the persisted session at
  startup, and `AppBloc` waits on the splash screen for the first auth event.
- **Session expiration:** when Supabase signs out with
  `SignOutReason.sessionExpired` or `sessionMissing`, `AppBloc` emits
  `unauthenticated` with `sessionExpired: true`, and the login screen shows
  "Your session has expired. Please sign in again." Transient refresh
  failures while offline do not sign the user out.
- **Sign-out:** Profile → Log Out → confirmation → `AppSignOutRequested`. If
  the server call fails but the local session is already cleared, the user
  is signed out anyway. If the session genuinely remains, Profile shows
  "Couldn't log out".

## 4. Routing behaviour

| `AppStatus` | Allowed locations | Everything else redirects to |
| --- | --- | --- |
| `initializing` | `/` (splash) | `/?from=<original>`; `/` for auth or onboarding paths |
| `unauthenticated` | `/login`, `/login/phone`, `/login/phone/verify` | `/login` |
| `onboardingRequired` | `/onboarding` | `/onboarding` |
| `ready` | all app routes | `/home` (or the saved `from` target) for `/`, `/login*`, `/onboarding` |
| `failure` (onboarding status unavailable) | `/` (splash with Retry / Sign out) | `/?from=<original>` |

- Deep links such as `/customers/c1` cannot bypass sign-in or onboarding.
  While the session is restoring, the target is held in `from` and resumed
  once the user is ready. Only internal paths are resumed; absolute URLs,
  `//host` and auth/onboarding paths are ignored.
- `/login/phone/verify` requires the phone number as in-memory `extra`. It is
  never put in the URL, and the route redirects to `/login/phone` without it.
- Shell tabs: `/home`, `/calendar`, `/insights`, `/profile`. Tapping the
  active tab returns to its root.
- Full-screen routes above the shell: `/notifications`, `/bookings/new`,
  `/services`, `/business/edit`, `/customers/:customerId`.
- Onboarding is a single route that renders the step `AppBloc` reports, so a
  restarted app resumes at the correct step. Back on the business step
  returns to the profile step. Back on the profile step offers sign-out
  after confirmation.
- A test verifies that no redirect loops are possible: for every state and
  location, each redirect target is accepted as-is.

## 5. Behaviour changes and honesty fixes

| Area | Before | After |
| --- | --- | --- |
| OTP send failure | Error swallowed; navigated to OTP anyway | Stays on the page; shows the reason |
| Wrong OTP | Error swallowed; popped to root silently | Inline error; code cleared; retry allowed |
| Duplicate taps | Possible double SMS / double verify | Ignored while in flight |
| Onboarding resume | Profile-only check; could land on Home without a business | Profile **and** business checked |
| Onboarding status load failure | Treated as "no profile" → onboarding form | Retry screen ("We couldn't load your account") |
| Business categories load failure | Showed "Failed to create business" (or nothing, because the failure happened before the listener subscribed) | Inline message with Retry |
| Create booking | US sample customers (`kRecentCustomers`) mixed into real data | Real customers only, with loading, empty, error and search states; marked "still being built" |
| Customer creation | Phone required; matching phone silently returned the existing customer; fell back to an all-zero business ID | Phone optional; duplicate warning lets the user pick "Use existing" or "Create new customer"; no fallback ID |
| Customer details | Fake stats and event history ("Amara & James Wedding"); fake Call/Message/Edit snackbars | Real stored fields; honest booking-history placeholder; loads by ID; not-found and error states |
| Home | Hard-coded "25%" progress; always-on red dot; Services tab; placeholder text tabs | No percentage; bell badge only when the unread count > 0 (currently 0); four-tab shell; honest "coming soon" sections |
| Calendar, Insights, Services, Notifications | "Calendar Screen" text or nothing | Explicit "coming soon" screens |
| Edit Business | Form with hard-coded categories; Save did nothing | Notice that editing is not available yet |
| Profile settings | Notifications switch that did nothing; inert Help & Support row | Removed; Services entry added |
| Logging | `print` of user IDs, DB rows and message payloads | `logE` with context only; Bloc observer logs types, not state contents |
| Login layout | Could overflow on short screens | Scrollable |
| Profile rows | Long values overflowed | Truncated with ellipsis |

## 6. Files

### Added

**Packages**

- `packages/authentication_client/` (pubspec, analysis options, `lib/`, `test/`)
- `packages/app_ui/lib/src/widgets/app_empty_state.dart`
- `packages/customer_repository/lib/src/models/customer_phone.dart`
- `packages/customer_repository/analysis_options.yaml`
- `packages/database_client/lib/src/exceptions.dart`

**App**

- `lib/app/app_dependencies.dart`
- `lib/app/bloc/app_bloc.dart`, `app_event.dart`, `app_state.dart`
- `lib/app/routing/app_router.dart`, `app_redirect.dart`, `app_routes.dart`
- `lib/app/view/app_shell.dart`, `splash_page.dart`, `config_error_app.dart`
- `lib/auth/mobile_number/cubit/mobile_number_cubit.dart`, `mobile_number_state.dart`
- `lib/auth/otp/cubit/otp_cubit.dart`, `otp_state.dart`
- `lib/auth/shared/auth_failure_message.dart`, `phone_number.dart`
- `lib/booking/create_booking/cubit/select_customer_cubit.dart`
- `lib/calendar/`, `lib/insights/`, `lib/services/`: placeholder pages and barrels
- `lib/notifications/` (bell button and notifications page)
- `lib/customers/customers.dart`
- `lib/customers/create_customer/cubit/create_customer_state.dart`
- `lib/customers/customer_details/customer_details.dart`
- `lib/customers/customer_details/cubit/customer_details_cubit.dart`
- `lib/onboarding/onboarding.dart`
- `lib/onboarding/view/onboarding_page.dart`

**Config, database and docs**

- `config/*.example.json` (3 files)
- `supabase/migrations/0004_customer_phone_optional.sql`
- `docs/phase-1-report.md`

**Tests**

- `test/app/bloc/app_bloc_test.dart`
- `test/app/routing/app_redirect_test.dart`
- `test/app/view/config_error_app_test.dart`
- `test/auth/mobile_number/cubit/mobile_number_cubit_test.dart`
- `test/auth/otp/cubit/otp_cubit_test.dart`
- `test/auth/otp/view/otp_page_test.dart`
- `test/customers/create_customer/cubit/create_customer_cubit_test.dart`
- `test/onboarding/view/onboarding_page_test.dart`
- `test/profile/view/profile_page_test.dart`
- `test/helpers/mocks.dart`

### Changed

**App**

- `lib/bootstrap.dart`, `lib/main_{development,staging,production}.dart`
- `lib/app/app.dart`, `lib/app/view/app.dart`
- `lib/auth/login/login.dart`, `lib/auth/login/view/login_page.dart`
- `lib/auth/mobile_number/view/mobile_number_page.dart`
- `lib/auth/mobile_number/widgets/mobile_number_input_field.dart`
- `lib/auth/otp/view/otp_page.dart`, `lib/auth/otp/widgets/otp_input_field.dart`
- `lib/booking/create_booking/create_booking.dart`, `view/create_booking_page.dart`
- `lib/customers/create_customer/create_customer.dart`, `cubit/create_customer_cubit.dart`
- `lib/home/view/home_page.dart`
- `lib/onboarding/business_details/**`, `lib/onboarding/user_information/**`
- `lib/profile/profile.dart`, `cubit/profile_cubit.dart`, `view/profile_page.dart`, `view/edit_business_page.dart`

**Packages**

- `packages/env/**`, `packages/shared/**`
- `packages/database_client/lib/**`
- `packages/customer_repository/**`
- `packages/business_repository/lib/src/business_repository.dart`: added
  `getBusinessIdForOwner`; removed the duplicate `createCustomer`.
- `packages/user_repository/lib/src/user_repository.dart`: doc comment only.
- `packages/app_ui/lib/src/app_ui.dart`

**Config, tooling and tests**

- `pubspec.yaml`, `pubspec.lock`, `.gitignore`, `README.md`,
  `.vscode/launch.json`, `.idea/runConfigurations/*.xml`
- All pre-existing app tests and `test/helpers/pump_app.dart` were updated
  for the new DI and routing.

### Moved

| From | To |
| --- | --- |
| `lib/customer/create_customer/view/create_customer_sheet.dart` | `lib/customers/create_customer/view/` |
| `lib/customer/customer_details/view/customer_details_page.dart` | `lib/customers/customer_details/view/` |
| `lib/customer/customer_details/view/customer_details_view.dart` | `lib/customers/customer_details/view/` |
| `test/customer/**` | `test/customers/**` |

### Removed

| File | Reason |
| --- | --- |
| `lib/customers/create_customer/view/create_customer_page.dart` | Not referenced anywhere |
| `lib/customer/` barrels | Folder merged into `lib/customers/` |
| `lib/auth/login/cubit/login_cubit.dart`, `login_state.dart` | TODO stub with no logic |
| `packages/env/lib/src/env.dev.dart`, `env.prod.dart` | `envied` sources |
| `packages/shared/lib/src/config/app_flavour.dart` and its test | See §1 |
| `.env.dev`, `.env.prod` | Untracked from git; placeholders only |

**Customer folder consolidation.** `lib/customer/` held the active sheet and
details screens. `lib/customers/` held an unused full-page form and a cubit
that wrote through `BusinessRepository` with a `+1` default country code.
`lib/customers/` is now the canonical location. The active UI was kept and
moved there, and it is now driven by cubits on `CustomerRepository`.

## 7. Database

- **Added `0004_customer_phone_optional.sql` (not applied).** It drops the
  `customers_business_id_phone_key` unique constraint from `0002`, makes
  `phone` nullable (it was `NOT NULL` in `0001`), and adds a non-unique
  `(business_id, phone)` index.
  - Until it is applied, saving a customer without a phone fails with the
    generic message.
  - Choosing "Create new customer" for a shared number shows "Another
    customer already uses this phone number."
- **`0003_encrypt_customer_phone.sql` was not applied and was not modified
  by this phase.** It is no longer present in the working tree; it was
  never committed and Phase 1 did not delete it. A copy was taken at the
  start of the phase and can be restored on request. The recommendation
  stands not to apply it (pgsodium column encryption breaks phone lookups
  and would replicate ciphertext through PowerSync).
- Migrations `0000`–`0002` were not rewritten.
- No database redesign was started (Phase 2).

## 8. Verification results

Commands run on Flutter 3.44.8 / Dart 3.12.2, Windows:

| Check | Baseline (before) | After |
| --- | --- | --- |
| `dart format lib test packages` | n/a | 178 files, 0 changed on the final run |
| `flutter analyze` (root; covers app and packages) | **96 issues** (5 warnings, 0 errors) | **0 issues** |
| `dart run bloc_tools:bloc lint .` | not captured | 0 issues |
| `flutter test` (app) | **24 passed, 2 failed** | **111 passed, 0 failed** |
| Package tests (`dart test` / `flutter test` per package) | 39 passed | **77 passed, 0 failed** |
| `dart analyze` per package | n/a | 0 issues in all 11 packages |

Package test results after Phase 1:

| Package | Tests |
| --- | --- |
| app_ui | 5 |
| authentication_client | 22 (new) |
| business_repository | 1 |
| customer_repository | 15 |
| database_client | 1 |
| env | 12 |
| firebase_notifications_client | 6 |
| notifications_client | 3 |
| notifications_repository | 8 |
| shared | 3 (4 `AppFlavor` tests removed with the class) |
| user_repository | 1 |

Where the 96 baseline issues went:

- Most were in files rewritten or removed in this phase:
  - `profile_page.dart` 14, `database_client.dart` 14
  - `create_customer_page.dart` 11 (removed)
  - `create_booking_page.dart` 9, `home_page.dart` 9, `app.dart` 8
- The rest were fixed directly: unused imports, `print`, catch clauses,
  docs, and long lines wrapped by the formatter.
- No lint rule was disabled and no `ignore` was added except one documented
  `deprecated_member_use` for an exhaustive switch over Supabase's
  `AuthChangeEvent`.

### The two known failures

Both `home_page_test` failures came from `HomePage` calling
`context.read<BusinessRepository>()` in `initState` without a provider in the
test. The app pattern is repositories at the root and cubits created from
them. Home now reads a `ProfileCubit` provided by the shell. The test
provides that cubit, and its assertions were updated to the new honest
content rather than removed. Tab-switching assertions moved to the
shell-level routing tests (`test/app/view/app_test.dart`).

### Coverage of the requested scenarios

| Scenario | Tests |
| --- | --- |
| Initial auth loading | `app_bloc_test` "starts in initializing"; `app_test` "shows the splash screen…"; `app_redirect_test` "initial authentication loading" |
| Signed-out routing | `app_test` "routes signed-out users…", "a protected deep link cannot bypass sign-in"; `app_redirect_test` "signed out" |
| Authenticated routing | `app_test` "routes onboarded users to the four-tab shell", "switching tabs keeps…", "resumes a deep link…" |
| Onboarding routing | `app_test` profile and business step tests; `onboarding_page_test`; `app_bloc_test` onboarding cases |
| OTP sending failure | `mobile_number_cubit_test`; `mobile_number_page_test` "stays on the page and shows an error…" |
| Invalid OTP feedback | `otp_cubit_test` "gives invalid OTP feedback…"; `otp_page_test` "shows feedback and clears the code…" |
| Session expiration | `authentication_client_test` "flags involuntary sign-outs…"; `app_bloc_test` "session expiration"; `app_test` "returns to sign-in with a notice…"; `login_page_test` |
| Configuration validation | `packages/env/test/src/env_test.dart` (12 tests); `config_error_app_test` |

`flutter build apk --debug --flavor development -t lib/main_development.dart
--dart-define-from-file=config/development.json` succeeded
(`app-development-debug.apk`). No manual testing on a device or emulator was
performed in this phase, and no real OTP was sent.

## 9. Remaining known issues

1. **Migration `0004` must be applied** to the development database, using
   the SQL editor or the Supabase CLI.
2. **Schema drift.** `getVendorProfileDetails` reads `businesses.location`,
   which no migration creates. The profile falls back to "Location not set".
   Resolved by the Phase 2 schema baseline.
3. **Startup needs the network.** The onboarding check reads from Supabase,
   so an offline launch shows the retry screen. The session itself survives.
   Resolved when onboarding state is read from the local database (Phase 2).
4. **Duplicate businesses are not prevented at the database level.** A
   retried onboarding request could create two; the app now picks the
   oldest instead of failing. Needs a constraint or an onboarding RPC
   (Phase 2).
5. **Duplicate-phone detection loads all of a business's customers** to
   compare normalized numbers. Acceptable at current scale; becomes an
   indexed local query in Phase 2.
6. **Vendor sign-in is +91 only.** There is no country picker.
7. **The Terms and Privacy links on the login screen are TODOs.**
8. **Screens still hard-code colours and fonts** instead of `app_ui` tokens,
   and dark mode is disabled.
9. **New user-facing strings are not in the ARB files**, matching the
   existing screens.
10. **Staging and production config files and projects do not exist yet.**
11. **Production SMS** (provider and DLT templates) is not configured in
    Supabase.
12. **Booking creation stops at customer selection.** Calendar, Insights,
    Services, Notifications and Edit Business are placeholders.
13. **`flutter pub outdated` reports newer major versions for 77
    dependencies.** None were upgraded.
14. **The CI workflow (`very_good_workflows` `flutter_package`) may enforce
    a coverage threshold.** Coverage was not measured in this phase.

## 10. Deferred to Phase 2

- Supabase CLI project link and a baseline of the live development schema.
- `organizations` / `organization_members` model, replacing `businesses`
  with `owner_id`, and membership-based Row Level Security with tests.
- Services, bookings and payments schema with same-organization composite
  foreign keys.
- PowerSync Cloud instance, sync rules, `app_database` package and Supabase
  connector with upload-error handling.
- Repositories reading the local database (offline startup, offline
  onboarding check).
- Atomic onboarding (single RPC or transaction; one organization per owner
  for the MVP).
- Normalized customer phone column and indexed duplicate lookup.
- Sync-status indicator.
