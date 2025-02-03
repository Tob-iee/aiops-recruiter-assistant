# AI Recruiter Assistant Documentation
Overview
The AI Recruiter Assistant is a web-based tool designed to help recruiters evaluate job applicants more efficiently. The application runs locally and leverages AI to analyze resumes and assess the fitness of candidates for specific job roles. The system integrates a web UI, a PostgreSQL database, and a Retrieval-Augmented Generation (RAG) model to provide a seamless evaluation process.

## Features
- Web UI: A user-friendly interface for recruiters to upload resumes and select job roles.

- Resume Analysis: Upload a PDF resume and select a job role to evaluate the candidate.

- Job Role Selection: Choose from a list of job roles stored in a PostgreSQL database.

- AI-Powered Evaluation: The system generates questions based on the job description and resume, then uses RAG to evaluate the candidate's fitness for the role.

- Local Deployment: The entire application runs locally using Docker.

## Prerequisites
Before running the AI Recruiter Assistant, ensure you have the following installed on your system:

- Docker: Install Docker

- Docker Compose: Install Docker Compose

Getting Started

1. Set Up Environment Variables
Create a .env file in the root directory of the project and add the necessary environment variables.

2. Build and Run the Application
Run the following command to build and start the application:
```
bash

docker-compose up
```
This command will:

Start the PostgreSQL database and elastic search vector DB.

Build and run the web UI.

Start the AI evaluation service.

4. Access the Web UI
Once the application is running, open your web browser and navigate to:

http://0.0.0.0:8501

## Usage
1. Upload a Resume
On the web UI, click the "Upload Resume" button to select a PDF resume from your local machine.

2. Select a Job Role
Choose the job role you want to evaluate the candidate for from the drop-down menu. The job roles are fetched from the recruiting_jobs table in the PostgreSQL database.

3. Analyze the Resume
Click the "Analyze Resume" button to start the evaluation process.

The system will generate a question based on the job description and resume, then use RAG to evaluate the candidate's fitness for the role.

4. View the Evaluation
The evaluation results will be displayed on the web UI, providing insights into the candidate's suitability for the selected job role.


## Stopping the Application
To stop the application, press Ctrl+C in the terminal where the application is running, or run:

```
bash
docker-compose down
```

Contact
For any questions or issues, please contact [Your Name] at [your.email@example.com].

Thank you for using the AI Recruiter Assistant! We hope this tool helps streamline your recruitment process.