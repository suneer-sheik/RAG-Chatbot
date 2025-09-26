from langchain_community.vectorstores import FAISS
import os
from app.components.embeddings import get_embedding_model

from app.common.logger import get_logger
from app.common.custom_exception import CustomException

from app.config.config import DB_FAISS_PATH

logger = get_logger(__name__)

def load_vector_store():
    try:
        embedding_model = get_embedding_model()

        if os.path.exists(DB_FAISS_PATH):
            logger.info(f"Loading vector store from path: {DB_FAISS_PATH}")
            return FAISS.load_local(
                DB_FAISS_PATH,
                embedding_model,
                allow_dangerous_deserialization=True
            )
        else:
            logger.warning(f"FAISS database path does not exist: {DB_FAISS_PATH}")
            logger.error(str(error_message))
            
    except Exception as e:
        error_message = CustomException("Failed to load vectorstore" , e)
        logger.error(str(error_message))

# Create new vectorstore function
def save_vector_store(text_chunks):
    try:
        if not text_chunks:
            raise CustomException("Text chunks list is empty.")

        logger.info("Generating new vector store...")

        embedding_model = get_embedding_model()

        db = FAISS.from_documents(
            text_chunks,
            embedding_model
        )

        logger.info(f"Saving vector store to path: {DB_FAISS_PATH}")
        db.save_local(DB_FAISS_PATH)

        logger.info("Vector store saved successfully.")
        return db
    
    except Exception as e:
        error_message = CustomException("Failed to create new vectorstore", e)
        logger.error(str(error_message))