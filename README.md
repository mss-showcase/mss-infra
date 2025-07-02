# Manual-only deploy

This repository is by design does not do automatic deployment to let the IT stuff decide what and when to deploy and in what particular order.

# GitHub Organization Variables and Secrets

if you would fork this project, these vars and secrets needs to be defined at org level

| Name                                   | Type    | Description/Usage                                                                 |
|----------------------------------------|---------|----------------------------------------------------------------------------------|
| AWS_REGION                            | Variable| AWS region for all AWS CLI and Terraform operations                              |
| SHARED_DATA_BUCKET                    | Variable| S3 bucket for shared data                                                        |
| SHARED_BUILD_DATA_BUCKET               | Variable| S3 bucket for build artifacts                                                    |
| MSS_BACKEND_LAMBDA_NAME                | Variable| Name of the backend Lambda function                                              |
| MSS_BACKEND_VERSION                    | Variable| Version of the backend Lambda (hardcoded as 1.0.0 in workflow)                   |
| TICKS_TABLE                            | Variable| Name of the DynamoDB table for ticks (stock market data)                                            |
| TICKS_TABLE_ARN                        | Variable| ARN of the DynamoDB table for ticks                                              |
| FUNDAMENTALS_TABLE                     | Variable| Name of the DynamoDB table for (stock) fundamentals                                      |
| FUNDAMENTALS_TABLE_ARN                 | Variable| ARN of the DynamoDB table for fundamentals                                       |
| DYNAMODB_SENTIMENT_ARTICLES_TABLE      | Variable| Name of the DynamoDB table for sentiment (rss feed) articles                                |
| DYNAMODB_SENTIMENT_ARTICLES_TABLE_ARN  | Variable| ARN of the DynamoDB table for sentiment articles                                 |
| AWS_ROLE_ARN                           | Secret  | ARN of the AWS IAM role to assume for GitHub Actions                             |

# Deploy order

## MSS Stock Data Source Lambda

Because the mss-stock-data-source will put its data to S3, that will be behind an AWS CloudFront CDN, we need to keep this order:

1, CloudFront Key Management workflow
 
2, Deploy MSS Stock Data Source Lambda workflow (this will create a CloudFront Distribution too and link it to the S3 data bucket)

## MSS Deploy Data To Dynamo Lambda 

Simply run this workflow, this will deploy it to AWS. The necessary exec roles for this lambda will be set up too.

My first attempt (or idea) was to access stock data through CF, but I change my mind: this lambda put it into DynamoDB (with a 30 days TTL)
