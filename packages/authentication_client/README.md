# Authentication Client

Phone OTP authentication for Evently, backed by Supabase Auth. This is the
only package that calls Supabase Auth directly.

- `sendOtp` / `verifyOtp` / `signOut` throw `SendOtpFailure`,
  `VerifyOtpFailure` or `SignOutFailure` carrying a UI-safe
  `AuthFailureReason`; the original error is kept for diagnostics only.
- `changes` emits `Authenticated(user)` or `Unauthenticated(sessionExpired:)`.
  Session expiry is derived from Supabase's `SignOutReason`, and transient
  refresh failures (e.g. offline) are not treated as sign-outs.

Run tests with `dart test`.
