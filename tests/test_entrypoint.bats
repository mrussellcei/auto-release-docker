
setup() {
    export GITHUB_EVENT_PATH=$(mktemp /tmp/github_event_file.json.XXXXX)
    cat << EOF > $GITHUB_EVENT_PATH
{
    "action": "opened",
    "number": 2,
    "pull_request": {
        "title" : "PR 1",
        "created_at": "2384792374",
        "body": "# Title\nThis is paragraph",
        "user": {
            "name": "Sam Smith"
        }
    }
}
EOF
    export BATS_LIB_PATH=${BATS_LIB_PATH:-"/usr/lib"}
    bats_load_library bats-support
    bats_load_library bats-assert
    bats_load_library bats-file

    export GITHUB_OUTPUT=$(mktemp /tmp/github_output_file.bash.XXXXX)

    # get the containing directory of this file
    # use $BATS_TEST_FILENAME instead of ${BASH_SOURCE[0]} or $0,
    # as those will point to the bats executable's location or the preprocessed file respectively
    DIR="$( cd "$( dirname "$BATS_TEST_FILENAME" )" >/dev/null 2>&1 && pwd )"
    # make executables in src/ visible to PATH
    PATH="$DIR/..:$PATH"
}

@test "entry point fails when no parameter passed" {
    run entrypoint.sh
    [ "$status" -ne 0 ]
    assert_output '::error::The repo_token is required for the milstone release drafter. It is missing.'
}

@test "entry point fails when empty string passed" {
    run entrypoint.sh ""
    [ "$status" -ne 0 ]
    assert_output '::error::The repo_token is required for the milstone release drafter. It is zero length.'

}

@test "Exits with zero when the event type is not pull_request" {
    export GITHUB_EVENT_NAME='tag'
    run entrypoint.sh "4758127478"
    assert_output "::debug::The event name is 'tag' action skipping processing"
    [ "$status" -eq 0 ]
}

@test "Exits with zero processed properly" {
    export GITHUB_EVENT_NAME='pull_request'
    export GITHUB_REPOSITORY='mrussell/test_repo'

    run entrypoint.sh "4758127478" 1
    assert_output --partial 'user: Sam Smith'
    [ "$status" -eq 0 ]
}

teardown() {
    rm -f "${GITHUB_EVENT_PATH}" "${GITHUB_OUTPUT}"
}