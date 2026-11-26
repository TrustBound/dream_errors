import dream_errors
import snippets/to_error.{type StoreError}

/// The causes of the app: one variant for each package that the app uses.
pub type AppCause {
  Store(StoreError)
  Search(String)
}

/// Puts a store error into the error type of the app.
pub fn from_store(
  error: dream_errors.Error(StoreError),
) -> dream_errors.Error(AppCause) {
  dream_errors.map_cause(error, Store)
}
