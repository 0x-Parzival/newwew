from ..core.multi_task_agent import TaskType
from typing import Dict, Any

class AvatarIntegration:
    """Integrates Agent57 with Kalki's 12 avatar system"""
    def __init__(self):
        self.avatar_capabilities = {
            'matsya': ['system_monitoring', 'data_recovery'],
            'kurma': ['stability_optimization', 'system_patience'],
            'varaha': ['performance_rescue', 'resource_optimization'],
            'narasimha': ['security_enforcement', 'threat_elimination'],
            'vamana': ['efficient_resource_use', 'minimalism'],
            'parashurama': ['debugging', 'problem_elimination'],
            'rama': ['leadership', 'task_coordination'],
            'krishna': ['wisdom', 'complex_problem_solving'],
            'buddha': ['user_wellness', 'mindful_computing'],
            'kalki': ['future_optimization', 'innovation'],
            'hayagriva': ['knowledge_management', 'learning'],
            'dhanvantari': ['system_healing', 'maintenance']
        }
    async def route_task_to_avatar(self, task_type: TaskType, context: Dict[str, Any]) -> str:
        """Route Agent57 tasks to appropriate avatars"""
        if task_type == TaskType.SECURITY_MONITORING:
            return 'narasimha'
        elif task_type == TaskType.SYSTEM_OPTIMIZATION:
            if context.get('performance_critical', False):
                return 'varaha'
            else:
                return 'vamana'
        elif task_type == TaskType.USER_ASSISTANCE:
            if context.get('learning_context', False):
                return 'hayagriva'
            elif context.get('wellness_check', False):
                return 'buddha'
            else:
                return 'krishna'
        elif task_type == TaskType.RESOURCE_MANAGEMENT:
            return 'kurma'
        elif task_type == TaskType.APPLICATION_MANAGEMENT:
            return 'rama'
        else:
            return 'kalki' 