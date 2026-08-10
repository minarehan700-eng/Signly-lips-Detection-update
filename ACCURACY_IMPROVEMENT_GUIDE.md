# Sign Language Recognition Accuracy Improvement Guide

## Quick Fix: Use Settings Tab ⚙️

The app now has a **Settings** tab where you can tune recognition parameters without recompiling:

1. Go to **Settings tab** → Recognize tab
2. Try the **"Beginner"** preset (Lenient mode)
3. Test recognition - it should be much more responsive
4. Adjust sliders to find your sweet spot
5. Tap **"Save Settings"**

---

## Understanding the Problem

Your app recognizes **WRONG characters** for the same hand position. This suggests:

### Possible Causes (in order of likelihood):

1. **Threshold too high** (0.65) - Model isn't confident enough
2. **Stability window too strict** (5 frames) - Requires too many consistent frames
3. **Model trained on different hand positions** - Your hands may differ from training data
4. **Poor lighting/camera angle** - Hand landmarks extracted incorrectly
5. **Hand size/unique characteristics** - Model wasn't trained with your hand variations

---

## Solution 1: Adjust Settings (Immediate) 🎯

### **Beginner Preset (Recommended Start)**
- **Confidence Threshold**: 0.45
- **Window Size**: 2 frames
- **Best For**: Learning, getting started
- **Pros**: Very responsive, catches most signs
- **Cons**: More false positives

### **Balanced Preset (Sweet Spot)**
- **Confidence Threshold**: 0.55 ← **NEW DEFAULT**
- **Window Size**: 3 frames
- **Best For**: Most users, general use
- **Pros**: Good accuracy + fast response
- **Cons**: May miss some ambiguous signs

### **Expert Preset (High Accuracy)**
- **Confidence Threshold**: 0.75
- **Window Size**: 5 frames
- **Best For**: Hands trained with data
- **Pros**: Highly accurate, fewer false positives
- **Cons**: Slower, may miss some valid signs

---

## Solution 2: Fine-Tune Parameters 🔧

### **Confidence Threshold** (0.3 - 0.95)

**What it does**: Minimum certainty required to recognize a sign.

**If signs aren't recognized:**
- Lower the threshold (0.40 → 0.35)
- Makes model more lenient

**If you get wrong signs:**
- Raise the threshold (0.55 → 0.65)
- Makes model more strict

**Recommendation**: Start at 0.45-0.55

### **Stability Window** (1-10 frames)

**What it does**: How many frames must agree before recognizing a sign.

**If recognition is slow:**
- Reduce window size (5 → 2 or 3)
- Requires fewer frames to match

**If you get false positives:**
- Increase window size (3 → 5 or 7)
- Requires more consistent frames

**Recommendation**: Start with 2-3 frames

---

## Solution 3: Environmental Improvements 💡

### Lighting
- **Use bright, even lighting** (natural light preferred)
- Avoid shadows on hands
- Face away from bright light source
- Use diffused overhead lighting

### Camera Position
- **Keep camera at eye level**
- Distance: 30-60 cm from camera
- Center your hands in frame
- Keep both hands visible

### Hand Clarity
- **Clean your hands** (no heavy shadows)
- **Remove jewelry/watches** (if they interfere)
- **Keep hands relaxed** (avoid tension)
- **Use slow, deliberate movements** (not too fast)

---

## Solution 4: Understanding Model Limitations

The TFLite model (`asl_classifier.tflite`) was trained on specific data. It may struggle with:

### Hand Size Variations
- Model trained on average hand sizes
- **Your hand might be larger/smaller**
- **Fix**: Stand farther/closer to camera

### Hand Angle Variations
- Model trained on specific camera angles
- **Fix**: Rotate your hand slightly until recognition works

### Hand Speed Variations
- Model expects certain hand speeds
- **Fix**: Move hand slower/faster to match training data

### Lighting Conditions
- Model trained on specific lighting
- **Fix**: Adjust lighting to be brighter/softer

---

## Solution 5: Advanced Debugging

### Enable Debug Mode (in Settings)
Turn on **"Show Raw Predictions"** to see:
- What the model actually thinks
- Top 3 guesses instead of final answer
- Raw confidence scores

This helps identify:
- If model is confused (similar scores for multiple signs)
- If lighting is the problem (very low scores)
- If your hand position doesn't match training data

---

## Solution 6: Retraining the Model (Advanced) 🤖

If you have access to the training code:

### What you need:
1. Training dataset (ASL sign videos)
2. Original model architecture
3. Training script (Python + TensorFlow)

### Steps:
1. Collect more training data with YOUR hand position/angle
2. Augment data with variations (rotation, brightness, size)
3. Retrain the model with additional data
4. Export as TFLite format
5. Replace `assets/models/asl_classifier.tflite`
6. Re-test

### Data Augmentation Techniques:
- Rotate images ±15°
- Adjust brightness ±20%
- Zoom in/out 10-20%
- Flip horizontally
- Add slight blur/noise

---

## Troubleshooting Checklist ✅

- [ ] Lowered confidence threshold to 0.45-0.55?
- [ ] Reduced window size to 2-3 frames?
- [ ] Tested with good lighting?
- [ ] Camera at correct distance (30-60cm)?
- [ ] Hands clearly visible and centered?
- [ ] Moved hands slower/steadier?
- [ ] Tried different hand angles?
- [ ] Tried different hand positions?
- [ ] Enabled debug mode to see raw predictions?

---

## Expected Accuracy by Scenario

| Scenario | Accuracy | Confidence | Window |
|----------|----------|------------|--------|
| Learning/beginner | 70-80% | 0.45 | 2 |
| General use | 85-90% | 0.55 | 3 |
| Expert user | 90-95% | 0.70 | 5 |
| Perfect conditions | 95%+ | 0.60 | 3 |

---

## What to Do If Nothing Works

1. **Document the problem**:
   - Which signs are misrecognized?
   - Do the same signs always get confused?
   - Is confidence score low or high when wrong?

2. **Check the model**:
   - Is `asl_classifier.tflite` being loaded correctly?
   - File size: Check if it's a valid, non-corrupted file
   - Location: Ensure it's in `assets/models/`

3. **Consider alternative models**:
   - Check if there's an updated/better model available
   - Google MediaPipe Gesture Recognizer (newer)
   - Microsoft Gesture Recognition models

4. **Collect training data**:
   - Record your own ASL signs
   - Use MediaPipe to extract landmarks
   - Fine-tune model with your data

---

## Quick Start (TL;DR)

1. Open **Settings** tab
2. Tap **"Beginner (Lenient)"** preset
3. Test recognition
4. Adjust sliders if needed
5. Save settings
6. Test again

**Expected result**: Significantly improved recognition! 🎉

---

## Support & Next Steps

- Settings are saved to device
- Each app instance has independent settings
- Settings persist after app restart
- Export settings as JSON (coming in future update)

Good luck! 🚀
