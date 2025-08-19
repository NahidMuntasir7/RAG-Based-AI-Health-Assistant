from fastapi import FastAPI
from pydantic import BaseModel
from gradio_client import Client

app = FastAPI()

# Initialize the Gradio client without the tokenn
client = Client("nahidmuntasir7/HealthAssistant")

# Define the request model
class ChatRequest(BaseModel):
    message: str

# Define the FastAPI endpoint
@app.post("/chat")
async def chat(request: ChatRequest):
    try:
        # Get response from Gradio Space
        response = client.predict(request.message, api_name="/chat")
        return {"response": response}
    except Exception as e:
        return {"error": str(e)}  # Return error message if any exception occurs

# Ensure the app runs correctly when executed directly
if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=7860)
