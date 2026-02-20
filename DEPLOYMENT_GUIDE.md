# Deploy Python Backend - Quick Guide

Since your backend is on Supabase, you need to deploy the Python service separately (librosa is too heavy for Edge Functions).

## 🚀 Recommended: Railway (Easiest)

### Step 1: Prepare for Deployment
```bash
cd bandsync-backend/python-service
```

### Step 2: Create `railway.json`
```json
{
  "build": {
    "builder": "NIXPACKS"
  },
  "deploy": {
    "startCommand": "gunicorn app:app",
    "restartPolicyType": "ON_FAILURE",
    "restartPolicyMaxRetries": 10
  }
}
```

### Step 3: Add to requirements.txt
```bash
echo "gunicorn==21.2.0" >> requirements.txt
```

### Step 4: Deploy to Railway
1. Go to https://railway.app
2. Sign up with GitHub
3. Click "New Project" → "Deploy from GitHub repo"
4. Select your repo
5. Add environment variables:
   - `OPENAI_API_KEY` (optional)
6. Deploy! You'll get a URL like: `https://your-app.up.railway.app`

### Step 5: Update Flutter
In `audio_analysis_service.dart`:
```dart
static const String baseUrl = 'https://your-app.up.railway.app';
```

---

## Alternative 1: Render.com (Free Tier)

### Create `render.yaml`
```yaml
services:
  - type: web
    name: bandsync-audio-analysis
    env: python
    buildCommand: pip install -r requirements.txt
    startCommand: gunicorn app:app
    envVars:
      - key: PYTHON_VERSION
        value: 3.11.0
      - key: OPENAI_API_KEY
        sync: false
```

### Deploy
1. Go to https://render.com
2. New → Web Service
3. Connect GitHub repo
4. Select `python-service` directory
5. Deploy

---

## Alternative 2: Google Cloud Run

### Create `Dockerfile`
```dockerfile
FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

CMD exec gunicorn --bind :$PORT --workers 1 --threads 8 --timeout 0 app:app
```

### Deploy
```bash
gcloud run deploy bandsync-audio \
  --source . \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated
```

---

## Alternative 3: AWS Lambda (Advanced)

Use AWS Lambda with a custom runtime for Python + librosa.

### Create `lambda_function.py`
```python
import json
from utils.audio_analyzer import AudioAnalyzer
import base64
import tempfile
import os

def lambda_handler(event, context):
    try:
        # Decode base64 audio
        audio_data = base64.b64decode(event['body'])
        
        # Save to temp file
        with tempfile.NamedTemporaryFile(delete=False, suffix='.mp3') as tmp:
            tmp.write(audio_data)
            tmp_path = tmp.name
        
        # Analyze
        analyzer = AudioAnalyzer()
        result = analyzer.analyze(tmp_path)
        
        # Cleanup
        os.remove(tmp_path)
        
        return {
            'statusCode': 200,
            'body': json.dumps(result)
        }
    except Exception as e:
        return {
            'statusCode': 500,
            'body': json.dumps({'error': str(e)})
        }
```

---

## 🎯 Quick Comparison

| Platform | Cost | Setup Time | Best For |
|----------|------|------------|----------|
| **Railway** | $5/mo | 5 min | Quick start |
| **Render** | Free tier | 10 min | Budget |
| **Cloud Run** | Pay-per-use | 15 min | Scale |
| **Lambda** | Pay-per-use | 30 min | AWS users |

---

## 📝 After Deployment

1. **Get your URL** from the platform
2. **Update Flutter**:
   ```dart
   // lib/services/audio_analysis_service.dart
   static const String baseUrl = 'https://your-deployed-url.com';
   ```
3. **Test it**:
   ```bash
   curl -X POST https://your-url.com/health
   ```

---

## 🔒 Security (Important!)

### Add API Key Authentication

Update `app.py`:
```python
from functools import wraps
from flask import request

API_KEY = os.getenv('API_KEY', 'your-secret-key')

def require_api_key(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        key = request.headers.get('X-API-Key')
        if key != API_KEY:
            return jsonify({'error': 'Invalid API key'}), 401
        return f(*args, **kwargs)
    return decorated

@app.route('/analyze', methods=['POST'])
@require_api_key  # Add this
def analyze_audio():
    # ... existing code
```

Update Flutter:
```dart
var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/analyze'));
request.headers['X-API-Key'] = 'your-secret-key';  // Add this
request.files.add(await http.MultipartFile.fromPath('audio', audioFilePath));
```

---

## 🐛 Troubleshooting

### "Module not found: librosa"
```bash
pip install --upgrade librosa
```

### "Memory limit exceeded"
Increase memory in platform settings:
- Railway: Settings → Memory → 2GB
- Render: Settings → Instance Type → Standard
- Cloud Run: --memory 2Gi

### "Timeout"
Increase timeout:
- Railway: Auto-handled
- Render: Settings → Health Check → 300s
- Cloud Run: --timeout 300

---

## 💡 Pro Tips

1. **Use Railway for development** (easiest)
2. **Use Cloud Run for production** (scales better)
3. **Cache results** in Supabase to avoid re-analyzing
4. **Compress audio** before upload to reduce processing time
5. **Add rate limiting** to prevent abuse

---

## Next Steps

1. Choose a platform (Railway recommended)
2. Deploy the Python service
3. Update the Flutter baseUrl
4. Test with a song
5. Add to Supabase Storage for caching

Need help? Check the platform-specific docs or ask!
