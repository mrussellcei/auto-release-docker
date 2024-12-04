#!/bin/bash

set -euo pipefail

echo "::debug::Seting the release URL"
echo "::set-output name=release-url::http://example.com"

exit 0