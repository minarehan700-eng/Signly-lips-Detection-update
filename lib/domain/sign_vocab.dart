const kLettersPath = 'assets/sign_language/letters/';
const kGifsPath = 'assets/sign_language/gifs/';

/// Known word → GIF display duration in milliseconds.
const kKnownWords = <String, int>{
  'hello': 2640,
  'you': 3200,
  'good': 2640,
  'morning': 3080,
};

const kHelloAliases = ['hello', 'hey', 'hi', 'hii', 'hay'];
const kYouAliases = ['you', 'your', "your's"];

const kLetters = [
  'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm',
  'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z',
  '0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
];

/// Classifier labels matching assets/models/labels.json (37 classes).
const kClassifierLetterLabels = [
  'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M',
  'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z',
];

const kClassifierNumberLabels = [
  '0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
];

const kClassifierSpaceLabel = ' ';

const kClassifierLabels = [
  ...kClassifierLetterLabels,
  ...kClassifierNumberLabels,
  kClassifierSpaceLabel,
];

const kLetterDisplayDurationMs = 1500;
const kSpaceDisplayDurationMs = 1000;
const kUnknownCharDisplayDurationMs = 1000;

String letterAsset(String char) => '$kLettersPath${char.toLowerCase()}.png';

String wordGifAsset(String word) => '$kGifsPath$word.gif';

String spaceAsset() => '${kLettersPath}space.png';

bool isKnownLetter(String char) => kLetters.contains(char.toLowerCase());

int? knownWordDuration(String word) => kKnownWords[word];

String? resolveWordAlias(String word) {
  if (kHelloAliases.contains(word)) return 'hello';
  if (kYouAliases.contains(word)) return 'you';
  return null;
}
