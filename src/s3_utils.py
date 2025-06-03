import os
import boto3
import json
import pandas as pd
from io import StringIO
from botocore.exceptions import ClientError, NoCredentialsError
from dotenv import load_dotenv

load_dotenv()

class S3Manager:
    def __init__(self):
        self.bucket_name = os.getenv("S3_BUCKET_NAME")
        self.s3_prefix = os.getenv("S3_PREFIX", "rag-source-knowledge/")  # Default prefix
        
        # Initialize S3 client
        try:
            self.s3_client = boto3.client(
                's3',
                aws_access_key_id=os.getenv("AWS_ACCESS_KEY_ID"),
                aws_secret_access_key=os.getenv("AWS_SECRET_ACCESS_KEY"),
                region_name=os.getenv("AWS_DEFAULT_REGION", "us-east-1")
            )
            print(f"S3 client initialized for bucket: {self.bucket_name}")
        except NoCredentialsError:
            print("AWS credentials not found. Make sure to set AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY")
            raise
    
    def download_json_file(self, s3_key):
        """Download JSON file from S3 and return as Python object."""
        try:
            full_key = f"{self.s3_prefix}{s3_key}" if not s3_key.startswith(self.s3_prefix) else s3_key
            print(f"Downloading JSON from S3: s3://{self.bucket_name}/{full_key}")
            
            response = self.s3_client.get_object(Bucket=self.bucket_name, Key=full_key)
            content = response['Body'].read().decode('utf-8')
            return json.loads(content)
        except ClientError as e:
            print(f"Error downloading JSON file from S3: {str(e)}")
            raise
        except json.JSONDecodeError as e:
            print(f"Error parsing JSON file: {str(e)}")
            raise
    
    def download_csv_file(self, s3_key):
        """Download CSV file from S3 and return as pandas DataFrame."""
        try:
            full_key = f"{self.s3_prefix}{s3_key}" if not s3_key.startswith(self.s3_prefix) else s3_key
            print(f"Downloading CSV from S3: s3://{self.bucket_name}/{full_key}")
            
            response = self.s3_client.get_object(Bucket=self.bucket_name, Key=full_key)
            content = response['Body'].read().decode('utf-8')
            return pd.read_csv(StringIO(content))
        except ClientError as e:
            print(f"Error downloading CSV file from S3: {str(e)}")
            raise
        except Exception as e:
            print(f"Error reading CSV file: {str(e)}")
            raise
    
    def upload_file(self, local_file_path, s3_key):
        """Upload a file to S3."""
        try:
            full_key = f"{self.s3_prefix}{s3_key}" if not s3_key.startswith(self.s3_prefix) else s3_key
            print(f"Uploading file to S3: s3://{self.bucket_name}/{full_key}")
            
            self.s3_client.upload_file(local_file_path, self.bucket_name, full_key)
            print(f"Successfully uploaded {local_file_path} to S3")
        except ClientError as e:
            print(f"Error uploading file to S3: {str(e)}")
            raise
    
    def check_file_exists(self, s3_key):
        """Check if a file exists in S3."""
        try:
            full_key = f"{self.s3_prefix}{s3_key}" if not s3_key.startswith(self.s3_prefix) else s3_key
            self.s3_client.head_object(Bucket=self.bucket_name, Key=full_key)
            return True
        except ClientError:
            return False