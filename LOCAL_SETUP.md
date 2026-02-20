# 🎵 Local Setup - AI Audio Analysis

## Quick Start (5 minutes)

### Step 1: Install Python Dependencies
```bash
cd bandsync-backend/python-service
pip install -r requirements.txt
```

### Step 2: Start Python Backend
```bash
python app.py
```

You should see:
```
 * Running on http://0.0.0.0:5000
 * Running on http://127.0.0.1:5000
```

### Step 3: Run Flutter App
Open a new terminal:
```bash
cd bandsync
flutter run
```

### Step 4: Test It!
1. Open app → Library tab
2. Tap + button → "AI Audio Analysis"
3. Upload an audio file
4. See the magic! ✨

---

## 🎯 What Works Locally

✅ Chord Recognition (Major, Minor, 7th, Maj7, Min7)  
✅ Key Detection (C, D, E, etc. + major/minor)  
✅ Tempo Detection (BPM)  
✅ Chord Timeline  
✅ Chord Progression  
⚠️ AI Insights (needs OpenAI API key - optional)  
⚠️ Similar Songs (needs OpenAI API key - optional)

---

## 🔑 Optional: Add OpenAI for AI Insights

### 1. Get API Key
- Go to https://platform.openai.com/api-keys
- Create new key
- Copy it

### 2. Add to .env
```bash
cd bandsync-backend/python-service
echo "OPENAI_API_KEY=sk-your-key-here" >> .env
```

### 3. Restart Backend
```bash
python app.py
```

Now you'll get AI insights and similar song suggestions!

---

## 🐛 Troubleshooting

### "Module not found: librosa"
```bash
pip install librosa
```

### "Port 5000 already in use"
Kill the process:
```bash
# Windows
netstat -ano | findstr :5000
taskkill /PID <PID> /F

# Mac/Linux
lsof -ti:5000 | xargs kill -9
```

### "Connection refused" in Flutter
- Make sure Python backend is running
- Check terminal shows "Running on http://127.0.0.1:5000"
- Try restarting both services

### "No audio file provided"
- Make sure file picker has permission
- Try a different audio format (MP3, WAV)

---

## 📱 Testing on Physical Device

If testing on a physical phone (not emulator):

### 1. Find Your Computer's IP
```bash
# Windows
ipconfig
# Look for IPv4 Address (e.g., 192.168.1.100)

# Mac/Linux
ifconfig
# Look for inet (e.g., 192.168.1.100)
```

### 2. Update Flutter Service
```dart
// lib/services/audio_analysis_service.dart
static const String baseUrl = 'http://192.168.1.100:5000'; // Your IP
```

### 3. Make Sure Same WiFi
- Phone and computer must be on same network
- Disable firewall if needed

---

## 🎨 Test Files

Want to test quickly? Use these sample audio files:
- Any MP3 from your music library
- YouTube to MP3 converter
- Free music from: https://freemusicarchive.org

---

## ⚡ Quick Commands

### Start Everything
```bash
# Terminal 1: Python Backend
cd bandsync-backend/python-service && python app.py

# Terminal 2: Flutter App
cd bandsync && flutter run
```

### Test Backend Directly
```bash
curl http://localhost:5000/health
# Should return: {"status":"healthy","service":"audio-analysis"}
```

### Test with Sample File
```bash
cd bandsync-backend/python-service
python test_analysis.py path/to/your/song.mp3
```

---

## 💡 Pro Tips

1. **Keep backend running** while developing Flutter
2. **Use hot reload** in Flutter (press 'r' in terminal)
3. **Check backend logs** for errors
4. **Test with short audio files** first (30 seconds)
5. **Use MP3 format** for best compatibility

---

## 🚀 When Ready to Deploy

When you want to share your app or deploy:
1. Read `RAILWAY_DEPLOY.md` for quick deployment
2. Or check `DEPLOYMENT_GUIDE.md` for all options
3. Update `baseUrl` in Flutter to deployed URL

---

## 📊 Performance

Local processing times:
- 30 sec song: ~5-10 seconds
- 3 min song: ~15-30 seconds
- 5 min song: ~30-60 seconds

Factors:
- Computer speed
- Audio quality
- File format

---

## ✅ You're All Set!

Your local AI audio analysis is ready to use!

**Backend**: http://localhost:5000  
**Flutter**: Running on your device/emulator  
**Cost**: $0 (completely free!)

🎸 Happy analyzing!
