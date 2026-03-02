# HIT App Preferences & Specifications

Foundational mandates and architectural decisions for the HIT (High-Intensity Training) Garmin application.

## Project Metadata
- **App Name:** HIT
- **Target Device:** Garmin Venu 3 (AMOLED, 454x454)
- **Activity Type:** Strength Training (`SPORT_STRENGTH`)
- **Connect Session Name:** "HIT"

## UI & UX Conventions
- **Start Page:** Top/Bottom layout. Top displays "HIT Stopwatch" (two lines). Bottom features a vertical pill-highlighted picker for "Start Activity", "Configure", and "Quit".
- **Configure Page:** Two side-by-side vertical selection wheels.
  - Left wheel: Workout Slot (1-12).
  - Right wheel: Kieser Machine list.
  - Action: "OK" button to save to persistent storage; Back button to discard changes.
- **Workout Layout:**
  - **Top Carousel:** Horizontal exercise selection wheel. Displays clean machine codes (e.g., "A1", "F3.1").
  - **Main Area:** Large center-aligned stopwatch counting up in seconds.
  - **Bottom Label:** Shows only the machine description (e.g., "Lower Back").
- **Color Logic:**
  - `0 - 89s`: Black Background / White Text.
  - `90 - 119s`: Yellow Background / Black Text.
  - `120s+`: Green Background / Black Text.
  - **Divider Line:** Turns Dark Red when the timer is paused.
- **Alerts:** 
  - **Silent Mode:** Absolutely no audio beeps.
  - **Haptic:** Single short vibration (150ms) triggered exactly at 120s.

## Functional Requirements
- **Workout Structure:** 12 persistent exercise slots.
- **Data Integration:** 
  - Machine codes are saved into the FIT file's Lap data using `FitContributor` (Field name: "machine").
  - Activity is recorded as a single session with `addLap()` used for exercise transitions to ensure a quiet experience.
- **Quiet Recording:** The `ActivityRecording` session starts once; no system start/stop tones during transitions or pauses.

## Technical Specifications
- **Machine List:** Standardized 32-item Kieser Training machine array.
- **Memory Efficiency:** 
  - Cached coordinate calculations.
  - `Number` (Integer) used for all time tracking.
  - Minimal object creation in `onUpdate`.
- **File Consistency:** All files renamed to match "HIT" branding (e.g., `HITStopwatchView.mc`).
