#!/usr/bin/env python3
"""
Krix AI - Core AI Integration Service
Provides a unified interface for AI models and services
"""

import os
import json
import logging
from typing import Dict, Any, Optional
from pathlib import Path
from fastapi import FastAPI, HTTPException, Depends, status
from fastapi.security import OAuth2PasswordBearer
from pydantic import BaseModel, BaseSettings
import uvicorn
from rich.console import Console
from rich.logging import RichHandler

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format="%(message)s",
    datefmt="[%X]",
    handlers=[RichHandler(rich_tracebacks=True)]
)
logger = logging.getLogger("krix-ai")

# Configuration
class Settings(BaseSettings):
    app_name: str = "Krix AI"
    app_version: str = "0.1.0"
    api_version: str = "v1"
    debug: bool = False
    host: str = "0.0.0.0"
    port: int = 8000
    model_dir: Path = Path("/home/kalki/ai-models")
    ollama_host: str = "http://localhost:11434"
    
    class Config:
        env_file = ".env"
        env_file_encoding = 'utf-8'

# Initialize FastAPI app
app = FastAPI(
    title="Krix AI",
    description="AI Integration Service for Dharma OS",
    version="0.1.0",
    docs_url="/api/docs",
    redoc_url="/api/redoc",
    openapi_url="/api/openapi.json"
)

# Global state
settings = Settings()
console = Console()

# Models
class ChatRequest(BaseModel):
    model: str
    messages: list[Dict[str, str]]
    temperature: float = 0.7
    max_tokens: Optional[int] = None
    stream: bool = False

class ChatResponse(BaseModel):
    response: str
    model: str
    tokens_used: int

# Routes
@app.get("/api/health")
async def health_check():
    """Health check endpoint"""
    return {
        "status": "healthy",
        "service": settings.app_name,
        "version": settings.app_version
    }

@app.post("/api/chat", response_model=ChatResponse)
async def chat(chat_request: ChatRequest):
    """Chat completion endpoint"""
    try:
        # Placeholder for actual model inference
        # In a real implementation, this would interface with Ollama or other model backends
        response = {
            "response": f"This is a placeholder response from {chat_request.model}. "
                      "AI model integration will be configured post-installation.",
            "model": chat_request.model,
            "tokens_used": 0
        }
        return ChatResponse(**response)
    except Exception as e:
        logger.error(f"Error in chat completion: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Error processing chat request"
        )

@app.get("/api/models")
async def list_models():
    """List available AI models"""
    try:
        models = []
        if settings.model_dir.exists():
            models = [d.name for d in settings.model_dir.iterdir() if d.is_dir()]
        
        # Add Ollama models if available
        try:
            import httpx
            async with httpx.AsyncClient() as client:
                ollama_models = await client.get(f"{settings.ollama_host}/api/tags")
                if ollama_models.status_code == 200:
                    models.extend([m["name"] for m in ollama_models.json().get("models", [])])
        except Exception:
            pass
            
        return {"models": sorted(list(set(models)))}
    except Exception as e:
        logger.error(f"Error listing models: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Error listing available models"
        )

def main():
    """Main entry point"""
    console.print(f"[bold green]Starting {settings.app_name} v{settings.app_version}")
    console.print(f"[bold]API Documentation:[/bold] http://{settings.host}:{settings.port}/api/docs")
    
    # Create model directory if it doesn't exist
    settings.model_dir.mkdir(parents=True, exist_ok=True)
    
    # Start the server
    uvicorn.run(
        "krix_ai.main:app",
        host=settings.host,
        port=settings.port,
        reload=settings.debug,
        log_level="info" if not settings.debug else "debug",
        workers=1
    )

if __name__ == "__main__":
    main()
