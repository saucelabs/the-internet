# CLAUDE.md

The Internet — a Sinatra app of deliberately "ugly" web patterns used worldwide to practice test automation. Live at https://the-internet.herokuapp.com. Owned by Sauce Labs.

## Golden rule: don't break existing users
Thousands of tutorials, courses and test suites target the live site. Treat every example page's **URLs, DOM structure, ids, classes, element text and behaviour as a public API**.
- Never rename/remove ids, classes, or change text/flow of an existing example unless explicitly asked.
- Shared chrome selectors in `views/layout.erb` are also relied on: `#flash-messages`, `#flash`, `.flash.success|error|notice`, `#content`, `#page-footer`, `.example`, `h3`.
- Restyling must be CSS/layout-chrome only. New behaviour → new example page or a new query param.

## Layout
- `server.rb` — all routes. Two Rack apps:
  - `Protected` — `/digest_auth` (digest auth via `lib/digest_auth.rb`, admin/admin), mounted in `config.ru`.
  - `Public` — everything else.
- `config.ru` — `Rack::URLMap` mounting the two apps.
- `views/*.erb` — one view per example; `layout.erb` is the shared shell. Some views render without layout (frames, `/windows/new`, `/javascript_error`).
- `views/examples.erb` — **generated** from `examples.csv` by `rake gen_docs` (also regenerates `README.md` from `README.template`). Edit the CSV, not the view.
- `views/scss/` — old Foundation 4 + Compass sources (no longer buildable); `public/css/app.css` is the source of truth until the styling rework.
- `public/js/vendor/` — vendored jQuery 1.11, jQuery UI 1.11, tablesorter, jscroll, dropzone, ouibounce, stickyfloat. `298279967.js` is a self-contained Optimizely Classic snippet that **drives `/abtest`** ("A/B Test Control"/"Variation 1", `optimizelyOptOut` cookie) — only on the `the-internet.herokuapp.com` hostname, so locally `/abtest` always shows "No A/B Test". Do not remove it.
- `/tinymce` uses TinyMCE 6.8.6 (MIT, last MIT release; 7+ is GPL), vendored minimal in `public/js/vendor/tinymce/` with the `tinymce-5` skin to match the old look. Do not switch to Tiny Cloud (editor-load quota made it read-only).
- `public/uploads/` — target of `/upload`, listed by `/download` and `/download_secure`.
- `spec/contract/` — HTTP contract suite (black-box, any `BASE_URL`): statuses, auth, redirects, flash, cookies and markup snapshots recorded from the live site. Run it after any change. See its README.
- `spec/e2e/` — Selenium 4 browser suite, one scenario per example; local headless (`rake e2e`, `BROWSER=chrome|firefox|edge|safari`) or Sauce Labs (`TARGET=saucelabs`, needs `SAUCE_USERNAME`/`SAUCE_ACCESS_KEY`, plus `SAUCE_TUNNEL_NAME` for a localhost app).
- `config/puma.rb`, `Procfile` — server config for Heroku and Docker.

## Adding an example
1. Route in `server.rb` (`Public` class) + view in `views/`.
2. Row in `examples.csv` (`title,url_path,notes`).
3. `bundle exec rake gen_docs`.
4. Contract entry in `spec/contract/pages.rb` (+ snapshot) and an E2E scenario in `spec/e2e/examples/`.
5. Bump `VERSION` and add a matching entry at the top of `changelog.md` (every PR; CI checks it).

## Run
Ruby version is in `.ruby-version` (Gemfile reads it).
```
bundle install
bundle exec rackup            # http://localhost:9292
bundle exec rake contract     # boots the app and runs the HTTP contract suite
```
Markup change on purpose? Re-record snapshots with `UPDATE_SNAPSHOTS=1` and review the diff.

## Deploy
Heroku app `the-internet`, `web` process from `Procfile` (puma). Config vars: `SESSION_SECRET` (shared by all puma workers); for real Forgot Password email `SMTP_ADDRESS`, `SMTP_PORT`, `SMTP_USERNAME`, `SMTP_PASSWORD`, `MAIL_FROM` (without `SMTP_ADDRESS`, mail is only logged). `WEB_CONCURRENCY` sets puma workers. Deploys: the `deploy` job in `.github/workflows/ci.yml` pushes `main` to Heroku git after all CI jobs pass (secret `HEROKU_API_KEY`; the Heroku GitHub integration is not allowed in the saucelabs org). After deploying, it tags the commit with `VERSION` (every merged PR is a release). Docker image goes to `ghcr.io/saucelabs/the-internet` (private).

## Credentials baked into examples (intentional)
- Form login: `tomsmith` / `SuperSecretPassword!`
- Basic, digest, secure download: `admin` / `admin`
