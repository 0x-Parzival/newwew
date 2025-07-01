#!/usr/bin/env python3
"""
Avatar Learning and Customization System
Enables personality adaptation while maintaining dharmic principles
"""

import json
import re
import numpy as np
import logging
from datetime import datetime, timedelta
from pathlib import Path
from typing import Dict, List, Tuple, Optional, Any, DefaultDict, Set
from collections import defaultdict, Counter
from dataclasses import dataclass, field, asdict
import hashlib

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.StreamHandler(),
        logging.FileHandler('/var/log/kalki/avatars/learning.log')
    ]
)
logger = logging.getLogger('avatar_learning')

@dataclass
class InteractionRecord:
    """Represents a single interaction with an avatar"""
    timestamp: datetime = field(default_factory=datetime.utcnow)
    user_input: str = ""
    avatar_response: str = ""
    satisfaction_score: float = 0.0  # -1.0 to 1.0
    interaction_type: str = "general"
    response_time: float = 0.0  # in seconds
    user_follow_up: Optional[str] = None
    metadata: Dict[str, Any] = field(default_factory=dict)
    
    def to_dict(self) -> Dict[str, Any]:
        """Convert to dictionary for serialization"""
        return {
            'timestamp': self.timestamp.isoformat(),
            'user_input': self.user_input,
            'avatar_response': self.avatar_response,
            'satisfaction_score': self.satisfaction_score,
            'interaction_type': self.interaction_type,
            'response_time': self.response_time,
            'user_follow_up': self.user_follow_up,
            'metadata': self.metadata
        }
    
    @classmethod
    def from_dict(cls, data: Dict[str, Any]) -> 'InteractionRecord':
        """Create from dictionary"""
        return cls(
            timestamp=datetime.fromisoformat(data['timestamp']),
            user_input=data['user_input'],
            avatar_response=data['avatar_response'],
            satisfaction_score=data['satisfaction_score'],
            interaction_type=data['interaction_type'],
            response_time=data['response_time'],
            user_follow_up=data.get('user_follow_up'),
            metadata=data.get('metadata', {})
        )

@dataclass
class UserPreferences:
    """Stores learned preferences for a specific user-avatar pair"""
    response_length: str = "moderate"  # brief, moderate, detailed
    technical_depth: str = "medium"     # low, medium, high
    emoji_usage: str = "moderate"       # minimal, moderate, frequent
    interaction_style: str = "balanced"  # formal, balanced, casual
    preferred_topics: List[str] = field(default_factory=list)
    avoided_topics: List[str] = field(default_factory=list)
    custom_vocabulary: Dict[str, str] = field(default_factory=dict)
    
    def to_dict(self) -> Dict[str, Any]:
        """Convert to dictionary for serialization"""
        return {
            'response_length': self.response_length,
            'technical_depth': self.technical_depth,
            'emoji_usage': self.emoji_usage,
            'interaction_style': self.interaction_style,
            'preferred_topics': self.preferred_topics,
            'avoided_topics': self.avoided_topics,
            'custom_vocabulary': self.custom_vocabulary
        }
    
    @classmethod
    def from_dict(cls, data: Dict[str, Any]) -> 'UserPreferences':
        """Create from dictionary"""
        return cls(
            response_length=data.get('response_length', 'moderate'),
            technical_depth=data.get('technical_depth', 'medium'),
            emoji_usage=data.get('emoji_usage', 'moderate'),
            interaction_style=data.get('interaction_style', 'balanced'),
            preferred_topics=data.get('preferred_topics', []),
            avoided_topics=data.get('avoided_topics', []),
            custom_vocabulary=data.get('custom_vocabulary', {})
        )

class AvatarLearningEngine:
    """
    Handles learning from user interactions to personalize avatar behavior
    while maintaining core personality characteristics.
    """
    
    def __init__(self, data_dir: str = "/var/lib/kalki/avatars/learning"):
        self.data_dir = Path(data_dir)
        self.data_dir.mkdir(parents=True, exist_ok=True)
        
        # In-memory caches
        self.interaction_history: DefaultDict[str, List[InteractionRecord]] = defaultdict(list)
        self.user_preferences: DefaultDict[str, UserPreferences] = defaultdict(UserPreferences)
        self.personality_adjustments: DefaultDict[str, Dict[str, float]] = defaultdict(dict)
        
        # Learning parameters
        self.learning_rate = 0.1
        self.max_personality_drift = 0.3  # Prevent major personality changes
        self.min_interactions_for_learning = 5
        self.history_limit = 1000  # Max interactions to keep in memory per user-avatar pair
        
        # Load existing data
        self._load_data()
    
    def _get_user_avatar_key(self, avatar_name: str, user_id: str) -> str:
        """Generate a unique key for user-avatar pair"""
        return f"{user_id}::{avatar_name}"
    
    def _get_user_data_path(self, user_id: str) -> Path:
        """Get path to user's data directory"""
        # Create a hash of the user ID for directory naming
        user_hash = hashlib.sha256(user_id.encode()).hexdigest()[:16]
        return self.data_dir / user_hash
    
    def _load_data(self) -> None:
        """Load user interaction data from disk"""
        try:
            # Load all user data directories
            for user_dir in self.data_dir.iterdir():
                if not user_dir.is_dir():
                    continue
                
                # Load interaction history
                history_file = user_dir / "interactions.jsonl"
                if history_file.exists():
                    with open(history_file, 'r', encoding='utf-8') as f:
                        for line in f:
                            try:
                                data = json.loads(line)
                                key = f"{data['user_id']}::{data['avatar_name']}"
                                self.interaction_history[key].append(InteractionRecord.from_dict(data))
                            except (json.JSONDecodeError, KeyError) as e:
                                logger.warning(f"Failed to load interaction: {e}")
                
                # Load user preferences
                prefs_file = user_dir / "preferences.json"
                if prefs_file.exists():
                    with open(prefs_file, 'r', encoding='utf-8') as f:
                        prefs_data = json.load(f)
                        for avatar_name, prefs in prefs_data.items():
                            key = f"{user_dir.name}::{avatar_name}"
                            self.user_preferences[key] = UserPreferences.from_dict(prefs)
            
            logger.info(f"Loaded data for {len(self.interaction_history)} user-avatar pairs")
            
        except Exception as e:
            logger.error(f"Error loading learning data: {e}", exc_info=True)
    
    def _save_interaction(self, avatar_name: str, user_id: str, interaction: InteractionRecord) -> None:
        """Save interaction to disk"""
        try:
            user_dir = self._get_user_data_path(user_id)
            user_dir.mkdir(parents=True, exist_ok=True)
            
            # Append to interaction history file
            history_file = user_dir / "interactions.jsonl"
            with open(history_file, 'a', encoding='utf-8') as f:
                data = interaction.to_dict()
                data.update({
                    'avatar_name': avatar_name,
                    'user_id': user_id
                })
                f.write(json.dumps(data) + '\n')
            
            # Enforce history limit by rotating if needed
            if history_file.stat().st_size > 10 * 1024 * 1024:  # 10MB limit
                self._rotate_history_file(history_file)
                
        except Exception as e:
            logger.error(f"Failed to save interaction: {e}", exc_info=True)
    
    def _rotate_history_file(self, history_file: Path) -> None:
        """Rotate history file to prevent it from growing too large"""
        try:
            # Read recent interactions
            with open(history_file, 'r', encoding='utf-8') as f:
                lines = f.readlines()
            
            # Keep only the most recent interactions
            keep_lines = lines[-self.history_limit:]
            
            # Write back the reduced history
            with open(history_file, 'w', encoding='utf-8') as f:
                f.writelines(keep_lines)
                
        except Exception as e:
            logger.error(f"Failed to rotate history file: {e}")
    
    def _save_user_preferences(self, avatar_name: str, user_id: str, preferences: UserPreferences) -> None:
        """Save user preferences to disk"""
        try:
            user_dir = self._get_user_data_path(user_id)
            user_dir.mkdir(parents=True, exist_ok=True)
            
            prefs_file = user_dir / "preferences.json"
            
            # Load existing preferences
            all_prefs = {}
            if prefs_file.exists():
                with open(prefs_file, 'r', encoding='utf-8') as f:
                    all_prefs = json.load(f)
            
            # Update with new preferences
            all_prefs[avatar_name] = preferences.to_dict()
            
            # Save back to disk
            with open(prefs_file, 'w', encoding='utf-8') as f:
                json.dump(all_prefs, f, indent=2)
                
        except Exception as e:
            logger.error(f"Failed to save user preferences: {e}", exc_info=True)
    
    def record_interaction(self, avatar_name: str, user_id: str, interaction_data: Dict) -> None:
        """
        Record a user interaction for learning analysis
        
        Args:
            avatar_name: Name of the avatar involved
            user_id: ID of the user
            interaction_data: Dictionary containing interaction details
        """
        try:
            # Create interaction record
            interaction = InteractionRecord(
                user_input=interaction_data.get('user_input', ''),
                avatar_response=interaction_data.get('avatar_response', ''),
                satisfaction_score=float(interaction_data.get('satisfaction_score', 0.0)),
                interaction_type=interaction_data.get('type', 'general'),
                response_time=float(interaction_data.get('response_time', 0.0)),
                user_follow_up=interaction_data.get('follow_up'),
                metadata=interaction_data.get('metadata', {})
            )
            
            # Add to in-memory history
            key = self._get_user_avatar_key(avatar_name, user_id)
            self.interaction_history[key].append(interaction)
            
            # Enforce history limit
            if len(self.interaction_history[key]) > self.history_limit:
                self.interaction_history[key] = self.interaction_history[key][-self.history_limit:]
            
            # Save to disk
            self._save_interaction(avatar_name, user_id, interaction)
            
            # Update user preferences based on interaction
            self._update_user_preferences(avatar_name, user_id, interaction)
            
            logger.debug(f"Recorded interaction for {key}")
            
        except Exception as e:
            logger.error(f"Error recording interaction: {e}", exc_info=True)
    
    def _update_user_preferences(self, avatar_name: str, user_id: str, interaction: InteractionRecord) -> None:
        """Update user preferences based on interaction"""
        key = self._get_user_avatar_key(avatar_name, user_id)
        interactions = self.interaction_history[key]
        
        # Need minimum interactions before updating preferences
        if len(interactions) < self.min_interactions_for_learning:
            return
        
        # Get or create preferences
        if key not in self.user_preferences:
            self.user_preferences[key] = UserPreferences()
        
        prefs = self.user_preferences[key]
        
        # Analyze response length preference
        response_lengths = [
            len(ia.avatar_response.split()) 
            for ia in interactions[-self.min_interactions_for_learning:]
            if ia.satisfaction_score > 0.5  # Only consider positive interactions
        ]
        
        if response_lengths:
            avg_length = np.mean(response_lengths)
            if avg_length < 20:
                prefs.response_length = "brief"
            elif avg_length > 100:
                prefs.response_length = "detailed"
            else:
                prefs.response_length = "moderate"
        
        # Analyze technical depth preference
        technical_terms = ['algorithm', 'implementation', 'configuration', 'debug', 'optimize']
        technical_score = sum(
            sum(1 for term in technical_terms if term in ia.avatar_response.lower())
            for ia in interactions[-self.min_interactions_for_learning:]
            if ia.satisfaction_score > 0.5
        )
        
        if technical_score > 5:
            prefs.technical_depth = "high"
        elif technical_score > 2:
            prefs.technical_depth = "medium"
        else:
            prefs.technical_depth = "low"
        
        # Analyze emoji usage preference
        emoji_pattern = re.compile(
            r'[\U0001F600-\U0001F64F\U0001F300-\U0001F5FF\U0001F680-\U0001F6FF\U0001F1E0-\U0001F1FF]'
        )
        
        emoji_counts = [
            len(emoji_pattern.findall(ia.avatar_response))
            for ia in interactions[-self.min_interactions_for_learning:]
            if ia.satisfaction_score > 0.5
        ]
        
        if emoji_counts and np.mean(emoji_counts) > 3:
            prefs.emoji_usage = "frequent"
        elif emoji_counts and np.mean(emoji_counts) > 0:
            prefs.emoji_usage = "moderate"
        else:
            prefs.emoji_usage = "minimal"
        
        # Save updated preferences
        self._save_user_preferences(avatar_name, user_id, prefs)
    
    def analyze_user_preferences(self, avatar_name: str, user_id: str) -> Dict[str, Any]:
        """
        Analyze user interaction patterns to identify preferences
        
        Returns:
            Dictionary containing learned preferences
        """
        key = self._get_user_avatar_key(avatar_name, user_id)
        
        if key in self.user_preferences:
            return self.user_preferences[key].to_dict()
        
        # Fallback to analyzing interactions if no prefs exist yet
        interactions = self.interaction_history.get(key, [])
        if len(interactions) < self.min_interactions_for_learning:
            return {}
        
        # This will trigger preference analysis and return the result
        self._update_user_preferences(avatar_name, user_id, interactions[-1])
        return self.user_preferences[key].to_dict() if key in self.user_preferences else {}
    
    def generate_personalized_system_prompt(
        self, 
        avatar_name: str, 
        user_id: str, 
        base_prompt: str
    ) -> str:
        """
        Generate a personalized system prompt based on learned preferences
        
        Args:
            avatar_name: Name of the avatar
            user_id: ID of the user
            base_prompt: The base system prompt to personalize
            
        Returns:
            Personalized system prompt string
        """
        # Get user preferences
        prefs = self.analyze_user_preferences(avatar_name, user_id)
        if not prefs:
            return base_prompt
        
        # Build personalization additions
        personalizations = []
        
        # Response length
        if prefs['response_length'] == 'brief':
            personalizations.append("Keep responses concise and to the point")
        elif prefs['response_length'] == 'detailed':
            personalizations.append("Provide comprehensive, detailed explanations")
        
        # Technical depth
        if prefs['technical_depth'] == 'high':
            personalizations.append("Use technical terminology and provide implementation details")
        elif prefs['technical_depth'] == 'low':
            personalizations.append("Explain concepts in simple, accessible terms")
        
        # Emoji usage
        if prefs['emoji_usage'] == 'frequent':
            personalizations.append("Use emojis liberally to enhance expression")
        elif prefs['emoji_usage'] == 'minimal':
            personalizations.append("Use emojis sparingly and only when highly relevant")
        
        # Add preferred topics if any
        if prefs.get('preferred_topics'):
            topics = ", ".join(f"{topic}" for topic in prefs['preferred_topics'][:3])
            personalizations.append(f"When relevant, incorporate these topics: {topics}")
        
        # Add custom vocabulary
        if prefs.get('custom_vocabulary'):
            vocab_items = ", ".join(f"{k} ({v})" for k, v in prefs['custom_vocabulary'].items())
            personalizations.append(f"Use these custom terms: {vocab_items}")
        
        if not personalizations:
            return base_prompt
        
        # Combine with base prompt
        personalized_addition = "\n\nPersonalization for this user:\n- " + "\n- ".join(personalizations)
        return base_prompt + personalized_addition
    
    def adapt_avatar_behavior(
        self, 
        avatar_name: str, 
        user_id: str, 
        feedback_data: Dict
    ) -> Dict[str, Any]:
        """
        Adapt avatar behavior based on user feedback
        
        Args:
            avatar_name: Name of the avatar
            user_id: ID of the user
            feedback_data: Dictionary containing feedback details
            
        Returns:
            Dictionary with adaptation results
        """
        try:
            # Record the feedback as an interaction
            self.record_interaction(avatar_name, user_id, feedback_data)
            
            key = self._get_user_avatar_key(avatar_name, user_id)
            
            # Initialize adjustments if needed
            if key not in self.personality_adjustments:
                self.personality_adjustments[key] = {
                    'response_speed': 0.0,      # -1.0 (slower) to 1.0 (faster)
                    'technical_depth': 0.0,      # -1.0 (simpler) to 1.0 (more technical)
                    'friendliness': 0.0,         # -1.0 (more formal) to 1.0 (more casual)
                    'verbosity': 0.0,            # -1.0 (more concise) to 1.0 (more verbose)
                    'creativity': 0.0,           # -1.0 (more factual) to 1.0 (more creative)
                    'last_updated': datetime.utcnow().isoformat()
                }
            
            adjustments = self.personality_adjustments[key]
            satisfaction = float(feedback_data.get('satisfaction_score', 0))
            
            # Only adjust based on significant feedback
            if abs(satisfaction) > 0.3:
                # Adjust based on explicit feedback keywords
                user_input = feedback_data.get('user_input', '').lower()
                
                # Response speed adjustments
                if any(word in user_input for word in ['slow', 'fast', 'quick', 'speed']):
                    if 'slow' in user_input and satisfaction < 0:
                        adjustments['response_speed'] += self.learning_rate * abs(satisfaction)
                    elif 'fast' in user_input or 'quick' in user_input:
                        if satisfaction > 0:
                            adjustments['response_speed'] += self.learning_rate * satisfaction
                        else:
                            adjustments['response_speed'] -= self.learning_rate * abs(satisfaction)
                
                # Technical depth adjustments
                if any(word in user_input for word in ['technical', 'simple', 'explain', 'detail']):
                    if 'too technical' in user_input or 'confusing' in user_input:
                        adjustments['technical_depth'] -= self.learning_rate * abs(satisfaction)
                    elif 'more detail' in user_input or 'technical' in user_input:
                        adjustments['technical_depth'] += self.learning_rate * satisfaction
                
                # Friendliness adjustments
                if any(word in user_input for word in ['friendly', 'formal', 'casual', 'professional']):
                    if 'too casual' in user_input or 'unprofessional' in user_input:
                        adjustments['friendliness'] -= self.learning_rate * abs(satisfaction)
                    elif 'friendly' in user_input or 'casual' in user_input:
                        adjustments['friendliness'] += self.learning_rate * satisfaction
                
                # Verbosity adjustments
                if any(word in user_input for word in ['verbose', 'wordy', 'brief', 'concise']):
                    if 'too long' in user_input or 'wordy' in user_input:
                        adjustments['verbosity'] -= self.learning_rate * abs(satisfaction)
                    elif 'more detail' in user_input or 'explain more' in user_input:
                        adjustments['verbosity'] += self.learning_rate * satisfaction
                
                # Apply bounds to all adjustments
                for adj_key in ['response_speed', 'technical_depth', 'friendliness', 'verbosity', 'creativity']:
                    adjustments[adj_key] = max(-1.0, min(1.0, adjustments[adj_key]))
                
                adjustments['last_updated'] = datetime.utcnow().isoformat()
                
                logger.info(f"Updated personality adjustments for {key}: {adjustments}")
            
            return {
                'status': 'success',
                'adjustments': adjustments,
                'timestamp': datetime.utcnow().isoformat()
            }
            
        except Exception as e:
            logger.error(f"Error adapting avatar behavior: {e}", exc_info=True)
            return {
                'status': 'error',
                'error': str(e),
                'timestamp': datetime.utcnow().isoformat()
            }

# Example usage
if __name__ == "__main__":
    # Initialize the learning engine
    engine = AvatarLearningEngine()
    
    # Example interaction
    interaction = {
        'user_input': 'Can you explain how to optimize this code?',
        'avatar_response': 'Here are some optimization techniques...',
        'satisfaction_score': 0.8,
        'type': 'code_help',
        'response_time': 2.5,
        'follow_up': 'That was helpful, thanks!',
        'metadata': {'context': 'programming'}
    }
    
    # Record the interaction
    engine.record_interaction('mushak', 'user123', interaction)
    
    # Get personalized prompt
    base_prompt = "You are a helpful AI assistant."
    personalized = engine.generate_personalized_system_prompt('mushak', 'user123', base_prompt)
    print("Personalized Prompt:", personalized)
    
    # Provide feedback
    feedback = {
        'user_input': 'Your response was too technical',
        'satisfaction_score': -0.7,
        'type': 'feedback',
        'follow_up': 'Can you explain in simpler terms?'
    }
    
    # Adapt behavior based on feedback
    result = engine.adapt_avatar_behavior('mushak', 'user123', feedback)
    print("Adaptation Result:", result)
