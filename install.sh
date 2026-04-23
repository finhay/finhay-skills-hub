#!/bin/bash

set -e

REPO_URL="https://github.com/finhay/finhay-skills-hub.git"
BRANCH="main"
WORKDIR="_tmp_finhay_skills_hub"
CURDIR="$(pwd)"

rm -rf "$CURDIR/finhay-market" "$CURDIR/finhay-portfolio" "$CURDIR/finhay-market.zip" "$CURDIR/finhay-portfolio.zip" "$CURDIR/$WORKDIR"

git clone -b "$BRANCH" "$REPO_URL" "$CURDIR/$WORKDIR"

cd "$CURDIR/$WORKDIR"
chmod +x finhay.sh

for skill_dir in skills/*; do
  [ -d "$skill_dir" ] || continue
  skill_name=$(basename "$skill_dir")
  rm -f "skills/$skill_name/finhay.sh" "skills/$skill_name/finhay.ps1"
  cp finhay.sh "skills/$skill_name/finhay.sh"
  cp finhay.ps1 "skills/$skill_name/finhay.ps1"
done

cd "skills"
zip -r "$CURDIR/finhay-market.zip" finhay-market
zip -r "$CURDIR/finhay-portfolio.zip" finhay-portfolio

cd "$CURDIR"
rm -rf "$WORKDIR"

echo "Done. Created $CURDIR/finhay-market.zip and $CURDIR/finhay-portfolio.zip."
