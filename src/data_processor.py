import os
import io
import sys
import time
import argparse

import numpy as np
import pandas as pd

import psycopg2
from psycopg2.extensions import ISOLATION_LEVEL_AUTOCOMMIT

from dotenv import load_dotenv

pd.set_option('display.max_columns', None)

# Load environment variables
load_dotenv()

def wait_for_database(max_retries=30, retry_delay=1):
    """Wait for PostgreSQL database to be ready."""
    for i in range(max_retries):
        try:
            conn = psycopg2.connect(
                host=os.getenv("POSTGRES_HOST"),
                database=os.getenv("POSTGRES_DB"),
                user=os.getenv("POSTGRES_USER"),
                password=os.getenv("POSTGRES_PASSWORD")
            )
            conn.close()
            print("Database connection successful!")
            return True
        except psycopg2.OperationalError as e:
            if i == max_retries - 1:
                print(f"Could not connect to database after {max_retries} attempts")
                raise e
            print(f"Waiting for database connection... ({i+1}/{max_retries})")
            time.sleep(retry_delay)
    return False

def clean_dataframe(df):
    """Clean and prepare dataframe for database insertion."""
    try:
        # Print original columns for debugging
        print("\nOriginal columns:")
        print(df.columns.tolist())
        
        # Define exact column mapping
        column_mapping = {
            'Job Title': 'job_title',
            'Job Description': 'job_description'
        }
        
        # Rename columns to match database schema
        df = df.rename(columns=column_mapping)
        
        print("\nColumns after renaming:")
        print(df.columns.tolist())
        
        # Clean text data
        df['job_title'] = df['job_title'].apply(lambda x: str(x).strip())
        df['job_description'] = df['job_description'].apply(lambda x: str(x).strip())
        
        # Add status column with random values
        if 'status' not in df.columns:
            df['status'] = np.random.choice(['available', 'unavailable'], size=len(df))
        
        df['status'] = df['status'].apply(lambda x: str(x).strip())
        
        # Replace any empty strings with default values
        df['job_title'] = df['job_title'].replace('', 'Untitled Position')
        df['job_description'] = df['job_description'].replace('', 'No description provided')
        df['status'] = df['status'].replace('', 'available')
        
        # Verify all required columns exist
        required_columns = ['job_title', 'job_description', 'status']
        missing_columns = [col for col in required_columns if col not in df.columns]
        if missing_columns:
            raise ValueError(f"Missing required columns: {', '.join(missing_columns)}")
        
        print("\nColumns after cleaning:")
        print(df.columns.tolist())
        
        # Print sample of processed data
        print("\nSample of processed data:")
        print(df.head())
        
        return df
    
    except Exception as e:
        raise Exception(f"Error cleaning data: {str(e)}")

def add_status_column(csv_path):
    """Add random status column to the dataset."""
    try:
        # Check if file exists
        if not os.path.exists(csv_path):
            raise FileNotFoundError(f"CSV file not found at: {csv_path}")
            
        # Read the CSV file
        df = pd.read_csv(csv_path)
        df =df.drop(columns=['Unnamed: 0'])

        # Print original data info
        print("\nOriginal data info:")
        print(df.info())
        
        # Clean and standardize the dataframe
        df = clean_dataframe(df)
        
        print(f"\nSuccessfully processed dataset with {len(df)} rows")
        return df
    except Exception as e:
        raise Exception(f"Error processing CSV: {str(e)}")

def save_to_database(df):
    """Save the dataframe to PostgreSQL database using psycopg2."""
    try:
        # Wait for database to be ready
        wait_for_database()
        
        # Final data validation
        df = clean_dataframe(df)
        
        # Connect to database
        conn = psycopg2.connect(
            host=os.getenv("POSTGRES_HOST"),
            database=os.getenv("POSTGRES_DB"),
            user=os.getenv("POSTGRES_USER"),
            password=os.getenv("POSTGRES_PASSWORD")
        )
        conn.set_isolation_level(ISOLATION_LEVEL_AUTOCOMMIT)
        
        # Create cursor
        cur = conn.cursor()
        
        # Create table if it doesn't exist
        cur.execute("""
            CREATE TABLE IF NOT EXISTS recruiting_jobs (
                id SERIAL PRIMARY KEY,
                job_title TEXT NOT NULL,
                job_description TEXT NOT NULL,
                status TEXT NOT NULL CHECK (status IN ('available', 'unavailable'))
            )
        """)
        
        # Clear existing data
        cur.execute("TRUNCATE TABLE recruiting_jobs RESTART IDENTITY")
        
        # Insert new data
        for index, row in df.iterrows():
            cur.execute("""
                INSERT INTO recruiting_jobs (job_title, job_description, status)
                VALUES (%s, %s, %s)
            """, (
                row['job_title'],
                row['job_description'],
                row['status']
            ))
        
        # Create index on status
        cur.execute("""
            DO $$
            BEGIN
                IF NOT EXISTS (
                    SELECT 1 FROM pg_indexes 
                    WHERE indexname = 'idx_status'
                ) THEN
                    CREATE INDEX idx_status ON recruiting_jobs(status);
                END IF;
            END$$;
        """)
        
        print(f"Successfully saved {len(df)} rows to recruiting_jobs table!")
        
        # Close connections
        cur.close()
        conn.commit()
        conn.close()
        
    except Exception as e:
        raise Exception(f"Database error: {str(e)}")
    
def preview_data(df):
    """Preview the dataframe data."""
    print("\nData Preview:")
    print("-" * 80)
    print("\nColumns:")
    print(df.columns.tolist())
    print("\nFirst few rows:")
    print(df[['job_title', 'job_description', 'status']].head())
    print("\nDataframe Info:")
    print(df.info())
    print("\nValue counts for 'status' column:")
    print(df['status'].value_counts())
    print("\nMissing values:")
    print(df.isnull().sum())
    print("-" * 80)

def parse_arguments():
    """Parse command line arguments."""
    parser = argparse.ArgumentParser(description='Process job descriptions CSV and save to database.')
    parser.add_argument('csv_path', 
                       type=str,
                       help='Path to the CSV file containing job descriptions')
    parser.add_argument('--preview', 
                       action='store_true',
                       help='Preview the data before saving to database')
    return parser.parse_args()

def main():
    try:
        # Parse command line arguments
        args = parse_arguments()
        
        # Step 1: Add status column
        print(f"Processing CSV file: {args.csv_path}")
        modified_df = add_status_column(args.csv_path)
        
        # Preview data if requested
        if args.preview:
            preview_data(modified_df)
            
            # Ask for confirmation before saving to database
            response = input("\nDo you want to proceed with saving to database? (y/n): ").lower()
            if response != 'y':
                print("Operation cancelled by user.")
                sys.exit(0)
        
        # Step 2: Save to database
        print("\nSaving to database...")
        save_to_database(modified_df)
        
        print("\nProcess completed successfully!")
        
    except Exception as e:
        print(f"\nError: {str(e)}")
        sys.exit(1)

if __name__ == "__main__":
    main()

# docker exec aiops-recruiter-assistant-web-1 python src/data_processor.py /app/rag-source-knowledge/job_title_des.csv --preview
# python src/data_processor.py rag-source-knowledge/job_title_des.csv --preview