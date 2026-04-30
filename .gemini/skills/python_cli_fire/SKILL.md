# Python CLI Creation using Google Fire

When creating command-line entry points for Python scripts (especially those executed by AWS CDK, SageMaker Pipelines, Docker containers, or manual tasks), use the `fire` library to automatically generate the CLI.

This pattern is highly effective for centralizing infrastructure deployments, data processing scripts, or general utility actions into clean, accessible CLIs.

## Core Guidelines

1. **Encapsulate Logic**: Keep the core business logic in standard functions or classes outside of the CLI entry point module. Import them into your CLI module.
2. **Dictionary Command Mapping**: Expose multiple functions by passing a dictionary to `Fire()`. The dictionary keys become the CLI command names.
3. **Dedicated Entry Points**: Group related commands under distinct functions (e.g., `def main(): ...`, `def scripts(): ...`) so they can be easily mapped as console scripts in your project configuration (like `pyproject.toml` or `setup.py`).
4. **Type Hints and Docstrings**: `fire` uses docstrings for help menus (`--help`) and type hints for parsing arguments. Always provide comprehensive type hints and docstrings on the functions you expose.

## Boilerplate Pattern

```python
from fire import Fire

# Import your core logic functions
from my_project.cdk.deploy_stack import deploy_main_stack
from my_project.cdk.deploy_database import deploy_database_stack
from my_project.scripts.setup_env import setup_environment
from my_project.scripts.seed_data import seed_test_data

def main():
    """
    Main CLI for deploying infrastructure stacks.
    """
    # Use a dictionary to map custom command names to imported functions
    Fire(
        {
            "deploy_main_stack": deploy_main_stack,
            "deploy_database": deploy_database_stack,
        }
    )

def scripts():
    """
    Secondary CLI for running standalone utility scripts.
    """
    Fire(
        {
            "setup_env": setup_environment,
            "seed_data": seed_test_data,
        }
    )

if __name__ == '__main__':
    # Typically, you'd configure entry points in pyproject.toml instead of
    # relying heavily on __main__, but you can provide a default fallback here.
    main()
```

## Example `pyproject.toml` Entry Points

When using the above pattern, you can expose these CLIs globally within your Python environment by registering them in your build system configuration:

```toml
[project.scripts]
# Installs a command `my-cli` that runs the `main()` function
my-cli = "my_project.cli:main"
# Installs a command `my-scripts` that runs the `scripts()` function
my-scripts = "my_project.cli:scripts"
```

## Execution Examples

With the entry points configured (or by directly calling the script if using `__main__`), you can invoke the logic from the terminal:

*   **Deploy Main Stack:** `my-cli deploy_main_stack --environment=dev --region=ap-southeast-2`
*   **Run Seed Data Script:** `my-scripts seed_data --records=1000 --dry-run=True`
*   **Show Help for Main CLI:** `my-cli --help`
*   **Show Help for Specific Command:** `my-cli deploy_main_stack --help`

## Benefits of this Pattern

*   **Clean Namespaces:** You can map long, complex function names (e.g., `deploy_alpr_platform_foundation_stack`) to identical or simplified CLI command names without cluttering the global namespace.
*   **Modular Entry Points:** Splitting into `main()` and `scripts()` (or `deploy()`, `train()`, etc.) allows you to create distinct binaries or Docker entry points for different operational scopes.
*   **Automatic Parsing:** `fire` automatically parses bools, ints, strings, and even complex types directly from the command line flags based on the function signatures.
