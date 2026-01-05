# LAUNCH NOW - Copy-Paste Guide

## STEP 1: Create GitHub Repo (2 min)

1. Go to: https://github.com/new
2. Repository name: `one-message-experiment`
3. Make it **Public**
4. Check "Add a README file"
5. Click **Create repository**
6. Click the pencil icon to edit README.md
7. Delete everything and paste this:

```
# The One-Message Experiment

We removed:
- likes
- replies
- profiles
- followers
- timelines
- edits
- deletion

And asked one question:

**What does a human say when they are allowed to speak once — and only once — knowing it can never be changed?**

There is no audience.
There is no feedback.
There is no visibility.
There is no reward.

Only the act of choosing words under irreversible constraint.

Some messages are anonymous.
Some are signed.
All are final.

We are not analysing the data.
We are not selling the data.
We are not optimising engagement.

The experiment is live.

Search: **LIMITED**
```

8. Click **Commit changes**

---

## STEP 2: Post on X/Twitter (1 min)

1. Go to: https://twitter.com/compose/tweet
2. Paste this EXACTLY:

```
I've been thinking about irreversible systems lately.

This experiment asks what happens when humans get exactly one chance to speak, with no audience and no undo.

github.com/YOURUSERNAME/one-message-experiment
```

3. Replace `YOURUSERNAME` with your GitHub username
4. Post it
5. **DO NOT reply to comments. DO NOT explain. Walk away.**

---

## STEP 3: Submit to Play Store (30 min)

### Build the APK (on a machine with Android SDK):
```bash
cd /Users/vinoteca/Desktop/Limited
flutter build apk --release
```

APK location: `build/app/outputs/flutter-apk/app-release.apk`

### Play Console:
1. Go to: https://play.google.com/console
2. Create app → Name: `LIMITED`
3. Upload the APK
4. Fill in listing:

**Short description (80 chars):**
```
One chance to write your truth. Seal it forever. No edits. No deletes.
```

**Full description:**
```
Some things can only be said once.

LIMITED gives you one chance—just one—to write something that matters. A confession. A goodbye. A truth you've carried too long.

Once you seal it, it's permanent. No edits. No deletes. No going back.

• One chance per category
• Permanent seal
• See truths from others on the Global Wall
• No accounts, no social pressure

This isn't an app you use every day. It's a ritual.

Some truths deserve to exist.
```

5. Set category: **Lifestyle**
6. Content rating: **12+**
7. Pricing: **Free**
8. Submit for review

---

## STEP 4: Submit to App Store (30 min)

### Build for iOS (requires Mac with Xcode):
```bash
cd /Users/vinoteca/Desktop/Limited
flutter build ios --release
```

Then open `ios/Runner.xcworkspace` in Xcode and Archive.

### App Store Connect:
1. Go to: https://appstoreconnect.apple.com
2. Create new app → Name: `LIMITED`
3. Upload build from Xcode
4. Use same description as Play Store
5. Submit for review

---

## STEP 5: Wait (do nothing)

- Don't check stats obsessively
- Don't reply to the X post
- Don't explain the app anywhere
- Let curiosity do the work

---

## OPTIONAL: Reddit Post (if X doesn't get traction in 48h)

Go to: https://reddit.com/r/InternetIsBeautiful/submit

Title:
```
I think I just used the most uncomfortable app I've ever seen
```

Body:
```
I'm not linking it because I don't want this to look like promotion.

It only lets you write one message.
You don't get to edit it.
You don't get to delete it.

After you submit it, the app locks it forever and shows you one sentence.

I'm not sure if that sentence was random or not, but it felt personal.

I can't stop thinking about it.

If someone else knows what I'm talking about, please tell me this isn't just me.
```

**DO NOT include a link. Wait for someone to ask.**

---

## That's it.

The app is built to spread itself now.
Your job is to plant the seed and walk away.
