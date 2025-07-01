from typing import List
from ..core.multi_task_agent import SystemState, TaskType

class TaskSelectorNetwork:
    def __init__(self):
        pass

class ExplorationController:
    def __init__(self):
        pass

class SystemPriorityModel:
    async def get_priorities(self, system_state: SystemState):
        # Placeholder: return dummy priorities
        return {
            'security_threat': 0.1,
            'user_activity': 0.5
        }

class MetaController:
    """Selects which tasks to focus on and exploration strategies"""
    def __init__(self):
        self.task_selector = TaskSelectorNetwork()
        self.exploration_controller = ExplorationController()
        self.system_priority_model = SystemPriorityModel()
    
    async def select_tasks(self, system_state: SystemState) -> List[TaskType]:
        """Select which tasks should be active based on system state"""
        priorities = await self.system_priority_model.get_priorities(system_state)
        selected_tasks = []
        if priorities['security_threat'] > 0.3:
            selected_tasks.append(TaskType.SECURITY_MONITORING)
        if system_state.cpu_usage > 80 or system_state.memory_usage > 85:
            selected_tasks.append(TaskType.RESOURCE_MANAGEMENT)
        if priorities['user_activity'] > 0.5:
            selected_tasks.append(TaskType.USER_ASSISTANCE)
        if priorities['user_activity'] < 0.2:
            selected_tasks.append(TaskType.SYSTEM_OPTIMIZATION)
        return selected_tasks
    
    async def get_exploration_params(self) -> dict:
        """Get exploration parameters for current situation"""
        return {
            'epsilon': 0.1,
            'temperature': 1.0,
            'curiosity_weight': 0.2,
            'novelty_threshold': 0.8
        } 