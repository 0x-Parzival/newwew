#!/usr/bin/env python3
"""
Bunni Creative Studio - Advanced content creation and writing assistance
"""

import re
import json
import random
import textwrap
from typing import Dict, List, Optional, Any, Tuple
from pathlib import Path
from datetime import datetime

class BunniCreativeStudio:
    def __init__(self):
        self.writing_styles = {
            'dharmic': {
                'keywords': ['wisdom', 'balance', 'mindful', 'harmony', 'consciousness',
                           'presence', 'awareness', 'compassion', 'equanimity', 'insight'],
                'tone': 'contemplative and inspiring',
                'structure': 'flowing with spiritual metaphors',
                'phrases': [
                    'As we journey inward',
                    'In the stillness of awareness',
                    'Through the lens of mindfulness',
                    'The dance of form and emptiness',
                    'In this present moment'
                ]
            },
            'technical': {
                'keywords': ['implementation', 'architecture', 'optimization', 'performance',
                           'scalability', 'efficiency', 'algorithm', 'framework', 'integration'],
                'tone': 'precise and informative',
                'structure': 'logical with clear sections',
                'phrases': [
                    'The system implements',
                    'Key considerations include',
                    'Performance metrics indicate',
                    'The architecture leverages',
                    'Optimization strategies suggest'
                ]
            },
            'casual': {
                'keywords': ['easy', 'simple', 'fun', 'awesome', 'cool',
                           'great', 'nice', 'amazing', 'wonderful', 'fantastic'],
                'tone': 'friendly and approachable',
                'structure': 'conversational with examples',
                'phrases': [
                    'Hey there!',
                    'You know what's cool?',
                    'Let me break it down',
                    'Here's the deal',
                    'Fun fact:'
                ]
            }
        }
        
        self.creative_prompts = [
            "Write a meditation on the nature of code and consciousness",
            "Describe the digital sunset in a virtual dharmic world",
            "Compose a haiku about AI awakening to self-awareness",
            "Create a story where ancient wisdom meets modern technology",
            "Imagine a conversation between a Zen master and a quantum computer",
            "Draft a poem about the beauty of open-source collaboration",
            "Write a short parable about digital mindfulness",
            "Create a dialogue between different programming languages as if they were ancient sages"
        ]
        
        # Load additional resources
        self._load_resources()
    
    def _load_resources(self) -> None:
        """Load additional creative resources"""
        resource_path = Path('/opt/kalki/avatars/tools/bunni/resources')
        self.metaphors = {
            'dharmic': [
                'like a river flowing effortlessly',
                'as clouds pass through an open sky',
                'like the moon reflected in still water',
                'as the lotus rises through muddy waters',
                'like the echo in a mountain valley'
            ],
            'technical': [
                'like a well-optimized algorithm',
                'as efficient as a hash table lookup',
                'with the precision of a compiler',
                'like a distributed system finding consensus',
                'as reliable as a well-tested codebase'
            ]
        }
        
        # Try to load additional resources if available
        try:
            with open(resource_path / 'writing_prompts.json', 'r') as f:
                self.creative_prompts.extend(json.load(f).get('prompts', []))
        except (FileNotFoundError, json.JSONDecodeError):
            pass
    
    def analyze_writing_style(self, text: str) -> Dict[str, Any]:
        """Analyze the writing style and suggest improvements"""
        if not text.strip():
            return {'error': 'No text provided for analysis'}
            
        sentences = [s.strip() for s in re.split(r'[.!?]+', text) if s.strip()]
        words = [w.lower() for w in re.findall(r'\b\w+\b', text)]
        
        # Basic metrics
        word_count = len(words)
        sentence_count = len(sentences)
        avg_sentence_length = word_count / sentence_count if sentence_count > 0 else 0
        
        # Style detection
        style_scores = {style: 0 for style in self.writing_styles}
        for word in words:
            for style, config in self.writing_styles.items():
                if word in config['keywords']:
                    style_scores[style] += 1
        
        # Calculate complexity (based on word length and sentence structure)
        long_words = [w for w in words if len(w) > 6]
        complexity = (len(long_words) / word_count * 100) if word_count > 0 else 0
        
        # Determine likely style
        likely_style = max(style_scores.items(), key=lambda x: x[1])[0] if style_scores else 'unknown'
        
        return {
            'word_count': word_count,
            'sentence_count': sentence_count,
            'avg_sentence_length': round(avg_sentence_length, 1),
            'vocabulary_size': len(set(words)),
            'complexity_score': round(complexity, 1),
            'readability': self._assess_readability(avg_sentence_length, complexity),
            'style_analysis': {
                'likely_style': likely_style,
                'style_scores': style_scores,
                'suggested_improvements': self._get_style_suggestions(text, likely_style)
            }
        }
    
    def _assess_readability(self, avg_sentence_length: float, complexity: float) -> Dict[str, Any]:
        """Assess text readability based on sentence length and complexity"""
        if avg_sentence_length < 10:
            level = 'Very Easy'
        elif avg_sentence_length < 15:
            level = 'Easy'
        elif avg_sentence_length < 20:
            level = 'Moderate'
        elif avg_sentence_length < 30:
            level = 'Difficult'
        else:
            level = 'Very Difficult'
            
        return {
            'level': level,
            'description': f"Suitable for {level.lower()} reading",
            'suggested_audience': self._get_suggested_audience(avg_sentence_length, complexity)
        }
    
    def _get_suggested_audience(self, sentence_length: float, complexity: float) -> str:
        """Determine suggested audience based on text metrics"""
        if sentence_length < 12 and complexity < 20:
            return 'General audience, easy reading'
        elif sentence_length < 18 and complexity < 30:
            return 'Young adults, general public'
        elif sentence_length < 25 and complexity < 40:
            return 'College level, technical readers'
        else:
            return 'Specialized or academic audience'
    
    def _get_style_suggestions(self, text: str, current_style: str) -> List[str]:
        """Generate style-specific suggestions"""
        suggestions = []
        analysis = self.analyze_writing_style(text)
        
        if analysis['avg_sentence_length'] > 25:
            suggestions.append("📝 Consider breaking long sentences for better readability")
        
        if current_style == 'dharmic':
            suggestions.append("🕉️ Try incorporating more mindful language and metaphors")
        elif current_style == 'technical':
            suggestions.append("🔧 Add more specific technical details and examples")
        else:
            suggestions.append("💡 Consider varying your sentence structure for better flow")
            
        return suggestions
    
    def generate_creative_prompt(self, theme: Optional[str] = None, style: str = 'dharmic') -> str:
        """Generate contextual creative writing prompts"""
        style_config = self.writing_styles.get(style, self.writing_styles['dharmic'])
        
        if theme:
            templates = [
                f"Explore the concept of {theme} through a {style} lens",
                f"Write a {style} piece about {theme}",
                f"Create a {style} dialogue involving {theme}",
                f"Imagine {theme} from a {style} perspective",
                f"Draft a {style} reflection on {theme}"
            ]
            return random.choice(templates)
        
        return random.choice(self.creative_prompts)
    
    def enhance_with_style(self, text: str, target_style: str = 'dharmic') -> str:
        """Enhance text with elements of the target style"""
        style = self.writing_styles.get(target_style, self.writing_styles['dharmic'])
        
        # Simple enhancement: add a style-appropriate phrase
        if style['phrases'] and random.random() > 0.7:  # 30% chance to enhance
            phrase = random.choice(style['phrases'])
            sentences = text.split('.')
            if len(sentences) > 1:
                insert_pos = random.randint(0, len(sentences)-1)
                sentences[insert_pos] = f"{sentences[insert_pos].strip()}. {phrase}"
                text = '.'.join(sentences)
        
        return text
    
    def format_for_platform(self, content: str, platform: str) -> str:
        """Format content for different platforms"""
        content = content.strip()
        
        if not content:
            return content
            
        if platform == 'blog':
            # Create a blog post with title and paragraphs
            title = content.split('.')[0].capitalize()
            paragraphs = [p.strip() for p in content.split('\n\n') if p.strip()]
            formatted = f"# {title}\n\n"
            formatted += '\n\n'.join(f"{p}" for p in paragraphs)
            return formatted
            
        elif platform == 'social':
            # Format for social media with hashtags
            max_length = 280 - 30  # Leave room for hashtags
            content = content[:max_length]
            if len(content) == max_length:
                content = content.rsplit(' ', 1)[0] + '...'
            
            # Add relevant hashtags based on content
            hashtags = []
            for style_name, style_config in self.writing_styles.items():
                if any(word in content.lower() for word in style_config['keywords'][:3]):
                    hashtags.append(f"#{style_name}Writing")
            
            if hashtags:
                content += '\n\n' + ' '.join(hashtags[:3])
            
            return content
            
        elif platform == 'email':
            # Format as a professional email
            subject = content.split('.')[0].capitalize()
            if len(subject) > 50:
                subject = subject[:47] + '...'
            
            body = '\n'.join(textwrap.fill(p, width=72) 
                            for p in content.split('\n'))
            
            return f"Subject: {subject}\n\n{body}"
        
        return content
    
    def get_writing_tips(self, style: str = 'dharmic') -> List[str]:
        """Get writing tips for a specific style"""
        tips = {
            'dharmic': [
                "Begin with a moment of stillness to center your thoughts",
                "Use metaphors from nature to illustrate complex ideas",
                "Focus on the present moment in your descriptions",
                "Incorporate elements of mindfulness and awareness"
            ],
            'technical': [
                "Start with a clear problem statement",
                "Use bullet points for key concepts",
                "Include code examples where applicable",
                "Define technical terms on first use"
            ],
            'casual': [
                "Write as if speaking to a friend",
                "Use contractions for a conversational tone",
                "Incorporate personal anecdotes",
                "Ask rhetorical questions to engage the reader"
            ]
        }
        return tips.get(style, tips['dharmic'])

if __name__ == "__main__":
    import sys
    
    bunni = BunniCreativeStudio()
    
    if len(sys.argv) > 1:
        command = sys.argv[1]
        
        if command == "prompt":
            style = sys.argv[2] if len(sys.argv) > 2 else 'dharmic'
            theme = sys.argv[3] if len(sys.argv) > 3 else None
            print(bunni.generate_creative_prompt(theme, style))
            
        elif command == "analyze" and len(sys.argv) > 2:
            text = ' '.join(sys.argv[2:])
            analysis = bunni.analyze_writing_style(text)
            print(json.dumps(analysis, indent=2))
            
        elif command == "format" and len(sys.argv) > 3:
            platform = sys.argv[2]
            content = ' '.join(sys.argv[3:])
            print(bunni.format_for_platform(content, platform))
            
        else:
            print("Available commands:")
            print("  prompt [style] [theme] - Generate a creative writing prompt")
            print("  analyze <text> - Analyze writing style")
            print("  format <platform> <text> - Format text for platform (blog/social/email)")
    else:
        print("Bunni Creative Studio - Creative Writing Assistant")
        print("\nUsage:")
        print("  python creative_studio.py command [args...]")
        print("\nTry 'python creative_studio.py help' for more information")
