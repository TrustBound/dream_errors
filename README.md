<div align="center">
  <img src="https://raw.githubusercontent.com/TrustBound/dream/main/ricky_and_lucy.png" alt="Ricky Moony and Lucy, a moon shaped mascot for Dream with the star shaped mascot for Gleam, each with cute cartoon eyes and a smile" width="200">

<b>One error type for every Dream package</b>

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

## What is Dream Errors?

Dream Errors is the one error type that every Dream package returns. Each package maps its own error to seven shared variants and keeps the original as a typed `cause`, so your app matches on one type for every package, and your logs still get the exact error. It depends only on the Gleam standard library.

## Features

### One type to match on

Seven variants that mean the same thing in every package. [Read more](https://github.com/TrustBound/dream_errors/blob/main/docs/guides/using-dream-errors.md#what-each-variant-means).

| Feature                 | What you get                                                                                              |
| ----------------------- | --------------------------------------------------------------------------------------------------------- |
| 🎯 **Seven variants**   | `NotFound`, `Retry`, `Conflict`, `Invalid`, `Unavailable`, `Timeout` and `Failed`, in every Dream package |
| 🔁 **Retry with delay** | `Retry` carries `after_seconds`, the delay before the next try, when the source knows it                  |
| 🌐 **HTTP status**      | In a Dream app, `error.from_shared` of Dream 3.0.0 gives the status of an error                           |

### The exact error, kept

The package's own error stays whole, for logs and for exact matches. [Read more](https://github.com/TrustBound/dream_errors/blob/main/docs/guides/using-dream-errors.md#match-on-the-error-in-an-app).

| Feature                | What you get                                                                    |
| ---------------------- | ------------------------------------------------------------------------------- |
| 🧬 **Typed cause**     | The package's own error as `cause`, so you can match one exact case             |
| 🔀 **Many packages**   | `map_cause` puts the errors of two packages into one app type                   |
| 📝 **Log-ready**       | `message` and `kind_name` give text for a log line; never show them to users    |

### Map your own errors

Give your package the same shape. [Read more](https://github.com/TrustBound/dream_errors/blob/main/docs/guides/using-dream-errors.md#map-a-package-error).

| Feature                 | What you get                                                              |
| ----------------------- | ------------------------------------------------------------------------- |
| 🗺️ **`to_error`**       | One function sends each case of your error to a variant                   |
| 📦 **No dependencies**  | The Gleam standard library and nothing else                               |

## A Quick Example

### Answer with a status and your own text <a href="https://github.com/TrustBound/dream_errors/blob/1.0.0/test/snippets/answer.gleam"><img align="right" alt="Tested snippet" src="https://img.shields.io/badge/%F0%9F%A7%AA_tested-snippet-lightgreen.svg?style=flat-square"></a> <a href="https://github.com/TrustBound/dream_errors/blob/1.0.0/docs/guides/using-dream-errors.md#answer-with-a-status-and-your-own-text-"><img align="right" alt="Guide: Using dream_errors" title="Guide: Using dream_errors" src="https://img.shields.io/badge/%F0%9F%93%96_read-guide-blue.svg?style=flat-square"></a>

```gleam
import dream_errors.{
  type Error, Conflict, Failed, Invalid, NotFound, Retry, Timeout, Unavailable,
}

/// The status code and the text that an app shows for a shared error.
/// The text is the app's own text, never the message of the error.
pub fn answer(error: Error(cause)) -> #(Int, String) {
  case error {
    NotFound(..) -> #(404, "We could not find that.")
    Retry(..) -> #(503, "Please try again.")
    Conflict(..) -> #(409, "That exists already.")
    Invalid(..) -> #(400, "Please check your input.")
    Unavailable(..) | Timeout(..) -> #(503, "Please try again soon.")
    Failed(..) -> #(500, "Something went wrong.")
  }
}
```

**Run this:** `answer(NotFound("no user"))` → `#(404, "We could not find that.")`

## Installation

```sh
gleam add dream_errors
```

## Guides

- [Using Dream Errors](https://github.com/TrustBound/dream_errors/blob/main/docs/guides/using-dream-errors.md): what each variant means, why the message is not for users, how a package maps its error, and how an app matches on it
- [API reference](https://hexdocs.pm/dream_errors): every module and function on HexDocs

## Requirements

- Gleam 1.19.2 or newer.
- No other dependency than the Gleam standard library.

## About Dream

[Dream](https://github.com/TrustBound/dream) is a collection of Gleam packages for building production web applications. Each package implements its standards completely, shares the same naming and style as the others, and is fully tested. TrustBound builds Dream for its own production systems and shares it in the hope that it helps yours.

Dream Errors works on its own. You don't need the rest of Dream to use it.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

[MIT](LICENSE)
