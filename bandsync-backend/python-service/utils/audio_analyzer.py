import librosa
import numpy as np
from .chord_recognizer import ChordRecognizer
from .ai_analyzer import AIAnalyzer

class AudioAnalyzer:
    def __init__(self):
        self.note_names = ['C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B']
        self.major_profile = [6.35, 2.23, 3.48, 2.33, 4.38, 4.09, 2.52, 5.19, 2.39, 3.66, 2.29, 2.88]
        self.minor_profile = [6.33, 2.68, 3.52, 5.38, 2.60, 3.53, 2.54, 4.75, 3.98, 2.69, 3.34, 3.17]
        self.chord_recognizer = ChordRecognizer()
        self.ai_analyzer = AIAnalyzer()
    
    def analyze(self, audio_path):
        """Main analysis function with AI enhancement"""
        try:
            # Load audio
            y, sr = librosa.load(audio_path)
            
            # Detect tempo
            tempo = self.detect_tempo(y, sr)
            
            # Detect key
            key, scale = self.detect_key(y, sr)
            
            # Enhanced chord recognition
            chords_timeline = self.chord_recognizer.recognize_chords(y, sr)
            chord_progression = self.chord_recognizer.get_chord_progression(chords_timeline)
            
            # Get duration
            duration = librosa.get_duration(y=y, sr=sr)
            
            # AI analysis (optional, only if API key is set)
            ai_insights = self.ai_analyzer.analyze_chord_progression(
                key, scale, chord_progression, tempo
            )
            similar_songs = self.ai_analyzer.suggest_similar_songs(
                key, scale, chord_progression
            )
            
            return {
                'tempo': round(tempo, 1),
                'key': key,
                'scale': scale,
                'chords_timeline': chords_timeline,
                'chord_progression': chord_progression,
                'duration': round(duration, 2),
                'ai_insights': ai_insights,
                'similar_songs': similar_songs,
                'success': True
            }
        except Exception as e:
            raise Exception(f'Analysis failed: {str(e)}')
    
    def detect_tempo(self, y, sr):
        """Detect tempo using beat tracking"""
        tempo, _ = librosa.beat.beat_track(y=y, sr=sr)
        return float(tempo)
    
    def detect_key(self, y, sr):
        """Detect musical key using chromagram and Krumhansl-Schmuckler algorithm"""
        # Get chromagram
        chroma = librosa.feature.chroma_cqt(y=y, sr=sr)
        chroma_avg = np.mean(chroma, axis=1)
        
        # Normalize
        chroma_avg = chroma_avg / np.sum(chroma_avg)
        
        # Calculate correlation with major and minor profiles
        major_correlations = []
        minor_correlations = []
        
        for i in range(12):
            # Rotate profiles
            major_rotated = np.roll(self.major_profile, i)
            minor_rotated = np.roll(self.minor_profile, i)
            
            # Calculate correlation
            major_corr = np.corrcoef(chroma_avg, major_rotated)[0, 1]
            minor_corr = np.corrcoef(chroma_avg, minor_rotated)[0, 1]
            
            major_correlations.append(major_corr)
            minor_correlations.append(minor_corr)
        
        # Find best match
        max_major = max(major_correlations)
        max_minor = max(minor_correlations)
        
        if max_major > max_minor:
            key_index = major_correlations.index(max_major)
            scale = 'major'
        else:
            key_index = minor_correlations.index(max_minor)
            scale = 'minor'
        
        key = self.note_names[key_index]
        
        return key, scale
    

