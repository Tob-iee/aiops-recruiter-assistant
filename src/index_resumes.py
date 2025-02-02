import os
import json
import time
from sentence_transformers import SentenceTransformer
from elasticsearch import Elasticsearch
from tqdm.auto import tqdm
from dotenv import load_dotenv

load_dotenv()

ELASTIC_URL = os.getenv("ELASTIC_URL_LOCAL")
EMBEDDED_MODEL_NAME = os.getenv("EMBEDDED_MODEL_NAME")
INDEX_NAME = os.getenv("INDEX_NAME")

DATA_LOCATION = "/app/rag-source-knowledge/Resume_DataSet-with-ids.json"

def fetch_documents():
    print("Fetching documents...")
    try:
        with open(DATA_LOCATION, 'r', encoding='utf-8') as file:
            documents = json.load(file)
        print(f"Successfully loaded {len(documents)} documents")
        return documents
    except Exception as e:
        print(f"Error loading documents: {str(e)}")
        return []

def embed_documents(documents):
    print("Embedding documents...")
    try:
        embedded_model = SentenceTransformer(EMBEDDED_MODEL_NAME)
        embedded_documents = []

        for doc in tqdm(documents):
            doc['Resume_Vector'] = embedded_model.encode(doc['Resume']).tolist()
            embedded_documents.append(doc)
        return embedded_documents
    except Exception as e:
        print(f"Error embedding documents: {str(e)}")
        return []

def setup_elasticsearch():
    print("Setting up Elasticsearch...")
    try:
        es_client = Elasticsearch(ELASTIC_URL)
        index_settings = {
            "settings": {
                "number_of_shards": 2,
                "number_of_replicas": 2
            },
            "mappings": {
                "properties": {
                    "Category": {"type": "text"},
                    "Resume": {"type": "text"},
                    "Id": {"type": "keyword"},
                    "Resume_Vector": {
                        "type": "dense_vector",
                        "dims": 768,
                        "index": True,
                        "similarity": "cosine"
                    }
                }
            }
        }

        # Delete index if exists and Create new index
        es_client.indices.delete(index=INDEX_NAME, ignore_unavailable=True)
        es_client.indices.create(index=INDEX_NAME, body=index_settings)
        
        print(f"Elasticsearch index '{INDEX_NAME}' created")
        return es_client
    except Exception as e:
        print(f"Error setting up Elasticsearch: {str(e)}")
        return None

def index_documents(es_client, documents):
    print("Indexing documents...")
    if not es_client or not documents:
        print("Cannot index documents: missing client or documents")
        return

    embedded_documents = embed_documents(documents)
    for doc in tqdm(embedded_documents):
        try:
            es_client.index(index=INDEX_NAME, document=doc)
        except Exception as e:
            print(f"Error indexing document: {str(e)}")

    print(f"Indexed {len(documents)} documents")

def main():
    print("Starting the indexing process...")
    
    # Wait for Elasticsearch to be ready
    max_retries = 30
    retry_delay = 2
    
    for i in range(max_retries):
        try:
            es_client = Elasticsearch(ELASTIC_URL)
            es_client.info()
            print("Successfully connected to Elasticsearch")
            break
        except Exception as e:
            if i == max_retries - 1:
                print(f"Could not connect to Elasticsearch after {max_retries} attempts")
                return
            print(f"Waiting for Elasticsearch... ({i+1}/{max_retries})")
            time.sleep(retry_delay)

    documents = fetch_documents()
    if documents:
        es_client = setup_elasticsearch()
        if es_client:
            index_documents(es_client, documents)
            print("Indexing process completed successfully")
        else:
            print("Failed to setup Elasticsearch")
    else:
        print("No documents to index")

if __name__ == "__main__":
    main()