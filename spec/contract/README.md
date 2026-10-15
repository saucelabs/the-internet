# HTTP contract suite

Black-box checks that every example keeps the same URLs, status codes, auth challenges, redirects, flash messages, cookies and markup. It runs against any deployment, so the live site is the baseline and the upgraded app is compared to it.

```
cd spec/contract && bundle install
BASE_URL=https://the-internet.herokuapp.com bundle exec rspec   # against live
BASE_URL=http://localhost:9292 bundle exec rspec                # against a local server (default)
```

- `snapshots/` holds the canonical markup of each deterministic page (`#content` only, or the whole document for pages without the layout), recorded from the live site on 2026-10-15. After an intentional markup change, re-record with `UPDATE_SNAPSHOTS=1` and review the diff.
- `:writes` examples (upload, forgot password) only run against localhost unless `ALLOW_WRITES=1`.
- `:unreleased` examples (on `main`, not yet deployed) are skipped against the live site.
