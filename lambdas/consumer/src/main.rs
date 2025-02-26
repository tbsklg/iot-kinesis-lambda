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

#[cfg(test)]
mod tests {
    use std::{fs::File, io::BufReader};

    use aws_lambda_events::kinesis::KinesisEvent;
    use lambda_runtime::{Context, LambdaEvent};

    use crate::{function_handler, BatchItemResponse};

    #[tokio::test]
    async fn should_process_valid_batch() -> Result<(), anyhow::Error> {
        let file = File::open("./events/kinesis_valid_test_event.json")?;
        let kinesis_event: KinesisEvent = serde_json::from_reader(BufReader::new(file))?;

        let context = Context::default();
        let event = LambdaEvent {
            payload: kinesis_event,
            context,
        };

        let result = function_handler(event).await;

        assert_eq!(
            BatchItemResponse {
                batch_item_failures: vec![]
            },
            result.ok().unwrap()
        );

        Ok(())
    }
}
