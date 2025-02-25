use aws_lambda_events::event::kinesis::KinesisEvent;
use lambda_runtime::{run, service_fn, tracing, Error, LambdaEvent};

async fn function_handler(event: LambdaEvent<KinesisEvent>) -> Result<(), Error> {
    let messages = event
        .payload
        .records
        .iter()
        .map(|r| std::str::from_utf8(&r.kinesis.data).unwrap_or(""))
        .collect::<Vec<_>>();

    for message in messages {
        tracing::info!("Message: {}", message);
    }

    Ok(())
}

#[tokio::main]
async fn main() -> Result<(), Error> {
    tracing::init_default_subscriber();

    run(service_fn(function_handler)).await
}
