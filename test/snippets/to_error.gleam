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
