use Slate::run_server;
use Slate::SlateConfig;

#[tokio::main]
async fn main() -> std::io::Result<()> {
    let config = SlateConfig::load("config.slate")
        .expect("error: failed to load configuration!");

    run_server(config).await
}
