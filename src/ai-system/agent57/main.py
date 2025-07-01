import asyncio
from core.multi_task_agent import KalkiAgent57, SystemState
import time

async def main():
    agent = KalkiAgent57()
    # Dummy system state for demonstration
    state = SystemState(
        cpu_usage=10.0,
        memory_usage=20.0,
        disk_usage=30.0,
        network_activity=5.0,
        running_processes=["init", "bash"],
        user_activity={"active": True},
        security_alerts=[],
        timestamp=time.time()
    )
    results = await agent.step(state)
    print("Agent57 step results:", results)

if __name__ == "__main__":
    asyncio.run(main()) 