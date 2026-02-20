# 🚀 Deploy to Railway (5 Minutes)

## ✅ Checklist

### 1. Sign Up for Railway
- [ ] Go to https://railway.app
- [ ] Sign up with GitHub
- [ ] Verify email

### 2. Deploy Python Service
- [ ] Click "New Project"
- [ ] Select "Deploy from GitHub repo"
- [ ] Choose your `Bandsync` repository
- [ ] Set root directory: `bandsync-backend/python-service`
- [ ] Railway will auto-detect Python and deploy

### 3. Add Environment Variables (Optional)
- [ ] Go to your project → Variables
- [ ] Add: `OPENAI_API_KEY` = `sk-your-key-here`
- [ ] Click "Add" (skip if you don't have OpenAI key)

### 4. Get Your URL
- [ ] Go to Settings → Networking
- [ ] Click "Generate Domain"
- [ ] Copy the URL (e.g., `https://bandsync-production.up.railway.app`)

### 5. Update Flutter App
- [ ] Open `lib/services/audio_analysis_service.dart`
- [ ] Replace:
```dart
static const String baseUrl = 'https://your-python-service-url.com';
```
With your Railway URL:
```dart
static const String baseUrl = 'https://bandsync-production.up.railway.app';
```

### 6. Test It!
- [ ] Run your Flutter app
- [ ] Go to Library → + → AI Audio Analysis
- [ ] Upload a song
- [ ] Wait for results

---

## 🎉 Done!

Your AI audio analysis is now live on Railway!

**Cost**: ~$5/month (Railway hobby plan)
**Free Alternative**: Use Render.com (slower but free)

---

## 🐛 If Something Goes Wrong

### Check Deployment Logs
1. Railway Dashboard → Your Project
2. Click "Deployments"
3. View logs for errors

### Common Issues

**"Build failed"**
- Check `requirements.txt` is in the right folder
- Ensure Python 3.11 is specified in `runtime.txt`

**"Service unavailable"**
- Wait 2-3 minutes for first deployment
- Check if service is running in Railway dashboard

**"Connection refused" in Flutter**
- Make sure you copied the full URL with `https://`
- Check if Railway service is running

---

## 💰 Cost Optimization

### Free Tier Options
1. **Render.com** - Free (slower cold starts)
2. **Fly.io** - Free tier available
3. **Google Cloud Run** - Free tier (2M requests/month)

### Reduce Railway Costs
- Use "Sleep on idle" (Settings → Sleep)
- Only wake when analyzing audio
- Cache results in Supabase Storage

---

## 🔄 Alternative: Use Supabase Storage + Edge Function

If you want to avoid external hosting:

1. **Upload audio to Supabase Storage**
2. **Trigger Edge Function** to call external API
3. **Use a serverless ML API** like:
   - Replicate.com
   - Hugging Face Inference API
   - AWS SageMaker

This is more complex but keeps everything in Supabase ecosystem.

---

## 📞 Need Help?

- Railway Docs: https://docs.railway.app
- Railway Discord: https://discord.gg/railway
- Check `DEPLOYMENT_GUIDE.md` for other platforms
