<div align="center">
  <img src="https://raw.githubusercontent.com/TrustBound/dream/main/ricky_and_lucy.png" alt="Ricky Moony and Lucy, a moon shaped mascot for Dream with the star shaped mascot for Gleam, each with cute cartoon eyes and a smile" width="200">

<b>The shared error type of the Dream ecosystem</b>

</div>

<br />

<div align="center">
  <a href="https://hex.pm/packages/dream_errors"><img src="https://img.shields.io/hexpm/v/dream_errors" alt="Hex Package"></a>
  <a href="https://github.com/TrustBound/dream_errors/releases"><img src="https://img.shields.io/github/v/release/TrustBound/dream_errors?label=Release" alt="Latest Release"></a>
  <a href="https://hexdocs.pm/dream_errors"><img src="https://img.shields.io/badge/hex-docs-lightgreen.svg" alt="HexDocs"></a>
  <a href="https://github.com/TrustBound/dream_errors/actions/workflows/ci.yml?query=branch%3Amain"><img src="https://img.shields.io/endpoint?url=https://raw.githubusercontent.com/TrustBound/dream_errors/badges/coverage.json" alt="Coverage"></a>
  <a href="https://github.com/TrustBound/dream_errors/blob/main/LICENSE"><img src="https://img.shields.io/badge/license-MIT-blue.svg" alt="MIT License"></a>
  <a href="https://gleam.run"><img src="https://img.shields.io/badge/gleam-%E2%9C%A8-ffaff3" alt="Gleam"></a>
</div>

<br />

# dream_errors

dream_errors is the shared error type of the [Dream](https://github.com/TrustBound/dream) packages. Each package, for example dream_postgres, dream_ets, dream_http_client and dream_opensearch, maps its own error to `dream_errors.Error(cause)`. The package keeps its own error whole as the `cause`. Your app matches on one type for every package, and your logs still get the exact error.

dream_errors depends only on the Gleam standard library.

## Features

- ✅ Six variants that every package shares: `NotFound`, `Conflict`, `Invalid`, `Unavailable`, `Timeout` and `Failed`
- ✅ The package's own error as a typed `cause`, for logs and for exact matches
- ✅ `message`, `cause`, `map_cause` and `kind_name`
- ✅ No dependencies other than `gleam_stdlib`

## Installation

```sh
gleam add dream_errors
```

## Quick Start

The type:

### The shared error type <a href="https://github.com/TrustBound/dream_errors/blob/1.0.0/src/dream_errors.gleam#L37-L52"><img align="right" alt="Tested snippet" src="https://img.shields.io/badge/%F0%9F%A7%AA_tested-snippet-lightgreen.svg?style=flat-square"></a> <a href="https://github.com/TrustBound/dream_errors/blob/1.0.0/docs/guides/using-dream-errors.md#the-shared-error-type-"><img align="right" alt="Guide: Using dream_errors" title="Guide: Using dream_errors" src="https://img.shields.io/badge/%F0%9F%93%96_read-guide-blue.svg?style=flat-square"></a>

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

The `message` is text for developers and logs. Never show it to the users of your app: it can name tables, constraints, hosts and keys.

A package maps its own error with a `to_error` function:

### Map a package error <a href="https://github.com/TrustBound/dream_errors/blob/1.0.0/test/snippets/to_error.gleam"><img align="right" alt="Tested snippet" src="https://img.shields.io/badge/%F0%9F%A7%AA_tested-snippet-lightgreen.svg?style=flat-square"></a> <a href="https://github.com/TrustBound/dream_errors/blob/1.0.0/docs/guides/using-dream-errors.md#map-a-package-error-"><img align="right" alt="Guide: Using dream_errors" title="Guide: Using dream_errors" src="https://img.shields.io/badge/%F0%9F%93%96_read-guide-blue.svg?style=flat-square"></a>

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

An app matches on the variant, and shows its own text:

### Answer with a status and your own text <a href="https://github.com/TrustBound/dream_errors/blob/1.0.0/test/snippets/answer.gleam"><img align="right" alt="Tested snippet" src="https://img.shields.io/badge/%F0%9F%A7%AA_tested-snippet-lightgreen.svg?style=flat-square"></a> <a href="https://github.com/TrustBound/dream_errors/blob/1.0.0/docs/guides/using-dream-errors.md#answer-with-a-status-and-your-own-text-"><img align="right" alt="Guide: Using dream_errors" title="Guide: Using dream_errors" src="https://img.shields.io/badge/%F0%9F%93%96_read-guide-blue.svg?style=flat-square"></a>

```gleam
import dream_errors

/// The status code and the text that an app shows for a shared error.
/// The text is the app's own text, never the message of the error.
pub fn answer(error: dream_errors.Error(cause)) -> #(Int, String) {
  case error {
    dream_errors.NotFound(..) -> #(404, "We could not find that.")
    dream_errors.Conflict(..) -> #(409, "That exists already.")
    dream_errors.Invalid(..) -> #(400, "Please check your input.")
    dream_errors.Unavailable(..) | dream_errors.Timeout(..) -> #(
      503,
      "Please try again soon.",
    )
    dream_errors.Failed(..) -> #(500, "Something went wrong.")
  }
}
```

In a Dream app, `error.from_shared` of Dream 3.0.0 gives the HTTP status of the error.

## Guides

- [Using dream_errors](https://github.com/TrustBound/dream_errors/blob/main/docs/guides/using-dream-errors.md): what each variant means, why the message is not for users, how a package maps its error, and how an app matches on it

## Requirements

- Gleam 1.19.2 or newer.

## About Dream

dream_errors is part of [Dream](https://github.com/TrustBound/dream), a web toolkit for Gleam. It is built with the same quality standards as Dream.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

[MIT](LICENSE)
