---
name: python-dev-standards
description: Python development standards, dependency management with uv, ruff, bandit, pytest, type hints, and documentation. Use when writing Python code, adding new features, or fixing bugs in Python.
---

# Python Development Standards

This skill provides mandatory standards for Python development in this project.

## Development Standards
- **Python Version**: >= 3.12
- **Dependency Management**: Use `uv` for all package management and synchronization.
- **Build System**: Hatchling (`hatchling`) or similar modern PEP 621 compliant build system.
- **Formatting & Linting**: Ruff is used for linting and formatting.
- **Security Scanning**: `bandit` is used for Static Application Security Testing (SAST) and `pip-audit` for dependency vulnerability scanning.
- **Testing**: Pytest for unit, integration, and regression testing.
- **Type Hints**: All function arguments and return values must have explicit type declarations.
- **Documentation**: All public functions and classes must have clear docstrings.
- **Programming Paradigm**: Use Object-Oriented Programming (OOP) and encapsulate functions within classes where practical. Follow SOLID principles.
- **Data Structures**: Use defined `dataclasses` (or Pydantic models) instead of raw JSON/dictionaries for complex data passing.
- **Error Handling**: Always handle exceptions. Terminate gracefully and cleanly with informative diagnostic messages.
- **Containerization**: Use Docker or Podman for containerizing applications and services.

## Key Libraries (Common Recommendations)
- **OmegaConf**: For configuration management.
- **Pydantic**: For data validation, with robustness, particular when dealing with external data.
- **Dataclass**: For simple data structure definition, all internal.
- **SQLAlchemy**: For database abstraction and interaction.
- **MLflow**: For experiment tracking, model registry, and artifact logging.
- **Pandas / Polars**: For data manipulation and processing.
- **Scikit-learn / PyTorch / TensorFlow**: For machine learning and deep learning tasks.
- **FastAPI**: For building performant API endpoints.

## Common Commands
- Sync dependencies: `uv sync`
- Run tests: `pytest`
- Run linting: `ruff check .`
- Run formatting: `ruff format .`
- Run security scan (SAST): `uv run bandit -r src/`
- Run dependency vulnerability scan: `uv run pip-audit`
