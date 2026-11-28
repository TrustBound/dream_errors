# Changelog

All notable changes to `dream_errors` will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - Unreleased

### Added
- `dream_errors.Error(cause)`, the shared error type of the Dream
  packages, with seven variants: `NotFound(message)`,
  `Retry(message, cause, after_seconds)`, `Conflict(message, cause)`,
  `Invalid(message, cause)`, `Unavailable(message, cause)`,
  `Timeout(message, cause)` and `Failed(message, cause)`. The `cause` is
  the package's own error. `NotFound` has no cause, because absence is a
  result, not a fault. `after_seconds` is `Some(n)` when the source knows
  the delay before the next try, else `None`.
- `message(error)`: the message, text for developers and logs only.
- `cause(error)`: `Some(cause)`, or `None` for `NotFound`.
- `map_cause(error, with)`: changes the cause, and keeps the variant,
  the message and the `after_seconds` of a `Retry`.
- `kind_name(error)`: the variant in snake case, for example
  `"not_found"`.
- The guide "Using dream_errors".

### Testing
- 44 tests, 0 failed, 100.0% line coverage (20 of 20 lines). The run took 0.58 seconds of wall time, and the runner reports 5 ms of test time. Mode: one `gleam test` with line coverage on. Machine: Apple M1 Max, 10 cores, 64 GB, macOS 26.5.1, OTP 29, Gleam 1.19.2.
