#!/bin/bash
# start.sh

# Set working directory
# cd /app

# with S3

# Wait for PostgreSQL to be ready
echo "Initializing database..."
python src/data_processor.py job_title_des.csv --preview

# Initialize Elasticsearch with resume data
echo "Initializing Elasticsearch with resume data..."
python src/index_resumes.py

# Start the Streamlit application
echo "Starting Streamlit application..."
cd src && streamlit run app.py --server.port=8501 --server.address=0.0.0.0


