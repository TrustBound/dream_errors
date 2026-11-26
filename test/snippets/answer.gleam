import dream_errors.{
  type Error, Conflict, Failed, Invalid, NotFound, Timeout, Unavailable,
}

/// The status code and the text that an app shows for a shared error.
/// The text is the app's own text, never the message of the error.
pub fn answer(error: Error(cause)) -> #(Int, String) {
  case error {
    NotFound(..) -> #(404, "We could not find that.")
    Conflict(..) -> #(409, "That exists already.")
    Invalid(..) -> #(400, "Please check your input.")
    Unavailable(..) | Timeout(..) -> #(503, "Please try again soon.")
    Failed(..) -> #(500, "Something went wrong.")
  }
}
