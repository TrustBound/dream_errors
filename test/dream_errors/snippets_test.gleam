//// Tests for the code of the docs: each file of `test/snippets` that the
//// README, the guide and the doc comments show.

import dream_errors.{
  Conflict, Failed, Invalid, NotFound, Retry, Timeout, Unavailable,
}
import dream_test/matchers.{be_equal, or_fail_with, should}
import dream_test/suite.{type TestSuite}
import dream_test/unit.{type UnitNode, describe, group, it}
import gleam/option.{None}
import snippets/answer
import snippets/exact_cause.{is_taken}
import snippets/log_line
import snippets/map_cause.{Store, from_store}
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

fn to_error_tests() -> List(UnitNode) {
  [
    it("maps a missing key to NotFound", fn() {
      // Arrange
      let store_error = KeyMissing("a")

      // Act
      let found = to_error.to_error(store_error)

      // Assert
      found
      |> should
      |> be_equal(NotFound("no value for key a"))
      |> or_fail_with("Expected NotFound(\"no value for key a\")")
    }),
    it("maps a taken key to Conflict", fn() {
      // Arrange
      let store_error = KeyTaken("a")

      // Act
      let found = to_error.to_error(store_error)

      // Assert
      found
      |> should
      |> be_equal(Conflict("the key a has a value", KeyTaken("a")))
      |> or_fail_with(
        "Expected Conflict(\"the key a has a value\", KeyTaken(\"a\"))",
      )
    }),
    it("maps a store that is down to Unavailable", fn() {
      // Arrange
      let store_error = StoreDown("closed")

      // Act
      let found = to_error.to_error(store_error)

      // Assert
      found
      |> should
      |> be_equal(Unavailable("the store is down: closed", StoreDown("closed")))
      |> or_fail_with(
        "Expected Unavailable(\"the store is down: closed\", StoreDown(\"closed\"))",
      )
    }),
  ]
}

fn answer_tests() -> List(UnitNode) {
  [
    it("answers a NotFound with 404", fn() {
      // Arrange
      let error = NotFound("no user 7")

      // Act
      let found = answer.answer(error)

      // Assert
      found
      |> should
      |> be_equal(#(404, "We could not find that."))
      |> or_fail_with("Expected #(404, \"We could not find that.\")")
    }),
    it("answers a Retry with 503", fn() {
      // Arrange
      let error = Retry("deadlock detected", Nil, None)

      // Act
      let found = answer.answer(error)

      // Assert
      found
      |> should
      |> be_equal(#(503, "Please try again."))
      |> or_fail_with("Expected #(503, \"Please try again.\")")
    }),
    it("answers a Conflict with 409", fn() {
      // Arrange
      let error = Conflict("users_email_key", Nil)

      // Act
      let found = answer.answer(error)

      // Assert
      found
      |> should
      |> be_equal(#(409, "That exists already."))
      |> or_fail_with("Expected #(409, \"That exists already.\")")
    }),
    it("answers an Invalid with 400", fn() {
      // Arrange
      let error = Invalid("email is empty", Nil)

      // Act
      let found = answer.answer(error)

      // Assert
      found
      |> should
      |> be_equal(#(400, "Please check your input."))
      |> or_fail_with("Expected #(400, \"Please check your input.\")")
    }),
    it("answers an Unavailable with 503", fn() {
      // Arrange
      let error = Unavailable("refused", Nil)

      // Act
      let found = answer.answer(error)

      // Assert
      found
      |> should
      |> be_equal(#(503, "Please try again soon."))
      |> or_fail_with("Expected #(503, \"Please try again soon.\")")
    }),
    it("answers a Timeout with 503", fn() {
      // Arrange
      let error = Timeout("no answer", Nil)

      // Act
      let found = answer.answer(error)

      // Assert
      found
      |> should
      |> be_equal(#(503, "Please try again soon."))
      |> or_fail_with("Expected #(503, \"Please try again soon.\")")
    }),
    it("answers a Failed with 500", fn() {
      // Arrange
      let error = Failed("syntax error", Nil)

      // Act
      let found = answer.answer(error)

      // Assert
      found
      |> should
      |> be_equal(#(500, "Something went wrong."))
      |> or_fail_with("Expected #(500, \"Something went wrong.\")")
    }),
  ]
}

fn exact_cause_tests() -> List(UnitNode) {
  [
    it("gives True for a Conflict of the same key", fn() {
      // Arrange
      let error = Conflict("taken", KeyTaken("a"))

      // Act
      let found = is_taken(error, "a")

      // Assert
      found
      |> should
      |> be_equal(True)
      |> or_fail_with("Expected True")
    }),
    it("gives False for a Conflict of another key", fn() {
      // Arrange
      let error = Conflict("taken", KeyTaken("b"))

      // Act
      let found = is_taken(error, "a")

      // Assert
      found
      |> should
      |> be_equal(False)
      |> or_fail_with("Expected False")
    }),
    it("gives False for another variant", fn() {
      // Arrange
      let error = NotFound("no value for key a")

      // Act
      let found = is_taken(error, "a")

      // Assert
      found
      |> should
      |> be_equal(False)
      |> or_fail_with("Expected False")
    }),
  ]
}

fn map_cause_tests() -> List(UnitNode) {
  [
    it("puts the store error into Store", fn() {
      // Arrange
      let error = Conflict("the key a has a value", KeyTaken("a"))

      // Act
      let found = from_store(error)

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
      let found = from_store(error)

      // Assert
      found
      |> should
      |> be_equal(NotFound("no value for key a"))
      |> or_fail_with("Expected NotFound(\"no value for key a\")")
    }),
  ]
}
