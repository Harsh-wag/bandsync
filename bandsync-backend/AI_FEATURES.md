# AI Audio Analysis - Setup Guide

## Features

### 1. Chord Recognition
- **Template Matching Algorithm**: Recognizes major, minor, 7th, maj7, and m7 chords
- **Timeline Detection**: Shows when each chord appears in the song
- **Chord Progression**: Extracts the unique chord sequence

### 2. Key Detection
- **Krumhansl-Schmuckler Algorithm**: Detects musical key (C, D, E, etc.)
- **Scale Detection**: Identifies major or minor scale
- **Chromagram Analysis**: Uses librosa's CQT chromagram for accuracy

### 3. AI Insights (Optional)
- **Musical Analysis**: AI explains the mood and feel of the progression
- **Genre Suggestions**: Recommends suitable genres
- **Playing Tips**: Provides advice for musicians
- **Similar Songs**: Suggests popular songs with similar progressions

## Setup Instructions

### Backend Setup

1. **Install Python Dependencies**
   ```bash
   cd bandsync-backend/python-service
   pip install -r requirements.txt
   ```

2. **Configure OpenAI API (Optional)**
   - Copy `.env.example` to `.env`
   - Add your OpenAI API key:
     ```
     OPENAI_API_KEY=sk-your-key-here
     ```
   - Get key from: https://platform.openai.com/api-keys
   - **Note**: App works without this, but AI insights won't be available

3. **Run the Backend**
   ```bash
   python app.py
   ```
   Server runs on `http://localhost:5000`

### Flutter App Setup

1. **Install Dependencies**
   ```bash
   cd bandsync
   flutter pub get
   ```

2. **Update Backend URL** (if not using localhost)
   Edit `lib/services/audio_analysis_service.dart`:
   ```dart
   static const String baseUrl = 'http://your-server-ip:5000';
   ```

3. **Run the App**
   ```bash
   flutter run
   ```

## Usage

1. Open BandSync app
2. Go to Library tab
3. Tap the + button
4. Select "AI Audio Analysis"
5. Upload an audio file (MP3, WAV, FLAC, M4A, OGG)
6. Wait for analysis (10-30 seconds depending on file size)
7. View results:
   - Key and tempo
   - Chord progression
   - Chord timeline
   - AI insights (if API key configured)
   - Similar songs

## Technical Details

### Chord Recognition Algorithm
- Uses chromagram (pitch class profile) from librosa
- Template matching with pre-defined chord patterns
- Supports: Major, Minor, 7th, Maj7, Min7 chords
- Filters short chord changes (< 0.5s) for cleaner results

### Key Detection Algorithm
- Krumhansl-Schmuckler key-finding algorithm
- Compares chromagram to major/minor key profiles
- Uses correlation to find best match
- Highly accurate for Western music

### AI Integration
- Uses OpenAI GPT-3.5-turbo
- Analyzes chord progressions in musical context
- Provides human-readable insights
- Suggests similar songs based on harmonic content

## Troubleshooting

### Backend Issues
- **Error: librosa not found**
  ```bash
  pip install librosa
  ```

- **Error: No module named 'openai'**
  ```bash
  pip install openai
  ```

- **Port 5000 already in use**
  Change port in `app.py`:
  ```python
  app.run(host='0.0.0.0', port=5001, debug=True)
  ```

### Flutter Issues
- **Connection refused**
  - Ensure backend is running
  - Check firewall settings
  - Use correct IP address (not localhost on physical devices)

- **File picker not working**
  ```bash
  flutter pub get
  flutter clean
  flutter run
  ```

## Future Enhancements

- [ ] Real-time chord detection during playback
- [ ] Beat detection and rhythm analysis
- [ ] Melody extraction
- [ ] Automatic chord sheet generation
- [ ] Export analysis to PDF
- [ ] Integration with music notation software
- [ ] Support for more chord types (sus, dim, aug)
- [ ] Machine learning model training on custom dataset

## API Costs

- **OpenAI GPT-3.5-turbo**: ~$0.002 per analysis
- **Alternative**: Use AWS Bedrock with Claude for similar results
- **Free Option**: Disable AI insights (chord/key detection still works)

## Credits

- **librosa**: Audio analysis library
- **OpenAI**: AI insights
- **Flutter**: Mobile framework
- **Krumhansl & Schmuckler**: Key-finding algorithm
