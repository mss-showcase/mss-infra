# Manual-only deploy

This repository is by design does not do automatic deployment to let the IT stuff decide what and when to deploy and in what particular order.

# Deploy order

## MSS Stock Data Source Lambda

Because the mss-stock-data-source will put its data to S3, that will be behind an AWS CloudFront CDN, we need to keep this order:

1, CloudFront Key Management workflow
 
2, Deploy MSS Stock Data Source Lambda workflow (this will create a CloudFront Distribution too and link it to the S3 data bucket)

## MSS Deploy Data To Dynamo Lambda 

Simply run this workflow, this will deploy it to AWS. The necessary exec roles for this lambda will be set up too.

My first attempt (or idea) was to access stock data through CF, but I change my mind: this lambda put it into DynamoDB (with a 30 days TTL)
