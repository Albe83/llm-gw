# llm-gw

LLM Gateway is a small container image that bundles the [LiteLLM Proxy](https://github.com/BerriAI/litellm). It ships an opinionated entrypoint and a Helm chart to ease running the proxy locally or on Kubernetes.

## Features

- **Reproducible build**: the `Dockerfile` pins the Oracle Linux base image by digest and installs `litellm` with a specific version.
- **Minimal runtime**: the container creates a dedicated non‑root user and copies only the entrypoint script and its configuration.
- **Configurable**: point the `LITELLM_CONFIG` environment variable to a YAML file containing your model configuration. A placeholder file is provided in the repository.
- **Helm chart**: under `chart/llm-gw` you will find a chart ready to deploy the container with common settings.

## Building the image

```bash
docker build -t llm-gw .
```

## Running

Supply a configuration file and map the service port (default `4000`):

```bash
docker run --rm -p 4000:4000 \
  -v $(pwd)/litellm_config.yaml:/litellm_config.yaml:ro \
  llm-gw
```

The entrypoint prints basic information and forwards all arguments to `litellm`.

## Helm installation

```bash
helm install my-gateway ./chart/llm-gw
```

Adjust values in `chart/llm-gw/values.yaml` to match your environment.

## Tests

A small test script verifies the behaviour of `entrypoint.sh`:

```bash
./tests/test_entrypoint.sh
```

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.

