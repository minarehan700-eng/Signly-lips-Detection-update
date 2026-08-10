# Recognition Settings Reference Card

## Quick Parameter Guide

```
CONFIDENCE THRESHOLD (0.30 - 0.95)
├─ 0.30-0.40: Very Lenient    (catches everything, many false positives)
├─ 0.40-0.50: Lenient         ⭐ BEGINNER MODE
├─ 0.50-0.60: Balanced        ⭐ RECOMMENDED
├─ 0.60-0.75: Strict          (fewer false positives)
└─ 0.75-0.95: Very Strict     (only high-confidence signs)

WINDOW SIZE (1-10 frames)
├─ 1-2 frames:  Instant       ⭐ FASTEST RESPONSE
├─ 3-4 frames:  Balanced      ⭐ RECOMMENDED
├─ 5-7 frames:  Stable        (smoother, slower)
└─ 8-10 frames: Very Stable   (most reliable, slowest)

TIME EQUIVALENT (at ~11 FPS)
├─ 2 frames:  ~180ms
├─ 3 frames:  ~270ms
├─ 5 frames:  ~450ms
└─ 10 frames: ~900ms
```

---

## Problem → Solution Matrix

### Problem: "App doesn't recognize my signs at all"
**Likely Cause**: Confidence threshold too high OR bad hand detection
| Setting | Try This |
|---------|----------|
| Confidence | Lower to 0.40 |
| Window | Lower to 2 |
| Action | Check lighting, ensure hands clearly visible |

### Problem: "Wrong signs recognized (A detected as B)"
**Likely Cause**: Model confusion on similar signs
| Setting | Try This |
|---------|----------|
| Confidence | Raise to 0.65-0.75 |
| Window | Raise to 4-5 |
| Action | Move hands more deliberately, slower |

### Problem: "Recognition is too slow / delayed"
**Likely Cause**: Window size too large
| Setting | Try This |
|---------|----------|
| Confidence | Keep current |
| Window | Lower to 2 |
| Action | Result should appear 3x faster |

### Problem: "Too many false positives / random detections"
**Likely Cause**: Threshold too low, window too small
| Setting | Try This |
|---------|----------|
| Confidence | Raise to 0.60-0.70 |
| Window | Raise to 4-5 |
| Action | Requires more consistent hand position |

### Problem: "Some specific signs never work"
**Likely Cause**: Model not trained on your hand position
| Setting | Try This |
|---------|----------|
| Confidence | Lower by 0.10 |
| Window | Lower by 1 |
| Action | Try different hand angle/position |

---

## Recommended Presets

### 🌱 Beginner / Learning Mode
```
Confidence: 0.45
Window: 2
Use When: Learning, first-time users, want quick feedback
Pros: Very responsive, catches most signs
Cons: More false positives
```

### ⚖️ Balanced / Default Mode
```
Confidence: 0.55
Window: 3
Use When: General use, texting, day-to-day
Pros: Good accuracy, responsive
Cons: May miss some edge cases
```

### 🎯 Expert / High Accuracy Mode
```
Confidence: 0.75
Window: 5
Use When: Professional use, important documents
Pros: High accuracy, few false positives
Cons: Slower, requires precise hand position
```

### ⚡ Speed / Real-time Mode
```
Confidence: 0.50
Window: 1
Use When: Fast response needed, live conversation
Pros: Instant feedback
Cons: May have errors, requires user attention
```

### 🔒 Strict / Verification Mode
```
Confidence: 0.80
Window: 7
Use When: Critical applications (medical, legal)
Pros: Extremely accurate
Cons: Slow, may need multiple attempts
```

---

## Tuning Workflow

### Step 1: Start with Preset
Pick one that matches your use case (see above)

### Step 2: Test & Observe
- Try 10 signs you use frequently
- Note which ones fail or misrecognize
- Check if issue is speed or accuracy

### Step 3: Adjust One Parameter
- Only change ONE setting at a time
- Make small adjustments (0.05 intervals)
- Test again

### Step 4: If Still Wrong
- Try opposite direction
- OR switch to different preset
- Re-test

### Step 5: Save
- Once happy, tap "Save Settings"
- Settings persist across app restarts

---

## Sign-Specific Tuning

Some signs are harder to recognize. If specific signs fail:

### Signs Often Confused (similar hand shapes):
- **A vs S** (both closed fists)
- **G vs H** (similar finger positions)
- **C vs O** (both circular)
- **6 vs 9** (similar finger arrangements)

**Solution**: 
- Move hand more slowly
- Use more exaggerated motion
- Ensure clear camera angle
- Increase confidence threshold slightly

### Signs Requiring Precision:
- **F** (thumb-index circle)
- **M, N, T** (fingers over thumb)
- **D, P, Q** (pointing variations)

**Solution**:
- Reduce confidence threshold
- Reduce window size
- Practice exact finger positions
- Move slower

---

## Advanced: Reading Debug Output

Enable "Show Raw Predictions" in Settings to see:

```
Prediction:  [A: 0.78]  [B: 0.15]  [C: 0.07]
                ↓          ↓          ↓
            BEST      MAYBE       UNLIKELY

If top 3 are very close (0.35, 0.33, 0.32):
→ Model is confused, need clearer hand position

If top score is low (0.32):
→ Maybe bad lighting or hand out of frame

If one dominates (0.92, 0.05, 0.03):
→ Model is confident, good conditions
```

---

## Default Values Explained

**Old Defaults** (too strict):
- Confidence: 0.65
- Window: 5 frames

**New Defaults** (more user-friendly):
- Confidence: 0.55
- Window: 3 frames

**Why Changed**:
- Users reported low accuracy
- Original thresholds designed for perfect conditions
- New defaults work better in real-world use

---

## Emergency Settings

If app is completely broken:

**Reset to Factory Defaults**:
```
Settings → Load "Beginner" preset → Save
Clear app cache (Settings → Apps → [App] → Clear Cache)
Restart app
```

**If Still Broken**:
```
Uninstall and reinstall app
App will use new defaults
```

---

## Saving Your Perfect Settings

Once you find settings that work for you:

1. Take a screenshot of the Settings screen
2. Note the values:
   - Confidence: ___
   - Window: ___
3. Keep this as reference
4. Easy to restore if needed

---

## Testing Your Settings

Use the **Practice Mode** to validate settings:

1. Go to Practice tab
2. Pick one difficult sign (like A)
3. Try it 10 times
4. Count successful attempts
5. If <7/10: adjust settings lower
6. If >9/10: try stricter settings

---

## Performance Expectations

| Condition | Expected | Latency |
|-----------|----------|---------|
| Good light + close | 95%+ | <300ms |
| Normal office light | 85-90% | <400ms |
| Dim light | 70-80% | <500ms |
| Moving fast | 70-75% | <300ms |

If below expected: adjust settings down

---

## When to Give Up on Settings

If you've tried:
- ✓ All 5 presets
- ✓ Adjusted threshold ±0.20
- ✓ Adjusted window ±5 frames
- ✓ Improved lighting
- ✓ Changed hand angle

And still getting <50% accuracy → **Model may need retraining** (see ACCURACY_IMPROVEMENT_GUIDE.md)

---

## Quick Reference Card (Print This!)

```
TOO STRICT (signs not recognized)?
→ Confidence ↓ (lower)
→ Window ↓ (smaller)

TOO LOOSE (wrong signs)?
→ Confidence ↑ (higher)
→ Window ↑ (larger)

TOO SLOW?
→ Window ↓ (smaller)

TOO MANY ERRORS?
→ Confidence ↑ (higher)
→ Window ↑ (larger)
```

---

**Happy signing!** 🤟
