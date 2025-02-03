FROM python:3.11-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    postgresql-client \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements first for better cache utilization
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# # Create cache directory and set environment variable
# ENV TRANSFORMERS_CACHE=/root/.cache/huggingface
# RUN mkdir -p /root/.cache/huggingface


# # Pre-download the model during build
# RUN python -c "from sentence_transformers import SentenceTransformer; SentenceTransformer('sentence-transformers/all-mpnet-base-v2')"

# Copy the application code
COPY . .

# Set correct permissions for start.sh
RUN chmod +x /app/start.sh && \
    # Ensure the script uses Unix line endings
    sed -i 's/\r$//' /app/start.sh

# Make port 8501 available for Streamlit
EXPOSE 8501

# Command to run the application
# ENTRYPOINT ["/app/start.sh"] 
CMD ["/bin/bash", "/app/start.sh"]
# ENTRYPOINT ["/bin/bash"]
# CMD ["/app/start.sh"]
# CMD [""]
# CMD ["streamlit", "run", "app.py"]