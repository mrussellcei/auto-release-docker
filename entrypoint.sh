#!/bin/bash

set -euo pipefail

TESTING=0

if [ $# -lt 1 ]; then
    echo "::error::The repo_token is required for the milstone release drafter. It is missing."
    exit 1
fi

repo_token=$1

if [ -z "${repo_token}" ]; then
    echo "::error::The repo_token is required for the milstone release drafter. It is zero length."
    exit 1
fi

if [ $# -eq 2 ]; then
    TESTING=1
fi    

if [ "${GITHUB_EVENT_NAME}" != "milestone" ]; then
    echo "::debug::The event name is '${GITHUB_EVENT_NAME}' action skipping processing"
    exit 0
fi

echo "::debug::GITHUB_EVENT_PATH=${GITHUB_EVENT_PATH}"

if [[ ! -f "${GITHUB_EVENT_PATH}" ]]; then
    echo "::error::The event path could not be found ${GITHUB_EVENT_PATH}"
    exit 1
fi

event_type="$(jq --raw-output '.action' $GITHUB_EVENT_PATH)"

if [ "${event_type}" != "closed" ]; then
    echo "::debug::The event type was ${event_type}"
    exit 0
fi

milestone_name="$(jq --raw-output '.milestone.title' $GITHUB_EVENT_PATH)"

IFS='/' read owner repository <<< "${GITHUB_REPOSITORY}"

release_url="https://dummy.com"
rm_rc=0

if [ ! ${TESTING} -eq 1 ]; then
    set +e
    release_url="$(dotnet gitreleasemanager create \
        --milestone $milestone_name \
        --targetcommitsh $GITHUB_SHA \
        --token $repo_token \
        --owner $owner \
        --repository $repository)"
    rm-rc=$?
    set -e
fi

if [ ${rm_rc} -ne 0 ]; then
    echo "::error::Failed to create the release draft"
    exit 1
fi

echo "::debug::Seting the release URL to ${release_url}"
echo "release-url=${release_url}" >> $GITHUB_OUTPUT

exit 0