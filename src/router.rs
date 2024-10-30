use std::path::PathBuf;
use crate::config::SlateConfig;
use crate::pages::{index, not_found};

pub struct Router {
    config: SlateConfig,
}

impl Router {
    pub fn new(config: SlateConfig) -> Self {
        Router { config }
    }

    pub async fn route(&self, path: &str) -> Vec<u8> {
        let file_path = self.resolve_path(path);
        
        if path == "/" && self.config.main_page.is_empty() {
            index().into_bytes()
        } else if self.config.not_found_page.is_empty() {
            not_found().into_bytes()
        } else {
            match tokio::fs::read(&file_path).await {
                Ok(content) => content,
                Err(_) => not_found().into_bytes()
            }
        }
    }

    fn resolve_path(&self, path: &str) -> PathBuf {
        let file_path = self.config.routes.get(path)
            .map(|p| format!("{}/{}", self.config.root, p))
            .unwrap_or_else(|| {
                if path == "/" {
                    format!("{}/{}", self.config.root, self.config.main_page)
                } else {
                    format!("{}/{}", self.config.root, self.config.not_found_page)
                }
            });
        
        PathBuf::from(file_path)
    }
}
