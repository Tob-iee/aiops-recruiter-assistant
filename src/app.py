import os
import torch
import streamlit as st
from database import get_job_description, init_database
from rag import rag
from agent_handler import candidate_question_generator
from s3_utils import S3Manager  

# torch.classes.__path__ = [os.path.join(torch.__path__[0], torch.classes.__file__)] 

# or simply:
    
torch.classes.__path__ = [] # add this line to manually set it to empty. 

def print_log(message):
    print(message, flush=True)

@st.cache_data
def fetch_job_descriptions():
    return get_job_description()

def main():
    # Initialize database
    try:
        init_database()
    except Exception as e:
        st.error(f"Database initialization error: {str(e)}")
        return

    st.title("Resume Analysis Assistant")
    
    # File upload
    uploaded_file = st.file_uploader("Upload PDF", type=['pdf'])
    
    # Fetch available jobs
    jobs = fetch_job_descriptions()
    if not jobs:
        st.error("No available jobs found in the database!")
        return
        
    # Create job options for dropdown
    job_options = {f"{job[1]} (ID: {job[0]})": job[0] for job in jobs}
    
    # Job description dropdown
    selected_job = st.selectbox("Select Job Description", options=list(job_options.keys()))
    job_id = job_options[selected_job]

    if uploaded_file and job_id and st.button("Analyse Resume"):
        with st.spinner("Processing..."):
            print_log(
                f"Getting answer from assistant for job ID: {job_id}"
            )
        try:

            job_info = get_job_description(job_id)
            if not job_info:
                st.error("Job description not found!")
                return

            # Update agent context and Process query
            with st.spinner("Generating analysis..."):
                agent_generated_question = candidate_question_generator(uploaded_file, job_info)
            
                if agent_generated_question:
                    with st.spinner("Analyzing resume..."):
                        response = rag(agent_generated_question)
                        st.success("Analysis complete!")
                        st.write("Response:", response)
                else:
                    st.error("Failed to generate analysis question")
                
        except Exception as e:
            st.error(f"Error during analysis: {str(e)}")

if __name__ == "__main__":
    main()