#!/usr/bin/env python3
"""
Kalki OS Voice Service
Handles continuous voice recognition and integration with OMNet
"""

import asyncio
import json
import websockets
from pathlib import Path
import signal
import logging
from voice_handler import VoiceHandler

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    filename='/var/log/kalki/voice_service.log'
)
logger = logging.getLogger('KalkiVoice')

class VoiceService:
    def __init__(self):
        self.voice = VoiceHandler()
        self.omnet_ws = None
        self.running = True
        self.current_avatar = 'krix'
        
        # Handle graceful shutdown
        signal.signal(signal.SIGINT, self.signal_handler)
        signal.signal(signal.SIGTERM, self.signal_handler)
    
    def signal_handler(self, signum, frame):
        """Handle shutdown signals"""
        logger.info("Shutting down voice service...")
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
    
    async def process_voice_command(self, text):
        """Send voice command to OMNet and speak the response"""
        if not text or not self.omnet_ws:
            return
            
        try:
            payload = {
                'avatar': self.current_avatar,
                'input': text,
                'session_id': f'voice_{self.current_avatar}'
            }
            
            await self.omnet_ws.send(json.dumps(payload))
            response = await self.omnet_ws.recv()
            response_data = json.loads(response)
            
            # Speak the response
            self.voice.speak(response_data.get('response', 'I did not understand that'), 
                           self.current_avatar)
            
        except Exception as e:
            logger.error(f"Error processing voice command: {e}")
            self.voice.speak("I'm having trouble connecting to the system.")
    
    async def run(self):
        """Main voice service loop"""
        await self.connect_omnet()
        
        logger.info("Starting voice service. Say 'Hey Krix' to begin.")
        self.voice.speak("Voice service activated. I'm listening for your commands.")
        
        while self.running:
            try:
                # Listen for wake word
                avatar, command = self.voice.listen_for_wake_word()
                
                if avatar:
                    self.current_avatar = avatar
                    self.voice.speak(f"Yes, I'm listening.", avatar)
                    
                    # Get the actual command
                    _, command = self.voice.listen_for_wake_word()
                    if command:
                        await self.process_voice_command(command)
                
                await asyncio.sleep(0.1)
                
            except Exception as e:
                logger.error(f"Error in main loop: {e}")
                await asyncio.sleep(1)

if __name__ == "__main__":
    # Create log directory
    log_dir = Path('/var/log/kalki')
    log_dir.mkdir(exist_ok=True, parents=True)
    
    service = VoiceService()
    asyncio.run(service.run())
