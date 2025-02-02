import os
import psycopg2

def get_db_connection():
    return psycopg2.connect(
        host=os.getenv("POSTGRES_HOST"),
        database=os.getenv("POSTGRES_DB"),
        user=os.getenv("POSTGRES_USER"),
        password=os.getenv("POSTGRES_PASSWORD"),
    )

def init_database():
    """Initialize database and create tables if they don't exist."""
    conn = get_db_connection()
    try:
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
        
        # Create index on status if it doesn't exist
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
        
        conn.commit()
        cur.close()
        conn.close()
        
    except Exception as e:
        raise Exception(f"Database initialization error: {str(e)}")

def get_job_description(job_id=None):
    """Fetch available job descriptions from PostgreSQL database."""
    conn = get_db_connection()
    try:
        cur = conn.cursor()
        
        if job_id is None:
            # Fetch all available jobs
            cur.execute("""
                SELECT id, job_title, job_description 
                FROM recruiting_jobs 
                WHERE status = 'available'
                ORDER BY job_title
            """)
            result = cur.fetchall()
        else:
            # Fetch specific job
            cur.execute("""
                SELECT job_title, job_description 
                FROM recruiting_jobs 
                WHERE status = 'available' AND id = %s
            """, (job_id,))
            result = cur.fetchone()
        
        cur.close()
        conn.close()
        
        return result
    except Exception as e:
        raise Exception(f"Database error: {str(e)}")


