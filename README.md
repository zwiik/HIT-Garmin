# HIT - High-Intensity Training Stopwatch for Garmin

**HIT** is a specialized workout application for Garmin Venu 3 and other AMOLED watches, meticulously designed for precision-based strength training (such as Kieser Training). It combines a high-contrast, distraction-free UI with advanced data logging to ensure your focus remains entirely on your performance.

![App Logo](resources/drawables/launcher_icon.svg)

## Key Features

### 🎯 Optimized for Precision
- **12 Exercise Slots:** Pre-configure your entire training sequence.
- **Horizontal Carousel:** Quickly switch between machine codes using intuitive swipe or tap gestures.
- **Large Stopwatch:** High-visibility countdown centered for easy reading during intense sets.

### 🎨 Intelligent Visual Feedback
- **Dynamic Backgrounds:** The screen automatically changes color to indicate set progress:
  - **Yellow (90s):** Approaching the goal.
  - **Green (120s):** Goal reached.
- **Silent Alerts:** A single, short haptic vibration at 120s notifies you without the distraction of audio beeps.
- **Pause Indicator:** The UI dims and the divider turns dark red when the timer is paused.

### 📊 Advanced Data Logging
- **Kieser Mapping:** Map each slot to specific machine codes (e.g., A1, B2, F3.1) using an interactive two-wheel picker.
- **FIT Field Integration:** Automatically saves **Machine Codes** and **Time Under Load (TUL)** into your Garmin Connect activity laps.
- **Activity Classification:** Workouts are saved as "Strength Training" with the session name "HIT".

### 🤫 Professional Focus
- **Quiet Mode:** System start/stop tones are suppressed during exercise transitions for a truly focused session.

## Compatibility
Optimized for the **Garmin Venu 3**, with full support for:
- Venu 2, Venu 2 Plus, Venu 2S, Venu 3S, Venu Sq 2
- Forerunner 265, 965, 165
- Epix (Gen 2) and Epix Pro series
- Fenix 7, Fenix 8 (AMOLED)
- Marq (Gen 2), Vivoactive 5

## Development & Installation

### Side-loading
1. Download the latest `HIT.prg` from the `bin/` folder.
2. Connect your Garmin watch via USB.
3. Copy the file to `Internal Storage/GARMIN/Apps`.

### Building from Source
Requirements:
- [Garmin Connect IQ SDK](https://developer.garmin.com/connect-iq/sdk/)
- [Visual Studio Code](https://code.visualstudio.com/) with Monkey C extension

```powershell
# Compile the project
monkeyc -f monkey.jungle -y developer_key -o bin/HIT.prg -d venu3
```

## License
This project is licensed under the **GNU General Public License v3.0**. See the [LICENSE](LICENSE) file for details.

---
*Created for the serious athlete. Train hard, log precisely.*
