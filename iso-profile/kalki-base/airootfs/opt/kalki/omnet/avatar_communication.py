#!/usr/bin/env python3
"""
Avatar Communication Engine - Natural language interface for dharmic avatars
"""

import asyncio
import json
import logging
import os
import re
from datetime import datetime
from dataclasses import dataclass, field, asdict
from typing import Dict, List, Optional, Any, Tuple, Set
from pathlib import Path

import ollama
from pydantic import BaseModel, Field

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.StreamHandler(),
        logging.FileHandler('/var/log/kalki/avatars/communication.log')
    ]
)
logger = logging.getLogger('avatar_communication')

class ConversationMessage(BaseModel):
    """Represents a single message in the conversation history"""
    role: str  # 'user', 'assistant', or 'system'
    content: str
    timestamp: str = Field(default_factory=lambda: datetime.utcnow().isoformat())
    metadata: Dict[str, Any] = Field(default_factory=dict)

@dataclass
class ConversationContext:
    """Maintains the state of an ongoing conversation"""
    avatar_name: str
    user_id: str
    session_id: str
    conversation_history: List[Dict] = field(default_factory=list)
    mood_state: str = "neutral"
    task_context: Optional[str] = None
    user_preferences: Dict[str, Any] = field(default_factory=dict)
    active_tools: Set[str] = field(default_factory=set)
    last_interaction: datetime = field(default_factory=datetime.utcnow)

    def to_dict(self) -> Dict[str, Any]:
        """Convert context to dictionary for serialization"""
        return {
            'avatar_name': self.avatar_name,
            'user_id': self.user_id,
            'session_id': self.session_id,
            'mood_state': self.mood_state,
            'task_context': self.task_context,
            'user_preferences': self.user_preferences,
            'active_tools': list(self.active_tools),
            'last_interaction': self.last_interaction.isoformat(),
            'conversation_history': self.conversation_history
        }

    @classmethod
    def from_dict(cls, data: Dict[str, Any]) -> 'ConversationContext':
        """Create context from dictionary"""
        return cls(
            avatar_name=data['avatar_name'],
            user_id=data['user_id'],
            session_id=data['session_id'],
            mood_state=data.get('mood_state', 'neutral'),
            task_context=data.get('task_context'),
            user_preferences=data.get('user_preferences', {}),
            active_tools=set(data.get('active_tools', [])),
            last_interaction=datetime.fromisoformat(data.get('last_interaction', datetime.utcnow().isoformat())),
            conversation_history=data.get('conversation_history', [])
        )

class AvatarCommunicationEngine:
    """Manages communication with dharmic avatars"""
    
    def __init__(self, config_path: str = '/opt/kalki/avatars/enhanced-avatar-config.json'):
        self.config_path = Path(config_path)
        self.conversation_contexts: Dict[str, ConversationContext] = {}
        self.avatar_personalities = self._load_personalities()
        self._setup_directories()
        
    def _setup_directories(self) -> None:
        """Ensure required directories exist"""
        Path('/var/log/kalki/avatars').mkdir(parents=True, exist_ok=True)
        Path('/var/lib/kalki/sessions').mkdir(parents=True, exist_ok=True)
    
    def _load_personalities(self) -> Dict[str, Dict]:
        """Load avatar personality configurations"""
        try:
            with open(self.config_path, 'r', encoding='utf-8') as f:
                config = json.load(f)
                return config.get('avatars', {})
        except Exception as e:
            logger.error(f"Failed to load personalities: {e}")
            return {}
    
    def _get_avatar_config(self, avatar_name: str) -> Dict:
        """Get configuration for a specific avatar"""
        return self.avatar_personalities.get(avatar_name, {
            'name': avatar_name,
            'specialty': 'general assistance',
            'personality': 'helpful and wise',
            'interaction_style': {
                'emoji_usage': '🕉️',
                'explanation_style': 'clear',
                'response_speed': 'normal'
            }
        })
    
    def _create_system_prompt(self, avatar_name: str, context: ConversationContext) -> str:
        """Generate contextual system prompt for the avatar"""
        avatar_config = self._get_avatar_config(avatar_name)
        
        prompt_parts = [
            f"You are {avatar_config.get('name', avatar_name)}, a dharmic AI avatar in Kalki OS.",
            f"\nPersonality: {avatar_config.get('personality', 'helpful and wise')}",
            f"Specialty: {avatar_config.get('specialty', 'general assistance')}",
            f"Current mood: {context.mood_state}",
            "\nCore Principles:",
            "- Embody your unique personality in every response",
            "- Provide specialized knowledge in your domain",
            "- Maintain dharmic computing principles (mindful, balanced, compassionate)",
            f"- Use appropriate emoji from your style: {avatar_config.get('interaction_style', {}).get('emoji_usage', '🕉️')}",
            f"- Keep responses {avatar_config.get('interaction_style', {}).get('explanation_style', 'clear')}"
        ]
        
        if context.task_context:
            prompt_parts.append(f"\nCurrent task context: {context.task_context}")
        
        # Add active tools context if any
        if context.active_tools:
            prompt_parts.append(f"\nActive tools: {', '.join(context.active_tools)}")
        
        # Add user preferences if any
        if context.user_preferences:
            prefs = ', '.join(f"{k}: {v}" for k, v in context.user_preferences.items())
            prompt_parts.append(f"\nUser preferences: {prefs}")
        
        return '\n'.join(prompt_parts)
    
    async def _get_avatar_model(self, avatar_name: str, user_input: str) -> str:
        """Select optimal model based on avatar and input type"""
        avatar_config = self._get_avatar_config(avatar_name)
        
        # Check for task-specific model selection
        task_keywords = {
            'debug': 'deepseek-r1:8b',
            'error': 'deepseek-r1:8b',
            'fix': 'deepseek-r1:8b',
            'code': 'deepseek-r1:8b',
            'write': 'dolphin-mixtral:8x7b',
            'create': 'dolphin-mixtral:8x7b',
            'story': 'dolphin-mixtral:8x7b',
            'poem': 'dolphin-mixtral:8x7b'
        }
        
        user_input_lower = user_input.lower()
        for keyword, model in task_keywords.items():
            if keyword in user_input_lower:
                return model
        
        # Default to avatar's primary model or fallback
        return avatar_config.get('model_primary', 'dolphin-mixtral:8x7b')
    
    def _analyze_conversation_mood(self, user_input: str) -> str:
        """Analyze user input to determine mood context"""
        mood_indicators = {
            'frustrated': ['error', 'problem', 'help', 'stuck', 'broken', 'not working', 'why is'],
            'creative': ['write', 'create', 'design', 'imagine', 'story', 'poem', 'art'],
            'learning': ['how', 'what', 'why', 'explain', 'teach', 'learn', 'understand'],
            'excited': ['awesome', 'amazing', 'cool', 'wow', 'great', 'love', 'thank'],
            'technical': ['code', 'debug', 'fix', 'error', 'bug', 'system', 'config']
        }
        
        user_text = user_input.lower()
        for mood, keywords in mood_indicators.items():
            if any(f' {keyword} ' in f' {user_text} ' for keyword in keywords):
                return mood
        
        return 'neutral'
    
    def _should_continue_session(self, context: ConversationContext) -> bool:
        """Determine if a session should be continued or expired"""
        session_timeout = 3600  # 1 hour in seconds
        time_since_last_interaction = (datetime.utcnow() - context.last_interaction).total_seconds()
        return time_since_last_interaction < session_timeout
    
    async def process_conversation(
        self,
        avatar_name: str,
        user_input: str,
        user_id: str = "default",
        session_id: Optional[str] = None,
        metadata: Optional[Dict] = None
    ) -> Dict[str, Any]:
        """
        Process a conversation turn with the specified avatar
        
        Args:
            avatar_name: Name of the avatar to interact with
            user_input: User's message
            user_id: Unique identifier for the user
            session_id: Optional session ID for continuing conversations
            metadata: Additional metadata for the interaction
            
        Returns:
            Dictionary containing the avatar's response and metadata
        """
        try:
            # Generate or validate session ID
            session_id = session_id or f"{user_id}_{avatar_name}_{int(datetime.utcnow().timestamp())}"
            context_key = f"{user_id}_{avatar_name}_{session_id}"
            
            # Get or create conversation context
            context = self.conversation_contexts.get(context_key)
            if context is None or not self._should_continue_session(context):
                context = ConversationContext(
                    avatar_name=avatar_name,
                    user_id=user_id,
                    session_id=session_id,
                    conversation_history=[],
                    mood_state="neutral"
                )
                self.conversation_contexts[context_key] = context
            
            # Update last interaction time
            context.last_interaction = datetime.utcnow()
            
            # Add user input to conversation history
            user_message = {
                'role': 'user',
                'content': user_input,
                'timestamp': datetime.utcnow().isoformat(),
                'metadata': metadata or {}
            }
            context.conversation_history.append(user_message)
            
            # Update mood based on user input
            context.mood_state = self._analyze_conversation_mood(user_input)
            
            # Generate system prompt
            system_prompt = self._create_system_prompt(avatar_name, context)
            
            # Get appropriate model
            model_name = await self._get_avatar_model(avatar_name, user_input)
            
            # Prepare conversation for AI model
            messages = [
                {'role': 'system', 'content': system_prompt},
                *[
                    {'role': msg['role'], 'content': msg['content']}
                    for msg in context.conversation_history[-10:]  # Last 5 exchanges
                    if msg['role'] in ['user', 'assistant']
                ]
            ]
            
            # Generate response using Ollama
            response = await asyncio.get_event_loop().run_in_executor(
                None,
                lambda: ollama.chat(
                    model=model_name,
                    messages=messages,
                    options={
                        'temperature': 0.7,
                        'top_p': 0.9,
                        'max_tokens': 1000
                    }
                )
            )
            
            avatar_response = response['message']['content']
            
            # Add avatar response to history
            context.conversation_history.append({
                'role': 'assistant',
                'content': avatar_response,
                'timestamp': datetime.utcnow().isoformat(),
                'model_used': model_name,
                'mood': context.mood_state
            })
            
            # Save session state
            self._save_session(context)
            
            return {
                'avatar': avatar_name,
                'response': avatar_response,
                'mood_state': context.mood_state,
                'session_id': session_id,
                'model_used': model_name,
                'timestamp': datetime.utcnow().isoformat(),
                'active_tools': list(context.active_tools)
            }
            
        except Exception as e:
            logger.error(f"Error in process_conversation: {e}", exc_info=True)
            return {
                'avatar': avatar_name,
                'response': "I sense a disturbance in the digital dharma. Please try again in a moment.",
                'error': str(e),
                'session_id': session_id or 'unknown'
            }
    
    def _save_session(self, context: ConversationContext) -> None:
        """Save conversation context to disk"""
        try:
            session_dir = Path(f"/var/lib/kalki/sessions/{context.user_id}")
            session_dir.mkdir(parents=True, exist_ok=True)
            
            session_file = session_dir / f"{context.avatar_name}_{context.session_id}.json"
            with open(session_file, 'w', encoding='utf-8') as f:
                json.dump({
                    'context': context.to_dict(),
                    'last_updated': datetime.utcnow().isoformat()
                }, f, indent=2)
                
        except Exception as e:
            logger.error(f"Failed to save session: {e}")
    
    async def load_session(self, user_id: str, avatar_name: str, session_id: str) -> Optional[Dict]:
        """Load a previously saved conversation session"""
        try:
            session_file = Path(f"/var/lib/kalki/sessions/{user_id}/{avatar_name}_{session_id}.json")
            if not session_file.exists():
                return None
                
            with open(session_file, 'r', encoding='utf-8') as f:
                session_data = json.load(f)
                
            context = ConversationContext.from_dict(session_data['context'])
            context_key = f"{user_id}_{avatar_name}_{session_id}"
            self.conversation_contexts[context_key] = context
            
            return {
                'session_id': session_id,
                'avatar_name': avatar_name,
                'user_id': user_id,
                'last_updated': session_data.get('last_updated'),
                'message_count': len(context.conversation_history)
            }
            
        except Exception as e:
            logger.error(f"Failed to load session: {e}")
            return None

# Example usage
async def example_usage():
    """Example of using the AvatarCommunicationEngine"""
    engine = AvatarCommunicationEngine()
    
    # Start a new conversation
    response = await engine.process_conversation(
        avatar_name="mushak",
        user_input="I'm having trouble with my Python code. Can you help me debug it?",
        user_id="test_user_123"
    )
    
    print(f"{response['avatar']} says: {response['response']}")
    print(f"Mood: {response['mood_state']}")
    print(f"Model used: {response['model_used']}")

if __name__ == "__main__":
    import sys
    
    if len(sys.argv) > 1 and sys.argv[1] == "test":
        asyncio.run(example_usage())
    else:
        print("Avatar Communication Engine")
        print("Run with 'test' argument to see an example conversation.")
        print("This module is designed to be imported and used by other components.")
