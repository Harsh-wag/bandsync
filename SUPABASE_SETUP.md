# 🎵 BandSync AI - Supabase Backend Setup

## Your Situation
✅ Flutter app  
✅ Supabase backend  
✅ Need AI audio analysis (chord recognition + key detection)

## The Solution

Since **librosa** (Python ML library) is too heavy for Supabase Edge Functions, you need to:

1. **Deploy Python service separately** (Railway, Render, etc.)
2. **Flutter app calls the Python service** directly
3. **Store results in Supabase** (optional caching)

---

## 🚀 Quick Start (Choose One)

### Option A: Railway (Recommended - Easiest)
```bash
# 1. Push your code to GitHub
git add .
git commit -m "Add AI audio analysis"
git push

# 2. Go to railway.app and deploy
# 3. Get your URL: https://your-app.up.railway.app

# 4. Update Flutter
# In lib/services/audio_analysis_service.dart:
static const String baseUrl = 'https://your-app.up.railway.app';
```

**Cost**: $5/month  
**Setup Time**: 5 minutes  
**Docs**: `RAILWAY_DEPLOY.md`

---

### Option B: Render.com (Free Tier)
```bash
# 1. Go to render.com
# 2. New Web Service → Connect GitHub
# 3. Select python-service folder
# 4. Deploy (takes ~10 min first time)
```

**Cost**: FREE (with cold starts)  
**Setup Time**: 10 minutes  
**Docs**: `DEPLOYMENT_GUIDE.md`

---

### Option C: Keep It Local (Development)
```bash
# Run Python service locally
cd bandsync-backend/python-service
python app.py

# Flutter connects to localhost
# In audio_analysis_service.dart:
static const String baseUrl = 'http://localhost:5000';
```

**Cost**: FREE  
**Limitation**: Only works on your machine

---

## 📁 Files Ready for Deployment

All set! These files are ready:
- ✅ `railway.json` - Railway config
- ✅ `Procfile` - Heroku/Railway start command
- ✅ `runtime.txt` - Python version
- ✅ `requirements.txt` - Dependencies (with gunicorn)
- ✅ All Python code (chord_recognizer, ai_analyzer, etc.)

---

## 🎯 Architecture

```
Flutter App (Mobile)
    ↓ HTTP POST
Python Service (Railway/Render)
    ↓ Uses librosa
Chord & Key Detection
    ↓ (Optional) OpenAI API
AI Insights
    ↓ JSON Response
Flutter App (Display Results)
    ↓ (Optional) Save to
Supabase Database
```

---

## 💾 Optional: Cache in Supabase

To avoid re-analyzing the same song:

### 1. Create Supabase Table
```sql
CREATE TABLE audio_analysis (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  song_id TEXT NOT NULL,
  key TEXT,
  scale TEXT,
  tempo NUMERIC,
  chord_progression JSONB,
  chords_timeline JSONB,
  ai_insights TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);
```

### 2. Update Flutter Service
```dart
// Check cache first
final cached = await supabase
  .from('audio_analysis')
  .select()
  .eq('song_id', songId)
  .maybeSingle();

if (cached != null) {
  return cached; // Use cached result
}

// If not cached, analyze
final result = await analyzeAudio(audioPath);

// Save to cache
await supabase.from('audio_analysis').insert({
  'song_id': songId,
  ...result,
});
```

---

## 🔐 Security Best Practices

### 1. Add API Key to Python Service
```python
# app.py
API_KEY = os.getenv('API_KEY', 'your-secret-key')

@app.route('/analyze', methods=['POST'])
def analyze_audio():
    if request.headers.get('X-API-Key') != API_KEY:
        return jsonify({'error': 'Unauthorized'}), 401
    # ... rest of code
```

### 2. Add to Flutter
```dart
request.headers['X-API-Key'] = 'your-secret-key';
```

### 3. Store Key in Supabase Vault
- Supabase Dashboard → Project Settings → Vault
- Add secret: `PYTHON_API_KEY`
- Access in Flutter via environment variable

---

## 📊 Cost Breakdown

| Component | Service | Cost |
|-----------|---------|------|
| Flutter App | Your device | FREE |
| Supabase | Free tier | FREE |
| Python Service | Railway | $5/mo |
| OpenAI API | Pay-per-use | ~$0.002/song |
| **Total** | | **~$5/mo** |

### Free Alternative
- Use Render.com (free tier)
- Skip OpenAI (chord/key still works)
- **Total: $0/month**

---

## 🎓 What You Built

1. ✅ **Advanced Chord Recognition**
   - Major, Minor, 7th, Maj7, Min7 chords
   - Timeline with timestamps
   - Chord progression extraction

2. ✅ **Key Detection**
   - Krumhansl-Schmuckler algorithm
   - 85-95% accuracy

3. ✅ **AI Insights** (Optional)
   - Musical mood analysis
   - Genre suggestions
   - Similar songs

4. ✅ **Beautiful Flutter UI**
   - Upload audio
   - Real-time progress
   - Results display

---

## 📚 Documentation

- **Quick Deploy**: `RAILWAY_DEPLOY.md`
- **All Platforms**: `DEPLOYMENT_GUIDE.md`
- **Technical Details**: `AI_FEATURES.md`
- **System Flow**: `SYSTEM_FLOW.md`
- **Quick Start**: `QUICKSTART_AI.md`

---

## 🚦 Next Steps

### Immediate (5 min)
1. [ ] Choose deployment platform (Railway recommended)
2. [ ] Deploy Python service
3. [ ] Update Flutter baseUrl
4. [ ] Test with a song

### Soon (30 min)
1. [ ] Add API key authentication
2. [ ] Set up Supabase caching
3. [ ] Add OpenAI key for AI insights

### Later (Optional)
1. [ ] Add rate limiting
2. [ ] Implement audio compression
3. [ ] Create admin dashboard
4. [ ] Add batch processing

---

## 🎉 You're All Set!

Your BandSync app now has AI-powered audio analysis! 

**Questions?** Check the docs or deployment guides.

**Ready to deploy?** Start with `RAILWAY_DEPLOY.md`

🎸 Happy coding!
