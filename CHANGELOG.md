# Changelog

All notable changes to `dream_errors` will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - Unreleased

### Added
- `dream_errors.Error(cause)`, the shared error type of the Dream
  packages, with six variants: `NotFound(message)`,
  `Conflict(message, cause)`, `Invalid(message, cause)`,
  `Unavailable(message, cause)`, `Timeout(message, cause)` and
  `Failed(message, cause)`. The `cause` is the package's own error.
  `NotFound` has no cause, because absence is a result, not a fault.
- `message(error)`: the message, text for developers and logs only.
- `cause(error)`: `Some(cause)`, or `None` for `NotFound`.
- `map_cause(error, with)`: changes the cause, and keeps the variant and
  the message.
- `kind_name(error)`: the variant in snake case, for example
  `"not_found"`.
- The guide "Using dream_errors".

### Testing
- 39 tests, 0 failed, 100.0% line coverage (18 of 18 lines). The run took 0.55 seconds of wall time, and the runner reports 3 ms of test time. Mode: one `gleam test` with line coverage on. Machine: Apple M1 Max, 10 cores, 64 GB, macOS 26.5.1, OTP 29, Gleam 1.19.2.
