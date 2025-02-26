# AWS IoT Rule to AWS Kinesis Data Streams to AWS Lambda in Rust
When a message is published to the IoT topic, the message will be delivered to AWS Kinesis Data Stream.

## AWS Infrastructure
![AWS Infrastructure diagram](infrastructure/docs/arch.svg)

## Requirements
- AWS Account
- AWS CLI
- Terraform
- Rust

## Deployment

```
terraform init
```

```
terraform plan
```

```
terraform apply
```

## Cleanup

```
terraform destroy
```
