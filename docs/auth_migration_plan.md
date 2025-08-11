# Authentication Migration Plan

This document maps each of the 10 provided Authentication Prompts to their purpose, file targets, implementation status, and cross-cutting dependencies. It also provides a dependency graph and a recommended implementation order.

---

## Prompt Mapping Table

| # | Prompt Purpose | File Targets | Status | Cross-Cut Dependencies |
|---|----------------|-------------|--------|-----------------------|
| 1 | **Single-session enforcement:** Prevent multiple concurrent logins for a user. | `lib/core/services/auth_service.dart`, `lib/core/repository/auth_repository_impl.dart` | New | Supabase, Session management, AppRouter |
| 2 | **Email confirmation logic:** Require users to confirm their email before full access. | `lib/core/services/auth_service.dart`, `lib/screens/onboarding/email_verification_screen.dart` | Partially exists | Supabase, UI, AppRouter |
| 3 | **Auto-refresh sessions:** Automatically refresh expired sessions and handle failures. | `lib/core/services/auth_service.dart`, `lib/core/repository/auth_repository_impl.dart` | Exists, needs enhancement | Supabase, Providers |
| 4 | **Separate profiles table:** Store user profile data in a dedicated table, not in auth. | `lib/core/services/auth_service.dart`, `lib/core/repository/profile_repository_impl.dart`, `lib/models/user_profile.dart` | Exists | Supabase, Database |
| 5 | **Onboarding/profile flow:** Guide new users through profile completion after signup. | `lib/screens/onboarding/`, `lib/screens/profile/complete_profile_screen.dart`, `lib/core/services/auth_service.dart` | Partially exists | AppRouter, Providers |
| 6 | **Password reset and recovery:** Allow users to reset forgotten passwords. | `lib/core/services/auth_service.dart`, `lib/screens/onboarding/reset_password_screen.dart` | Exists | Supabase, UI |
| 7 | **Session management:** Detect expired sessions, auto sign-in, and sign out. | `lib/core/services/auth_service.dart`, `lib/core/repository/auth_repository_impl.dart` | Exists, needs review | Supabase, Providers |
| 8 | **User existence checks:** Check if a user exists by email/phone before signup. | `lib/core/services/auth_service.dart` | Exists | Supabase |
| 9 | **Comprehensive error handling:** Surface all errors to the UI and log them. | `lib/core/services/auth_service.dart`, `lib/core/config/app_initializer.dart`, `lib/utils/logger.dart` | Partially exists | UI, Logger |
| 10 | **Security and session tokens:** Ensure secure storage and handling of tokens. | `lib/core/services/auth_service.dart`, `lib/core/repository/auth_repository_impl.dart` | Exists, needs review | Supabase, Secure Storage |

---

## Dependency Graph

- **auth_service.dart**: Central for all auth logic; depends on Supabase, session, and profile repositories.
- **auth_repository_impl.dart**: Implements repository pattern; depends on `auth_service.dart`, environment, and routing.
- **profile_repository_impl.dart**: Handles profile CRUD; depends on Supabase and user models.
- **app_initializer.dart**: Handles global error handling and logging; depends on logger and environment.
- **UI screens**: Depend on auth/profile services and AppRouter for navigation.
- **Logger**: Used by all services for error reporting.
- **Providers**: Used for state management and dependency injection.

---

## Prioritized Implementation Order

1. **Session & Token Security** (Prompt 10):
   - Review and secure token storage and session handling.
2. **Single-Session Enforcement** (Prompt 1):
   - Implement logic to prevent concurrent logins.
3. **Email Confirmation Logic** (Prompt 2):
   - Ensure email confirmation is required and surfaced in UI.
4. **Auto-Refresh Sessions** (Prompt 3):
   - Enhance session refresh and expiry handling.
5. **Comprehensive Error Handling** (Prompt 9):
   - Ensure all errors are logged and surfaced to the UI.
6. **Onboarding/Profile Flow** (Prompt 5):
   - Guide users through profile completion after signup.
7. **User Existence Checks** (Prompt 8):
   - Ensure checks before signup for both email and phone.
8. **Password Reset & Recovery** (Prompt 6):
   - Review and enhance password reset flows.
9. **Session Management** (Prompt 7):
   - Review auto sign-in, sign out, and session expiry logic.
10. **Profiles Table Separation** (Prompt 4):
    - Ensure all profile data is in a dedicated table, not in auth.

---

## Recommended Cursor Task-Run Order

1. Secure session/token storage and review `auth_service.dart` (Prompt 10)
2. Implement single-session logic in `auth_service.dart` and `auth_repository_impl.dart` (Prompt 1)
3. Add/verify email confirmation logic in `auth_service.dart` and onboarding UI (Prompt 2)
4. Enhance session auto-refresh in `auth_service.dart` (Prompt 3)
5. Add/verify error handling and logging in all services (Prompt 9)
6. Implement onboarding/profile completion flow (Prompt 5)
7. Ensure user existence checks before signup (Prompt 8)
8. Review password reset and recovery flows (Prompt 6)
9. Review session management and auto sign-in (Prompt 7)
10. Confirm all profile data is separated from auth (Prompt 4)

---

## Architecture Enhancements

- **Layered Structure:**
  - **Domain Layer:** Place business logic, entities, and use cases in `lib/domain/auth/` and `lib/domain/profile/`.
  - **Data Layer:** Place repositories, data sources, and DTOs in `lib/data/auth/` and `lib/data/profile/`.
  - **Services Layer:** Place Supabase and cache services in `lib/core/services/`.
  - **Presentation Layer:** Place UI, state management, and navigation in `lib/screens/` and `lib/widgets/`.
  - **Dependency Injection:** Use a provider (e.g., Riverpod/GetIt) for wiring dependencies.

- **Single-Session Enforcement:**
  - Store the latest valid refresh token in the database (profiles table or a dedicated sessions table).
  - On login, compare the device's token with the server's; if mismatched, force logout on other devices.
  - Invalidate old sessions by revoking tokens or updating a `session_valid` flag in the backend.

- **Automatic Session Refresh:**
  - Call `refreshSession` on:
    - App start (before showing main UI)
    - App resume (foreground event)
    - Before any API call if session is near expiry (e.g., <5 min left)
  - Use a session manager/provider to orchestrate refresh and propagate state to the UI.

- **Profile Caching & Offline:**
  - Cache user profile locally (e.g., SharedPreferences or local DB).
  - On app start, load cached profile and update in background if online.
  - Provide fallback UI for offline profile access and sync changes when reconnected.

- **Error Handling Strategy:**
  - Convert exceptions in services to domain-specific `Failure` objects (e.g., `AuthFailure`, `NetworkFailure`).
  - Map failures to user-friendly error messages in the presentation layer.
  - Log all errors centrally (e.g., in `Logger` or a crash reporting service).
  - Use Result/Either types in domain/data layers for testability and composability.

---

## Breaking-Change Risks & Mitigations

- **Session Invalidation:**
  - Risk: Users may be logged out unexpectedly if session logic is incorrect.
  - Mitigation: Roll out to a test group, provide clear UI messaging, and allow re-authentication.

- **Profile Data Migration:**
  - Risk: Moving to a separate profiles table may orphan or lose user data.
  - Mitigation: Write migration scripts, backup data, and verify integrity post-migration.

- **Token Storage Changes:**
  - Risk: Changing token storage may break auto-login or session refresh.
  - Mitigation: Version token storage logic, provide fallback to re-login, and test across devices.

- **Error Handling Refactor:**
  - Risk: New error mapping may surface unhandled cases or break flows.
  - Mitigation: Add comprehensive tests, log all failures, and monitor crash reports after release.

- **API Contract Changes:**
  - Risk: Backend changes for session enforcement or profile may break existing clients.
  - Mitigation: Use feature flags, maintain backward compatibility, and coordinate backend/frontend releases.
