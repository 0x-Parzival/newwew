#!/usr/bin/env python3
"""
Kalki OS Gesture Service
Handles continuous gesture recognition and avatar control
"""

import asyncio
import json
import websockets
import logging
import signal
from pathlib import Path

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    filename='/var/log/kalki/gesture_service.log'
)
logger = logging.getLogger('KalkiGesture')

class GestureService:
    def __init__(self):
        self.gesture_handler = None
        self.omnet_ws = None
        self.running = True
        self.last_gesture_time = 0
        self.gesture_cooldown = 3  # seconds
        
        # Handle graceful shutdown
        signal.signal(signal.SIGINT, self.signal_handler)
        signal.signal(signal.SIGTERM, self.signal_handler)
    
    def signal_handler(self, signum, frame):
        """Handle shutdown signals"""
        logger.info("Shutting down gesture service...")
        self.running = False
    
    async def connect_omnet(self):
        """Connect to OMNet WebSocket"""
        while self.running:
            try:
                self.omnet_ws = await websockets.connect('ws://localhost:8765')
                logger.info("Connected to OMNet WebSocket")
                return True
            except Exception as e:
                logger.error(f"Failed to connect to OMNet: {e}")
                await asyncio.sleep(5)  # Wait before retry
    
    async def process_gesture(self, gesture):
        """Process detected gesture and trigger avatar action"""
        current_time = time.time()
        if current_time - self.last_gesture_time < self.gesture_cooldown:
            return  # Cooldown period
        
        self.last_gesture_time = current_time
        
        # Map gesture to avatar action
        avatar_map = {
            'peace': 'krix',
            'fist': 'mushak',
            'open_palm': 'nandi',
            'pointing': 'shera',
            'heart': 'bunni'
        }
        
        if gesture in avatar_map:
            avatar = avatar_map[gesture]
            logger.info(f"Detected gesture '{gesture}' - summoning {avatar}")
            await self.summon_avatar(avatar)
    
    async def summon_avatar(self, avatar):
        """Send summon command to OMNet"""
        if not self.omnet_ws:
            return
            
        try:
            payload = {
                'avatar': avatar,
                'input': f'summon {avatar} via gesture',
                'session_id': f'gesture_{avatar}'
            }
            
            await self.omnet_ws.send(json.dumps(payload))
            response = await self.omnet_ws.recv()
            response_data = json.loads(response)
            
            logger.info(f"Avatar {avatar} response: {response_data.get('response', 'No response')}")
            
        except Exception as e:
            logger.error(f"Error summoning avatar: {e}")
    
    async def run(self):
        """Main gesture service loop"""
        from gesture_handler import GestureHandler
        
        await self.connect_omnet()
        self.gesture_handler = GestureHandler()
        
        # Start gesture recognition in a separate thread
        def start_gesture_loop():
            try:
                self.gesture_handler.start_gesture_recognition()
            except Exception as e:
                logger.error(f"Gesture recognition error: {e}")
        
        import threading
        gesture_thread = threading.Thread(target=start_gesture_loop, daemon=True)
        gesture_thread.start()
        
        logger.info("Gesture service started")
        
        # Keep the service running
        while self.running:
            await asyncio.sleep(1)
        
        logger.info("Gesture service stopped")

if __name__ == "__main__":
    # Create log directory
    log_dir = Path('/var/log/kalki')
    log_dir.mkdir(exist_ok=True, parents=True)
    
    service = GestureService()
    asyncio.run(service.run())
