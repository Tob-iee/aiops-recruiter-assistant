###########################################
# COMPILER IMAGE: Compiled Image Layer
###########################################
# Base Image: python:3.11-slim
FROM python:3.11-slim AS compile-image

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    postgresql-client \
    && rm -rf /var/lib/apt/lists/*

# Set environment variables
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    TRANSFORMERS_OFFLINE=1 \
    HF_HUB_OFFLINE=1 \
    HF_HOME=/app/.cache/huggingface 
    # PYTHONPATH=/app 

# Build: dev & build dependencies can be installed here
# Set the working directory
WORKDIR /app

# The virtual environment is used to "package" the application
# and its dependencies in a self-contained way.
RUN python -m venv .venv
ENV PATH="/app/.venv/bin:$PATH"

# Copy requirements first for better cache utilization
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the application code
COPY . .

# Remove cache, logs, and unnecessary files
RUN rm -rf /root/.cache /app/.cache /tmp/*

# Set correct permissions for start.sh and ensure the script uses Unix line endings
RUN chmod +x ./start.sh && \
    sed -i 's/\r$//' ./start.sh


############################################
# RUNTIME IMAGE: Runtime Image Layer
############################################
# FROM gcr.io/distroless/python3-debian11 AS runtime-image
FROM python:3.11-slim AS runtime-image

# Set the same working directory as compile stage
WORKDIR /app

# Copy the compiled application from the previous stage
COPY --from=compile-image /app /app

# Use the virtual environment from the compile stage
ENV PATH="/app/.venv/bin:$PATH"

# Create and mount the data directory
VOLUME /app/rag-source-knowledge

# Make port 8501 available for Streamlit
EXPOSE 8501

# Command to run the application
CMD ["./start.sh"]

