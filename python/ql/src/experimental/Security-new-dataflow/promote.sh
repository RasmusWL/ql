#!/bin/bash
set -Eeuo pipefail # see https://vaneyckt.io/posts/safer_bash_scripts_with_set_euxo_pipefail/

# Promotes new dataflow queries to the real ones for dist-compare

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

cd $SCRIPTDIR
for file in $(find . -name '*.ql'); do
    mv "$file" "../../Security/${file}"
done
