#!/usr/bin/env python3
"""
Avatar Model Manager for Kalki OS
Handles dynamic model assignment and resource optimization
"""

import json
import asyncio
import logging
from pathlib import Path
from typing import Dict, List, Optional
import ollama

class AvatarModelManager:
    def __init__(self):
        self.config_path = Path('/opt/kalki/avatars/enhanced-avatar-config.json')
        self.avatars = self.load_avatar_config()
        self.active_models = {}
        self.model_usage_stats = {}
        self.max_concurrent_models = 3
        
    def load_avatar_config(self) -> Dict:
        """Load avatar configuration with error handling"""
        try:
            with open(self.config_path, 'r') as f:
                config = json.load(f)
                return config.get('avatars', {})
        except Exception as e:
            logging.error(f"Failed to load avatar config: {e}")
            return {}
    
    async def get_optimal_model(self, avatar_name: str, task_type: str) -> str:
        """Select optimal model based on avatar and task"""
        avatar_config = self.avatars.get(avatar_name, {})
        
        # Determine model based on task complexity and avatar specialty
        if task_type in ['code_analysis', 'debugging', 'system_diagnosis']:
            if avatar_name in ['mushak', 'kalkian']:
                return avatar_config.get('model_primary', 'deepseek-r1:8b')
        elif task_type in ['creative_writing', 'conversation', 'emotional_support']:
            return avatar_config.get('model_primary', 'dolphin-mixtral:8x7b')
        
        # Default to primary model for avatar
        return avatar_config.get('model_primary', 'dolphin-mixtral:8x7b')
    
    async def ensure_model_loaded(self, model_name: str) -> bool:
        """Ensure model is loaded and ready for inference"""
        if model_name in self.active_models:
            return True
        
        # Check if we need to unload models due to resource constraints
        if len(self.active_models) >= self.max_concurrent_models:
            await self.unload_least_used_model()
        
        try:
            # Load model via Ollama
            ollama.pull(model_name)
            self.active_models[model_name] = True
            logging.info(f"Successfully loaded model: {model_name}")
            return True
        except Exception as e:
            logging.error(f"Failed to load model {model_name}: {e}")
            return False
    
    async def unload_least_used_model(self):
        """Unload the least recently used model to free resources"""
        if not self.model_usage_stats:
            return
        
        least_used = min(self.model_usage_stats, key=self.model_usage_stats.get)
        if least_used in self.active_models:
            del self.active_models[least_used]
            logging.info(f"Unloaded model: {least_used}")

    async def update_usage_stats(self, model_name: str):
        """Update usage statistics for model tracking"""
        self.model_usage_stats[model_name] = asyncio.get_event_loop().time()

    async def get_available_models(self) -> List[str]:
        """Return list of available models on the system"""
        try:
            models = ollama.list()
            return [model['name'] for model in models.get('models', [])]
        except Exception as e:
            logging.error(f"Failed to list available models: {e}")
            return []

    async def cleanup(self):
        """Clean up resources and unload all models"""
        self.active_models.clear()
        logging.info("Cleaned up all loaded models")
