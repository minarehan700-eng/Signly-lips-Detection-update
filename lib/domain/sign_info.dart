class SignInfo {
  final String label;
  final String description;
  final List<String> tips;
  final String? videoUrl;
  final bool isPhrase;

  const SignInfo({
    required this.label,
    required this.description,
    required this.tips,
    this.videoUrl,
    this.isPhrase = false,
  });
}

final kSignInfoMap = <String, SignInfo>{
  'A': SignInfo(
    label: 'A',
    description: 'Make a fist with palm facing the camera and thumb on the side of the index finger.',
    tips: [
      'Palm faces forward toward the camera',
      'Thumb on the side of the index — not over the fingers like S',
      'Keep a tight, firm fist',
    ],
  ),
  'B': SignInfo(
    label: 'B',
    description: 'Hold four fingers straight up and together with palm facing the camera; thumb tucked flat in the palm.',
    tips: [
      'Palm faces forward toward the camera',
      'Four fingers together pointing up — not spread like 4',
      'Thumb flat and tucked against the palm',
    ],
  ),
  'C': SignInfo(
    label: 'C',
    description: 'Curve fingers and thumb to form an open C shape, shown from the side with a visible gap.',
    tips: [
      'Show a curved gap between thumb and fingers',
      'Side view works best — not a closed circle like O',
      'Keep the opening clearly visible',
    ],
  ),
  'D': SignInfo(
    label: 'D',
    description: 'Touch your middle, ring, and pinky fingers to your thumb. Point your index finger up.',
    tips: ['Index finger points upward', 'Other fingers touching thumb', 'Makes a D shape'],
  ),
  'E': SignInfo(
    label: 'E',
    description: 'Curl all fingers down to meet the thumb.',
    tips: ['All five fingers curled', 'Touching the thumb', 'Like a small closed ball'],
  ),
  'F': SignInfo(
    label: 'F',
    description: 'Touch index finger and thumb to form a circle, other fingers spread.',
    tips: ['Index and thumb make a circle', 'Middle, ring, pinky spread up', 'Pinky should be extended'],
  ),
  'G': SignInfo(
    label: 'G',
    description: 'Point index finger sideways, thumb points upward, like a hand gun shape.',
    tips: ['Index finger points to the side', 'Thumb points upward', 'Other fingers curl down'],
  ),
  'H': SignInfo(
    label: 'H',
    description: 'Index and middle fingers extended horizontally and touching each other.',
    tips: ['Both fingers extended and together', 'Horizontal position', 'Other fingers curled'],
  ),
  'I': SignInfo(
    label: 'I',
    description: 'Make a fist, extend only the pinky finger up.',
    tips: ['Make a tight fist', 'Extend pinky finger high', 'Other fingers stay down'],
  ),
  'J': SignInfo(
    label: 'J',
    description: 'Make the I handshape and draw a J motion in the air.',
    tips: ['Start with I shape', 'Move finger in J pattern', 'Flowing motion downward'],
  ),
  'K': SignInfo(
    label: 'K',
    description: 'Index and middle finger make a V, thumb extends between them.',
    tips: ['Index and middle form a V', 'Thumb between them pointing up', 'Other fingers curl'],
  ),
  'L': SignInfo(
    label: 'L',
    description: 'Make an L shape with index finger up and thumb extended out.',
    tips: ['Index finger points up', 'Thumb points out to side', 'Other fingers curled'],
  ),
  'M': SignInfo(
    label: 'M',
    description: 'Place three middle fingers (middle, ring, pinky) over the thumb.',
    tips: ['Three fingers tip over thumb', 'Thumb visible underneath', 'Index finger curled'],
  ),
  'N': SignInfo(
    label: 'N',
    description: 'Place two fingers (middle and ring) over the thumb.',
    tips: ['Two fingers tip over thumb', 'Index and pinky curled', 'Thumb visible underneath'],
  ),
  'O': SignInfo(
    label: 'O',
    description: 'Form a circle with all fingers and thumb touching each other.',
    tips: ['All fingers meet thumb', 'Create a perfect circle', 'Compact shape'],
  ),
  'P': SignInfo(
    label: 'P',
    description: 'Index and middle fingers down, thumb extended, similar to K but upside down.',
    tips: ['Index and middle point down', 'Thumb points to side', 'Like a P shape'],
  ),
  'Q': SignInfo(
    label: 'Q',
    description: 'Index finger points down, thumb points down, like P moving downward.',
    tips: ['Index points downward', 'Thumb also points down', 'Distinctive downward motion'],
  ),
  'R': SignInfo(
    label: 'R',
    description: 'Cross index and middle fingers, with the middle finger in front.',
    tips: ['Index and middle fingers cross', 'Middle finger on top', 'Other fingers curled'],
  ),
  'S': SignInfo(
    label: 'S',
    description: 'Make a fist with the thumb over the fingers.',
    tips: ['Tight closed fist', 'Thumb rests over fingers', 'Strong, firm hand'],
  ),
  'T': SignInfo(
    label: 'T',
    description: 'Make a fist with the thumb between index and middle finger.',
    tips: ['Thumb between index and middle', 'Thumb visible through', 'Other fingers curl down'],
  ),
  'U': SignInfo(
    label: 'U',
    description: 'Index and middle fingers extended upward together, like a peace sign but together.',
    tips: ['Index and middle together pointing up', 'Parallel to each other', 'Other fingers curled'],
  ),
  'V': SignInfo(
    label: 'V',
    description: 'Make a V or peace sign with index and middle fingers spread apart.',
    tips: ['Index and middle fingers form V', 'Fingers slightly spread', 'Classic peace sign'],
  ),
  'W': SignInfo(
    label: 'W',
    description: 'Three fingers (index, middle, ring) spread out in a W formation.',
    tips: ['Three fingers extended upward', 'Fingers separated', 'Pinky and thumb curled'],
  ),
  'X': SignInfo(
    label: 'X',
    description: 'Bend index finger to form a hook, like an X shape.',
    tips: ['Index finger hooked', 'Cross other fingers', 'Bent, not straight'],
  ),
  'Y': SignInfo(
    label: 'Y',
    description: 'Extend thumb and pinky finger, fold other fingers in.',
    tips: ['Thumb and pinky extended', 'Middle fingers folded', 'Y shape clear'],
  ),
  'Z': SignInfo(
    label: 'Z',
    description: 'Use index finger to draw a Z motion in the air.',
    tips: ['Index finger draws Z pattern', 'Flowing motion', 'Diagonal movements'],
  ),
  '0': SignInfo(
    label: '0',
    description: 'Form a circle with all fingers and thumb touching (same as letter O).',
    tips: ['All fingers meet thumb', 'Perfect circle shape', 'Similar to letter O'],
  ),
  '1': SignInfo(
    label: '1',
    description: 'Point index finger up, all other fingers and thumb curl down.',
    tips: ['Only index finger extended', 'Others tucked down', 'Straight upward point'],
  ),
  '2': SignInfo(
    label: '2',
    description: 'Point index and middle fingers up, like a V or peace sign.',
    tips: ['Two fingers up', 'Other fingers curled', 'Palm outward'],
  ),
  '3': SignInfo(
    label: '3',
    description: 'Extend thumb, index, and middle fingers.',
    tips: ['Three fingers spread', 'Thumb visible', 'Other fingers curled'],
  ),
  '4': SignInfo(
    label: '4',
    description: 'Extend four fingers (all except thumb).',
    tips: ['Four fingers up', 'Thumb curled into palm', 'All four fingers together'],
  ),
  '5': SignInfo(
    label: '5',
    description: 'Open hand with all five fingers spread wide.',
    tips: ['All fingers extended and spread', 'Thumb also out', 'Wide open palm'],
  ),
  '6': SignInfo(
    label: '6',
    description: 'Touch pinky to thumb, other fingers spread.',
    tips: ['Pinky touches thumb', 'Other fingers extended', 'Bottom of hand shape'],
  ),
  '7': SignInfo(
    label: '7',
    description: 'Touch ring finger to thumb, index and middle extended.',
    tips: ['Ring finger on thumb', 'Index and middle up', 'Specific finger arrangement'],
  ),
  '8': SignInfo(
    label: '8',
    description: 'Touch middle finger to thumb, index and ring extended.',
    tips: ['Middle finger to thumb', 'Index and ring extended', 'Symmetrical spread'],
  ),
  '9': SignInfo(
    label: '9',
    description: 'Touch index finger to thumb, middle finger extended upward.',
    tips: ['Index to thumb', 'Middle finger up', 'Rest curled down'],
  ),
  ' ': SignInfo(
    label: 'Space',
    description: 'Keep hands at rest position, ready for next sign.',
    tips: ['Relaxed hand position', 'No finger movement', 'Break between signs'],
  ),
  'I LOVE YOU': SignInfo(
    label: 'I LOVE YOU',
    description: 'Point out your thumb and index finger to form an "L". While keeping them extended, lift your little finger. Your middle and ring finger keep touching your palm. Finally, direct your hand towards the person you are talking to.',
    tips: [
      'Form the letter "L" with thumb and index finger',
      'Lift your pinky (little finger) upward',
      'Middle and ring fingers stay on palm',
      'Point or move hand toward the other person',
      'Common expression of love and affection'
    ],
    isPhrase: true,
    videoUrl: 'https://www.youtube.com/embed/1Qd2wCeWzRM',
  ),
  'HI': SignInfo(
    label: 'HI',
    description: 'Place the hand you are writing with on your forehead close to your ear and move it outwards and away from your body.',
    tips: [
      'Start hand near forehead and ear',
      'Move hand outward and away from body',
      'Open hand with fingers extended',
      'Friendly greeting gesture',
      'Can be done with one or both hands'
    ],
    isPhrase: true,
    videoUrl: 'https://www.youtube.com/embed/98wlZBmxT7c',
  ),
  'HOW ARE YOU': SignInfo(
    label: 'HOW ARE YOU',
    description: 'Sign "HOW" using bent-V hands moving upward from your body, then sign "ARE" by moving right hand to the right, and point to the person for "YOU".',
    tips: [
      'HOW: Both hands in bent-V position, move upward',
      'ARE: Right hand moves right while being flat',
      'YOU: Point index finger toward the person',
      'Common greeting phrase',
      'Often used to ask about someone\'s well-being'
    ],
    isPhrase: true,
    videoUrl: 'https://www.youtube.com/embed/y9Rj_X0IsKY',
  ),
  'GOOD MORNING': SignInfo(
    label: 'GOOD MORNING',
    description: 'Sign "GOOD" by moving your right hand from your mouth down to your other hand\'s palm, then sign "MORNING" by showing a sunrise motion with your arm.',
    tips: [
      'GOOD: Move right hand from mouth down to left palm',
      'MORNING: Right arm shows sunrise arc over left arm',
      'Use this greeting in the morning hours',
      'Combine both signs smoothly',
      'Friendly and warm greeting'
    ],
    isPhrase: true,
    videoUrl: 'https://www.youtube.com/embed/qqHx7IuCN60',
  ),
};
