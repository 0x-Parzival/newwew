#!/usr/bin/env python3
"""
OMNet: The Neural Core of Kalki OS
Coordinates all avatars, processes requests, and maintains system harmony
"""

import asyncio
import json
import logging
import websockets
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Optional
import ollama

class OMNetCore:
    def __init__(self):
        self.avatars = {}
        self.active_sessions = {}
        self.load_avatar_configs()
        self.setup_logging()
        
    def load_avatar_configs(self):
        """Load avatar personality configurations"""
        config_file = Path('/opt/kalki/avatars/avatar-config.json')
        if config_file.exists():
            with open(config_file, 'r') as f:
                config = json.load(f)
                self.avatars = config.get('avatars', {})
        
    def setup_logging(self):
        """Configure dharmic logging system"""
        log_dir = Path('/var/log/kalki')
        log_dir.mkdir(exist_ok=True, parents=True)
        
        logging.basicConfig(
            filename=log_dir / 'omnet.log',
            level=logging.INFO,
            format='%(asctime)s - %(levelname)s - %(message)s'
        )
        self.logger = logging.getLogger('OMNet')
        
    async def process_request(self, request: Dict) -> Dict:
        """Process incoming requests from avatars or terminals"""
        try:
            avatar_name = request.get('avatar', 'krix')
            user_input = request.get('input', '')
            session_id = request.get('session_id', 'default')
            
            # Get avatar personality
            avatar_config = self.avatars.get(avatar_name, self.avatars.get('krix'))
            
            # Create context-aware prompt
            system_prompt = self.build_system_prompt(avatar_config, session_id)
            
            # Generate response using appropriate model
            model = self.get_avatar_model(avatar_name)
            response = await self.generate_response(model, system_prompt, user_input)
            
            # Log interaction for learning
            self.log_interaction(avatar_name, user_input, response, session_id)
            
            return {
                'avatar': avatar_name,
                'response': response,
                'timestamp': datetime.now().isoformat(),
                'session_id': session_id
            }
            
        except Exception as e:
            self.logger.error(f"OMNet processing error: {str(e)}")
            return {
                'avatar': 'krix',
                'response': 'I sense a disturbance in the digital dharma. Please try again.',
                'error': str(e)
            }
    
    def build_system_prompt(self, avatar_config: Dict, session_id: str) -> str:
        """Build context-aware system prompt for avatar"""
        base_prompt = f"""
You are {avatar_config['name']}, an AI avatar in Kalki OS.
Specialty: {avatar_config['specialty']}
Personality: {avatar_config['personality']}

Key principles:
- Respond in character with your unique personality
- Provide helpful, dharmic guidance
- Keep responses concise but meaningful
- Reference your specialty when relevant
- Always maintain respect for the user's spiritual journey

Current session: {session_id}
"""
        return base_prompt
    
    def get_avatar_model(self, avatar_name: str) -> str:
        """Get appropriate AI model for avatar"""
        model_mapping = {
            'krix': 'phi3:mini',
            'mushak': 'codellama:7b',
            'nandi': 'llama2:7b',
            'shera': 'mistral:7b',
            'bunni': 'mistral:7b',
            'default': 'phi3:mini'
        }
        return model_mapping.get(avatar_name.lower(), model_mapping['default'])
    
    async def generate_response(self, model: str, system_prompt: str, user_input: str) -> str:
        """Generate AI response using Ollama"""
        try:
            response = ollama.chat(
                model=model,
                messages=[
                    {'role': 'system', 'content': system_prompt},
                    {'role': 'user', 'content': user_input}
                ]
            )
            return response['message']['content']
        except Exception as e:
            self.logger.error(f"AI generation error: {str(e)}")
            return "The digital dharma flows differently today. Please try again."
    
    def log_interaction(self, avatar: str, input_text: str, response: str, session_id: str):
        """Log interactions for learning and improvement"""
        interaction = {
            'timestamp': datetime.now().isoformat(),
            'avatar': avatar,
            'input': input_text,
            'response': response,
            'session_id': session_id
        }
        
        # Log to file for analysis
        log_file = Path(f'/var/log/kalki/interactions_{session_id}.jsonl')
        log_file.parent.mkdir(parents=True, exist_ok=True)
        with open(log_file, 'a') as f:
            f.write(json.dumps(interaction) + '\n')

# WebSocket server for real-time communication
async def websocket_handler(websocket, path):
    """Handle WebSocket connections from terminals and applications"""
    omnet = OMNetCore()
    
    try:
        async for message in websocket:
            request = json.loads(message)
            response = await omnet.process_request(request)
            await websocket.send(json.dumps(response))
    except websockets.exceptions.ConnectionClosed:
        pass
    except Exception as e:
        logging.error(f"WebSocket error: {str(e)}")

def start_omnet_server():
    """Start the OMNet coordination server"""
    print("🌌 Starting OMNet Neural Core...")
    start_server = websockets.serve(websocket_handler, "localhost", 8765)
    asyncio.get_event_loop().run_until_complete(start_server)
    print("✅ OMNet Core active on localhost:8765")
    asyncio.get_event_loop().run_forever()

if __name__ == "__main__":
    start_omnet_server()
