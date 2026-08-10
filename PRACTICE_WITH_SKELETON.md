# Practice Mode with Hand Skeleton - Learning Guide

## Overview

**Practice Mode** now shows your hand skeleton in real-time, making it easier to learn correct sign positions. See exactly how your hand compares to what the model expects!

---

## Features

### 🎯 Real-Time Skeleton Overlay
- See all 21 hand landmarks while practicing
- Watch your hand structure in real-time
- Understand what the model is detecting

### 👁️ Toggle Button
- Eye icon in top-right corner
- Tap to show/hide skeleton
- Useful when you want to focus or see full hand

### 📊 Live Feedback
- Confidence percentage (shows model certainty)
- Color-coded progress bar:
  - 🔴 Red (<55%): Not confident
  - 🟡 Amber (55-80%): Good progress
  - 🟢 Green (>80%): Excellent!
- Current recognized sign
- Success animation when correct

### 📈 Session Tracking
- Attempts counter
- Correct on first try counter
- Real-time accuracy stats

---

## How to Use Practice Mode

### Step 1: Start Practice
1. Go to **Practice** tab
2. App shows target sign (e.g., "A")
3. See sign description and tips
4. Camera preview shows below with skeleton

### Step 2: Watch the Skeleton
```
You see:
┌─ Your hand
│  ├─ Camera preview
│  ├─ Hand skeleton overlay (cyan + green)
│  ├─ Confidence meter
│  └─ Current sign detection
└─ Eye icon (👁️) to toggle skeleton
```

### Step 3: Perform the Sign
1. Form the target sign (e.g., make a fist for "A")
2. **Watch your skeleton** match the correct shape
3. Keep hand **steady and visible**
4. Monitor **confidence bar** (aim for green)

### Step 4: Success!
When you hold the sign correctly for 3+ frames:
- ✓ "Correct!" message appears
- 🎉 Success animation
- ✅ Sign added to practice session
- Auto-advance to next sign option

---

## Learning Strategy with Skeleton

### For Each Sign:

1. **Read Description**
   - Understand hand position
   - Note key features

2. **Look at Dictionary Reference** (optional)
   - Compare to guide
   - See official hand shape

3. **Watch Your Skeleton**
   - See what you're doing
   - Compare to target shape
   - Adjust hand position

4. **Improve Gradually**
   - Make small adjustments
   - Watch skeleton respond
   - Get higher confidence

5. **Master the Sign**
   - Hit 80%+ confidence
   - Success on first try
   - Move to next sign

---

## Skeleton Interpretation

### What Skeleton Shows

```
Perfect "A" Sign:
●──●  ← Thumb (to the side)
  │
  │  ← Fingers (closed/curled)
  │
  ●  ← Wrist (closed fist)

Skeleton shows:
✓ Thumb position
✓ Finger closure
✓ Overall hand shape
✓ Bone connections
```

### Skeleton Tells You:

| Skeleton Look | What It Means | Action |
|---------------|--------------|--------|
| All 21 points visible | Hand fully detected | Good! Continue |
| Some points missing | Hand partially obscured | Adjust angle/lighting |
| Points shaking | Hand/lighting unstable | Slow down, improve light |
| Completely different shape | Wrong sign shape | Refer to tips, adjust |
| Perfect match visually | Great form | Should recognize soon! |

---

## Common Learning Scenarios

### Scenario 1: Sign Not Recognized

**Check:**
1. Is skeleton visible? (If no → adjust hand position)
2. Does skeleton match target? (Compare visually)
3. Is confidence low? (Skeleton might be slightly off)

**Fix:**
```
Read tips again
↓
Adjust hand slowly
↓
Watch skeleton change
↓
Aim for perfect visual match
↓
Confidence should increase
↓
Success!
```

### Scenario 2: Wrong Sign Detected

**Example**: You're doing "A" but it recognizes "B"

**Why**: Hand shape is similar but slightly different

**Solution**:
1. Look at skeleton carefully
2. Compare to "A" vs "B" tips
3. Adjust specific fingers
4. Watch skeleton change
5. Re-test

### Scenario 3: Unstable Detection

**Symptoms**: Skeleton shaking, recognition jumping between signs

**Causes**:
- Poor lighting
- Hand moving too fast
- Camera angle unstable
- Hand too close/far

**Fixes**:
```
Improve Lighting → Brighter room
Slow Movement → Hold hand steadier
Better Angle → Center in frame
Adjust Distance → 30-60cm from camera
```

---

## Comparing Skeleton to Target

### Visual Reference While Practicing

1. **Read Target Description**
   ```
   "B: Hold all four fingers straight up and together, 
    with the thumb tucked in."
   ```

2. **See Your Skeleton**
   ```
   ●──●──●──●  ← Four fingers up?
      │   │   │   │
      │   │   │   │
   ```

3. **Adjust Based On What You See**
   - Fingers not up enough? → Straighten more
   - Fingers too spread? → Keep together
   - Thumb showing? → Tuck it behind

4. **Confidence Increases**
   - Visual match improves
   - Model confidence grows
   - Success becomes achievable

---

## Best Practices for Practice Mode

### ✅ DO:

- **Use skeleton actively** - Compare your hand to tips
- **Practice slowly** - Let skeleton stabilize
- **Good lighting** - Skeleton shows clearly
- **Clear hand position** - All 21 points should be visible
- **One sign at a time** - Master before moving to next
- **Repeat struggling signs** - Practice builds muscle memory
- **Check skeleton after** - Understand what happened

### ❌ DON'T:

- Ignore skeleton feedback
- Move hand too quickly
- Practice in dim lighting
- Hide your hands in shadows
- Skip tips reading
- Rush through signs
- Practice wrong form repeatedly

---

## Skeleton Settings

### Toggle On/Off
- **Why toggle off?**
  - Focus on hand feel (proprioception)
  - See cleaner camera view
  - Test without visual feedback

- **Why keep on?**
  - Real-time guidance
  - Immediate feedback
  - Compare to target shape
  - Debug recognition issues

### Recommended
- **Start**: Skeleton ON (visual feedback)
- **After mastering**: Toggle OFF for challenge
- **Back to learning**: Toggle ON for refinement

---

## Example Learning Session

### Sign "F"
```
Target: "Index and thumb to form a circle, 
         other fingers spread"

Step 1: Read tip
Step 2: Form hand
Step 3: Watch skeleton
        - Index+thumb circle? ○
        - Other fingers spread? ✌️ ✌️ ✌️
Step 4: Look at confidence
        - Too low? Adjust thumb/index circle
        - Getting better? Keep going
        - 80%+? Hold steady for success!
Step 5: Success!
        - "Correct!" appears
        - Move to next sign
```

---

## Troubleshooting

### Problem: Can't see skeleton clearly

**Solutions:**
1. Increase brightness (more light on hand)
2. Center hand in frame
3. Move closer to camera (but not too close)
4. Ensure camera is not covered
5. Try different hand angle

### Problem: Skeleton doesn't match what I'm doing

**Check:**
- Camera lens not dirty
- MediaPipe not missing points
- Hand at extreme angle (try different angle)
- Camera resolution ok

### Problem: Confidence stuck at 50%

**Why**: Hand shape doesn't exactly match training data

**Solutions:**
1. Refer to tips more carefully
2. Look at skeleton vs target
3. Make micro-adjustments
4. Ask: Which finger is wrong?
5. Practice that specific finger position

### Problem: Success animation appears but sign is wrong

**Why**: Model has low threshold or settings too lenient

**Action:**
1. Go to Settings tab
2. Increase confidence threshold
3. Increase window size
4. Return to Practice
5. Re-test

---

## Advanced Learning Techniques

### 1. Skeleton Comparison Method
```
During practice:
├─ Read tip
├─ Read skeleton carefully
├─ Adjust ONE thing at a time
├─ Watch skeleton respond
└─ Repeat until match
```

### 2. Slow Motion Technique
```
Move hand very slowly (2-3 seconds per sign)
→ Skeleton stays stable
→ Model can detect better
→ Higher confidence
→ Better success rate
```

### 3. Angle Exploration
```
If sign doesn't recognize:
├─ Rotate hand slightly left
├─ Rotate hand slightly right
├─ Rotate hand up
├─ Rotate hand down
└─ Find angle where skeleton looks right
```

### 4. Progressive Difficulty
```
Session 1: Skeleton ON, Lenient settings
Session 2: Skeleton ON, Balanced settings
Session 3: Skeleton ON, Strict settings
Session 4: Skeleton OFF, Balanced settings
```

---

## Performance Metrics

### What You'll See:

| Metric | Meaning | Target |
|--------|---------|--------|
| **Confidence** | Model certainty (0-100%) | 80%+ |
| **Attempts** | Times you've tried | Varies |
| **1st Try** | Correct on first attempt | >50% |
| **Accuracy** | Success rate this session | 80%+ |

### Improvement Timeline:

```
Session 1: 30-40% accuracy (learning)
Session 2: 50-60% accuracy (improving)
Session 3: 70-80% accuracy (good progress)
Session 4: 85-95% accuracy (mastered!)
```

---

## Tips for Fast Learning

### Top 5 Tips:

1. **Master basics first** - A, B, C before complex signs
2. **Use skeleton actively** - Don't ignore visual feedback
3. **Practice consistently** - 10 signs × 3 times each
4. **Move slowly** - Skeleton needs time to stabilize
5. **Review tips** - Understand before doing

### Best Signs to Start:
- A: Simple closed fist
- B: All fingers up
- C: Open C shape
- I: Just pinky up
- O: Circle with all fingers

### Harder Signs (Save for Later):
- F: Requires precise finger circle
- M, N, T: Specific finger over thumb
- K, R: Crossing fingers at angle

---

## Integration with Other Features

### Use Dictionary + Practice
1. Go to **Dictionary** tab
2. Tap a sign card
3. Read full description and tips
4. Tap "Practice this sign"
5. Learn with skeleton guidance

### Use Settings + Practice
1. Practice mode too hard? → Go to Settings
2. Lower confidence threshold
3. Reduce window size
4. Return to Practice
5. Should be easier now

### Track Your Progress
1. Use **Accuracy Feedback** in Recognition tab
2. Mark correct/incorrect after practice
3. Go to Settings to see stats
4. Identify which signs you need help with
5. Practice those signs more

---

## Session Recommendations

### Beginner Session (30 minutes)
```
Warm-up (5 min): A, B, C, D, E
Practice (20 min): F, G, H, I, J (3x each)
Review (5 min): Favorite or hardest sign
```

### Intermediate Session (45 minutes)
```
Review (5 min): Last session's struggles
New Learning (20 min): K, L, M, N, O (3x each)
Refinement (15 min): Mix of old and new
Challenge (5 min): Strict settings on mastered signs
```

### Advanced Session (60 minutes)
```
Accuracy Test (10 min): All 37 signs, skeleton OFF
Struggle Focus (20 min): Hardest signs, skeleton ON
Speed Practice (15 min): Fast signs, lower confidence
Numbers Practice (10 min): 0-9 learning
Mastery (5 min): Show off your best 5 signs
```

---

## When to Move to Recognition Mode

Once you:
- ✅ Master 10+ signs with 80%+ accuracy
- ✅ Don't need skeleton guidance
- ✅ Recognize quickly (no hesitation)
- ✅ Can do signs without tips

**Then**: Try Recognition mode for real-time typing experience!

---

**Happy practicing! 🚀 Your hand skeleton is your guide to perfect signs!**
