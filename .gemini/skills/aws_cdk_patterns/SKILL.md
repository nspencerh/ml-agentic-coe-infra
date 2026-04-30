# AWS CDK Infrastructure Definition Pattern

When creating AWS Cloud Development Kit (CDK) infrastructure, particularly in platforms deploying across multiple accounts (e.g., discovery, staging, production), follow this established pattern for structuring stacks and deployment scripts.

This approach pairs cleanly with the Python `fire` CLI pattern for centralized execution.

## Core Guidelines

1. **Modular Stacks**: Define each infrastructure component as a separate class inheriting from `aws_cdk.Stack` within a dedicated `stacks/` directory.
2. **Environment Resolution**: Account and region information can be resolved in two main ways:
    *   **CDK Context (`cdk.json`)**: Retrieved inside the stack or wrapper using `app.node.try_get_context()`.
    *   **External Configurations (`OmegaConf`)**: Passed as direct arguments to your deploy function from the CLI, then used to look up account IDs from a YAML configuration file. This is often preferred for managing complex cross-account lookups natively in Python.
3. **Dedicated Deploy Functions**: Create a wrapper function that initializes the `cdk.App()`, resolves the environment and config, instantiates the required stacks, and calls `app.synth()`.
4. **Integration with CLI**: Expose the deployment wrapper function via your `cli.py` (using `fire`).

## Boilerplate Pattern (Config-Driven Approach)

### 1. The Stack Definition (`stacks/my_component_stack.py`)

```python
import aws_cdk as cdk
from constructs import Construct
from aws_cdk import aws_iam as iam

class MyComponentStack(cdk.Stack):
    def __init__(self, scope: Construct, construct_id: str, account_alias: str, **kwargs) -> None:
        super().__init__(scope, construct_id, **kwargs)

        # Example: Conditional resource creation based on passed-in environment
        if account_alias in ["staging", "prod"]:
            self._build_production_resources()

    def _build_production_resources(self) -> None:
        # Example resource
        iam.Role(
            self,
            "MyComponentRole",
            role_name="my-component-role",
            assumed_by=iam.ServicePrincipal("ec2.amazonaws.com")
        )
```

### 2. The Deployment Wrapper (`deploy_my_platform.py`)

This function serves as the entry point for synthesizing the stacks. Notice how `account_alias` and `aws_region` are exposed as arguments, making them controllable via the `fire` CLI.

```python
from pathlib import Path
import aws_cdk as cdk
from omegaconf import OmegaConf

# Import your custom stacks
from my_project.cdk.stacks.my_component_stack import MyComponentStack

def deploy_platform_stack(
    account_alias: str = "discovery",
    aws_region: str = "ap-southeast-2",
):
    """
    Deploys the foundational stacks for the platform.
    Initializes the CDK app, applies global tags, and synthesizes the stacks.
    """
    app = cdk.App()

    # 1. Resolve Configuration using OmegaConf
    config_path = (
        Path(__file__)
        .parents[2] # adjust path as necessary
        .joinpath("config/domain_config.yaml")
        .as_posix()
    )
    config = OmegaConf.load(config_path)

    # Example: Look up account ID from config
    # (assuming yaml has: account_numbers: { discovery: '123...', staging: '456...' })
    target_account_id = config["account_numbers"][account_alias]

    # 2. Tagging (Optional but recommended: use OmegaConf to load standard tags)
    # tag_path = Path(__file__).parents[2].joinpath("config/default_tags.yml").as_posix()
    # tag_config = OmegaConf.load(tag_path)
    # tag_resources(cdk_app=app, tag_config=tag_config)

    # 3. Instantiate Stacks
    MyComponentStack(
        app,
        "my-component-deployment-stack",
        account_alias=account_alias,
        env=cdk.Environment(
            account=target_account_id,
            region=aws_region,
        ),
    )

    # 4. Synthesize the App
    app.synth()
```

### 3. CLI Integration (`cli.py`)

Connect the deployment function to your project's CLI entry point using `fire`.

```python
from fire import Fire
from my_project.cdk.deploy_my_platform import deploy_platform_stack

def main():
    Fire(
        {
            "deploy_platform_stack": deploy_platform_stack,
        }
    )
```

## Execution Example

Once wired into the CLI, you can synthesize/deploy by passing arguments directly through the command line (which `fire` maps to your wrapper function arguments):

```bash
# Synthesize for the discovery account (using defaults)
my-cli deploy_platform_stack

# Synthesize for the production account
my-cli deploy_platform_stack --account_alias=prod --aws_region=ap-southeast-2
```
