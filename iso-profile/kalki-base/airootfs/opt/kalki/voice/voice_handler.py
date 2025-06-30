#!/usr/bin/env python3
"""
Voice Handler for Kalki OS
Integrates speech recognition and text-to-speech for avatar interaction
"""

import speech_recognition as sr
import pyttsx3
import asyncio
import json
from pathlib import Path

class VoiceHandler:
    def __init__(self):
        self.recognizer = sr.Recognizer()
        self.microphone = sr.Microphone()
        self.tts_engine = pyttsx3.init()
        self.setup_tts()
        
    def setup_tts(self):
        """Configure text-to-speech with dharmic voice"""
        voices = self.tts_engine.getProperty('voices')
        # Prefer female voice for spiritual feel
        for voice in voices:
            if 'female' in voice.name.lower():
                self.tts_engine.setProperty('voice', voice.id)
                break
        
        self.tts_engine.setProperty('rate', 150)  # Slower, more meditative
        self.tts_engine.setProperty('volume', 0.8)
    
    def listen_for_wake_word(self):
        """Listen for avatar wake words"""
        wake_words = ['hey krix', 'hey mushak', 'hey nandi', 'hey shera', 'hey bunni']
        
        with self.microphone as source:
            self.recognizer.adjust_for_ambient_noise(source)
        
        try:
            with self.microphone as source:
                audio = self.recognizer.listen(source, timeout=1, phrase_time_limit=3)
            
            text = self.recognizer.recognize_google(audio).lower()
            
            for wake_word in wake_words:
                if wake_word in text:
                    avatar = wake_word.split()[1]
                    return avatar, text.replace(wake_word, '').strip()
            
            return None, None
            
        except sr.RequestError:
            return None, "Network error"
        except sr.UnknownValueError:
            return None, None
        except sr.WaitTimeoutError:
            return None, None
    
    def speak(self, text, avatar='krix'):
        """Convert text to speech with avatar personality"""
        # Adjust voice characteristics based on avatar
        if avatar == 'mushak':
            self.tts_engine.setProperty('rate', 200)  # Faster for debugging
        elif avatar == 'nandi':
            self.tts_engine.setProperty('rate', 130)  # Slower, more stable
        elif avatar == 'bunni':
            self.tts_engine.setProperty('rate', 170)  # Playful pace
        else:
            self.tts_engine.setProperty('rate', 150)  # Default
        
        self.tts_engine.say(text)
        self.tts_engine.runAndWait()
