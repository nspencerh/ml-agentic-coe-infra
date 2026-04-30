# ml-template-repo

This is a base template repository that can be used to clone and create other machine learning and AI engineering projects.

## Features & Setup

This template is pre-configured with modern Python tooling and CI/CD practices:

- **Dependency Management:** Uses [`uv`](https://github.com/astral-sh/uv) for fast and reliable dependency resolution.
- **Build System:** Configured with `hatchling` via `pyproject.toml`.
- **Linting & Formatting:** Uses [`ruff`](https://github.com/astral-sh/ruff), replacing older tools like flake8 and black.
- **Type Checking:** Uses Astral's new blazingly fast type checker [`ty`](https://github.com/astral-sh/ty).
- **Testing:** Pre-configured with `pytest`.
- **Pre-commit Hooks:** Included `.pre-commit-config.yaml` to ensure code quality before commits.
- **Security:** Integrated `bandit` (SAST) and `pip-audit` (dependency vulnerabilities).
- **CI/CD Workflows (`.github/workflows/`):**
  - **Lint and Format:** Automatically runs `ruff check` and `ruff format` on PRs and pushes.
  - **Security Scan:** Runs `bandit` and `pip-audit` on PRs, pushes, and on a weekly schedule.
  - **Deployment / Unit Tests:** Basic pipeline to run tests and deploy infrastructure (commented/adjustable based on environment).
- **Standardized Ignored Paths:** `.gitignore` includes setups for local `data/` directories and `mlruns/` to prevent committing artifacts.

## Post-Clone Checklist

Once you have generated a new repository from this template, immediately complete the following steps to customize it for your specific project:

1.  **Update `pyproject.toml`:**
    *   Change the `name` field from `"ml-template"` to your new project's name (e.g., `"customer-churn-model"`).
    *   Update the `description`.
    *   Reset the `version` to `"0.1.0"` or your preferred starting version.
    *   Add or remove packages in the `dependencies` list as needed for your specific workload (e.g., `uv add boto3 polars`).
2.  **Update `README.md`:** Replace the contents of this file with documentation specific to your new project.
3.  **Configure CI/CD Workflows (`.github/workflows/cicd.yaml`):**
    *   Update environment variables like `AWS_REGION` if necessary.
    *   Uncomment the deployment jobs and update the AWS OIDC roles and account IDs (`<ACCOUNT_ID>`, `<DISCOVERY_ROLE_NAME>`, etc.) when your infrastructure is ready to be deployed.
    *   Uncomment the `run_tests` job dependency once you have added actual test files to the `tests/` directory.
    *   Set up environment variables in github correspondingly
4. **Configure `.pre-commit-config.yaml`**: This template includes both mandatory and optional pre-commit hooks to enforce code quality and security.
    *   **Mandatory Hooks (Enabled by default):**
        *   **Standard File Fixers:** Trims trailing whitespace, fixes EOF, checks YAML/TOML/JSON syntax, prevents committing large files or merge conflicts, and catches debug statements.
        *   **Python Quality (Local via `uv`):** Runs `ruff` (linting & formatting) and `ty` (type checking) instantly using your local virtual environment.
        *   **Security (Local via `uv`):** Runs `bandit` for Python Static Application Security Testing (SAST).
        *   **Documentation (Local via `uv`):** Uses `ruff` (enabled via the `D` rules in `pyproject.toml`) to enforce docstring presence and style.
        *   **Secret Scanning:** Uses `gitleaks` (managed automatically by pre-commit) to detect hardcoded secrets, API keys, and passwords.
    *   **Optional Hooks (Commented out at the bottom of the file):**
        *   **Jupyter Notebooks:** `nbstripout` automatically clears notebook execution outputs before committing.
        *   **Terraform:** Hooks to lint, format, and validate Infrastructure as Code.
        *   **GitHub Actions:** `actionlint` to validate `.github/workflows` syntax.
    *   **Action:** Review `.pre-commit-config.yaml` and uncomment any optional hooks that your project requires.

## Usage

1. **Install Dependencies:**
   ```bash
   uv sync
   ```
2. **Setup Pre-commit:**
   ```bash
   pre-commit install
   ```
3. **Develop:**
   - Format code: `uv run ruff format .`
   - Lint code: `uv run ruff check .`
   - Type check: `uv run ty check .`
   - Run tests: `uv run pytest`
   - Security scan: `uv run bandit -r src/ -ll -ii` and `uv run pip-audit`
4. **Configure CI/CD:**
   - Uncomment unit test run in `.github/workflows/unit_test.yaml` when tests are ready.
   - Uncomment and update the deployment jobs in `.github/workflows/cicd.yaml` when your infrastructure (e.g., AWS OIDC) and tests are ready.
   - Note: The `run_tests` job in `cicd.yaml` might be temporarily commented out if there are no test files initially. Uncomment it once tests are added.

## Note on Repository Settings
Repository settings like branch protection and collaborators do not currently carry over when cloning as a template. (See related Gitea issue: [gitea#14303](https://github.com/go-gitea/gitea/issues/14303)).
