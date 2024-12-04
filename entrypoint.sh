#!/bin/bash

set -euo pipefail

echo "::debug::Seting the release URL"
echo "release-url=http://example.com" >> $GITHUB_OUTPUT

exit 0