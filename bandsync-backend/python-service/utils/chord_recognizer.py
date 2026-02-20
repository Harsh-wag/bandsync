import librosa
import numpy as np
from collections import Counter

class ChordRecognizer:
    def __init__(self):
        self.note_names = ['C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B']
        self.chord_templates = self._create_chord_templates()
    
    def _create_chord_templates(self):
        """Create templates for major, minor, 7th, and other common chords"""
        templates = {}
        
        for i, root in enumerate(self.note_names):
            # Major chord (root, major third, perfect fifth)
            major = np.zeros(12)
            major[[i, (i+4)%12, (i+7)%12]] = [1.0, 0.8, 0.9]
            templates[root] = major
            
            # Minor chord (root, minor third, perfect fifth)
            minor = np.zeros(12)
            minor[[i, (i+3)%12, (i+7)%12]] = [1.0, 0.8, 0.9]
            templates[f"{root}m"] = minor
            
            # Dominant 7th (root, major third, perfect fifth, minor seventh)
            dom7 = np.zeros(12)
            dom7[[i, (i+4)%12, (i+7)%12, (i+10)%12]] = [1.0, 0.7, 0.8, 0.6]
            templates[f"{root}7"] = dom7
            
            # Major 7th
            maj7 = np.zeros(12)
            maj7[[i, (i+4)%12, (i+7)%12, (i+11)%12]] = [1.0, 0.7, 0.8, 0.6]
            templates[f"{root}maj7"] = maj7
            
            # Minor 7th
            min7 = np.zeros(12)
            min7[[i, (i+3)%12, (i+7)%12, (i+10)%12]] = [1.0, 0.7, 0.8, 0.6]
            templates[f"{root}m7"] = min7
        
        return templates
    
    def recognize_chords(self, y, sr, hop_length=4096):
        """Advanced chord recognition using template matching"""
        # Get chromagram
        chroma = librosa.feature.chroma_cqt(y=y, sr=sr, hop_length=hop_length)
        
        # Detect chord for each frame
        chords_timeline = []
        times = librosa.frames_to_time(np.arange(chroma.shape[1]), sr=sr, hop_length=hop_length)
        
        for i in range(chroma.shape[1]):
            frame = chroma[:, i]
            # Normalize
            if np.sum(frame) > 0:
                frame = frame / np.sum(frame)
            
            # Find best matching chord
            best_chord = self._match_chord(frame)
            chords_timeline.append({
                'time': float(times[i]),
                'chord': best_chord
            })
        
        # Simplify by grouping consecutive same chords
        simplified = self._simplify_chord_sequence(chords_timeline)
        
        return simplified
    
    def _match_chord(self, chroma_frame):
        """Match chromagram frame to chord template"""
        best_match = 'N'  # No chord
        best_score = -1
        
        for chord_name, template in self.chord_templates.items():
            # Calculate correlation
            score = np.dot(chroma_frame, template)
            
            if score > best_score:
                best_score = score
                best_match = chord_name
        
        # Threshold for "no chord"
        if best_score < 0.3:
            return 'N'
        
        return best_match
    
    def _simplify_chord_sequence(self, chords_timeline, min_duration=0.5):
        """Group consecutive same chords and filter short ones"""
        if not chords_timeline:
            return []
        
        simplified = []
        current_chord = chords_timeline[0]['chord']
        start_time = chords_timeline[0]['time']
        
        for i in range(1, len(chords_timeline)):
            if chords_timeline[i]['chord'] != current_chord:
                duration = chords_timeline[i]['time'] - start_time
                
                if duration >= min_duration:
                    simplified.append({
                        'chord': current_chord,
                        'start': round(start_time, 2),
                        'duration': round(duration, 2)
                    })
                
                current_chord = chords_timeline[i]['chord']
                start_time = chords_timeline[i]['time']
        
        # Add last chord
        duration = chords_timeline[-1]['time'] - start_time
        if duration >= min_duration:
            simplified.append({
                'chord': current_chord,
                'start': round(start_time, 2),
                'duration': round(duration, 2)
            })
        
        return simplified
    
    def get_chord_progression(self, chords_timeline):
        """Extract unique chord progression"""
        if not chords_timeline:
            return []
        
        progression = []
        for chord_info in chords_timeline:
            chord = chord_info['chord']
            if chord != 'N' and (not progression or progression[-1] != chord):
                progression.append(chord)
        
        return progression
