import os
from typing import Optional
from typing import Union, IO

from dotenv import load_dotenv

from huggingface_hub import login
from smolagents import CodeAgent, HfApiModel 

load_dotenv()

HF_API_KEY = os.getenv("HF_API_KEY")
if not HF_API_KEY:
    raise ValueError("Hugging Face API Key is missing! Set 'HUGGINGFACEHUB_API_TOKEN'.")

# login(HF_API_KEY) # Not required for public models

# The agent_handler.py script contains a function called candidate_question_generator that generates a question based on the job description and the extracted information from a resume. The function uses the CodeAgent class from the smolagents library to create an AI agent that can generate questions. The agent is configured with a model from the Hugging Face Model Hub (HfApiModel) and a tool for extracting text content from a PDF file (extract_pdf_content).


def candidate_question_generator(pdf_file: Union[str, IO], job_info: tuple) -> Optional[str]:
    model = HfApiModel()
    agent = CodeAgent(tools=[],
                model=model,
                add_base_tools=True)

    job_title, job_description = job_info


    return agent.run(
        f"""Generate a question that will be used as a query for a RAG system to evaluate how much the candidate fits with the job role they are applying for.
        
        Job Title: {job_title}
        Job Description: {job_description}
        Resume: {pdf_file}
        
        The question should be elaborate and specific, encompassing the level of experience and skills of the particular candidate as well as the tools and experience they have gained over time concerning the role."""
    )

# def main():
#     pdf_file = Path("rag-source-knowledge/Nwoke Tochukwu Resume.pdf")  # Set the PDF file path here
#     job_description = "We are looking for hire experts flutter developer. So you are eligible this post then apply your resume. Job Types: Full-time, Part-time Salary: ₹20,000.00 - ₹40,000.00 per month Benefits: Flexible schedule Food allowance Schedule: Day shift Supplemental Pay: Joining bonus Overtime pay Experience: total work: 1 year (Preferred) Housing rent subsidy: Yes Industry: Software Development Work Remotely: Temporarily due to COVID-19"
#     candidate_question_generator(pdf_file,job_description)
    # print(agent.system_prompt_template)

# if __name__ == "__main__":
#     main()
# Get the job description info and user uploaded resume in pdf from the streamlit web ui.
#  Then extract the content of the pdf file. Using the job description and extracted resume info,
#  generate a question and pass it to the rag which generates an output to the user.

