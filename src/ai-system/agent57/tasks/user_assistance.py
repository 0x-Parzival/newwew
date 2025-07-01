from ..core.multi_task_agent import SystemState

class UserAssistanceTask:
    """Provides intelligent user assistance"""
    def __init__(self):
        pass
    async def get_action(self, state: SystemState, exploration_params: dict, relevant_episodes: list):
        """Decide how to assist the user"""
        return {"avatar": "krishna", "assistance_type": "general_help"}  # Placeholder 