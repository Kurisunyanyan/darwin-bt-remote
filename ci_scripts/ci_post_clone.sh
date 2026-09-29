#!/usr/bin/env bash

which xcodegen || brew install xcodegen

cd "${CI_PRIMARY_REPOSITORY_PATH:-.}"
for file in company_ids service_uuids; do
    [ -f "BTRemote/Resources/$file.json" ] || curl -fsSL -o "BTRemote/Resources/$file.json" "https://raw.githubusercontent.com/NordicSemiconductor/bluetooth-numbers-database/master/v1/$file.json"
done
xcodegen generate
