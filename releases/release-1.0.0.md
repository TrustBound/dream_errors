# dream_errors 1.0.0 Release Notes

**Release Date:** Unreleased

This is the first release of dream_errors, the shared error type of the Dream packages. Each package maps its own error to `dream_errors.Error(cause)`, and keeps its own error whole as the `cause`. An app matches on one type for every package.

## Key Highlights

- **Six shared variants**: `NotFound`, `Conflict`, `Invalid`, `Unavailable`, `Timeout` and `Failed`
- **A typed cause**: the package's own error, for logs and for exact matches
- **Four helpers**: `message`, `cause`, `map_cause` and `kind_name`
- **No dependencies** other than `gleam_stdlib`

## What's New

### The shared error type

#### The type <a href="https://github.com/TrustBound/dream_errors/blob/1.0.0/src/dream_errors.gleam#L37-L52"><img align="right" alt="Tested snippet" src="https://img.shields.io/badge/%F0%9F%A7%AA_tested-snippet-lightgreen.svg?style=flat-square"></a>

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

The `message` is text for developers and logs only. Never show it to the users of an app.

### Map a package error

A package adds a `to_error` function that maps each case of its own error to one variant:

#### Map a store error <a href="https://github.com/TrustBound/dream_errors/blob/1.0.0/test/snippets/to_error.gleam"><img align="right" alt="Tested snippet" src="https://img.shields.io/badge/%F0%9F%A7%AA_tested-snippet-lightgreen.svg?style=flat-square"></a>

```gleam
import dream_errors

/// The error of a store package.
pub type StoreError {
  KeyMissing(key: String)
  KeyTaken(key: String)
  StoreDown(reason: String)
}

/// Maps a store error to the shared error, with the store error as the cause.
pub fn to_error(error: StoreError) -> dream_errors.Error(StoreError) {
  case error {
    KeyMissing(key:) -> dream_errors.NotFound("no value for key " <> key)
    KeyTaken(key:) ->
      dream_errors.Conflict("the key " <> key <> " has a value", error)
    StoreDown(reason:) ->
      dream_errors.Unavailable("the store is down: " <> reason, error)
  }
}
```

### The helpers

- `message(error) -> String`
- `cause(error) -> Option(cause)`, `None` for `NotFound`
- `map_cause(error, fn(a) -> b) -> Error(b)`
- `kind_name(error) -> String`, for example `"not_found"`

## Testing

- 39 tests, 0 failed, 100.0% line coverage (18 of 18 lines). The run took 0.55 seconds of wall time, and the runner reports 3 ms of test time. Mode: one `gleam test` with line coverage on. Machine: Apple M1 Max, 10 cores, 64 GB, macOS 26.5.1, OTP 29, Gleam 1.19.2
- The tests also run each code block of the README, the guide and the doc comments

## Installing

```sh
gleam add dream_errors
```

## Documentation

- [dream_errors](https://hexdocs.pm/dream_errors) - v1.0.0
- [README](https://github.com/TrustBound/dream_errors/blob/main/README.md)
- [Using dream_errors](https://github.com/TrustBound/dream_errors/blob/main/docs/guides/using-dream-errors.md)
- [Changelog](https://github.com/TrustBound/dream_errors/blob/main/CHANGELOG.md)

## Community

- [Discussions](https://github.com/TrustBound/dream/discussions)
- [Report Issues](https://github.com/TrustBound/dream_errors/issues)
- [Contributing Guide](https://github.com/TrustBound/dream_errors/blob/main/CONTRIBUTING.md)
