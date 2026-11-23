#!/usr/bin/env bash
# Upload a static build directory to S3 with per-file Cache-Control and
# Content-Type. Non-HTML files go first and HTML last, so freshly uploaded HTML
# never references an asset that isn't there yet. Pruning stale objects is a
# separate step (see deploy.yml).
#
# Usage: s3-upload.sh <dist-dir> <bucket>
# Set DRY_RUN=1 to print the aws commands instead of running them.
set -euo pipefail

DIST="${1:?dist dir required}"
BUCKET="${2:?bucket required}"

CC_IMMUTABLE="public, max-age=31536000, immutable"
CC_HTML="public, max-age=0, must-revalidate"
CC_SEO="public, max-age=3600"
CC_DEFAULT="public, max-age=86400"

cache_control() {
  case "$1" in
    _astro/*) echo "$CC_IMMUTABLE" ;;
    *.html) echo "$CC_HTML" ;;
    sitemap*.xml | robots.txt | site.webmanifest) echo "$CC_SEO" ;;
    *) echo "$CC_DEFAULT" ;;
  esac
}

content_type() {
  local ext="${1##*.}"
  case "${ext,,}" in
    html) echo "text/html; charset=utf-8" ;;
    css) echo "text/css; charset=utf-8" ;;
    js | mjs) echo "text/javascript; charset=utf-8" ;;
    json | map) echo "application/json" ;;
    webmanifest) echo "application/manifest+json" ;;
    xml) echo "application/xml" ;;
    txt) echo "text/plain; charset=utf-8" ;;
    svg) echo "image/svg+xml" ;;
    avif) echo "image/avif" ;;
    webp) echo "image/webp" ;;
    png) echo "image/png" ;;
    jpg | jpeg) echo "image/jpeg" ;;
    gif) echo "image/gif" ;;
    ico) echo "image/x-icon" ;;
    woff2) echo "font/woff2" ;;
    woff) echo "font/woff" ;;
    pdf) echo "application/pdf" ;;
    *) echo "" ;; # let the AWS CLI guess
  esac
}

# Group files by (cache-control, content-type) so each group is a single
# `aws s3 cp --recursive` call instead of one process per file.
declare -A groups_asset=() groups_html=()
while IFS= read -r -d '' path; do
  rel="${path#"$DIST"/}"
  key="$(cache_control "$rel")|$(content_type "$rel")"
  if [[ "$rel" == *.html ]]; then
    groups_html["$key"]+="${rel}"$'\n'
  else
    groups_asset["$key"]+="${rel}"$'\n'
  fi
done < <(find "$DIST" -type f -print0 | sort -z)

upload_group() {
  local key="$1" files="$2"
  local cc="${key%%|*}" ct="${key#*|}"
  local args=(s3 cp "$DIST" "s3://${BUCKET}" --recursive --exclude "*" --only-show-errors
    --cache-control "$cc" --metadata-directive REPLACE)
  [[ -n "$ct" ]] && args+=(--content-type "$ct")
  local n=0
  while IFS= read -r f; do
    [[ -z "$f" ]] && continue
    # Escape glob metacharacters so filenames match literally.
    args+=(--include "$(printf '%s' "$f" | sed 's/[][*?]/[&]/g')")
    n=$((n + 1))
  done <<<"$files"
  echo "Uploading ${n} file(s): Cache-Control='${cc}' Content-Type='${ct:-auto}'"
  if [[ "${DRY_RUN:-0}" == "1" ]]; then
    printf '  aws'; printf ' %q' "${args[@]}"; printf '\n'
  else
    aws "${args[@]}"
  fi
}

echo "== Assets =="
for key in "${!groups_asset[@]}"; do upload_group "$key" "${groups_asset[$key]}"; done
echo "== HTML =="
for key in "${!groups_html[@]}"; do upload_group "$key" "${groups_html[$key]}"; done
