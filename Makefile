# dream_errors Makefile

.PHONY: test build format check check-snippets docs clean

# Run the tests with line coverage (fails below 100%).
test:
	@gleam test

build:
	@gleam build

format:
	@gleam format src test

# Run everything CI runs: format check, build, tests, docs build and the
# snippet check
check:
	@gleam format --check src test
	@gleam build
	@gleam test
	@gleam docs build
	@gleam run -m dream_snippets

check-snippets:
	@gleam run -m dream_snippets

docs:
	@gleam docs build

clean:
	@gleam clean
	@rm -f erl_crash.dump
