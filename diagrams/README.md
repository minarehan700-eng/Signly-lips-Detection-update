# Signly Diagrams

Simple PlantUML diagrams for the **Signly** graduation project (`mobile_offline`).

## Files

| File | Description |
|------|-------------|
| `01_use_case.puml` | User use cases: Login, Recognize ASL, Text/Voice to Sign, Letters & Numbers, Lips Detection, Dictionary, Profile |
| `02_system_architecture.puml` | App layers: Flutter UI → Application → Infrastructure → Native bridges → On-device models |
| `03_lips_detection_sequence.puml` | Camera frame flow for lips detection (JPEG → MediaPipe Face → detectors → UI) |
| `04_hand_recognition_sequence.puml` | Camera frame flow for ASL hand recognition (MediaPipe Hand → TFLite → controller → UI) |
| `05_app_navigation.puml` | Screen flow: Splash → Login → Home tabs and Translate sub-screens |
| `06_lips_classes.puml` | Class diagram for lips detection main classes |
| `07_ai_components.puml` | On-device AI/ML components: 3 models, hand & face paths, rule-based lips post-processing |

## How to View

### Option 1: PlantUML Online

1. Open [PlantUML Online Editor](https://www.plantuml.com/plantuml/uml/)
2. Copy the contents of any `.puml` file
3. Paste into the editor — the diagram renders automatically
4. Export as PNG or SVG if needed for your report or presentation

### Option 2: VS Code Extension

1. Install the **PlantUML** extension (by jebbs)
2. Open any `.puml` file in VS Code
3. Press `Alt+D` to preview, or run **PlantUML: Export Current Diagram**

### Option 3: Command Line

If you have PlantUML installed locally (Java required):

```bash
java -jar plantuml.jar diagrams/*.puml
```

This generates PNG files next to each `.puml` source file.
