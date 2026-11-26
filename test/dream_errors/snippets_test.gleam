//// Tests for the code of the docs: each file of `test/snippets` that the
//// README, the guide and the doc comments show.

import dream_errors.{Conflict, Failed, Invalid, NotFound, Timeout, Unavailable}
import dream_test/matchers.{be_equal, or_fail_with, should}
import dream_test/suite.{type TestSuite}
import dream_test/unit.{describe, group, it}
import gleam/list
import gleam/string
import snippets/answer
import snippets/exact_cause
import snippets/log_line
import snippets/map_cause.{Store}
import snippets/to_error.{KeyMissing, KeyTaken, StoreDown}

pub fn tests() -> TestSuite {
  describe("the code of the docs", [
    group("to_error.gleam", to_error_tests()),
    group("answer.gleam", answer_tests()),
    group("exact_cause.gleam", exact_cause_tests()),
    group("log_line.gleam", [
      it("gives the kind name and the message", fn() {
        // Arrange
        let error = Unavailable("connection refused", Nil)

        // Act
        let line = log_line.log_line(error)

        // Assert
        line
        |> should
        |> be_equal("unavailable: connection refused")
        |> or_fail_with("Expected \"unavailable: connection refused\"")
      }),
    ]),
    group("map_cause.gleam", map_cause_tests()),
  ])
}

fn to_error_tests() -> List(unit.UnitNode) {
  list.map(
    [
      #(KeyMissing("a"), NotFound("no value for key a")),
      #(KeyTaken("a"), Conflict("the key a has a value", KeyTaken("a"))),
      #(
        StoreDown("closed"),
        Unavailable("the store is down: closed", StoreDown("closed")),
      ),
    ],
    fn(example) {
      let #(store_error, expected) = example
      it("maps " <> string.inspect(store_error), fn() {
        // Act
        let error = to_error.to_error(store_error)

        // Assert
        error
        |> should
        |> be_equal(expected)
        |> or_fail_with("Expected " <> string.inspect(expected))
      })
    },
  )
}

fn answer_tests() -> List(unit.UnitNode) {
  list.map(
    [
      #(NotFound("no user 7"), #(404, "We could not find that.")),
      #(Conflict("users_email_key", Nil), #(409, "That exists already.")),
      #(Invalid("email is empty", Nil), #(400, "Please check your input.")),
      #(Unavailable("refused", Nil), #(503, "Please try again soon.")),
      #(Timeout("no answer", Nil), #(503, "Please try again soon.")),
      #(Failed("syntax error", Nil), #(500, "Something went wrong.")),
    ],
    fn(example) {
      let #(error, expected) = example
      it("answers " <> dream_errors.kind_name(error), fn() {
        // Act
        let found = answer.answer(error)

        // Assert
        found
        |> should
        |> be_equal(expected)
        |> or_fail_with("Expected " <> string.inspect(expected))
      })
    },
  )
}

fn exact_cause_tests() -> List(unit.UnitNode) {
  list.map(
    [
      #("the same key", Conflict("taken", KeyTaken("a")), True),
      #("another key", Conflict("taken", KeyTaken("b")), False),
      #("another variant", NotFound("no value for key a"), False),
    ],
    fn(example) {
      let #(name, error, expected) = example
      it("gives " <> string.inspect(expected) <> " for " <> name, fn() {
        // Act
        let found = exact_cause.is_taken(error, "a")

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
  [
    it("puts the store error into Store", fn() {
      // Arrange
      let error = Conflict("the key a has a value", KeyTaken("a"))

      // Act
      let found = map_cause.from_store(error)

      // Assert
      found
      |> should
      |> be_equal(Conflict("the key a has a value", Store(KeyTaken("a"))))
      |> or_fail_with("Expected the cause Store(KeyTaken(\"a\"))")
    }),
    it("keeps NotFound", fn() {
      // Arrange
      let error = NotFound("no value for key a")

      // Act
      let found = map_cause.from_store(error)

      // Assert
      found
      |> should
      |> be_equal(NotFound("no value for key a"))
      |> or_fail_with("Expected NotFound(\"no value for key a\")")
    }),
  ]
}
