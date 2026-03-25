#!/bin/sh

# This is the `bygg` test runner script.
#
# First, it runs shellcheck on both itself and bygg for linting and
# static analysis.
#
# However, the main testing is done by building each project in the tests/
# directory. Such a test consists of a src/ directory that defines the project
# to be built, as well as two text files: expected-exit.txt which defines what
# status code bygg should exit with and expected-output.txt which is compared
# to the output of building the project.
#
# For projects that are meant to successfully build the compared output is
# that of running the built binary. For projects that are meant to fail to
# build the compared output is the output from bygg itself.
#
# As with bygg, this test runner is meant to be fully POSIX compliant.
#

WIDTH=45

# Print a failure message and exit.
fail() { printf "\033[31;40mFAIL\033[0m (%s)\n" "$1"; exit 1; }

# Gets the length of a string
strlen() { printf %s "$1" | wc -c; }

# Pads a string to the right with dots.
dotpad() {
    str="$1"
    padding=$((WIDTH - $(strlen "${str}")))
    printf "%s" "${str}"
    printf "%*s" "${padding}" "" | tr ' ' '.'
}


# Useful to know which test runner and bygg we are testing.
TESTS="$(cd -- "$(dirname -- "$0")" && pwd)"
BYGG=$(cd "${TESTS}/../" || exit 1 && pwd)/bygg
echo "-----------------------------------------------"
printf "tests are at:\t%s\n" "${TESTS}"
printf "bygg is at:\t%s\n" "${BYGG}"
echo "-----------------------------------------------"

# Linting and static analysis of the test runner (this script!).
dotpad "shellcheck test"
shellcheck --norc -o all "${TESTS}/test.sh" || fail "shellcheck"
printf "\033[32;40mOK\033[0m\n"

# Linting and static analysis of bygg.
dotpad "shellcheck bygg"
shellcheck --norc -o all "${BYGG}" || fail "shelllcheck"
printf "\033[32;40mOK\033[0m\n"

# Build each of the test projects and check their output.
for t in "${TESTS}"/*; do
    [ -d "${t}" ] || continue
    dotpad "$(basename "${t}")"

    # Clean up build directory if it exists.
    rm -rf "${t}/build"

    expected_exit=$(cat "${t}/expected-exit.txt")

    # Positive test.
    if [ "${expected_exit}" -eq 0 ]; then
        (
            # Build the project.
            "${BYGG}" "--quiet" "${t}/src" "${t}/build" > /dev/null
            exit_code=$?

            # Check the exit code.
            if [ "${exit_code}" -ne "${expected_exit}" ]; then
                fail "expected exit code ${expected_exit}, got ${exit_code}"
            fi

            # Run the program.
            "${t}/build/a.out" > "${t}/output.txt" || fail "missing a.out"

            # Compare output.
            diff "${t}/output.txt" "${t}/expected-output.txt" >/dev/null 2>&1 || fail "diff mismatch"

            printf "\033[32;40mOK\033[0m\n"
        )
    fi

    # Negative test.
    if [ "${expected_exit}" -ne 0 ]; then
        (
            # Build the project.
            "${BYGG}" "--quiet" "${t}/src" "${t}/build" 2> "${t}/output.txt"
            exit_code=$?

            # Check the exit code.
            if [ "${exit_code}" -ne "${expected_exit}" ]; then
                fail "expected exit code ${expected_exit}, got ${exit_code}"
            fi

            # Compare output.
            diff "${t}/output.txt" "${t}/expected-output.txt" >/dev/null 2>&1 || fail "diff mismatch"

            printf "\033[32;40mOK\033[0m\n"
        )
    fi
done
