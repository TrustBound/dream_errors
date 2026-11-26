import dream_errors

/// One log line for an error, for developers.
pub fn log_line(error: dream_errors.Error(cause)) -> String {
  dream_errors.kind_name(error) <> ": " <> dream_errors.message(error)
}
