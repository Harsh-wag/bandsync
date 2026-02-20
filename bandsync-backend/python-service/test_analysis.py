"""
Test script for audio analysis
Run this to verify your setup is working
"""

from utils.audio_analyzer import AudioAnalyzer
import sys

def test_analysis():
    print("🎵 BandSync Audio Analysis Test\n")
    
    if len(sys.argv) < 2:
        print("Usage: python test_analysis.py <audio_file_path>")
        print("Example: python test_analysis.py test_song.mp3")
        return
    
    audio_path = sys.argv[1]
    
    print(f"Analyzing: {audio_path}\n")
    
    try:
        analyzer = AudioAnalyzer()
        result = analyzer.analyze(audio_path)
        
        print("✅ Analysis Complete!\n")
        print(f"🎹 Key: {result['key']} {result['scale']}")
        print(f"⏱️  Tempo: {result['tempo']} BPM")
        print(f"⏰ Duration: {result['duration']}s")
        print(f"\n🎸 Chord Progression:")
        print(" → ".join(result['chord_progression']))
        
        print(f"\n📊 Chord Timeline ({len(result['chords_timeline'])} changes):")
        for chord_info in result['chords_timeline'][:5]:  # Show first 5
            print(f"  {chord_info['start']}s: {chord_info['chord']} ({chord_info['duration']}s)")
        
        if result.get('ai_insights'):
            print(f"\n🤖 AI Insights:")
            print(f"  {result['ai_insights']}")
        else:
            print(f"\n💡 Tip: Add OPENAI_API_KEY to .env for AI insights")
        
        if result.get('similar_songs'):
            print(f"\n🎵 Similar Songs:")
            for song in result['similar_songs']:
                print(f"  • {song}")
        
        print("\n✨ Test passed! Your setup is working correctly.")
        
    except Exception as e:
        print(f"❌ Error: {e}")
        print("\nTroubleshooting:")
        print("1. Check if the audio file exists")
        print("2. Ensure librosa is installed: pip install librosa")
        print("3. Try a different audio format (MP3, WAV)")

if __name__ == "__main__":
    test_analysis()
