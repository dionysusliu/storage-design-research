#!/usr/bin/env bash
set -u

ROOT="."
BATCH="$ROOT/reference/web/batch-09"
SRC="$ROOT/reference/source-inventory.md"
RAW="$BATCH/raw"
TEXT="$BATCH/text"
RESULTS="$BATCH/results.tsv"

mkdir -p "$RAW" "$TEXT"

tsv_clean() {
  printf '%s' "${1:-}" | tr '\t\r\n' '   '
}

is_skip_url() {
  local u_lc
  u_lc="$(printf '%s' "$1" | tr '[:upper:]' '[:lower:]')"
  case "$u_lc" in
    mailto:*|git:*|ssh:*|*.pdf|*.pdf\?*|*.zip|*.zip\?*|*.tar|*.tar.gz|*.tgz|*.gz|*.bz2|*.xz)
      return 0
      ;;
  esac
  return 1
}

printf 'ordinal\tcategory\tentity\ttitle\turl\tstatus\thttp_code\tcontent_type\tbytes\thtml_path\ttext_path\terror\n' > "$RESULTS"

awk -F'|' '
  NR > 2 && $0 ~ /\| linked-only \|/ {
    c++;
    if (c % 10 == 8) {
      for (i = 2; i <= 6; i++) {
        gsub(/^ +| +$/, "", $i);
      }
      print c "\t" $2 "\t" $3 "\t" $4 "\t" $5;
    }
  }
' "$SRC" | while IFS=$'\t' read -r ordinal category entity title url; do
  html_path=""
  text_path=""
  http_code=""
  content_type=""
  bytes="0"
  error=""
  status="failed"

  if is_skip_url "$url"; then
    status="skipped"
    error="non-html-or-non-http-resource"
    printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
      "$(tsv_clean "$ordinal")" "$(tsv_clean "$category")" "$(tsv_clean "$entity")" "$(tsv_clean "$title")" \
      "$(tsv_clean "$url")" "$status" "$http_code" "$content_type" "$bytes" "$html_path" "$text_path" "$(tsv_clean "$error")" >> "$RESULTS"
    continue
  fi

  sha="$(printf '%s' "$url" | shasum -a 256 | awk '{print substr($1,1,16)}')"
  tmp_html="$RAW/$sha.tmp"
  header_path="$RAW/$sha.headers"
  final_html="$RAW/$sha.html"
  final_md="$TEXT/$sha.md"
  meta_path="$RAW/$sha.meta"

  rm -f "$tmp_html" "$header_path" "$meta_path"
  curl_status=0
  env -u http_proxy -u https_proxy -u HTTP_PROXY -u HTTPS_PROXY \
    curl -fL --retry 2 --connect-timeout 10 --max-time 45 \
      -A 'storage-reference-crawler/0.1' \
      -D "$header_path" \
      -o "$tmp_html" \
      -w '%{http_code}\t%{content_type}\t%{size_download}' \
      "$url" > "$meta_path" 2> "$RAW/$sha.curl.stderr" || curl_status=$?

  if [ -s "$meta_path" ]; then
    IFS=$'\t' read -r http_code content_type bytes < "$meta_path"
  fi

  if [ "$curl_status" -ne 0 ]; then
    status="failed"
    error="curl-exit-$curl_status"
    if [ -s "$RAW/$sha.curl.stderr" ]; then
      err_tail="$(tail -n 2 "$RAW/$sha.curl.stderr" | tr '\t\r\n' '   ')"
      error="$error $err_tail"
    fi
  elif [ ! -s "$tmp_html" ]; then
    status="failed"
    error="empty-body"
  elif ! printf '%s' "$content_type" | grep -qi 'html'; then
    status="skipped"
    error="non-html-content-type"
  else
    mv "$tmp_html" "$final_html"
    html_path="${final_html#$ROOT/}"
    if pandoc -f html -t gfm --wrap=none "$final_html" -o "$final_md" >/dev/null 2> "$RAW/$sha.pandoc.stderr" && [ -s "$final_md" ]; then
      text_path="${final_md#$ROOT/}"
      status="success"
      error=""
    else
      status="failed"
      error="pandoc-or-empty-markdown"
      text_path=""
    fi
  fi

  if [ "$status" != "success" ]; then
    rm -f "$tmp_html"
  fi

  printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
    "$(tsv_clean "$ordinal")" "$(tsv_clean "$category")" "$(tsv_clean "$entity")" "$(tsv_clean "$title")" \
    "$(tsv_clean "$url")" "$status" "$(tsv_clean "$http_code")" "$(tsv_clean "$content_type")" "$(tsv_clean "$bytes")" \
    "$(tsv_clean "$html_path")" "$(tsv_clean "$text_path")" "$(tsv_clean "$error")" >> "$RESULTS"
done
