//// The shared error type of the Dream ecosystem.
////
//// Each Dream package maps its own error to `Error(cause)`, and keeps its
//// own error whole as the `cause`. An app then matches on one type, and a
//// log still gets the exact error of the package.
////
//// The `message` of each variant is text for developers and logs. It is
//// never text for the users of an app: it can name tables, constraints,
//// hosts and keys. Show your own text to users.
////
//// ### Map a package error <a href="https://github.com/TrustBound/dream_errors/blob/1.0.0/test/snippets/to_error.gleam"><img align="right" alt="Tested snippet" src="https://img.shields.io/badge/%F0%9F%A7%AA_tested-snippet-lightgreen.svg?style=flat-square"></a>
////
//// ```gleam
//// import dream_errors
////
//// /// The error of a store package.
//// pub type StoreError {
////   KeyMissing(key: String)
////   KeyTaken(key: String)
////   StoreDown(reason: String)
//// }
////
//// /// Maps a store error to the shared error, with the store error as the cause.
//// pub fn to_error(error: StoreError) -> dream_errors.Error(StoreError) {
////   case error {
////     KeyMissing(key:) -> dream_errors.NotFound("no value for key " <> key)
////     KeyTaken(key:) ->
////       dream_errors.Conflict("the key " <> key <> " has a value", error)
////     StoreDown(reason:) ->
////       dream_errors.Unavailable("the store is down: " <> reason, error)
////   }
//// }
//// ```

import gleam/option.{type Option, None, Some}

/// What went wrong, in terms every Dream package shares. `cause` is the
/// package's own error, kept whole for logs and for exact matches.
pub type Error(cause) {
  /// The thing asked for does not exist. Absence is a result, not a fault, so it has no cause.
  NotFound(message: String)
  /// The write clashes with existing state (unique key, existing table).
  Conflict(message: String, cause: cause)
  /// The caller's input broke a rule.
  Invalid(message: String, cause: cause)
  /// A dependency could not be reached (refused, pool empty).
  Unavailable(message: String, cause: cause)
  /// A deadline passed.
  Timeout(message: String, cause: cause)
  /// Anything else.
  Failed(message: String, cause: cause)
}

/// The message of an error: text for developers and logs, never for the
/// users of an app.
pub fn message(error: Error(cause)) -> String {
  error.message
}

/// The package's own error, or `None` for `NotFound`, which has no cause.
pub fn cause(error: Error(cause)) -> Option(cause) {
  case error {
    NotFound(..) -> None
    Conflict(cause:, ..)
    | Invalid(cause:, ..)
    | Unavailable(cause:, ..)
    | Timeout(cause:, ..)
    | Failed(cause:, ..) -> Some(cause)
  }
}

/// Changes the cause of an error with `with`, and keeps the variant and
/// the message. A `NotFound` stays the same, because it has no cause.
pub fn map_cause(error: Error(a), with: fn(a) -> b) -> Error(b) {
  case error {
    NotFound(message:) -> NotFound(message:)
    Conflict(message:, cause:) -> Conflict(message:, cause: with(cause))
    Invalid(message:, cause:) -> Invalid(message:, cause: with(cause))
    Unavailable(message:, cause:) -> Unavailable(message:, cause: with(cause))
    Timeout(message:, cause:) -> Timeout(message:, cause: with(cause))
    Failed(message:, cause:) -> Failed(message:, cause: with(cause))
  }
}

/// The name of the variant in snake case, for logs and metrics:
/// `"not_found"`, `"conflict"`, `"invalid"`, `"unavailable"`, `"timeout"`
/// or `"failed"`.
pub fn kind_name(error: Error(cause)) -> String {
  case error {
    NotFound(..) -> "not_found"
    Conflict(..) -> "conflict"
    Invalid(..) -> "invalid"
    Unavailable(..) -> "unavailable"
    Timeout(..) -> "timeout"
    Failed(..) -> "failed"
  }
}
