## 🧭 Purpose
This file is a compact reference for AI coding assistants to become productive quickly in this Rails codebase.

---

## 🚀 Quickstart (Docker)
- Build and start services:  
  `docker compose build --no-cache && docker compose up --detach`
- Create/migrate DB and run migrations inside the web container:  
  `docker compose exec web bundle exec rails db:create db:migrate`
- Open a Rails console inside the container:  
  `docker compose exec web bin/rails c`
- Run the test suite:  
  `docker compose exec web bundle exec rspec`

Notes:
- The compose setup expects PostgreSQL host `db` (see `config/database.yml`).  Default POSTGRES_PASSWORD is `password` in `docker-compose.yml`.
- `start.sh` waits for Postgres and then runs `bundle`, `yarn`, `db:migrate`, and starts Puma — useful for local dockerized dev.

---

## 🏗️ Architecture & key components
- Rails 7 app (Ruby 3.2.x) - see `Gemfile`.
- PostgreSQL as DB (`config/database.yml`). Docker service name is `db`.
- Auth: Devise (`gem 'devise'`) — check `config/initializers/devise.rb` and `app/models/user.rb`.
- Frontend stack: Turbo, Stimulus, Tailwind (`tailwindcss-rails`, `turbo-rails`, `stimulus-rails`) and JS via `app/javascript` (entry: `app/javascript/application.js`).
- Assets served via Propshaft (`gem 'propshaft'`) and Tailwind build script in `package.json` (`npm run build:css`).
- File uploads: Active Storage is present (local in development). Example: `has_one_attached :snapshot` in `app/models/actual_outfit.rb`.

---

## 🔧 Project-specific conventions & patterns
- Use Turbo data attributes in views for confirmation and methods (see `app/views/items/show.html.erb`, uses `data: { turbo_method: :delete, turbo_confirm: ... }`).
- Mailer dev flow uses `letter_opener_web` in development (see `config/environments/development.rb`).
- `entrypoint.sh` and `start.sh` handle common Docker startup concerns (remove stale `tmp/pids/server.pid`, wait for DB, run installs and migration).

Examples to reference when implementing features:
- Model attachments: `app/models/actual_outfit.rb` (`has_one_attached :snapshot`).
- View behaviors: `app/views/items/show.html.erb` (Turbo deletion pattern).

---

## ✅ Tests and CI notes
- Tests: RSpec + FactoryBot (`gem 'rspec-rails'`, `gem 'factory_bot_rails'`). Run with `bundle exec rspec` (inside container preferred).
- System specs use Capybara + Selenium (`selenium-webdriver`), so expect JS/system tests to rely on a browser driver. If running CI or headless containers, ensure the driver environment is configured.

---

## ⚠️ Gotchas & tips
- DB host in docker is `db`; when running locally without docker, adjust `config/database.yml` or environment variables.
- When changing assets/CSS, run `npm run build:css` (see `package.json`).
- If the web process fails with "server is already running", check `tmp/pids/server.pid` — `entrypoint.sh` removes it on start.

---

## ❓ When in doubt — ask for:
- Expected behavior for a page or flow (attach a screenshot or link to the Figma in `README.md`).
- Whether you should add DB migrations and where to place them (naming conventions follow Rails defaults).

---

If you'd like, I can open a PR with this file or expand sections with concrete examples/snippets (e.g., common test helpers or a recommended rspec command matrix). Please tell me what to add or clarify. ✅
