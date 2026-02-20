# 🎵 Quick Reference - Local AI Audio Analysis

## ⚡ Start Commands

### Terminal 1: Python Backend
```bash
cd bandsync-backend/python-service
pip install -r requirements.txt  # First time only
python app.py
```
✅ Running on http://localhost:5000

### Terminal 2: Flutter App
```bash
cd bandsync
flutter run
```
✅ App running on device/emulator

---

## 🎯 How to Use

1. **Open BandSync app**
2. **Go to Library tab** (bottom navigation)
3. **Tap + button** (floating action button)
4. **Select "AI Audio Analysis"**
5. **Upload audio file** (MP3, WAV, FLAC, M4A, OGG)
6. **Wait 10-30 seconds**
7. **View results!**

---

## 📊 What You'll See

### Song Information
- 🎹 Key (e.g., C major)
- ⏱️ Tempo (e.g., 120 BPM)
- ⏰ Duration (e.g., 180s)

### Chord Progression
- Chips showing: C → Am → F → G

### Chord Timeline
- List of chords with timestamps
- Shows when each chord appears
- Duration of each chord

### AI Insights (Optional - needs OpenAI key)
- Musical mood analysis
- Genre suggestions
- Playing tips

### Similar Songs (Optional - needs OpenAI key)
- Songs with similar progressions

---

## 🔧 Configuration

### Current Setup
- **Backend**: http://localhost:5000 ✅
- **OpenAI**: Not configured (optional)
- **Cost**: $0 (completely free)

### Add OpenAI (Optional)
```bash
cd bandsync-backend/python-service
echo "OPENAI_API_KEY=sk-your-key-here" >> .env
```
Restart backend to enable AI insights.

---

## 🐛 Quick Fixes

### Backend won't start?
```bash
pip install --upgrade librosa numpy scipy flask flask-cors
```

### Flutter can't connect?
- Check backend is running (Terminal 1)
- Look for "Running on http://127.0.0.1:5000"
- Restart both services

### Port 5000 in use?
```bash
# Windows
netstat -ano | findstr :5000
taskkill /PID <PID> /F
```

---

## 📁 File Structure

```
bandsync-backend/python-service/
├── app.py                    # Flask server
├── requirements.txt          # Dependencies
├── .env                      # Config (optional)
├── utils/
│   ├── audio_analyzer.py     # Main analyzer
│   ├── chord_recognizer.py   # Chord detection
│   └── ai_analyzer.py        # AI insights
└── temp_uploads/             # Temp files (auto-created)

bandsync/lib/
├── services/
│   └── audio_analysis_service.dart  # API client
└── screens/library/
    └── audio_analysis_screen.dart   # UI
```

---

## 🎨 Supported Formats

✅ MP3  
✅ WAV  
✅ FLAC  
✅ M4A  
✅ OGG

---

## ⏱️ Processing Time

- 30 sec song: ~5-10 seconds
- 3 min song: ~15-30 seconds
- 5 min song: ~30-60 seconds

---

## 🎓 What It Detects

### Chords
- Major (C, D, E, F, G, A, B)
- Minor (Cm, Dm, Em, etc.)
- 7th (C7, D7, etc.)
- Major 7th (Cmaj7, Dmaj7, etc.)
- Minor 7th (Cm7, Dm7, etc.)

### Keys
- All 12 notes (C, C#, D, D#, E, F, F#, G, G#, A, A#, B)
- Major and Minor scales

---

## 📚 Full Documentation

- **This Guide**: `LOCAL_SETUP.md`
- **Technical Details**: `AI_FEATURES.md`
- **System Flow**: `SYSTEM_FLOW.md`
- **Deploy Later**: `RAILWAY_DEPLOY.md`

---

## ✅ Checklist

- [ ] Python backend running (Terminal 1)
- [ ] Flutter app running (Terminal 2)
- [ ] Both on same machine
- [ ] Audio file ready to test
- [ ] Go to Library → + → AI Audio Analysis

---

## 🎉 You're Ready!

Everything is set up for local development.

**No deployment needed** - works on your machine!  
**No costs** - completely free!  
**Full features** - chord + key detection!

🎸 Start analyzing!
