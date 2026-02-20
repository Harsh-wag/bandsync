# 🚀 Deploy to Render.com (FREE - 5 Minutes)

## ✅ Why Render?
- ✅ **FREE tier** (no credit card needed)
- ✅ Handles all Python dependencies automatically
- ✅ Easy GitHub integration
- ✅ Auto-deploys on push

## 📋 Step-by-Step Guide

### Step 1: Push Code to GitHub (if not already)
```bash
cd C:\Users\Harsh\Desktop\Bandsync
git init
git add .
git commit -m "Add AI audio analysis"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/bandsync.git
git push -u origin main
```

### Step 2: Sign Up for Render
1. Go to https://render.com
2. Click **"Get Started"**
3. Sign up with **GitHub** (easiest)
4. Authorize Render to access your repos

### Step 3: Create New Web Service
1. Click **"New +"** → **"Web Service"**
2. Click **"Connect a repository"**
3. Find and select your **Bandsync** repo
4. Click **"Connect"**

### Step 4: Configure Service
Fill in these settings:

**Name**: `bandsync-audio-analysis` (or any name you like)

**Root Directory**: `bandsync-backend/python-service`

**Environment**: `Python 3`

**Build Command**: 
```bash
pip install -r requirements.txt
```

**Start Command**:
```bash
gunicorn app:app
```

**Instance Type**: `Free`

### Step 5: Add Environment Variables (Optional)
Click **"Advanced"** → **"Add Environment Variable"**

Add this if you want AI insights:
- **Key**: `OPENAI_API_KEY`
- **Value**: `sk-your-openai-key-here`

(Skip this if you don't have OpenAI key - chord/key detection will still work!)

### Step 6: Deploy!
1. Click **"Create Web Service"**
2. Wait 5-10 minutes for first deployment
3. Watch the logs - you'll see it installing librosa, numpy, etc.
4. When done, you'll see: **"Your service is live 🎉"**

### Step 7: Get Your URL
1. At the top of the page, you'll see your URL
2. It looks like: `https://bandsync-audio-analysis.onrender.com`
3. **Copy this URL!**

### Step 8: Test Your Service
Open browser and go to:
```
https://your-service-name.onrender.com/health
```

You should see:
```json
{"status":"healthy","service":"audio-analysis"}
```

### Step 9: Update Flutter App
Open `lib/services/audio_analysis_service.dart` and update:

```dart
static const String baseUrl = 'https://bandsync-audio-analysis.onrender.com';
```

Replace with YOUR actual Render URL!

### Step 10: Run Flutter & Test!
```bash
cd bandsync
flutter run
```

Then:
1. Go to Library → + → AI Audio Analysis
2. Upload a song
3. Wait for results! 🎉

---

## 🎯 Important Notes

### Free Tier Limitations
- ⚠️ **Cold starts**: Service sleeps after 15 min of inactivity
- ⚠️ **First request**: Takes 30-60 seconds to wake up
- ⚠️ **After that**: Normal speed (~10-30 sec per song)

### How to Handle Cold Starts
The first analysis after sleep will be slow. Options:
1. **Accept it** (it's free!)
2. **Keep alive**: Use a service like UptimeRobot to ping every 10 min
3. **Upgrade**: $7/month for always-on instance

---

## 🔄 Auto-Deploy on Git Push

Every time you push to GitHub, Render auto-deploys!

```bash
# Make changes to Python code
git add .
git commit -m "Update chord recognition"
git push

# Render automatically deploys! 🚀
```

---

## 🐛 Troubleshooting

### "Build failed"
- Check logs in Render dashboard
- Make sure `requirements.txt` is in `python-service` folder
- Verify `runtime.txt` has `python-3.11.0`

### "Service unavailable"
- Wait 2-3 minutes after first deploy
- Check if service is running in Render dashboard
- Look at logs for errors

### "Connection refused" in Flutter
- Make sure you copied the FULL URL with `https://`
- Check if Render service is running (green dot)
- Test the `/health` endpoint in browser first

### "Takes too long"
- First request after sleep: 30-60 seconds (normal)
- Subsequent requests: 10-30 seconds
- Consider upgrading to paid tier for faster cold starts

---

## 💰 Cost

**Free Tier**:
- ✅ 750 hours/month (enough for hobby projects)
- ✅ Automatic SSL
- ✅ Auto-deploys
- ⚠️ Sleeps after 15 min inactivity

**Paid Tier** ($7/month):
- ✅ Always on (no cold starts)
- ✅ More memory
- ✅ Faster processing

---

## 🎉 You're Done!

Your AI audio analysis is now live on Render!

**URL**: https://your-service.onrender.com  
**Cost**: FREE  
**Features**: Full chord + key detection  
**AI Insights**: Add OpenAI key to enable

---

## 📊 What's Next?

### Immediate
- [ ] Test with a song
- [ ] Share your app with friends
- [ ] Add more audio files

### Soon
- [ ] Add OpenAI key for AI insights
- [ ] Set up UptimeRobot to prevent cold starts
- [ ] Cache results in Supabase

### Later
- [ ] Upgrade to paid tier for faster performance
- [ ] Add custom domain
- [ ] Monitor usage in Render dashboard

---

## 🔗 Useful Links

- **Render Dashboard**: https://dashboard.render.com
- **Render Docs**: https://render.com/docs
- **Your Service Logs**: Dashboard → Your Service → Logs
- **UptimeRobot** (keep alive): https://uptimerobot.com

---

## 💡 Pro Tips

1. **Bookmark your Render URL** for easy access
2. **Check logs** if something goes wrong
3. **Test /health endpoint** before using in app
4. **Use UptimeRobot** to ping every 10 min (keeps it awake)
5. **Monitor usage** in Render dashboard

🎸 Happy deploying!
