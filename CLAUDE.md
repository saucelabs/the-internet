# CLAUDE.md

The Internet — a Sinatra app of deliberately "ugly" web patterns used worldwide to practice test automation. Live at https://the-internet.herokuapp.com. Owned by Sauce Labs.

## Golden rule: don't break existing users
Thousands of tutorials, courses and test suites target the live site. Treat every example page's **URLs, DOM structure, ids, classes, element text and behaviour as a public API**.
- Never rename/remove ids, classes, or change text/flow of an existing example unless explicitly asked.
- Shared chrome selectors in `views/layout.erb` are also relied on: `#flash-messages`, `#flash`, `.flash.success|error|notice`, `#content`, `#page-footer`, `.example`, `h3`.
- Restyling must be CSS/layout-chrome only. New behaviour → new example page or a new query param.

## Layout
- `server.rb` — all routes. Two Rack apps:
  - `Protected` — `/digest_auth` (Rack Digest auth, admin/admin), mounted in `config.ru`.
  - `Public` — everything else.
- `config.ru` — `Rack::URLMap` mounting the two apps.
- `views/*.erb` — one view per example; `layout.erb` is the shared shell. Some views render without layout (frames, `/windows/new`, `/javascript_error`).
- `views/examples.erb` — **generated** from `examples.csv` by `rake gen_docs` (also regenerates `README.md` from `README.template`). Edit the CSV, not the view.
- `views/scss/` — Foundation 4 + Compass sources; compiled output is checked in at `public/css/app.css`. Compass is dead; treat `app.css` as the source of truth until the styling rework.
- `public/js/vendor/` — vendored jQuery 1.11, jQuery UI 1.11, tablesorter, jscroll, dropzone, ouibounce, stickyfloat; `298279967.js` is a dead Optimizely Classic snippet.
- `public/uploads/` — target of `/upload`, listed by `/download` and `/download_secure`.
- `spec/` — Selenium RSpec examples (page objects in `spec/pages/`). They hit the **live** site / Sauce Labs, not the local app. There are no app-level tests.

## Adding an example
1. Route in `server.rb` (`Public` class) + view in `views/`.
2. Row in `examples.csv` (`title,url_path,notes`).
3. `bundle exec rake gen_docs`.
4. Entry in `changelog.md`, bump `VERSION`.

## Run
```
bundle install
bundle exec rackup          # http://localhost:9292
```
Selenium specs: `host=localhost base_url=http://localhost:9292 bundle exec rspec`.

## Deploy
Heroku app `the-internet` (no Procfile; Heroku Ruby buildpack runs `rackup`). Docker image `tourdedave/the-internet` was built by Travis (`.travis.yml`, `docker_push.sh`) — Travis is defunct.

## Credentials baked into examples (intentional)
- Form login: `tomsmith` / `SuperSecretPassword!`
- Basic, digest, secure download: `admin` / `admin`

## Upgrade work
See `docs/UPGRADE_PLAN.md`.
