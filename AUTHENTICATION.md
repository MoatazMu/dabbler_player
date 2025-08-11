# Authentication Documentation

## Overview
Authentication in this app is managed via Supabase Auth, providing email/password, phone (OTP), and session-based authentication. The main logic is implemented in `lib/core/services/auth_service.dart`.

---

## Features
- **Email/Password Sign Up & Sign In**
- **Phone (OTP) Sign In & Verification**
- **Password Reset**
- **Session Management**
- **User Profile Fetch/Update**
- **User Existence Checks**
- **Sign Out**

---

## Main Methods

### Sign Up
```
Future<AuthResponse> signUpWithEmail({required String email, required String password})
```
Creates a new user with email and password.

### Sign In
```
Future<AuthResponse> signInWithEmail({required String email, required String password})
```
Authenticates a user with email and password.

### Phone (OTP) Sign In
```
Future<void> signInWithPhone({required String phone})
Future<AuthResponse> verifyOtp({required String phone, required String token})
```
Sends an OTP to the phone and verifies it.

### Password Reset
```
Future<void> sendPasswordResetEmail(String email)
```
Sends a password reset email.

### Session Management
- `getCurrentSession()` returns the current session.
- `isSessionExpired()` checks if the session is expired.
- `refreshSession()` refreshes the session.

### User Info
- `getCurrentUser()` returns the current user.
- `getCurrentUserId()` returns the user ID.
- `getCurrentUserEmail()` returns the user email.

### User Profile
- `getUserProfile()` fetches the user's profile from the database.
- `updateUserProfile(...)` updates the user's profile using a Supabase RPC.

### User Existence
- `checkUserExistsByEmail(String email)` checks if a user exists by email.
- `checkUserExistsByPhone(String phone)` checks if a user exists by phone.

### Sign Out
- `signOut()` signs out the current user.

---

## Usage Example
```dart
final auth = AuthService();

// Sign up
await auth.signUpWithEmail(email: 'test@example.com', password: 'password123');

// Sign in
await auth.signInWithEmail(email: 'test@example.com', password: 'password123');

// Sign out
await auth.signOut();

// Get current user
final user = auth.getCurrentUser();

// Check session
final session = auth.getCurrentSession();
final expired = auth.isSessionExpired();
```

---

## Authentication & Signup Scenarios

### 1. Email/Password Signup
- **Flow:**
  1. User enters email and password.
  2. `signUpWithEmail` is called.
  3. If successful, user receives a confirmation email (if enabled in Supabase).
  4. User must confirm email before being fully activated (if email confirmation is required).
  5. On error (e.g., email already registered), an exception is thrown.
- **Edge Cases:**
  - Email already in use: handled by Supabase, error returned.
  - Weak password: error returned.
  - Invalid email format: error returned.

### 2. Email/Password Sign In
- **Flow:**
  1. User enters email and password.
  2. `signInWithEmail` is called.
  3. If credentials are correct, user is authenticated and session is created.
  4. On error (e.g., wrong password, unconfirmed email), an exception is thrown.
- **Edge Cases:**
  - Wrong password: error returned.
  - Unconfirmed email: error returned.
  - User not found: error returned.

### 3. Phone (OTP) Sign In
- **Flow:**
  1. User enters phone number.
  2. `signInWithPhone` sends OTP to the phone.
  3. User enters OTP code.
  4. `verifyOtp` is called to verify the code.
  5. On success, user is authenticated and session is created.
  6. On error (e.g., wrong OTP, expired OTP), an exception is thrown.
- **Edge Cases:**
  - Invalid phone format: error returned.
  - Wrong OTP: error returned.
  - Expired OTP: error returned.
  - Phone already in use: error returned.

### 4. Password Reset
- **Flow:**
  1. User enters email.
  2. `sendPasswordResetEmail` is called.
  3. User receives reset email with link.
  4. User sets new password via link.
- **Edge Cases:**
  - Email not found: error returned.
  - Invalid email: error returned.

### 5. Session Management
- **Auto Sign-In:** If a valid session exists, user is auto-logged in on app start.
- **Session Expiry:** If session is expired, `isSessionExpired` returns true and user is logged out or prompted to re-authenticate.
- **Session Refresh:** `refreshSession` can be called to refresh the session token.

### 6. Sign Out
- **Flow:**
  1. User triggers sign out.
  2. `signOut` is called, session is cleared.
  3. User is redirected to login/onboarding.

### 7. User Existence Checks
- **By Email:** `checkUserExistsByEmail` returns true/false if user exists.
- **By Phone:** `checkUserExistsByPhone` returns true/false if user exists.

### 8. User Profile
- **Fetch:** `getUserProfile` fetches profile from DB.
- **Update:** `updateUserProfile` updates profile fields (name, age, gender, sports, intent).

### 9. Error Handling
- All errors are thrown as exceptions and should be caught in the UI.
- Debug logs are printed for all major actions.
- Common errors: network issues, invalid credentials, Supabase errors, session expired.

### 10. Security Notes
- Passwords are never stored locally.
- All authentication is handled via secure Supabase endpoints.
- Session tokens are managed by Supabase and stored securely.

---

For implementation details, see `lib/core/services/auth_service.dart` and this documentation.
