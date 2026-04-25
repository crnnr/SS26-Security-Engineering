# SS26-Security-Engineering

> Studienarbeit *Secure DevOps (DevSecOps) -- Sicherheitstechnische Betrachtung
> automatisierter CI/CD-Pipelines* (TH Deggendorf, SS 2026).

## Inhalt

| Pfad | Zweck |
| --- | --- |
| `app/` | Demo-App (Flask) als Subject-Under-Test |
| `Dockerfile` | Multi-stage, non-root, distroless-style Image |
| `.github/workflows/ci.yml` | Lint, Tests, SAST (Bandit, CodeQL), SCA (pip-audit), Secret-Scan, Container-Scan (Trivy), SBOM (Syft/CycloneDX), Cosign-Signing, SLSA-Provenance |
| `.github/workflows/cd.yml` | Tag-Trigger, Cosign-Verify, Staging $\to$ Production via Environments + Manual Approval |
| `.github/workflows/scorecard.yml` | OpenSSF Scorecard |
| `.github/dependabot.yml` | Wöchentliche Updates für pip / docker / actions |
| `.github/CODEOWNERS` | Vier-Augen-Prinzip für `main` und Pipelines |
| `.pre-commit-config.yaml` | Lokale Hooks (ruff, bandit, gitleaks) |
| `Pitch/` | Themenanmeldung (LaTeX) |
| `Doc/` | Projektdokumentation zur Abgabe (LaTeX) |

## Lokale Entwicklung

```bash
python -m venv .venv && source .venv/bin/activate
pip install -r app/requirements.txt -r app/requirements-dev.txt
pre-commit install
pytest
```

## Branch-Protection (manuell zu setzen)

- `main`: required reviews = 1, CODEOWNERS-Review verpflichtend,
  Status-Checks `lint-test`, `sast`, `sca`, `secret-scan`, `build-image`
  required, signed commits, kein force-push, lineare History.
- Environment `production`: required reviewer + wait-timer 5 min.
