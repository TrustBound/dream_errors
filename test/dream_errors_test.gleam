//// The test run. It measures the line coverage of `src` and fails below
//// 100%.

import dream_errors/error_test
import dream_errors/snippets_test
import dream_test/coverage
import dream_test/reporters/bdd
import dream_test/reporters/progress
import dream_test/runner

pub fn main() -> Nil {
  runner.new([error_test.tests(), snippets_test.tests()])
  |> runner.progress_reporter(progress.new())
  |> runner.results_reporters([bdd.new()])
  |> runner.coverage(coverage_config())
  |> runner.exit_on_failure()
  |> runner.run()
  Nil
}

fn coverage_config() -> coverage.CoverageConfig {
  coverage.new()
  |> coverage.show_missing()
  |> coverage.json_path("build/coverage/coverage.json")
  |> coverage.minimum_percent(100.0)
}
