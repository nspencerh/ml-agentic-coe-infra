# Snowflake Connection Boilerplate

When generating code that interacts with Snowflake for this project, adhere to the following template. It provides a robust `SnowflakeManager` class that supports multiple authentication methods: using AWS Secrets Manager (Service Accounts) with RSA private keys, or local named connections (User Credentials) and provides both native `SnowflakeConnection` and SQLAlchemy `Engine` support.

## 1. SnowflakeManager Class

```python
import json
from typing import Any, Dict, Optional

import boto3
from botocore.exceptions import ClientError
from cryptography.hazmat.backends import default_backend
from cryptography.hazmat.primitives import serialization
from cryptography.hazmat.primitives.asymmetric.rsa import RSAPrivateKey
from dataclasses import dataclass
from sqlalchemy import create_engine
from sqlalchemy.engine.base import Engine
import snowflake.connector
from snowflake.connector.connection import SnowflakeConnection
from snowflake.sqlalchemy import URL


@dataclass
class snowflake_service_account_cred:
    username: Optional[str] = None
    password: Optional[str] = None
    private_key: Optional[RSAPrivateKey] = None
    private_key_bytes: Optional[bytes] = None

    def __bool__(self) -> bool:
        """
        Check if any credential fields are populated.

        Returns:
            bool: True if at least one field is not None, False otherwise.
        """
        return any(v is not None for v in vars(self).values())


class SnowflakeManager:
    """
    Manages Snowflake connections using service account credentials stored in AWS Secrets Manager
    or local named connections.
    """

    def __init__(
        self,
        account: str = "transurban.ap-southeast-2.privatelink",
        connection_name: Optional[str] = None,
        secret_name: Optional[str] = None,
        schema: Optional[str] = None,
        database: Optional[str] = None,
        warehouse: Optional[str] = None,
        region_name: str = "ap-southeast-2",
        **kwargs: Any,
    ) -> None:
        """
        Initializes the SnowflakeManager with the necessary connection parameters.

        Args:
            account (str): The Snowflake account identifier. Defaults to "transurban.ap-southeast-2.privatelink".
            connection_name (Optional[str]): The name of the connection in ~/.snowflake/connections.toml.
            secret_name (Optional[str]): The name of the AWS Secrets Manager secret containing service account credentials.
            schema (Optional[str]): The default schema to use for the connection.
            database (Optional[str]): The default database to use for the connection.
            warehouse (Optional[str]): The default warehouse to use for the connection.
            region_name (str): The AWS region where the Secrets Manager secret is stored. Defaults to "ap-southeast-2".
            **kwargs: Additional keyword arguments.

        Raises:
            Exception: If neither `connection_name` nor `secret_name` is provided.
        """
        if connection_name is None and secret_name is None:
            raise Exception("Provide connection_name for SSO or secret_name for service account to establish connection")

        self.connection_name = connection_name
        self.secret_name = secret_name
        self.schema = schema
        self.database = database
        self.account = account
        self.warehouse = warehouse
        self.region_name = region_name
        self.role: Optional[str] = None
        self.svc_cred: Optional[snowflake_service_account_cred] = None

        if secret_name:
            self.svc_cred = snowflake_service_account_cred()

    def get_snowflake_creds(self) -> Dict[str, Any]:
        """
        Retrieves Snowflake service account credentials from AWS Secrets Manager.

        Returns:
            Dict[str, Any]: A dictionary containing the parsed JSON secret values from AWS Secrets Manager.

        Raises:
            ClientError: If there is an error communicating with AWS Secrets Manager.
        """
        session = boto3.session.Session()
        client = session.client(
            service_name="secretsmanager", region_name=self.region_name
        )
        try:
            response = client.get_secret_value(SecretId=self.secret_name)
            creds = json.loads(response["SecretString"])
            return creds
        except ClientError as e:
            raise e

    def set_up_service_account_creds(self) -> None:
        """
        Retrieves credentials from AWS Secrets Manager, parses them, and populates the
        `snowflake_service_account_cred` instance with the username, password, and serialized RSA private key.
        """
        snowflake_creds_dict = self.get_snowflake_creds()
        self.svc_cred.username = snowflake_creds_dict["username"]
        self.svc_cred.password = snowflake_creds_dict["passphrase"]
        private_key = snowflake_creds_dict["private_key"]
        self.role = snowflake_creds_dict.get("role", None)
        self.warehouse = snowflake_creds_dict.get("warehouse", None)

        self.svc_cred.private_key = serialization.load_pem_private_key(
            str.encode(private_key),
            password=str.encode(self.svc_cred.password),
            backend=default_backend(),
        )

        self.svc_cred.private_key_bytes = self.svc_cred.private_key.private_bytes(
            encoding=serialization.Encoding.DER,
            format=serialization.PrivateFormat.PKCS8,
            encryption_algorithm=serialization.NoEncryption(),
        )

    def establish_connection(self) -> SnowflakeConnection:
        """
        Creates a connection to Snowflake using the official snowflake-connector-python module.

        Returns:
            SnowflakeConnection: An active Snowflake connection object.
        """
        if self.connection_name:
            return snowflake.connector.connect(connection_name=self.connection_name)
        else:
            if not self.svc_cred:
                self.set_up_service_account_creds()
            return snowflake.connector.connect(
                user=self.svc_cred.username,
                account=self.account,
                private_key=self.svc_cred.private_key_bytes,
                role=self.role,
                warehouse=self.warehouse,
                database=self.database,
                schema=self.schema,
            )

    def create_snowflake_engine(self) -> Engine:
        """
        Creates an SQLAlchemy engine for connecting to Snowflake.

        Returns:
            Engine: An SQLAlchemy engine configured for the Snowflake connection.

        Raises:
            Exception: If `schema` or `database` are not provided during initialization.
            Exception: If `role` or `warehouse` cannot be found in the AWS Secrets Manager secret.
        """
        if self.schema is None or self.database is None:
            raise Exception("Must provide schema and database values")

        if not self.svc_cred:
            self.set_up_service_account_creds()

        if self.role is None or self.warehouse is None:
            raise Exception(f"Secrets {self.secret_name} did not contain any role or warehouse value, you must provide them on initiation")

        # Handle multiple schemas if separated by '|' - use FIRST schema only for private links
        if isinstance(self.schema, str) and "|" in self.schema:
            schema_str = self.schema.split("|")[0].strip()
        else:
            schema_str = self.schema

        # Construct the Snowflake URL
        snowflake_url = URL(
            account=self.account,
            user=self.svc_cred.username,
            password=self.svc_cred.password,
            schema=schema_str,
            warehouse=self.warehouse,
            database=self.database,
            role=self.role,
        )

        # Create the SQLAlchemy engine with SSL fixes for private link connections
        try:
            engine = create_engine(
                snowflake_url,
                connect_args={
                    "private_key": self.svc_cred.private_key_bytes,
                    # "insecure_mode": True,
                    "client_session_keep_alive": True,
                    "network_timeout": 3600,
                    "socket_timeout": 3600,
                    "login_timeout": 3600,
                    "ssl_wrap_socket": False,
                },
                pool_pre_ping=True,
                pool_recycle=3600,
            )
            return engine
        except Exception as e:
            raise e
```

## 2. Usage Examples

### Example A: Native Snowflake Connector with Named Connections (Local SSO)

```python
# connections.toml method
sm = SnowflakeManager(connection_name="mlops")
con = sm.establish_connection()
```

### Example B: SQLAlchemy Engine with AWS Secrets Manager (Service Account)

```python
# service account stored in secrets manager
sm = SnowflakeManager(
    secret_name="/discovery/snowflake/svc-ml-ops-temp",
    schema="ML_OPS_DISCOVERY",
    database="RDS_PROD"
)

# Connect using SQLAlchemy Engine
engine = sm.create_snowflake_engine()

# Or connect using native Snowflake Connection
# con = sm.establish_connection()
```
