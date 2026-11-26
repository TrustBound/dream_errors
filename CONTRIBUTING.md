# Contributing to dream_errors

dream_errors is the shared error type of the Dream packages. Other packages depend on it, so a change to the type is a change to all of them. Open an issue before you add a variant or a function, and name the package that needs it.

## Run the tests

1. Run `gleam test`.
2. Make sure that the line coverage is 100%. The test main fails the run below 100%.

The tests are black-box tests with [dream_test](https://github.com/TrustBound/dream_test). Each test has the parts Arrange, Act and Assert, makes one assertion, and compares exact values.

## Write the docs

Every code block in the README, the guide, the doc comments and the release notes is a copy of a tested file. `gleam run -m dream_snippets` checks each block against its file.

1. Put the code in a file in `test/snippets`, and add a test for it to `test/dream_errors/snippets_test.gleam`.
2. Put a heading directly above the block. End the heading with the "Tested snippet" badge, which links to the file at the release tag, for example `https://github.com/TrustBound/dream_errors/blob/1.0.0/test/snippets/to_error.gleam`. Add `#L4-L9` to the link for a part of a file.
3. In the README, add the guide badge after the tested snippet badge. It links to the section of the guide that shows the same code.
4. Give each fence a language.

## Before a commit

Run `make check`: the format check, the build, the tests, the docs build and the snippet check.

A commit message has the form `feat: <name>`, `fix: <name>` or `docs: <name>`, a blank line, and then the sections `Why This Change Was Made`, `What Was Changed` and `Note to Future Engineer`.
