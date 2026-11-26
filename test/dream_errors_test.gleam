//// The test run. It measures the line coverage of `src` and fails below
//// 100%.

import dream_errors/error_test
import dream_errors/snippets_test
import dream_test/coverage.{
  type CoverageConfig, json_path, minimum_percent, show_missing,
}
import dream_test/reporters/bdd
import dream_test/reporters/progress
import dream_test/runner.{
  exit_on_failure, new, progress_reporter, results_reporters, run,
}

pub fn main() -> Nil {
  new([error_test.tests(), snippets_test.tests()])
  |> progress_reporter(progress.new())
  |> results_reporters([bdd.new()])
  |> runner.coverage(coverage_config())
  |> exit_on_failure()
  |> run()
  Nil
}

fn coverage_config() -> CoverageConfig {
  coverage.new()
  |> show_missing()
  |> json_path("build/coverage/coverage.json")
  |> minimum_percent(100.0)
}
