"""
Kalki OS Dharmic Applications Framework
Core module for building conscious, avatar-integrated applications
"""

__version__ = "0.1.0"
__all__ = ['DharmicApp', 'AvatarIntegration', 'OfflineStorage', 'UIModule']

import os
import json
from pathlib import Path
from abc import ABC, abstractmethod
from typing import Dict, List, Optional, Any

class OfflineStorage:
    """Offline-first storage manager for dharmic applications"""
    
    def __init__(self, app_name: str):
        self.app_name = app_name
        self.storage_path = Path(f"~/.local/share/kalki/{app_name}").expanduser()
        self.storage_path.mkdir(parents=True, exist_ok=True)
    
    def save_data(self, key: str, data: Any) -> bool:
        """Save data with the given key"""
        try:
            file_path = self.storage_path / f"{key}.json"
            with open(file_path, 'w') as f:
                json.dump(data, f, indent=2)
            return True
        except Exception as e:
            print(f"Error saving data: {e}")
            return False
    
    def load_data(self, key: str, default: Any = None) -> Any:
        """Load data by key, return default if not found"""
        file_path = self.storage_path / f"{key}.json"
        if not file_path.exists():
            return default
        try:
            with open(file_path, 'r') as f:
                return json.load(f)
        except Exception as e:
            print(f"Error loading data: {e}")
            return default

class AvatarIntegration:
    """Manages avatar interactions for dharmic applications"""
    
    def __init__(self, app_context: str):
        self.app_context = app_context
        self.active_avatars = set()
    
    def request_avatar_assistance(self, avatar_name: str, context: Dict) -> Dict:
        """Request assistance from a specific avatar"""
        # This would integrate with the OMNet neural core
        # For now, return a mock response
        return {
            "success": True,
            "avatar": avatar_name,
            "response": f"{avatar_name} is ready to assist with {self.app_context}",
            "suggested_actions": []
        }
    
    def get_recommended_avatars(self) -> List[str]:
        """Get avatars most relevant to current app context"""
        # This would analyze the app context and return relevant avatars
        return ["nandi", "bunni", "mushak"]  # Example defaults

class UIModule(ABC):
    """Abstract base class for UI modules"""
    
    @abstractmethod
    def render(self, context: Dict) -> None:
        """Render the UI with the given context"""
        pass
    
    @abstractmethod
    def handle_input(self, user_input: str) -> Dict:
        """Process user input and return response"""
        pass

class DharmicApp(ABC):
    """Base class for all dharmic applications"""
    
    def __init__(self, app_name: str, description: str = ""):
        self.app_name = app_name
        self.description = description
        self.storage = OfflineStorage(app_name)
        self.avatar_integration = AvatarIntegration(app_name)
        self.ui_modules: Dict[str, UIModule] = {}
        self._load_config()
    
    def _load_config(self) -> None:
        """Load application configuration"""
        self.config = self.storage.load_data('config', {
            'theme': 'light',
            'notifications': True,
            'avatar_assistance': True
        })
    
    def save_config(self) -> bool:
        """Save current configuration"""
        return self.storage.save_data('config', self.config)
    
    def register_ui_module(self, name: str, module: UIModule) -> None:
        """Register a UI module"""
        self.ui_modules[name] = module
    
    @abstractmethod
    def run(self) -> None:
        """Main application entry point"""
        pass
    
    def cleanup(self) -> None:
        """Clean up resources before exit"""
        self.save_config()
        
    def __enter__(self):
        return self
        
    def __exit__(self, exc_type, exc_val, exc_tb):
        self.cleanup()

# Example usage:
if __name__ == "__main__":
    class MyApp(DharmicApp):
        def run(self):
            print(f"Running {self.app_name}")
            print(f"Available avatars: {self.avatar_integration.get_recommended_avatars()}")
    
    with MyApp("example_app", "An example dharmic application") as app:
        app.run()
