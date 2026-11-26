//// Tests for the public API of `dream_errors`.

import dream_errors.{
  type Error, Conflict, Failed, Invalid, NotFound, Timeout, Unavailable,
}
import dream_test/matchers.{be_equal, or_fail_with, should}
import dream_test/suite.{type TestSuite}
import dream_test/unit.{describe, group, it}
import gleam/list
import gleam/option.{None, Some}
import gleam/string

/// One error of each variant, with the cause "the cause".
fn each_variant() -> List(#(String, Error(String))) {
  [
    #("NotFound", NotFound("no user 7")),
    #("Conflict", Conflict("users_email_key", "the cause")),
    #("Invalid", Invalid("email is empty", "the cause")),
    #("Unavailable", Unavailable("connection refused", "the cause")),
    #("Timeout", Timeout("no answer in 5000 ms", "the cause")),
    #("Failed", Failed("syntax error", "the cause")),
  ]
}

pub fn tests() -> TestSuite {
  describe("dream_errors", [
    group("message", message_tests()),
    group("cause", cause_tests()),
    group("map_cause", map_cause_tests()),
    group("kind_name", kind_name_tests()),
  ])
}

fn message_tests() -> List(unit.UnitNode) {
  list.map(
    list.zip(each_variant(), [
      "no user 7", "users_email_key", "email is empty", "connection refused",
      "no answer in 5000 ms", "syntax error",
    ]),
    fn(example) {
      let #(#(name, error), expected) = example
      it("gives the message of " <> name, fn() {
        // Act
        let found = dream_errors.message(error)

        // Assert
        found
        |> should
        |> be_equal(expected)
        |> or_fail_with("Expected the message " <> expected)
      })
    },
  )
}

fn cause_tests() -> List(unit.UnitNode) {
  list.map(
    list.zip(each_variant(), [
      None,
      Some("the cause"),
      Some("the cause"),
      Some("the cause"),
      Some("the cause"),
      Some("the cause"),
    ]),
    fn(example) {
      let #(#(name, error), expected) = example
      it("gives " <> string.inspect(expected) <> " for " <> name, fn() {
        // Act
        let found = dream_errors.cause(error)

        // Assert
        found
        |> should
        |> be_equal(expected)
        |> or_fail_with("Expected " <> string.inspect(expected))
      })
    },
  )
}

fn map_cause_tests() -> List(unit.UnitNode) {
  list.map(
    list.zip(each_variant(), [
      NotFound("no user 7"),
      Conflict("users_email_key", 9),
      Invalid("email is empty", 9),
      Unavailable("connection refused", 9),
      Timeout("no answer in 5000 ms", 9),
      Failed("syntax error", 9),
    ]),
    fn(example) {
      let #(#(name, error), expected) = example
      it("changes the cause of " <> name <> " and keeps the rest", fn() {
        // Arrange
        let length = string.length

        // Act
        let found = dream_errors.map_cause(error, length)

        // Assert
        found
        |> should
        |> be_equal(expected)
        |> or_fail_with("Expected " <> string.inspect(expected))
      })
    },
  )
}

fn kind_name_tests() -> List(unit.UnitNode) {
  list.map(
    list.zip(each_variant(), [
      "not_found", "conflict", "invalid", "unavailable", "timeout", "failed",
    ]),
    fn(example) {
      let #(#(name, error), expected) = example
      it("gives \"" <> expected <> "\" for " <> name, fn() {
        // Act
        let found = dream_errors.kind_name(error)

        // Assert
        found
        |> should
        |> be_equal(expected)
        |> or_fail_with("Expected the kind name " <> expected)
      })
    },
  )
}
