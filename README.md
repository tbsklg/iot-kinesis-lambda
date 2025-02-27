# AWS IoT Rule to AWS Kinesis Data Streams to AWS Lambda in Rust
This project demonstrates a serverless event processing pipeline that:
1. Captures device data from IoT topics
2. Streams the data through Kinesis Data Streams
3. Processes events with a Rust-based Lambda consumer

When a message is published to the IoT topic, it's automatically delivered to a Kinesis Data Stream. A Lambda function written in Rust continuously polls the stream using an EventSourceMapping and processes the incoming data.

Reference: [AWS Lambda EventSourceMapping Documentation](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-lambda-eventsourcemapping.html)

## AWS Infrastructure
![AWS Infrastructure diagram](infrastructure/docs/arch.svg)

## Requirements
- AWS Account with permissions
- AWS CLI configured with credentials
- Terraform
- Rust
- Cargo Lambda

## Deployment
Navigate to the infrastructure folder and run:

```
terraform init
```

```
terraform plan
```

```
terraform apply
```

## Test
Run the provided simulation script to publish 100 test events to the IoT topic:
```
./simulate.sh
```

You can then verify the event processing by checking the CloudWatch logs:
1. Navigate to CloudWatch Logs in the AWS Console
2. Find the log group: `/aws/lambda/kinesis/stream/consumer`
3. You should see entries for each of the 10 events processed

## Cleanup
When you're finished with the project, remove all resources:

```
terraform destroy
```
