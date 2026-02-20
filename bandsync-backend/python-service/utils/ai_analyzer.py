import os
from openai import OpenAI
from dotenv import load_dotenv

load_dotenv()

class AIAnalyzer:
    def __init__(self):
        api_key = os.getenv('OPENAI_API_KEY')
        self.client = OpenAI(api_key=api_key) if api_key else None
    
    def analyze_chord_progression(self, key, scale, chords, tempo):
        """Use AI to analyze chord progression and provide insights"""
        if not self.client:
            return None
        
        try:
            prompt = f"""Analyze this song's musical characteristics:
- Key: {key} {scale}
- Tempo: {tempo} BPM
- Chord Progression: {' - '.join(chords)}

Provide a brief analysis (2-3 sentences) covering:
1. The mood/feel of this progression
2. Genre suggestions
3. One tip for playing this progression"""

            response = self.client.chat.completions.create(
                model="gpt-3.5-turbo",
                messages=[
                    {"role": "system", "content": "You are a music theory expert helping musicians understand their songs."},
                    {"role": "user", "content": prompt}
                ],
                max_tokens=150,
                temperature=0.7
            )
            
            return response.choices[0].message.content.strip()
        
        except Exception as e:
            print(f"AI analysis error: {e}")
            return None
    
    def suggest_similar_songs(self, key, scale, chords):
        """Suggest songs with similar chord progressions"""
        if not self.client:
            return []
        
        try:
            prompt = f"""List 3 popular songs that use similar chord progressions to:
Key: {key} {scale}
Chords: {' - '.join(chords[:4])}

Format: "Song Title" by Artist"""

            response = self.client.chat.completions.create(
                model="gpt-3.5-turbo",
                messages=[
                    {"role": "system", "content": "You are a music expert with knowledge of popular songs and their chord progressions."},
                    {"role": "user", "content": prompt}
                ],
                max_tokens=100,
                temperature=0.8
            )
            
            suggestions = response.choices[0].message.content.strip().split('\n')
            return [s.strip() for s in suggestions if s.strip()]
        
        except Exception as e:
            print(f"Song suggestion error: {e}")
            return []
