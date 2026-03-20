#!/bin/sh

COLS=40

fail() { printf "\033[31;40mFAIL\033[0m\n"; exit 1; }

wideprint() {
    str="$1"
    format="$2"

    len="$(printf %s "${str}" | wc -c)"
    dots=$((COLS - len))

    printf "%s" "${str}" "${format}"
    printf "%*s" "${dots}" "" | tr ' ' '.'
}

TESTS="$(cd -- "$(dirname -- "$0")" && pwd)"
BYGG=$(cd "${TESTS}/../" || exit 1 && pwd)/bygg

printf "tests are at:\t%s\n" "${TESTS}"
printf "bygg is at:\t%s\n" "${BYGG}"

# Do a lint check on the test runner.
wideprint "shellcheck (test runner)"
shellcheck --norc -o all "${TESTS}/test.sh" || fail
printf "\033[32;40mOK\033[0m\n"

# Do a lint check on the test runner.
wideprint "shellcheck (bygg)"
# : shellcheck --norc -o all "${BYGG}" || fail
printf "\033[32;40mOK\033[0m\n"

# Build each of the test projects and check their output.
for t in "${TESTS}"/*; do
    [ -d "${t}" ] || continue
    str="Running $(basename "${t}")"
    wideprint "${str}"

    # Clean up build directory if it exists.
    rm -rf "${t}/build"

    expected_exit=$(cat "${t}/expected-exit.txt")
    # Positive test.
    if [ "${expected_exit}" -eq 0 ]; then
        (
            # Build the project.
            "${BYGG}" "${t}/src" "${t}/build"
            exit_code=$?

            # Check the exit code.
            if [ "${exit_code}" -ne "${expected_exit}" ]; then
                fail
            fi

            # Run the program.
            "${t}/build/a.out" > "${t}/output.txt"

            # Compare output.
            diff "${t}/output.txt" "${t}/expected-output.txt" || fail
        )
    fi

    # Negative test.
    if [ "${expected_exit}" -ne 0 ]; then
        (
            # Build the project.
            "${BYGG}" "${t}/src" "${t}/build" > "${t}/output.txt"
            exit_code=$?

            # Check the exit code.
            if [ "${exit_code}" -ne "${expected_exit}" ]; then
                fail
            fi

            # Compare output.
            diff "${t}/output.txt" "${t}/expected-output.txt" || fail
        )
    fi

    #$BYGG $t/src $t/build || fail()
    ##(cd $t && $BYGG && build/a.out > output.txt)
    #echo "OK" 
    printf "\033[32;40mOK\033[0m\n"
done
