### GitHub Actions & AWS OIDC Authentication
To enable passwordless, secure deployment from GitHub Actions to AWS, use OpenID Connect (OIDC).

1.  **Identity Provider (IAM)**: Ensure an OIDC Identity Provider for `token.actions.githubusercontent.com` exists in the AWS account.
2.  **IAM Role**: Create a role (e.g., `github-actions-oidc-role`) with a Trust Relationship allowing the specific GitHub repository and branch/ref.
    ```json
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Principal": {
            "Federated": "arn:aws:iam::<ACCOUNT_ID>:oidc-provider/token.actions.githubusercontent.com"
          },
          "Action": "sts:AssumeRoleWithWebIdentity",
          "Condition": {
            "StringLike": {
              "token.actions.githubusercontent.com:sub": "repo:<ORG>/<REPO>:*"
            }
          }
        }
      ]
    }
    ```
3.  **Permissions**: Attach policies to this role granting least-privilege access needed for deployment (S3, Lambda, API Gateway, DynamoDB, etc.).
4.  **Workflow Configuration**:
    - Permission `id-token: write` is required.
    - Use `aws-actions/configure-aws-credentials` action.
