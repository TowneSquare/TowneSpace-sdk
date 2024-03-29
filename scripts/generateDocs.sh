#!/bin/sh

# Default to experimental if no label given, label must be set to stable explicitly
if [ -n "$1" ]; then
  LABEL=$1;
else
  LABEL="Stable";
fi

# Generate docs by version for the SDK
# References the Github repo directly
echo "Generating docs for version $npm_package_version";

if [ -d "docs/@townesquare/townespace-ts-sdk-$npm_package_version" ]; then
  echo "WARNING! Docs folder already exists, overwriting docs for version $npm_package_version";
fi

npx typedoc src/index.ts --out "docs/@townesquare/townespace-ts-sdk-$npm_package_version" --cleanOutputDir --excludeInternal --includeVersion;

# Update the main page
INDEX_FILE='docs/index.md';

# Get line of the SDK if the version is already there
LINE=$(sed -n "/.*$npm_package_version.*/{=;q;}" $INDEX_FILE);

# If it already exists, we can skip adding it to the file
if [ -n "$LINE" ]; then
  echo "WARNING! Version $npm_package_version already exists on line $LINE, not updating label";
else
  echo "Updating main docs page $INDEX_FILE with version $npm_package_version labeled with $LABEL";

  # This inserts it at the 7th line and is a hack because there are exactly 7 lines until the first SDK version in the file
  FIRST_LINE=7
  NEXT_LINE=$((FIRST_LINE + 1))

  # Add in the middle line the new version.
  {
    head -n $FIRST_LINE $INDEX_FILE;
    echo "- [$LABEL - @townesquare/townespace-ts-sdk-$npm_package_version](@townesquare/townespace-ts-sdk-$npm_package_version)";
    tail -n +$NEXT_LINE $INDEX_FILE;
  } > $INDEX_FILE.tmp && mv $INDEX_FILE.tmp $INDEX_FILE
fi
