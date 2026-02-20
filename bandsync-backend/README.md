# BandSync Backend

Backend services for BandSync - a band management and collaboration app.

## Architecture

- **Firebase Cloud Functions**: Auth triggers, notifications, data validation
- **Python Microservice**: Audio analysis using Librosa (key, tempo, chord detection)
- **Firestore**: Real-time database for songs, setlists, events, bands
- **Firebase Storage**: Audio files and images

## Setup

### Prerequisites
- Node.js 18+
- Python 3.8+
- Firebase CLI (`npm install -g firebase-tools`)

### Firebase Setup

1. **Initialize Firebase project**
```bash
cd bandsync-backend
firebase login
firebase init
```

2. **Install Cloud Functions dependencies**
```bash
cd functions
npm install
```

3. **Deploy Firestore rules and Cloud Functions**
```bash
firebase deploy --only firestore:rules
firebase deploy --only storage:rules
firebase deploy --only functions
```

### Python Service Setup

1. **Create virtual environment**
```bash
cd python-service
python -m venv venv
```

2. **Activate virtual environment**
- Windows: `venv\Scripts\activate`
- Mac/Linux: `source venv/bin/activate`

3. **Install dependencies**
```bash
pip install -r requirements.txt
```

4. **Run the service**
```bash
python app.py
```

The service will run on `http://localhost:5000`

## API Endpoints

### Python Service

#### POST /analyze
Analyze audio file for key, tempo, and chords.

**Request:**
- Method: POST
- Content-Type: multipart/form-data
- Body: `audio` file (mp3, wav, flac, m4a, ogg)

**Response:**
```json
{
  "tempo": 120.5,
  "key": "C",
  "scale": "major",
  "chords": ["C", "G", "Am", "F"],
  "duration": 180.5,
  "success": true
}
```

#### GET /health
Health check endpoint.

## Firebase Collections Structure

```
users/{userId}
  - uid, email, displayName, createdAt, settings
  - songs/{songId}
  - setlists/{setlistId}
  - events/{eventId}

bands/{bandId}
  - name, members[], createdAt
  - songs/{songId}
  - setlists/{setlistId}
  - events/{eventId}
```

## Development

### Run Firebase Emulators
```bash
firebase emulators:start
```

Access emulator UI at `http://localhost:4000`

### Test Cloud Functions locally
```bash
cd functions
npm run serve
```

### Test Python service
```bash
cd python-service
python app.py
```

## Deployment

### Deploy everything
```bash
firebase deploy
```

### Deploy specific services
```bash
firebase deploy --only functions
firebase deploy --only firestore:rules
firebase deploy --only storage:rules
```

## Environment Variables

### functions/.env
```
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_REGION=us-central1
```

### python-service/.env
```
FLASK_ENV=development
FLASK_DEBUG=True
PORT=5000
HOST=0.0.0.0
```

## Security

- Firestore rules enforce user authentication and ownership
- Storage rules validate file types and sizes
- Cloud Functions validate data before writes
- Audio files limited to 50MB
- Images limited to 5MB

## Notes

- Python service should be deployed separately (e.g., Cloud Run, Heroku, AWS Lambda)
- Update `AudioAnalysisService.baseUrl` in Flutter app to production URL
- Configure Firebase project ID in Flutter app
