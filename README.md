# GitHub Organization Variables and Secrets

if you would fork this project, these vars and secrets needs to be defined at org level

| Name                                   | Type    | Description/Usage                                                                 |
|----------------------------------------|---------|----------------------------------------------------------------------------------|
| AWS_REGION                            | Variable| AWS region for all AWS CLI and Terraform operations                              |
| SHARED_DATA_BUCKET                    | Variable| S3 bucket for shared data                                                        |
| SHARED_BUILD_DATA_BUCKET               | Variable| S3 bucket for build artifacts                                                    |
| MSS_BACKEND_LAMBDA_NAME                | Variable| Name of the backend Lambda function                                              |
| MSS_BACKEND_VERSION                    | Variable| Version of the backend Lambda (hardcoded as 1.0.0 in workflow)                   |
| TICKS_TABLE                            | Variable| Name of the DynamoDB table for ticks (stock market data)                         |
| TICKS_TABLE_ARN                        | Variable| ARN of the DynamoDB table for ticks                                              |
| FUNDAMENTALS_TABLE                     | Variable| Name of the DynamoDB table for (stock) fundamentals                              |
| FUNDAMENTALS_TABLE_ARN                 | Variable| ARN of the DynamoDB table for fundamentals                                       |
| DYNAMODB_SENTIMENT_ARTICLES_TABLE      | Variable| Name of the DynamoDB table for sentiment (rss feed) articles                     |
| DYNAMODB_SENTIMENT_ARTICLES_TABLE_ARN  | Variable| ARN of the DynamoDB table for sentiment articles                                 |
| AWS_ROLE_ARN                           | Secret  | ARN of the AWS IAM role to assume for GitHub Actions                             |
| WEBHOSTING_BUCKET                      | Variable| Name of the S3 bucket used for webhosting (used for Cognito callback/logout URLs)|
| COGNITO_POOL_ID_FILE                   | Variable| S3 key (filename) for storing Cognito User Pool ID                               |
| COGNITO_CLIENT_ID_FILE                 | Variable| S3 key (filename) for storing Cognito User Pool Client ID                        |
| COGNITO_ADMIN_PASSWORD_FILE            | Variable| S3 key (filename) for storing Cognito admin user's password                      |
| COGNITO_ADMIN_USERNAME                 | Variable| Username for the Cognito admin user                                              |
| COGNITO_ADMIN_PASSWORD                 | Secret  | Password for the Cognito admin user                                              |

# AWS_ROLE_ARN

You will need to create an AWS role that will be used (or its ARN) to let github to act as that role.
This role needs these security policies:

AmazonAPIGatewayAdministrator
AmazonCognitoPowerUser
AmazonDynamoDBFullAccess
AmazonEventBridgeFullAccess
AmazonS3FullAccess
AmazonSQSFullAccess
AWSLambda_FullAccess
CloudFrontFullAccess
IAMFullAccess
SecretsManagerReadWrite
CloudWatchLogsFullAccess

As the list is too long, you will need to create one Policy that rule them all:

{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "apigateway:*",
        "cognito-identity:*",
        "cognito-sync:*",
        "cognito-idp:*",
        "dynamodb:*",
        "events:*",
        "s3:*",
        "sqs:*",
        "lambda:*",
        "cloudfront:*",
        "iam:*",
        "secretsmanager:*",
        "logs:*"
      ],
      "Resource": "*"
    }
  ]
}

# Deploy

This repository uses manual-only deployment jobs, allowing IT to control what, when, and in what order to deploy. The available deploy jobs are:

## 1. MSS Stock Data Source Lambda
Deploys the two Lambdas that collect stock data (fundamentals and ticks) and put it into S3, which is processed by the next lambda. This job also creates the CloudFront distribution for webhosting and links it to the S3 data bucket.

## 2. MSS Deploy Data To Dynamo Lambda
Deploys the two Lambdas that move stock tick.json and funda.json data from S3 into DynamoDB (with a 30-day TTL). This job also sets up the necessary execution roles for the Lambda.

## 3. MSS Financial Sentiment Lambda
Deploys the feed reader and the sentiment Lambda responsible for processing financial news articles from RSS feeds and storing sentiment analysis results in DynamoDB. This job is responsible for ingesting and analyzing external sentiment data.

## 4. MSS Backend Lambda, API Gateway & Cognito
Deploys the backend Lambda, configures API Gateway routes for stock, fundamentals, sentiment data, and user management/authentication endpoints. This job also manages IAM permissions, environment variables, and integrates with Cognito for authentication and user management.

## 5. Cognito User Pool & Identity Provider
Creates or updates the Cognito User Pool, User Pool Client, and Google Identity Provider. This job supports both first-time creation and upsert (re-apply) scenarios, automatically handling import of existing resources if present. It also manages the upload of Cognito IDs to S3 for use by other jobs and environments.

## 6. Cognito Admin (and other) User Management
Creates or updates the Cognito admin user and sets the admin password. This job ensures the admin user exists and is configured with the correct credentials, uploading the password to S3 for reference by other jobs.

**Deploy Order Recommendation:**
1. CloudFront Key (provisions the CloudFront public key for signed URLs)
2. CloudFront (provisions the CloudFront distribution for webhosting)
3. MSS Stock Data Source Lambda
4. MSS Deploy Data To Dynamo Lambda
5. MSS Financial Sentiment Lambda
6. Cognito User Pool & Identity Provider
7. Cognito Admin User Management
8. MSS Backend Lambda, API Gateway & Cognito

Each job is triggered manually via GitHub Actions. See the respective workflow files in `.github/workflows/` for details and customization options, including `.github/workflows/configure-cognito.yml` for Cognito upsert and user management.
