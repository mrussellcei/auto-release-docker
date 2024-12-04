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

if [ "${GITHUB_EVENT_NAME}" != "pull_request" ]; then
    echo "::debug::The event name is '${GITHUB_EVENT_NAME}' action skipping processing"
    exit 0
fi

echo "::debug::GITHUB_EVENT_PATH=${GITHUB_EVENT_PATH}"

if [[ ! -f "${GITHUB_EVENT_PATH}" ]]; then
    echo "::error::The event path could not be found ${GITHUB_EVENT_PATH}"
    exit 1
fi

event_type="$(jq --raw-output '.action' $GITHUB_EVENT_PATH)"

if [ "${event_type}" != "opened" ]; then
    echo "::debug::The pull request event type was ${event_type}"
    exit 0
fi

pr_number="$(jq --raw-output '.number' $GITHUB_EVENT_PATH)"
title="$(jq --raw-output '.pull_request.title' $GITHUB_EVENT_PATH)"
created_at="$(jq --raw-output '.pull_request.created_at' $GITHUB_EVENT_PATH)"
user="$(jq --raw-output '.pull_request.user.name' $GITHUB_EVENT_PATH)"
body="$(jq --raw-output '.pull_request.body' $GITHUB_EVENT_PATH)"

echo "::debug::pr_number: ${pr_number}"
echo "::debug::title: ${title}"
echo "::debug::created_at: ${created_at}"
echo "::debug::user: ${user}"
echo "::debug::body: ${body}"

IFS='/' read owner repository <<< "${GITHUB_REPOSITORY}"

if [ "${body}" == "null" ]; then
    echo "::notice title=No Body::There is no Body in the pull request"
fi
echo "pr-number=${pr_number}" >> $GITHUB_OUTPUT
echo "pr-title=${title}" >> $GITHUB_OUTPUT
echo "pr-created_at=${created_at}" >> $GITHUB_OUTPUT
echo "pr-user=${user}" >> $GITHUB_OUTPUT
echo "pr-body=${body}" >> $GITHUB_OUTPUT


exit 0