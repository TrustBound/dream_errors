//// Tests for the public API of `dream_errors`.

import dream_errors.{
  Conflict, Failed, Invalid, NotFound, Retry, Timeout, Unavailable, cause,
  kind_name, map_cause, message,
}
import dream_test/matchers.{be_equal, or_fail_with, should}
import dream_test/suite.{type TestSuite}
import dream_test/unit.{type UnitNode, describe, group, it}
import gleam/option.{None, Some}
import gleam/string.{length}

pub fn tests() -> TestSuite {
  describe("dream_errors", [
    group("message", message_tests()),
    group("cause", cause_tests()),
    group("map_cause", map_cause_tests()),
    group("kind_name", kind_name_tests()),
  ])
}

fn message_tests() -> List(UnitNode) {
  [
    it("gives the message of a NotFound", fn() {
      // Arrange
      let error = NotFound("no user 7")

      // Act
      let found = message(error)

      // Assert
      found
      |> should
      |> be_equal("no user 7")
      |> or_fail_with("Expected the message no user 7")
    }),
    it("gives the message of a Retry", fn() {
      // Arrange
      let error = Retry("deadlock detected", "the cause", Some(30))

      // Act
      let found = message(error)

      // Assert
      found
      |> should
      |> be_equal("deadlock detected")
      |> or_fail_with("Expected the message deadlock detected")
    }),
    it("gives the message of a Conflict", fn() {
      // Arrange
      let error = Conflict("users_email_key", "the cause")

      // Act
      let found = message(error)

      // Assert
      found
      |> should
      |> be_equal("users_email_key")
      |> or_fail_with("Expected the message users_email_key")
    }),
    it("gives the message of an Invalid", fn() {
      // Arrange
      let error = Invalid("email is empty", "the cause")

      // Act
      let found = message(error)

      // Assert
      found
      |> should
      |> be_equal("email is empty")
      |> or_fail_with("Expected the message email is empty")
    }),
    it("gives the message of an Unavailable", fn() {
      // Arrange
      let error = Unavailable("connection refused", "the cause")

      // Act
      let found = message(error)

      // Assert
      found
      |> should
      |> be_equal("connection refused")
      |> or_fail_with("Expected the message connection refused")
    }),
    it("gives the message of a Timeout", fn() {
      // Arrange
      let error = Timeout("no answer in 5000 ms", "the cause")

      // Act
      let found = message(error)

      // Assert
      found
      |> should
      |> be_equal("no answer in 5000 ms")
      |> or_fail_with("Expected the message no answer in 5000 ms")
    }),
    it("gives the message of a Failed", fn() {
      // Arrange
      let error = Failed("syntax error", "the cause")

      // Act
      let found = message(error)

      // Assert
      found
      |> should
      |> be_equal("syntax error")
      |> or_fail_with("Expected the message syntax error")
    }),
  ]
}

fn cause_tests() -> List(UnitNode) {
  [
    it("gives None for a NotFound", fn() {
      // Arrange
      let error = NotFound("no user 7")

      // Act
      let found = cause(error)

      // Assert
      found
      |> should
      |> be_equal(None)
      |> or_fail_with("Expected None")
    }),
    it("gives Some(the cause) for a Retry", fn() {
      // Arrange
      let error = Retry("deadlock detected", "the cause", Some(30))

      // Act
      let found = cause(error)

      // Assert
      found
      |> should
      |> be_equal(Some("the cause"))
      |> or_fail_with("Expected Some(the cause)")
    }),
    it("gives Some(the cause) for a Conflict", fn() {
      // Arrange
      let error = Conflict("users_email_key", "the cause")

      // Act
      let found = cause(error)

      // Assert
      found
      |> should
      |> be_equal(Some("the cause"))
      |> or_fail_with("Expected Some(the cause)")
    }),
    it("gives Some(the cause) for an Invalid", fn() {
      // Arrange
      let error = Invalid("email is empty", "the cause")

      // Act
      let found = cause(error)

      // Assert
      found
      |> should
      |> be_equal(Some("the cause"))
      |> or_fail_with("Expected Some(the cause)")
    }),
    it("gives Some(the cause) for an Unavailable", fn() {
      // Arrange
      let error = Unavailable("connection refused", "the cause")

      // Act
      let found = cause(error)

      // Assert
      found
      |> should
      |> be_equal(Some("the cause"))
      |> or_fail_with("Expected Some(the cause)")
    }),
    it("gives Some(the cause) for a Timeout", fn() {
      // Arrange
      let error = Timeout("no answer in 5000 ms", "the cause")

      // Act
      let found = cause(error)

      // Assert
      found
      |> should
      |> be_equal(Some("the cause"))
      |> or_fail_with("Expected Some(the cause)")
    }),
    it("gives Some(the cause) for a Failed", fn() {
      // Arrange
      let error = Failed("syntax error", "the cause")

      // Act
      let found = cause(error)

      // Assert
      found
      |> should
      |> be_equal(Some("the cause"))
      |> or_fail_with("Expected Some(the cause)")
    }),
  ]
}

fn map_cause_tests() -> List(UnitNode) {
  [
    it("keeps a NotFound, which has no cause", fn() {
      // Arrange
      let error = NotFound("no user 7")

      // Act
      let found = map_cause(error, length)

      // Assert
      found
      |> should
      |> be_equal(NotFound("no user 7"))
      |> or_fail_with("Expected NotFound(\"no user 7\")")
    }),
    it("changes the cause of a Retry and keeps the rest", fn() {
      // Arrange
      let error = Retry("deadlock detected", "the cause", Some(30))

      // Act
      let found = map_cause(error, length)

      // Assert
      found
      |> should
      |> be_equal(Retry("deadlock detected", 9, Some(30)))
      |> or_fail_with("Expected Retry(\"deadlock detected\", 9, Some(30))")
    }),
    it("changes the cause of a Conflict and keeps the rest", fn() {
      // Arrange
      let error = Conflict("users_email_key", "the cause")

      // Act
      let found = map_cause(error, length)

      // Assert
      found
      |> should
      |> be_equal(Conflict("users_email_key", 9))
      |> or_fail_with("Expected Conflict(\"users_email_key\", 9)")
    }),
    it("changes the cause of an Invalid and keeps the rest", fn() {
      // Arrange
      let error = Invalid("email is empty", "the cause")

      // Act
      let found = map_cause(error, length)

      // Assert
      found
      |> should
      |> be_equal(Invalid("email is empty", 9))
      |> or_fail_with("Expected Invalid(\"email is empty\", 9)")
    }),
    it("changes the cause of an Unavailable and keeps the rest", fn() {
      // Arrange
      let error = Unavailable("connection refused", "the cause")

      // Act
      let found = map_cause(error, length)

      // Assert
      found
      |> should
      |> be_equal(Unavailable("connection refused", 9))
      |> or_fail_with("Expected Unavailable(\"connection refused\", 9)")
    }),
    it("changes the cause of a Timeout and keeps the rest", fn() {
      // Arrange
      let error = Timeout("no answer in 5000 ms", "the cause")

      // Act
      let found = map_cause(error, length)

      // Assert
      found
      |> should
      |> be_equal(Timeout("no answer in 5000 ms", 9))
      |> or_fail_with("Expected Timeout(\"no answer in 5000 ms\", 9)")
    }),
    it("changes the cause of a Failed and keeps the rest", fn() {
      // Arrange
      let error = Failed("syntax error", "the cause")

      // Act
      let found = map_cause(error, length)

      // Assert
      found
      |> should
      |> be_equal(Failed("syntax error", 9))
      |> or_fail_with("Expected Failed(\"syntax error\", 9)")
    }),
  ]
}

fn kind_name_tests() -> List(UnitNode) {
  [
    it("gives \"not_found\" for a NotFound", fn() {
      // Arrange
      let error = NotFound("no user 7")

      // Act
      let found = kind_name(error)

      // Assert
      found
      |> should
      |> be_equal("not_found")
      |> or_fail_with("Expected the kind name not_found")
    }),
    it("gives \"retry\" for a Retry", fn() {
      // Arrange
      let error = Retry("deadlock detected", "the cause", Some(30))

      // Act
      let found = kind_name(error)

      // Assert
      found
      |> should
      |> be_equal("retry")
      |> or_fail_with("Expected the kind name retry")
    }),
    it("gives \"conflict\" for a Conflict", fn() {
      // Arrange
      let error = Conflict("users_email_key", "the cause")

      // Act
      let found = kind_name(error)

      // Assert
      found
      |> should
      |> be_equal("conflict")
      |> or_fail_with("Expected the kind name conflict")
    }),
    it("gives \"invalid\" for an Invalid", fn() {
      // Arrange
      let error = Invalid("email is empty", "the cause")

      // Act
      let found = kind_name(error)

      // Assert
      found
      |> should
      |> be_equal("invalid")
      |> or_fail_with("Expected the kind name invalid")
    }),
    it("gives \"unavailable\" for an Unavailable", fn() {
      // Arrange
      let error = Unavailable("connection refused", "the cause")

      // Act
      let found = kind_name(error)

      // Assert
      found
      |> should
      |> be_equal("unavailable")
      |> or_fail_with("Expected the kind name unavailable")
    }),
    it("gives \"timeout\" for a Timeout", fn() {
      // Arrange
      let error = Timeout("no answer in 5000 ms", "the cause")

      // Act
      let found = kind_name(error)

      // Assert
      found
      |> should
      |> be_equal("timeout")
      |> or_fail_with("Expected the kind name timeout")
    }),
    it("gives \"failed\" for a Failed", fn() {
      // Arrange
      let error = Failed("syntax error", "the cause")

      // Act
      let found = kind_name(error)

      // Assert
      found
      |> should
      |> be_equal("failed")
      |> or_fail_with("Expected the kind name failed")
    }),
  ]
}
