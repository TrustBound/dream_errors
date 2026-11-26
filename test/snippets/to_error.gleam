import dream_errors.{type Error, Conflict, NotFound, Unavailable}

/// The error of a store package.
pub type StoreError {
  KeyMissing(key: String)
  KeyTaken(key: String)
  StoreDown(reason: String)
}

/// Maps a store error to the shared error, with the store error as the cause.
pub fn to_error(error: StoreError) -> Error(StoreError) {
  case error {
    KeyMissing(key:) -> NotFound("no value for key " <> key)
    KeyTaken(key:) -> Conflict("the key " <> key <> " has a value", error)
    StoreDown(reason:) -> Unavailable("the store is down: " <> reason, error)
  }
}
