#!/usr/bin/env bash
set -u

ROOT="/Users/chuang/Documents/dev/projects/researching/storage-design-research"
WORK="."
SRC="$WORK/reference/source-inventory.md"
OUT="$WORK/reference/web/batch-08"
RAW="$OUT/raw"
TEXT="$OUT/text"
TMP="$OUT/tmp"
RESULTS="$OUT/results.tsv"
README="$OUT/README.md"

mkdir -p "$RAW" "$TEXT" "$TMP"

sanitize_field() {
  printf '%s' "$1" | tr '\t\r\n' '   ' | sed 's/  */ /g; s/^ //; s/ $//'
}

is_non_web() {
  local url="$1"
  case "$url" in
    mailto:*|git://*|ssh://*) return 0 ;;
  esac
  if printf '%s' "$url" | grep -Eiq '\.(pdf|zip|tar|tar\.gz|tgz|gz|bz2|xz|7z|rar|pptx?|docx?|xlsx?)([?#].*)?$'; then
    return 0
  fi
  return 1
}

has_url_noise() {
  local url="$1"
  if printf '%s' "$url" | grep -Eq '[[:space:]]|\(|\)|（|）'; then
    return 0
  fi
  return 1
}

record_row() {
  local ordinal="$1" category="$2" entity="$3" title="$4" url="$5" status="$6"
  local http_code="$7" content_type="$8" bytes="$9" html_path="${10}" text_path="${11}" error="${12}"
  printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
    "$(sanitize_field "$ordinal")" \
    "$(sanitize_field "$category")" \
    "$(sanitize_field "$entity")" \
    "$(sanitize_field "$title")" \
    "$(sanitize_field "$url")" \
    "$(sanitize_field "$status")" \
    "$(sanitize_field "$http_code")" \
    "$(sanitize_field "$content_type")" \
    "$(sanitize_field "$bytes")" \
    "$(sanitize_field "$html_path")" \
    "$(sanitize_field "$text_path")" \
    "$(sanitize_field "$error")" >> "$RESULTS"
}

printf 'ordinal\tcategory\tentity\ttitle\turl\tstatus\thttp_code\tcontent_type\tbytes\thtml_path\ttext_path\terror\n' > "$RESULTS"

perl -ne '
  next unless /^\| /;
  @f = split /\|/;
  @f = map { s/^\s+|\s+$//gr } @f;
  next unless @f >= 10;
  next if $f[1] eq "---" || $f[1] eq "category";
  next unless $f[5] eq "linked-only";
  $n++;
  if ($n % 10 == 7) {
    print join("\t", $n, @f[1,2,3,4]), "\n";
  }
' "$SRC" > "$TMP/candidates.tsv"

total=0
success=0
failed=0
skipped=0

while IFS=$'\t' read -r ordinal category entity title url; do
  total=$((total + 1))

  if is_non_web "$url"; then
    skipped=$((skipped + 1))
    record_row "$ordinal" "$category" "$entity" "$title" "$url" "skipped-non-web" "" "" "0" "" "" "non-web extension or scheme"
    continue
  fi

  if has_url_noise "$url"; then
    skipped=$((skipped + 1))
    record_row "$ordinal" "$category" "$entity" "$title" "$url" "skipped-malformed-url" "" "" "0" "" "" "url contains spaces or annotation text"
    continue
  fi

  id="$(printf '%s' "$url" | shasum -a 256 | awk '{print substr($1,1,16)}')"
  html="$RAW/$id.html"
  text="$TEXT/$id.md"
  hdr="$TMP/$id.headers"
  body="$TMP/$id.body"
  err="$TMP/$id.err"

  rm -f "$hdr" "$body" "$err"
  http_code="$(env -u http_proxy -u https_proxy -u HTTP_PROXY -u HTTPS_PROXY \
    curl -fL --retry 2 --connect-timeout 10 --max-time 45 \
    -A 'storage-reference-crawler/0.1' \
    -D "$hdr" -o "$body" -w '%{http_code}' "$url" 2> "$err")"
  rc=$?

  content_type="$(awk 'BEGIN{IGNORECASE=1} /^content-type:/ { sub(/\r$/, ""); print substr($0, index($0,$2)); }' "$hdr" | tail -1)"
  bytes=0
  if [ -f "$body" ]; then
    bytes="$(wc -c < "$body" | tr -d ' ')"
  fi

  if [ "$rc" -ne 0 ]; then
    failed=$((failed + 1))
    msg="$(tr '\r\n\t' '   ' < "$err" | sed 's/  */ /g; s/^ //; s/ $//')"
    record_row "$ordinal" "$category" "$entity" "$title" "$url" "failed-fetch" "$http_code" "$content_type" "$bytes" "" "" "curl rc=$rc $msg"
    continue
  fi

  if [ "$bytes" -eq 0 ]; then
    failed=$((failed + 1))
    record_row "$ordinal" "$category" "$entity" "$title" "$url" "failed-empty" "$http_code" "$content_type" "$bytes" "" "" "empty response body"
    continue
  fi

  if ! printf '%s' "$content_type" | grep -Eiq 'text/html|application/xhtml\+xml|text/plain|application/xml|text/xml|application/json|application/octet-stream|^$'; then
    skipped=$((skipped + 1))
    record_row "$ordinal" "$category" "$entity" "$title" "$url" "skipped-non-html" "$http_code" "$content_type" "$bytes" "" "" "content-type not suitable for html/text extraction"
    continue
  fi

  cp "$body" "$html"
  if pandoc -f html -t gfm --wrap=none "$html" -o "$text" > "$TMP/$id.pandoc.out" 2> "$TMP/$id.pandoc.err"; then
    text_bytes="$(wc -c < "$text" | tr -d ' ')"
    if [ "$text_bytes" -lt 80 ]; then
      failed=$((failed + 1))
      record_row "$ordinal" "$category" "$entity" "$title" "$url" "failed-empty-text" "$http_code" "$content_type" "$bytes" "$html" "$text" "converted markdown too small: ${text_bytes} bytes"
    elif grep -Eiq 'enable javascript|requires javascript|sign in|log in|access denied|captcha|checking your browser' "$text"; then
      failed=$((failed + 1))
      record_row "$ordinal" "$category" "$entity" "$title" "$url" "failed-js-login-or-access" "$http_code" "$content_type" "$bytes" "$html" "$text" "converted content appears to require js login captcha or access"
    else
      success=$((success + 1))
      record_row "$ordinal" "$category" "$entity" "$title" "$url" "fetched" "$http_code" "$content_type" "$bytes" "$html" "$text" ""
    fi
  else
    failed=$((failed + 1))
    msg="$(tr '\r\n\t' '   ' < "$TMP/$id.pandoc.err" | sed 's/  */ /g; s/^ //; s/ $//')"
    record_row "$ordinal" "$category" "$entity" "$title" "$url" "failed-pandoc" "$http_code" "$content_type" "$bytes" "$html" "" "$msg"
  fi
done < "$TMP/candidates.tsv"

{
  printf '# batch-08 crawl report\n\n'
  printf '%s\n' "- Crawl time: $(date -u '+%Y-%m-%dT%H:%M:%SZ')"
  printf '%s\n' '- Shard rule: linked-only ordinal n % 10 == 7'
  printf '%s\n' "- Processed: $total"
  printf '%s\n' "- Fetched: $success"
  printf '%s\n' "- Failed: $failed"
  printf '%s\n\n' "- Skipped: $skipped"
  printf '## Limits\n\n'
  printf '%s\n' '- curl only fetched public HTTP/HTTPS responses; login, CAPTCHA, strong JavaScript shells, malformed annotated URLs, and non-web binaries were recorded rather than synthesized.'
  printf '%s\n\n' '- Markdown was extracted with pandoc from saved HTML snapshots.'
  printf '## Priority local Markdown\n\n'
  awk -F '\t' 'NR > 1 && $6 == "fetched" { print "- `" $11 "` - " $3 " / " $4 }' "$RESULTS" | head -12
  printf '\n## Failure summary\n\n'
  awk -F '\t' 'NR > 1 && $6 != "fetched" { count[$6]++ } END { for (s in count) print "- " s ": " count[s] }' "$RESULTS" | sort
} > "$README"

printf 'processed=%s fetched=%s failed=%s skipped=%s\n' "$total" "$success" "$failed" "$skipped"
