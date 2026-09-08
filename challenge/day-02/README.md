# Day 2 — Repository Structure, Reproducible Environment & Docs Skeleton

**Phase:** Foundations · **Time budget:** 10–12 h · **Skill focus:** engineering hygiene, packaging, CI
**Prereqs:** Day 1 PR merged.

## Why this day matters

A data platform interview will include "how do you make your work reproducible" and "walk me
through your CI." Today you make the repo something a new contributor can clone and run, and you
make green CI mean something. Sloppy foundations here cost you hours every later day.

## Mission

Turn the scaffold into a working project skeleton: an installable package, a task runner, a
local infra stack that starts with one command, pre-commit + CI that actually gate, and a docs
tree with real (if short) pages.

## Challenges

### C1 — Package & dependency management (~2 h)
- Make the repo an installable Python package (`pyproject.toml`, `src/` layout or the existing
  top-level modules — decide and record it).
- Pin dependencies with a lockfile. Every dependency line gets a comment saying why it's there.
- Provide `make setup` that creates the env and installs the package editable + dev extras.
- Acceptance: fresh clone → `make setup` → `python -c "import <yourpkg>"` works.

### C2 — Task runner & local infra (~2.5 h)
- Flesh out the `Makefile`: `setup`, `lint`, `fmt`, `test`, `up`, `down`, `logs`, `clean`.
- Write `docker-compose.yml` (or `deploy/local/`) with placeholder-but-real services you'll grow
  into: a broker, a Postgres, Prometheus, Grafana. They don't need to *do* anything yet, but
  `make up` must bring them healthy and `make down` must clean up volumes.
- Acceptance: `make up` → all containers `healthy` in `docker compose ps`; `make down` leaves no
  dangling volumes.

### C3 — Pre-commit & CI gates (~2.5 h)
- `.pre-commit-config.yaml`: formatter, linter, YAML/JSON check, large-file guard, secret scanner.
- Wire a CI workflow (GitHub Actions) that runs lint + tests + secret scan on every PR. Mirror
  the intent of the repo's existing `.gitlab-ci.yml` stages (validate, quality, security).
- Add one real test (e.g. "the package imports", "the compose file parses") so `make test` is
  not empty.
- Acceptance: open a PR with a deliberately unformatted file and a fake secret; CI goes red on
  both; fix them; CI goes green.

### C4 — Docs tree (~2.5 h)
- Create real pages (short is fine, TODO-marked is fine) for: `docs/data-dictionary.md`,
  `docs/deployment.md`, `docs/privacy.md`, `docs/runbooks/README.md`, `docs/glossary.md`.
- Move Day 1's requirements/architecture/capacity docs into a coherent `docs/` index
  (`docs/README.md` linking everything).
- Add a `CONTRIBUTING.md` describing the branch-per-day + PR flow you're using.
- Acceptance: `docs/README.md` links every doc; no dead links (`make docs-linkcheck` or a
  manual pass).

### Stretch (optional)
- Add a `devcontainer.json` so the environment is reproducible in Codespaces / VS Code.
- Add `make bootstrap-data` that downloads the PhysioNet BIDMC set into `data/raw/` if absent
  (you already have it, but script it for the fresh-clone story).

## Deliverables (branch `day-02-scaffold`)

- `pyproject.toml` + lockfile, `Makefile`, `docker-compose.yml`
- `.pre-commit-config.yaml`, `.github/workflows/ci.yml`
- `docs/README.md` + the new doc stubs, `CONTRIBUTING.md`
- At least one passing test in `tests/`

## Definition of done

- [ ] Fresh clone → `make setup && make up && make test` all succeed.
- [ ] CI is red on an unformatted file and a planted secret, green after fixes.
- [ ] `make down` cleans volumes.
- [ ] `docs/README.md` is a working index; ADR dir carried over from Day 1.
- [ ] `interview.md` answered.

## Hints (open only if stuck)

- `src/` layout avoids "it works because I'm in the repo root" import bugs. If you keep the flat
  layout (`ingestion/`, `processing/`, …), add an `__init__.py` strategy and record why.
- For compose health: give each service a `healthcheck:` and use `depends_on: condition:
  service_healthy` so `make up` blocks until ready.
- `detect-secrets scan > .secrets.baseline` then commit the baseline; the pre-commit hook diffs
  against it. `gitleaks` is a zero-config alternative.
- Keep CI fast: cache the Python env, don't build Spark images today.
- Don't gold-plate the docs. One paragraph + a TODO list per page is the target.
