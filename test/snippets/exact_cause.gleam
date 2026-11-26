import dream_errors
import snippets/to_error.{type StoreError, KeyTaken}

/// Whether an error is the clash of one exact key of the store.
pub fn is_taken(error: dream_errors.Error(StoreError), key: String) -> Bool {
  case error {
    dream_errors.Conflict(cause: KeyTaken(key: taken), ..) -> taken == key
    _ -> False
  }
}
