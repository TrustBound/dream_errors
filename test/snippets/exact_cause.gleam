import dream_errors.{type Error, Conflict}
import snippets/to_error.{type StoreError, KeyTaken}

/// Whether an error is the clash of one exact key of the store.
pub fn is_taken(error: Error(StoreError), key: String) -> Bool {
  case error {
    Conflict(cause: KeyTaken(key: taken), ..) -> taken == key
    _ -> False
  }
}
