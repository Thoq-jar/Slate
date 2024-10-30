#![allow(non_snake_case)]

mod config;
mod pages;
mod router;

use std::net::SocketAddr;
use tokio::net::TcpListener;
use tokio::io::{AsyncReadExt, AsyncWriteExt};
use std::time::Instant;
use chrono::Local;
use local_ip_address::local_ip;

pub use config::SlateConfig;
use router::Router;

const MAGENTA: &str = "\x1b[95m";
const BLUE: &str = "\x1b[94m";
const RESET: &str = "\x1b[0m";

pub async fn run_server(config: SlateConfig) -> std::io::Result<()> {
    let addr = SocketAddr::from((
        config.host.parse::<std::net::IpAddr>().expect("error: invalid host"),
        config.port
    ));
    let listener = TcpListener::bind(addr).await?;

    let local_addr = format!("http://127.0.0.1:{}", config.port);
    let network_addr = if config.host == "0.0.0.0" {
        match local_ip() {
            Ok(ip) => format!("http://{}:{}", ip, config.port),
            Err(_) => format!("http://{}:{}", config.host, config.port)
        }
    } else {
        format!("Please use host: 0.0.0.0 to bind to all interfaces!")
    };

    print!("\n");
    println!("{}● {} v{}", MAGENTA, env!("CARGO_PKG_NAME"), env!("CARGO_PKG_VERSION"));
    println!("  - Local:   {}{}{}", BLUE, local_addr, MAGENTA);
    println!("  - Network: {}{}{}", BLUE, network_addr, MAGENTA);
    print!("{}\n", RESET);

    loop {
        let (mut socket, _client_addr) = listener.accept().await?;
        let config = config.clone();

        tokio::spawn(async move {
            let start_time = Instant::now();
            let mut buffer = [0; 1024];
            
            match socket.read(&mut buffer).await {
                Ok(n) => {
                    let request = String::from_utf8_lossy(&buffer[..n]);
                    
                    let path = request.lines()
                        .next()
                        .and_then(|line| line.split_whitespace().nth(1))
                        .unwrap_or("/");

                    let router = Router::new(config.clone());
                    let content = router.route(path).await;

                    let response = format!(
                        "HTTP/1.1 200 OK\r\n\
                         Server: {}/{}\r\n\
                         X-Powered-By: Rust\r\n\
                         Content-Type: text/html\r\n\
                         Content-Length: {}\r\n\
                         \r\n",
                        env!("CARGO_PKG_NAME"),
                        env!("CARGO_PKG_VERSION"),
                        content.len()
                    );

                    let result = socket.write_all(&[response.as_bytes(), &content].concat()).await;
                    
                    let elapsed = start_time.elapsed();
                    let now = Local::now();
                    
                    let nanos = elapsed.as_nanos();
                    let micros = elapsed.as_micros();
                    let millis = elapsed.as_secs_f64() * 1000.0;

                    let time_display = if millis >= 1.0 {
                        format!("{:.2}ms", millis)
                    } else if micros >= 1 {
                        format!("{} µs", micros)
                    } else {
                        format!("{} ns", nanos)
                    };

                    let status = if result.is_ok() { "+" } else { "-" };
                    println!("[Slate] [{} {}] [{}] {} {:.<50} {}",
                        now.format("%Y-%m-%d"),
                        now.format("%H:%M:%S"),
                        status,
                        path,
                        ".",
                        time_display
                    );
                }
                Err(e) => eprintln!("Failed to read from socket: {}", e),
            }
        });
    }
}
