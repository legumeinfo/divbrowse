# Stage 1: build the Svelte/Vite frontend (produces divbrowse.js)
FROM node:22-slim AS frontend-builder
WORKDIR /frontend
COPY frontend/package.json frontend/package-lock.json ./
RUN npm ci
COPY frontend/ ./
RUN npm run build

# Stage 2: Python/conda runtime
FROM condaforge/mambaforge:latest

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    DIVBROWSE_PORT=8080 \
    DIVBROWSE_HOST=0.0.0.0

RUN apt-get update && apt-get install -y --no-install-recommends \
    wget \
    tabix \
    bcftools \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY environment.yml /app/environment.yml

RUN mamba env create -f environment.yml && \
    mamba clean --all -f -y

# Make RUN commands use the new environment
SHELL ["mamba", "run", "-n", "divbrowse_dev", "/bin/bash", "-c"]

COPY divbrowse/ /app/divbrowse/
COPY pyproject.toml /app/
COPY README.md /app/

# Drop in the frontend bundle built in stage 1 (served from divbrowse/static)
RUN mkdir -p /app/divbrowse/static
COPY --from=frontend-builder /frontend/dist/divbrowse.js /app/divbrowse/static/divbrowse.js

# Install the divbrowse package (deps already installed via conda)
RUN pip install --no-deps -e .

# Copy setup script (if users want to use it inside container)
COPY setup.sh /app/setup.sh
RUN chmod +x /app/setup.sh

RUN mkdir -p /opt/divbrowse/data
# Set working directory to where data will be mounted
WORKDIR /opt/divbrowse

# Expose the default port
EXPOSE 8080

# Create entrypoint script
COPY <<'EOF' /entrypoint.sh
#!/bin/bash
set -e

source /opt/conda/etc/profile.d/conda.sh
conda activate divbrowse_dev

cd /opt/divbrowse

# Check if data needs to be set up
if [ ! -d "variants.zarr" ]; then
    if [ -z "$VCF_URL" ] || [ -z "$GFF3_URL" ]; then
        echo "ERROR: No variants.zarr found and VCF_URL/GFF3_URL not set"
        echo ""
        echo "Either mount a data directory with existing data, or set environment variables:"
        echo "  VCF_URL       - URL to download VCF file"
        echo "  GFF3_URL      - URL to download GFF3 annotations"
        echo "  CHROM_PATTERN - (optional) Regex to filter chromosomes (e.g., 'Chr[0-9]+')"
        exit 1
    fi

    echo "=== Setting up data ==="
    echo "This may take a while (downloading VCF and GFF3, converting to Zarr)..."
    /app/setup.sh
    echo "=== Setup complete ==="
fi

# Verify config exists
if [ ! -f "divbrowse.config.yml" ]; then
    echo "ERROR: divbrowse.config.yml not found after setup"
    exit 1
fi

# Start the server
echo "Starting Divbrowse server on port ${DIVBROWSE_PORT}..."
exec divbrowse start --host ${DIVBROWSE_HOST} --port ${DIVBROWSE_PORT}
EOF
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
