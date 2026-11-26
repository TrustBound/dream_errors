# Using dream_errors

`dream_errors.Error(cause)` is the shared error type of the Dream packages. Each package maps its own error to it, and keeps its own error as the `cause`. This guide tells what each variant means, how a package maps its error, and how an app uses it.

## The shared error type <a href="https://github.com/TrustBound/dream_errors/blob/1.0.0/src/dream_errors.gleam#L35-L50"><img align="right" alt="Tested snippet" src="https://img.shields.io/badge/%F0%9F%A7%AA_tested-snippet-lightgreen.svg?style=flat-square"></a>

```gleam
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
```

## What each variant means

| Variant | Meaning | A package uses it when | Cause |
| --- | --- | --- | --- |
| `NotFound` | The thing asked for does not exist. | A query finds no row, a key has no value, a server answers 404. | None. Absence is a result, not a fault. |
| `Conflict` | The write clashes with existing state. | A unique key is taken, a table exists already, a version check fails. | The error of the package. |
| `Invalid` | The input of the caller broke a rule. | A value is out of range, a check constraint fails, a request is malformed. | The error of the package. |
| `Unavailable` | A dependency could not be reached. | A connection is refused, the pool is empty, a host does not resolve. | The error of the package. |
| `Timeout` | A deadline passed. | A query, a request or a checkout takes longer than its limit. | The error of the package. |
| `Failed` | Anything else. | Every other failure, for example a syntax error or a decode error. | The error of the package. |

Pick the first variant in the table that is true. When no other variant is true, use `Failed`. Do not use `Failed` for a case that another variant names, because an app then cannot tell the cases apart.

## The message is not for users

The `message` is text for developers and logs only. It can name tables, constraints, columns, hosts and keys, and it can hold parts of the input. Never show it to the users of an app, and never put it in an HTTP response. Show your own text to users.

`message` and `kind_name` give one log line:

### Write a log line <a href="https://github.com/TrustBound/dream_errors/blob/1.0.0/test/snippets/log_line.gleam"><img align="right" alt="Tested snippet" src="https://img.shields.io/badge/%F0%9F%A7%AA_tested-snippet-lightgreen.svg?style=flat-square"></a>

```gleam
import dream_errors.{type Error, kind_name, message}

/// One log line for an error, for developers.
pub fn log_line(error: Error(cause)) -> String {
  kind_name(error) <> ": " <> message(error)
}
```

For `Unavailable("connection refused", cause)`, the line is `unavailable: connection refused`.

## Map a package error

A package that returns `dream_errors.Error` keeps its own error type, and adds a `to_error` function that maps it. Each case of its error goes to one variant. The package puts its own error in whole as the `cause`, so a log and an exact match still have it.

### Map a package error <a href="https://github.com/TrustBound/dream_errors/blob/1.0.0/test/snippets/to_error.gleam"><img align="right" alt="Tested snippet" src="https://img.shields.io/badge/%F0%9F%A7%AA_tested-snippet-lightgreen.svg?style=flat-square"></a>

```gleam
import dream_errors.{type Error, Conflict, NotFound, Unavailable}

/// The error of a store package.
pub type StoreError {
  KeyMissing(key: String)
  KeyTaken(key: String)
  StoreDown(reason: String)
}

/// Maps a store error to the shared error, with the store error as the cause.
pub fn to_error(error: StoreError) -> Error(StoreError) {
  case error {
    KeyMissing(key:) -> NotFound("no value for key " <> key)
    KeyTaken(key:) -> Conflict("the key " <> key <> " has a value", error)
    StoreDown(reason:) -> Unavailable("the store is down: " <> reason, error)
  }
}
```

`NotFound` takes no cause. A missing key is a result that the caller asked about, not a fault of the store.

## Put the errors of two packages in one type

The `cause` of a store error is a `StoreError`, and the `cause` of another package is its own type. When one function of an app calls both packages, give the app one cause type with a variant for each package. `map_cause` changes the cause, and keeps the variant and the message:

### Put a store error into the app error <a href="https://github.com/TrustBound/dream_errors/blob/1.0.0/test/snippets/map_cause.gleam"><img align="right" alt="Tested snippet" src="https://img.shields.io/badge/%F0%9F%A7%AA_tested-snippet-lightgreen.svg?style=flat-square"></a>

```gleam
import dream_errors.{type Error, map_cause}
import snippets/to_error.{type StoreError}

/// The causes of the app: one variant for each package that the app uses.
pub type AppCause {
  Store(StoreError)
  Search(String)
}

/// Puts a store error into the error type of the app.
pub fn from_store(error: Error(StoreError)) -> Error(AppCause) {
  map_cause(error, Store)
}
```

`map_cause` gives a `NotFound` back with no change, because it has no cause. `cause` gives `None` for a `NotFound`, and `Some(cause)` for every other variant.

## Match on the error in an app

Match on the variant to pick what the app does. The app writes its own text for the user:

### Answer with a status and your own text <a href="https://github.com/TrustBound/dream_errors/blob/1.0.0/test/snippets/answer.gleam"><img align="right" alt="Tested snippet" src="https://img.shields.io/badge/%F0%9F%A7%AA_tested-snippet-lightgreen.svg?style=flat-square"></a>

```gleam
import dream_errors.{
  type Error, Conflict, Failed, Invalid, NotFound, Timeout, Unavailable,
}

/// The status code and the text that an app shows for a shared error.
/// The text is the app's own text, never the message of the error.
pub fn answer(error: Error(cause)) -> #(Int, String) {
  case error {
    NotFound(..) -> #(404, "We could not find that.")
    Conflict(..) -> #(409, "That exists already.")
    Invalid(..) -> #(400, "Please check your input.")
    Unavailable(..) | Timeout(..) -> #(503, "Please try again soon.")
    Failed(..) -> #(500, "Something went wrong.")
  }
}
```

Match on the `cause` only when the app must tell one exact case apart, for example one key of the store:

### Match one exact cause <a href="https://github.com/TrustBound/dream_errors/blob/1.0.0/test/snippets/exact_cause.gleam"><img align="right" alt="Tested snippet" src="https://img.shields.io/badge/%F0%9F%A7%AA_tested-snippet-lightgreen.svg?style=flat-square"></a>

```gleam
import dream_errors.{type Error, Conflict}
import snippets/to_error.{type StoreError, KeyTaken}

/// Whether an error is the clash of one exact key of the store.
pub fn is_taken(error: Error(StoreError), key: String) -> Bool {
  case error {
    Conflict(cause: KeyTaken(key: taken), ..) -> taken == key
    _ -> False
  }
}
```

## The HTTP status in Dream

Dream 3.0.0 has `error.from_shared`. It gives the HTTP status of a `dream_errors.Error`, so a Dream controller needs no status table of its own. See the Dream 3.0.0 docs for the status of each variant.
