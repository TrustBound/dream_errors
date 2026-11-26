import dream_errors.{type Error, kind_name, message}

/// One log line for an error, for developers.
pub fn log_line(error: Error(cause)) -> String {
  kind_name(error) <> ": " <> message(error)
}
