# AI Recruiter Assistant Documentation

## Overview
The **AI Recruiter Assistant** is a web-based tool designed to help recruiters evaluate job applicants efficiently. The application leverages AI to analyze resumes and assess candidates for specific job roles. It integrates a **web UI**, a **PostgreSQL database**, and a **Retrieval-Augmented Generation (RAG) model** to streamline the evaluation process.

---

## Features
- **Web UI**: A user-friendly interface for recruiters to upload resumes and select job roles.  
- **Resume Analysis**: Upload a PDF resume and select a job role to evaluate the candidate.  
- **Job Role Selection**: Choose from a list of job roles stored in a PostgreSQL database.  
- **AI-Powered Evaluation**:  
  - Generates questions based on the job description and resume.  
  - Uses **RAG** to assess the candidate’s suitability for the role.  
- **Local Deployment**: The entire application runs locally using **Docker**.  

---

## Prerequisites
Before running the AI Recruiter Assistant, ensure you have the following installed:

- **Docker**: [Install Docker](https://docs.docker.com/get-docker/)  
- **Docker Compose**: [Install Docker Compose](https://docs.docker.com/compose/install/)  

---

## Getting Started

### 1. Set Up Environment Variables  
Create a `.env` file in the root directory of the project and add the necessary environment variables.

```.env
    # PostgreSQL Configuration
    POSTGRES_HOST=localhost
    POSTGRES_DB=recruiter_assistant
    POSTGRES_USER=your_username
    POSTGRES_PASSWORD=your_password
    POSTGRES_PORT=5432

    # Elasticsearch Configuration
    ELASTIC_URL_LOCAL=http://localhost:9200
    ELASTIC_URL=http://elasticsearch:9200
    ELASTIC_PORT=9200

    # Streamlit Configuration
    STREAMLIT_PORT=8501

    OPENAI_API_KEY=""
    HF_API_KEY=""

    # Other Configuration
    # EMBEDDED_MODEL_NAME=sentence-transformers/all-mpnet-base-v2

    EMBEDDED_MODEL_NAME=multi-qa-MiniLM-L6-cos-v1
    INDEX_NAME=recruiter-assistant-resumes
```

### 2. Build and Run the Application  
Run the following command to build and start the application:

```bash
docker-compose up
```
This command will:

## Application Execution

Once the application is running, it will:

- Start the **PostgreSQL database** and **Elasticsearch vector DB**.  
- Build and run the **Web UI**.  
- Start the **AI evaluation service**.  

---

## Accessing the Web UI  

Open your web browser and navigate to:  

👉 [http://0.0.0.0:8501](http://0.0.0.0:8501)  

---

## Usage

### 1. Upload a Resume  
- Click the **"Upload Resume"** button on the **Web UI**.  
- Select a **PDF resume** from your local machine.  

### 2. Select a Job Role  
- Choose a job role from the **drop-down menu**.  
- Job roles are fetched from the `recruiting_jobs` table in the **PostgreSQL database**.  

### 3. Analyze the Resume  
- Click **"Analyze Resume"** to start the evaluation process.  
- The system will:  
  - Generate questions based on the **job description** and **resume**.  
  - Use **RAG** to evaluate the candidate’s suitability.  

### 4. View the Evaluation  
- The **evaluation results** will be displayed in the **Web UI**.  
- Insights into the candidate’s suitability for the selected job role will be provided.  

---

## Stopping the Application  
To stop the application, press **`Ctrl+C`** in the terminal where it is running, or execute:  

```bash
docker-compose down
```

## 📩 Contact  

For any questions or issues, please reach out to:  

📧 **[Nwoke_Tochukwu]** – [tochukwunwoke1@.gmail.com]  

---

Thank you for using the **AI Recruiter Assistant**! 🚀  
We hope this tool helps streamline your recruitment process. 