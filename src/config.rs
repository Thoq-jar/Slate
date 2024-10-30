use std::collections::HashMap;
use std::fs;
use std::path::Path;

#[derive(Debug, Clone)]
pub struct SlateConfig {
    pub root: String,
    pub host: String,
    pub port: u16,
    pub main_page: String,
    pub not_found_page: String,
    pub routes: HashMap<String, String>,
}

impl Default for SlateConfig {
    fn default() -> Self {
        SlateConfig {
            root: "./".to_string(),
            host: "127.0.0.1".to_string(),
            port: 22222,
            main_page: "".to_string(),
            not_found_page: "".to_string(),
            routes: HashMap::new(),
        }
    }
}

impl SlateConfig {
    pub fn load<P: AsRef<Path>>(path: P) -> Result<Self, Box<dyn std::error::Error>> {
        let contents = fs::read_to_string(path)?;
        let mut config = SlateConfig::default();

        for line in contents.lines() {
            if line.trim().is_empty() || line.starts_with('#') {
                continue;
            }

            let parts: Vec<&str> = line.split(':').collect();
            if parts.len() != 2 {
                continue;
            }

            match parts[0] {
                "root" => config.root = parts[1].to_string(),
                "host" => config.host = parts[1].to_string(),
                "port" => config.port = parts[1].parse()?,
                "main" => config.main_page = parts[1].to_string(),
                "404" => config.not_found_page = parts[1].to_string(),
                "routes" => {
                    for route in parts[1].split('|') {
                        let route_parts: Vec<&str> = route.split('=').collect();
                        if route_parts.len() == 2 {
                            config.routes.insert(
                                route_parts[0].to_string(),
                                route_parts[1].to_string(),
                            );
                        }
                    }
                }
                _ => {}
            }
        }

        Ok(config)
    }
}
