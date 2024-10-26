# Slate

A Configurable HTTP server written in [Go](https://go.dev)

## Syntax
```yaml
# Define this is a slate project
slate:
  # Define project settings
  project:
    package-manager: "slate"
    root-dir: "."
    main: "index.html"
    host: "0.0.0.0"
    port: "11111"

  # [COMING SOON] Code executable with slate task {script} (e.g. slate task serve)
  # scripts:
    # - clean: "echo Clean executed"
```

## License
### This project uses the [MIT](LICENSE) License