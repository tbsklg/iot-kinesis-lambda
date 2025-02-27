use aws_lambda_events::event::kinesis::KinesisEvent;
use lambda_runtime::{run, service_fn, tracing, Error, LambdaEvent};
use serde::Serialize;

async fn function_handler(event: LambdaEvent<KinesisEvent>) -> Result<BatchItemResponse, Error> {
    let processing_results = event
        .payload
        .records
        .iter()
        .map(|record| {
            let sequence_number = record.kinesis.sequence_number.clone();
            let result = std::str::from_utf8(&record.kinesis.data);

            (sequence_number, result)
        })
        .collect::<Vec<_>>();

    let batch_item_failures = processing_results
        .into_iter()
        .filter_map(|(sequence_number, result)| match result {
            Ok(_) => None,
            Err(_) => Some(BatchItem {
                item_identifier: sequence_number.unwrap(),
            }),
        })
        .collect();

    Ok(BatchItemResponse {
        batch_item_failures,
    })
}

#[derive(Serialize, Debug, Eq, PartialEq)]
struct BatchItemResponse {
    batch_item_failures: Vec<BatchItem>,
}

#[derive(Serialize, Debug, Eq, PartialEq)]
struct BatchItem {
    item_identifier: String,
}

#[tokio::main]
async fn main() -> Result<(), Error> {
    tracing::init_default_subscriber();

    run(service_fn(function_handler)).await
}
