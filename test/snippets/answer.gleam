import dream_errors

/// The status code and the text that an app shows for a shared error.
/// The text is the app's own text, never the message of the error.
pub fn answer(error: dream_errors.Error(cause)) -> #(Int, String) {
  case error {
    dream_errors.NotFound(..) -> #(404, "We could not find that.")
    dream_errors.Conflict(..) -> #(409, "That exists already.")
    dream_errors.Invalid(..) -> #(400, "Please check your input.")
    dream_errors.Unavailable(..) | dream_errors.Timeout(..) -> #(
      503,
      "Please try again soon.",
    )
    dream_errors.Failed(..) -> #(500, "Something went wrong.")
  }
}
