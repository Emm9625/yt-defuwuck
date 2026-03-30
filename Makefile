MODULES = \
	filters/shorts.txt \
	filters/comments.txt \
	filters/playables.txt \
	filters/subscriptions.txt

MASTERLIST = dist/masterlist.txt
HOMEPAGE = https://github.com/Emm9625/yt-defuwuck
LICENSE_URL = https://github.com/Emm9625/yt-defuwuck/blob/main/LICENSE.md

.PHONY: all masterlist verify

all: masterlist

masterlist: $(MASTERLIST)

$(MASTERLIST): $(MODULES)
	@mkdir -p "$$(dirname "$@")"; \
	tmp_file="$$(mktemp)"; \
	version="$$(TZ=UTC stat -f '%Sm' -t '%Y.%-m.%-d' $(MODULES) | sort | tail -n 1)"; \
	modified="$$(TZ=UTC stat -f '%Sm' -t '%Y-%m-%d %H:%M' $(MODULES) | sort | tail -n 1)"; \
	printf '%s\n' \
		'! Title: yt-defuwuck — Masterlist' \
		'! Description: Combined yt-defuwuck masterlist in canonical module order' \
		"! Version: $$version" \
		"! Last modified: $$modified" \
		'! Expires: 2 weeks (update frequency)' \
		'! Homepage: $(HOMEPAGE)' \
		'! License: $(LICENSE_URL)' \
		'' > "$$tmp_file"; \
		for module in $(MODULES); do \
			awk 'BEGIN { in_body = 0; pending_blank = 0 } /^$$/ { if (!in_body) { in_body = 1; next } pending_blank = 1; next } !in_body || /^!/ { next } { if (pending_blank) { print ""; pending_blank = 0 } print }' "$$module" >> "$$tmp_file"; \
			printf '\n' >> "$$tmp_file"; \
		done; \
		mv "$$tmp_file" "$@"

verify:
	@tmp_file="$$(mktemp)"; \
	rm -f "$$tmp_file"; \
	$(MAKE) --no-print-directory -B MASTERLIST="$$tmp_file" masterlist; \
	cmp -s "$$tmp_file" "$(MASTERLIST)" || (printf '%s\n' 'masterlist is out of date' && rm -f "$$tmp_file" && exit 1); \
	rm -f "$$tmp_file"
