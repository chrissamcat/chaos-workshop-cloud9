#!/bin/sh

INSTANCE=`aws ec2 describe-instances | jq -r '.Reservations[].Instances[0].InstanceId'`
ACCOUNT=`aws sts get-caller-identity | jq -r '.Account'`

echo '{"Version":"2012-10-17","Statement":[{"Effect":"Allow","Principal":{"Service":"ec2.amazonaws.com"},"Action":"sts:AssumeRole"}]}' > assume.json
echo '{"Version":"2012-10-17","Statement":[{"Effect":"Allow","Action":["cloudwatch:DeleteDashboards","cloudwatch:Describe*","cloudwatch:Get*","cloudwatch:List*","cloudwatch:PutDashboard","dynamodb:CreateTable","dynamodb:DeleteTable","dynamodb:TagResource","dynamodb:DescribeContinuousBackups","dynamodb:DescribeTable","dynamodb:DescribeTimeToLive","dynamodb:ListTagsOfResource","ec2:DescribeAccountAttributes","iam:CreateRole","iam:DeleteRole","iam:DeleteRolePolicy","iam:GetRole","iam:GetRolePolicy","iam:List*","iam:PassRole","iam:PutRolePolicy","lambda:CreateEventSourceMapping","lambda:CreateFunction","lambda:DeleteEventSourceMapping","lambda:DeleteFunction","lambda:List*","lambda:Get*","lambda:UpdateFunctionCode","lambda:UpdateFunctionConfiguration","s3:CreateBucket","s3:DeleteBucket","s3:DeleteObject","s3:DeleteObjectVersion","s3:GetAccelerateConfiguration","s3:GetBucketAcl","s3:GetBucketCORS","s3:GetBucketWebsite","s3:GetLifecycleConfiguration","s3:GetBucketPublicAccessBlock","s3:GetBucketLogging","s3:GetBucketNotification","s3:GetBucketObjectLockConfiguration","s3:GetBucketRequestPayment","s3:GetBucketTagging","s3:GetBucketVersioning","s3:GetEncryptionConfiguration","s3:GetReplicationConfiguration","s3:List*","s3:PutObject","s3:PutBucketNotification","s3:PutBucketPublicAccessBlock","sns:DeleteTopic","sns:Unsubscribe","sns:CreateTopic","sns:SetTopicAttributes","sns:Subscribe","sns:Get*","sns:List*","sns:Check*","sqs:Get*","sqs:List*","sqs:Receive*","sqs:CreateQueue","sqs:DeleteMessage","sqs:DeleteQueue","sqs:GetQueueAttributes","sqs:SetQueueAttributes","ssm:DeleteParameter","ssm:PutParameter","ssm:Describe*","ssm:Get*","ssm:List*"],"Resource":"*"}]}' > policy.json

aws iam create-role --role-name ChaosEngineeringWorkshopRole --assume-role-policy-document file://assume.json
aws iam create-policy --policy-name ChaosEngineeringWorkshopPolicy --policy-document file://policy.json
aws iam attach-role-policy --role-name ChaosEngineeringWorkshopRole --policy-arn arn:aws:iam::$ACCOUNT:policy/ChaosEngineeringWorkshopPolicy
aws iam create-instance-profile --instance-profile-name ChaosEngineeringWorkshopProfile
aws iam add-role-to-instance-profile --role-name ChaosEngineeringWorkshopRole --instance-profile-name ChaosEngineeringWorkshopProfile
aws ec2 associate-iam-instance-profile --instance-id $INSTANCE --iam-instance-profile Name=ChaosEngineeringWorkshopProfile
