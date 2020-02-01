# Terraform + API Gateway + Lambda + Elasticsearch Search Example

This is the AWS [Creating a Search Application](https://docs.aws.amazon.com/elasticsearch-service/latest/developerguide/search-example.html) tutorial for Amazon Elasticsearch, defined as a Terraform script and updated so it actually works.

## Setup
1. Install the AWS CLI
1. Set up your AWS credentials in your shell
1. Install git
1. Install NPM
1. Install terraform
1. Install serve

## Installation

1. Clone repo
1. Copy `terraform/config.tf.example` to `terraform/config.tf` and change the variable values to match your own
1. `cd terraform && terraform init`
1. `terraform plan` (assuming you've installed terraform)
1. `terraform apply`
1. Wait a long time, as AWS takes 10-15 minutes to create a new Elasticsearch domain
1. Open `terraform/lambda/searchFunction/index.js` and update `search-movies-YOUR_MOVIES_DOMAIN_ID_HERE.us-east-1.es.amazonaws.com` with the actual value for your Elasticsearch movies domain
1. Upload the `bulk_movies.json` file to your domain via `cd ../data && curl -XPOST https://search-movies-YOUR_MOVIES_DOMAIN_ID_HERE.us-east-1.es.amazonaws.com/_bulk --data-binary @bulk_movies.json -H 'Content-Type: application/json'`
1. Change API Gateway endpoint in `www/scripts/search.js` to `https://YOUR_APIGATEWAY_ID_HERE.execute-api.us-east-1.amazonaws.com/searchApiTest/search
1. `cd ../www && serve .` (assuming you've installed serve via `npm install -g serve`)
1. Open http://localhost:5000
1. Search for something and it should all work like magic
