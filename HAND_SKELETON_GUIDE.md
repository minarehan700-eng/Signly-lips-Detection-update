# Hand Skeleton Visualization Guide

## What is Hand Skeleton?

The **Hand Skeleton** is a real-time overlay that shows the detected hand landmarks and bones on the camera preview. It helps you:

- ✅ See what the app is detecting
- ✅ Understand why recognition might be wrong
- ✅ Improve your hand positioning
- ✅ Debug recognition issues

---

## Visual Breakdown

```
Camera Preview
├─ Hand from camera
└─ Skeleton Overlay
   ├─ Cyan Wrist (large circle) ●
   ├─ Green Joints (small circles) ● ● ● ●
   └─ Cyan Bones (connecting lines)
```

### Colors & Symbols

| Element | Color | Meaning |
|---------|-------|---------|
| **Wrist** | Cyan (Large ●) | Base of hand |
| **Joints** | Green (Small ●) | Finger knuckles |
| **Bones** | Cyan (Lines) | Connections between joints |

---

## Hand Landmarks (21 Points)

The skeleton shows **21 hand landmarks**:

```
                    Finger Tips (4 points)
                    ↓  ↓  ↓  ↓
Thumb:    0──1──2──3
          ╲
Wrist 0   ╱ Index:    5──6──7──8
          ╲  Middle:  9──10─11─12
           ╲ Ring:    13─14─15─16
            ╲ Pinky:  17─18─19─20
```

### Landmark Details

| Landmark | Location |
|----------|----------|
| **0** | Wrist (palm base) |
| **1-4** | Thumb (base to tip) |
| **5-8** | Index finger |
| **9-12** | Middle finger |
| **13-16** | Ring finger |
| **17-20** | Pinky finger |

---

## How to Use

### **Toggle Skeleton On/Off**

1. Open **Recognize** tab
2. Look for **eye icon** (👁️) in top-right corner of camera preview
3. Tap to **show/hide** skeleton
4. Toggle appears as: 👁️ (visible) ↔️ 👁️‍🗨️ (hidden)

### **Understanding the Overlay**

1. **Skeleton appears** = Hand detected ✅
2. **Skeleton missing** = Hand not in frame ❌
3. **Skeleton jumpy** = Poor lighting or fast movement
4. **Skeleton stable** = Good conditions ✅

---

## Troubleshooting with Skeleton

### Problem: Sign not recognized

**Check the skeleton:**
- [ ] Are all 21 points visible? If not → adjust camera angle
- [ ] Are joints in correct positions? If not → check hand position
- [ ] Is skeleton stable? If not → improve lighting

### Problem: Wrong sign detected

**What to check:**
1. Look at skeleton position
2. Compare with correct sign shape
3. Adjust hand to match reference from Dictionary
4. Re-test

### Problem: Skeleton not appearing

**Solutions:**
1. Ensure hand is in frame
2. Check lighting (should be bright)
3. Make sure Settings → Skeleton toggle is ON
4. Try moving hand closer to camera

### Problem: Skeleton is shaky/jumpy

**Cause**: Poor hand detection (lighting, speed, etc.)

**Solutions**:
1. Increase brightness (move to well-lit area)
2. Move hand slower
3. Keep hand steady for 1-2 seconds
4. Move closer to camera

---

## Best Practices

### For Clear Skeleton

✅ **DO:**
- Good, even lighting (natural light preferred)
- Hand centered in camera frame
- Fingers clearly visible
- Keep hand still during sign
- Camera 30-60cm away
- Hand perpendicular to camera

❌ **DON'T:**
- Dim lighting or shadows on hand
- Hand at edge of frame
- Fingers obscured
- Hand moving too fast
- Hand too close or far
- Hand at extreme angles

---

## Using Skeleton for Practice

### Step-by-Step Learning

1. **Open Dictionary** tab
2. **Pick a sign** (e.g., "A")
3. **Read the description**
4. **Go to Practice** tab → select same sign
5. **Watch the skeleton** as you perform the sign
6. **Compare** your skeleton to the target shape
7. **Adjust** until it matches
8. **Record** on first correct try

---

## Debug: What Skeleton Tells You

### Scenario 1: Perfect Skeleton
```
All 21 points visible
Connected smoothly
Stable position
→ Recognition should be accurate
```

### Scenario 2: Partial Skeleton
```
Only 15 points visible
Some joints missing
→ Hand partially obscured
→ Move to better angle/lighting
```

### Scenario 3: Noisy Skeleton
```
Points appear and disappear
Shaking constantly
→ Poor lighting
→ Hand too fast
→ Increase brightness, slow down
```

### Scenario 4: No Skeleton
```
Nothing appears
→ Hand not detected at all
→ Adjust lighting, angle, distance
```

---

## Technical Details

### Performance Impact

- **Skeleton rendering**: ~5-10% CPU overhead
- **Toggle on/off**: Instant (no processing change)
- **No effect on recognition speed**: Display-only feature

### Coordinate System

Skeleton uses **normalized coordinates** (0-1):
- Top-left: (0, 0)
- Bottom-right: (1, 1)
- Scales to camera preview size automatically

---

## Tips for Best Results

### Hand Positioning

**Correct (✅):**
```
Hand centered
All fingers visible
Palm facing camera or to side
Relaxed posture
Clear lighting on hand
```

**Incorrect (❌):**
```
Hand at edge/corner
Fingers hidden
Back of hand
Tense, awkward angle
Shadow on hand
```

### Camera Setup

**Optimal (✅):**
- Brightness: 500+ lux (well-lit room)
- Distance: 30-60cm
- Angle: Perpendicular to hand
- Resolution: 720p+ preferred
- FPS: 30+ frames/second

**Problematic (❌):**
- Brightness: <300 lux (dim room)
- Distance: <20cm or >100cm
- Angle: Extreme (top-down, side)
- Low resolution (<480p)
- Low FPS (<20 fps)

---

## Skeleton Timeline

| Condition | Skeleton Status | Action |
|-----------|-----------------|--------|
| Hand entering frame | Partial → Full | Wait for stability |
| Hand in frame, good light | Full & stable | Ready to recognize |
| Hand moving | Full but jumpy | Slow down movement |
| Hand leaving frame | Full → Partial | Adjust position |
| New hand detected | New skeleton | Same hand? |

---

## FAQ

**Q: Why is skeleton sometimes missing a finger?**
A: Hand angle or lighting prevents full detection. Adjust camera angle or brightness.

**Q: Does skeleton slow down recognition?**
A: No, it's display-only and doesn't affect processing.

**Q: Can I hide the skeleton permanently?**
A: Yes, tap the eye icon. Setting persists until next toggle.

**Q: Why do the bones look wrong?**
A: Hand is at unusual angle. Try different camera angle or hand position.

**Q: Can I use skeleton while practicing?**
A: Currently in Recognition tab. Coming soon to Practice tab!

---

## Visual Examples

### ✅ Good Skeleton (Clear A Sign)
```
●─●
│ │    ← Index finger
│ │    ← Middle finger
│ │    ← Ring finger
│ │    ← Pinky finger
●      ← Wrist (closed fist)
```

### ❌ Poor Skeleton (Partial Hand)
```
●  (only wrist visible)
```

### ⚠️ Shaky Skeleton (Bad Lighting)
```
Points dancing around
Connections unstable
```

---

## Next Steps

1. **Test it out!** Toggle skeleton in Recognition tab
2. **Compare** your skeleton to Dictionary reference
3. **Practice** adjusting hand position using skeleton feedback
4. **Improve** recognition by perfecting hand shape
5. **Enjoy** better accuracy! 🎉

---

**Pro Tip**: Use skeleton when learning new signs to ensure you're forming them correctly!
