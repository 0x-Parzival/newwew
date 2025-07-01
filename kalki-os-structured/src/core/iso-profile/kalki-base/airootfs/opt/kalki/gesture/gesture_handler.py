#!/usr/bin/env python3
"""
Gesture Handler for Kalki OS
MediaPipe-based hand gesture recognition for avatar control
"""

import cv2
import mediapipe as mp
import json
import time
from pathlib import Path

class GestureHandler:
    def __init__(self):
        self.mp_hands = mp.solutions.hands
        self.hands = self.mp_hands.Hands(
            static_image_mode=False,
            max_num_hands=2,
            min_detection_confidence=0.7,
            min_tracking_confidence=0.5
        )
        self.mp_draw = mp.solutions.drawing_utils
        
        # Define gesture mappings
        self.gestures = {
            'peace': 'summon_krix',
            'fist': 'summon_mushak',
            'open_palm': 'summon_nandi',
            'pointing': 'summon_shera',
            'heart': 'summon_bunni'
        }
    
    def detect_gesture(self, landmarks):
        """Detect gesture from hand landmarks"""
        # Get key points for gesture recognition
        thumb_tip = landmarks[4]
        index_tip = landmarks[8]
        middle_tip = landmarks[12]
        ring_tip = landmarks[16]
        pinky_tip = landmarks[20]
        
        # Peace sign (index and middle up)
        if (index_tip.y < landmarks[6].y and 
            middle_tip.y < landmarks[10].y and
            ring_tip.y > landmarks[14].y and
            pinky_tip.y > landmarks[18].y):
            return 'peace'
        
        # Fist (all fingers down)
        if (index_tip.y > landmarks[6].y and
            middle_tip.y > landmarks[10].y and
            ring_tip.y > landmarks[14].y and
            pinky_tip.y > landmarks[18].y):
            return 'fist'
        
        # Open palm (all fingers up)
        if (index_tip.y < landmarks[6].y and
            middle_tip.y < landmarks[10].y and
            ring_tip.y < landmarks[14].y and
            pinky_tip.y < landmarks[18].y):
            return 'open_palm'
        
        return None
    
    def start_gesture_recognition(self):
        """Start camera and gesture recognition loop"""
        cap = cv2.VideoCapture(0)
        
        while True:
            ret, frame = cap.read()
            if not ret:
                break
            
            # Flip frame horizontally for mirror effect
            frame = cv2.flip(frame, 1)
            rgb_frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
            
            # Process frame
            results = self.hands.process(rgb_frame)
            
            if results.multi_hand_landmarks:
                for hand_landmarks in results.multi_hand_landmarks:
                    # Draw landmarks
                    self.mp_draw.draw_landmarks(
                        frame, hand_landmarks, self.mp_hands.HAND_CONNECTIONS
                    )
                    
                    # Detect gesture
                    gesture = self.detect_gesture(hand_landmarks.landmark)
                    if gesture:
                        cv2.putText(frame, f"Gesture: {gesture}", 
                                  (10, 30), cv2.FONT_HERSHEY_SIMPLEX, 1, (0, 255, 0), 2)
                        
                        # Execute gesture command
                        if gesture in self.gestures:
                            print(f"Executing: {self.gestures[gesture]}")
            
            cv2.imshow('Kalki OS Gesture Recognition', frame)
            
            if cv2.waitKey(1) & 0xFF == ord('q'):
                break
        
        cap.release()
        cv2.destroyAllWindows()
