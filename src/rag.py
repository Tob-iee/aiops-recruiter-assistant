import os
import time
import json

from openai import OpenAI
from functools import lru_cache

from elasticsearch import Elasticsearch
from sentence_transformers import SentenceTransformer
from dotenv import load_dotenv

load_dotenv()

ELASTIC_URL = os.getenv("ELASTIC_URL", "http://elasticsearch:9200")
OPENAI_API_KEY = os.getenv("OPENAI_API_KEY", "your-api-key-here")
EMBEDDED_MODEL_NAME = os.getenv("EMBEDDED_MODEL_NAME", "multi-qa-MiniLM-L6-cos-v1")

if not OPENAI_API_KEY:
    raise ValueError("OpenAI API key not found in environment variables")

es_client = Elasticsearch(ELASTIC_URL)
openai_client = OpenAI(api_key=OPENAI_API_KEY)

embedded_model = SentenceTransformer(EMBEDDED_MODEL_NAME)

@lru_cache(maxsize=1)
def get_embedded_model():
    """Cache the model loading to avoid repeated downloads"""
    try:
        return SentenceTransformer(EMBEDDED_MODEL_NAME)
    except Exception as e:
        print(f"Error loading model: {str(e)}")
        raise


def elastic_search_vector(vector_search_term, index_name="recruiter-assistant-resumes"):
    knn = {
        "field": "Resume_Vector",  
        "query_vector": vector_search_term,
        "k": 5,
        "num_candidates": 10000,
    }

    search_query = {
        "knn": knn,
        "_source": ["Category", "Resume", 'Id']
    }

    try:
        res = es_client.search(index=index_name, body=search_query)
        result_docs = []
        for hit in res['hits']['hits']:
            result_docs.append(hit['_source'])
        return result_docs
    except Exception as e:
        print(f"Error in elastic search: {str(e)}")
        return []

def search(query):
    try:
        embedded_model = get_embedded_model()
        vector_query = embedded_model.encode(query)
        return elastic_search_vector(vector_query)
    except Exception as e:
        print(f"Error in search: {str(e)}")
        raise

def build_prompt(query, search_results):
    try:
        prompt_template = """
        You are a recruiter assistant. Using the information, skill, and experience of this candidate, 
        rate their fitness for the role on a scale of 1-100 percent with a descriptive answer to why they should be selected for this role. 
        Answer the QUESTION based on the CONTEXT.

        QUESTION: {question}

        CONTEXT: 
        {context}
        """.strip()

        context = ""
        for doc in search_results:
            context = context + f"Category: {doc['Category']}\nResume: {doc['Resume']}\n\n"

        return prompt_template.format(question=query, context=context).strip()
    except Exception as e:
        print(f"Error building prompt: {str(e)}")
        raise


def llm(prompt,model):
    try:
        response = openai_client.chat.completions.create(
            model=model,
            messages=[{"role":"user","content": prompt}],
            temperature=0.7,
            max_tokens=1000
        )

        return response.choices[0].message.content
    except Exception as e:
            print(f"Error in LLM call: {str(e)}")
            raise

def rag(query,model='gpt-4o-mini'):
    try:
        search_results = search(query)
        prompt = build_prompt(query, search_results)
        result = llm(prompt, model)
        return result
    except Exception as e:
        print(f"Error in RAG process: {str(e)}")
        raise



