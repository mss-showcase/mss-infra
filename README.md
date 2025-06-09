# Manual-only deploy

This repository is by design does not do automatic deployment to let the IT stuff decide what and when to deploy and in what particular order.

# Deploy order

Because the mss-stock-data-source will put its data to S3, that will be behind an AWS CloudFront CDN, we need to keep this order:
