import torch
import torch.nn as nn
from typing import List, Dict
from ..core.multi_task_agent import SystemState, TaskType

class EpisodicMemoryModule:
    """Stores and retrieves system management episodes"""
    def __init__(self, capacity: int = 100000):
        self.capacity = capacity
        self.episodes = []
        self.embedding_network = self._build_embedding_network()
    
    def store_episode(self, state: SystemState, action: Dict, reward: float, next_state: SystemState):
        """Store a system management episode"""
        episode = {
            'state': state,
            'action': action,
            'reward': reward,
            'next_state': next_state,
            'timestamp': state.timestamp,
            'embedding': self._get_state_embedding(state)
        }
        self.episodes.append(episode)
        if len(self.episodes) > self.capacity:
            self.episodes.pop(0)
    
    def get_relevant_episodes(self, task_type: TaskType, current_state: SystemState = None, k: int = 10) -> List[Dict]:
        """Retrieve similar episodes for current situation"""
        if current_state is None or not self.episodes:
            return []
        current_embedding = self._get_state_embedding(current_state)
        similarities = []
        for episode in self.episodes:
            if self._is_relevant_task(episode, task_type):
                similarity = self._cosine_similarity(current_embedding, episode['embedding'])
                similarities.append((similarity, episode))
        similarities.sort(key=lambda x: x[0], reverse=True)
        return [episode for _, episode in similarities[:k]]
    
    def _build_embedding_network(self) -> nn.Module:
        """Neural network to embed system states"""
        return nn.Sequential(
            nn.Linear(50, 128),
            nn.ReLU(),
            nn.Linear(128, 64),
            nn.ReLU(),
            nn.Linear(64, 32)
        )
    
    def _get_state_embedding(self, state: SystemState):
        # Placeholder: convert state to tensor and pass through embedding network
        # In practice, you would extract features from state
        dummy_features = torch.zeros(50)
        return self.embedding_network(dummy_features)
    
    def _cosine_similarity(self, a, b):
        return torch.nn.functional.cosine_similarity(a, b, dim=0).item()
    
    def _is_relevant_task(self, episode, task_type: TaskType):
        # Placeholder: always return True for now
        return True 