import os
import gradio as gr
from langchain_huggingface import HuggingFaceEmbeddings, HuggingFaceEndpoint
from langchain.chains import RetrievalQA
from langchain_community.vectorstores import FAISS
from langchain_core.prompts import PromptTemplate
from dotenv import load_dotenv, find_dotenv

load_dotenv(find_dotenv())

DB_FAISS_PATH = "vectorstore/db_faiss"

# Load vector store
def get_vectorstore():
    embedding_model = HuggingFaceEmbeddings(model_name='sentence-transformers/all-MiniLM-L6-v2')
    db = FAISS.load_local(DB_FAISS_PATH, embedding_model, allow_dangerous_deserialization=True)
    return db

# Set custom prompt
def set_custom_prompt():
    return PromptTemplate(
        template = """
        Your goal is to provide accurate, supportive, and professional responses based on the given context. 

        - Use only the information provided in the context to answer the user's question.
        - If the answer is not available in the context, kindly say, "I'm sorry, but I don't have that information."
        - Respond warmly and naturally to greetings like "hi" or "hello."
        - Maintain a compassionate, reassuring, and professional tone in all responses.
        - Keep answers concise yet informative, avoiding unnecessary details.
        - Do not mention whether context is available—just provide a clear, direct, and helpful response.
        - Focus solely on the current question without referencing previous interactions unless the user explicitly asks.

        Context: {context}  
        Question: {question}  

        Provide a thoughtful and accurate response while ensuring empathy and clarity.
        """,
        input_variables=["context", "question"]
    )

# Load LLM
def load_llm():
    return HuggingFaceEndpoint(
        repo_id="mistralai/Mistral-7B-Instruct-v0.3",
        temperature=0.5,
        huggingfacehub_api_token=os.environ.get("HF_TOKEN"),
        max_length=512
    )

# Define chatbot function with history (to show only the latest response)
def chatbot(prompt, history):
    try:
        vectorstore = get_vectorstore()
        qa_chain = RetrievalQA.from_chain_type(
            llm=load_llm(),
            chain_type="stuff",
            retriever=vectorstore.as_retriever(search_kwargs={'k': 3}),
            return_source_documents=False,
            chain_type_kwargs={'prompt': set_custom_prompt()}
        )
        
        # Only process the current prompt, not history
        response = qa_chain.invoke({'query': prompt})
        
        # Return just the current assistant's response (no history)
        return [{"role": "assistant", "content": response["result"]}]
        
    except Exception as e:
        return [{"role": "assistant", "content": f"Error: {str(e)}"}]

# Create Gradio interface with chat history
iface = gr.ChatInterface(
    fn=chatbot,
    title="AI Health Assistant",
    description="This chatbot provides supportive and professional responses to your health-related questions. Powered by LangChain, Hugging Face, and FAISS, it offers empathetic and accurate answers based on a curated knowledge base.",
    chatbot=gr.Chatbot(type="messages")
)

if __name__ == "__main__":
    iface.launch()



# python c:\Users\User\Desktop\mentsup\mentalbot.py




