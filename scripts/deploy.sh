#!/bin/bash

# Deploy script to upload build to AWS
set -e

# Change to the directory where this script is located
cd "$(dirname "${BASH_SOURCE[0]}")"

echo "Deploying to AWS..."

# Check if build directory exists (in parent directory)
if [ ! -d "../dist" ]; then
    echo "Error: Build directory '../dist' not found. Please run build script first."
    exit 1
fi

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    echo "Error: AWS CLI not found. Please install AWS CLI first."
    exit 1
fi

# Get AWS region
AWS_REGION=${AWS_REGION:-$(aws configure get region || echo "ca-central-1")}

# Get S3 bucket name from CDK stack outputs (since it's auto-generated)
if [ -z "${S3_BUCKET}" ]; then
    echo "Getting S3 bucket name from CDK stack..."
    S3_BUCKET=$(aws cloudformation describe-stacks \
        --stack-name ResumeBotFrontendStack \
        --region ${AWS_REGION} \
        --query 'Stacks[0].Outputs[?OutputKey==`S3BucketName`].OutputValue' \
        --output text 2>/dev/null || echo "")
    
    if [ -z "$S3_BUCKET" ]; then
        echo "Error: Could not get S3 bucket name from CloudFormation stack outputs"
        echo "Make sure the ResumeBotFrontendStack is deployed and has S3BucketName output"
        exit 1
    fi
fi

# Get CloudFront distribution ID from CDK stack outputs if not provided
if [ -z "${CLOUDFRONT_DISTRIBUTION_ID}" ]; then
    echo "Getting CloudFront distribution ID from CDK stack..."
    CLOUDFRONT_DISTRIBUTION_ID=$(aws cloudformation describe-stacks \
        --stack-name ResumeBotFrontendStack \
        --region ${AWS_REGION} \
        --query 'Stacks[0].Outputs[?OutputKey==`DistributionId`].OutputValue' \
        --output text 2>/dev/null || echo "")
fi

echo "Uploading to S3 bucket: $S3_BUCKET"

# Sync build files to S3 (from parent directory)
aws s3 sync ../dist/ s3://$S3_BUCKET/ --delete

# Invalidate CloudFront cache if distribution ID is provided
if [ ! -z "$CLOUDFRONT_DISTRIBUTION_ID" ]; then
    echo "Invalidating CloudFront distribution: $CLOUDFRONT_DISTRIBUTION_ID"
    aws cloudfront create-invalidation --distribution-id $CLOUDFRONT_DISTRIBUTION_ID --paths "/*"
fi

echo "Deployment completed successfully!"