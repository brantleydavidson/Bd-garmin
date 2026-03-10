# Prometheus Watch Face — Cursor Onboarding Guide

## What This Project Is

A custom Garmin Connect IQ watch face called **Prometheus** for the **Garmin Fenix 8 (47mm)**. It's written in Monkey C (Garmin's language). The watch face shows time, weather, health metrics (body battery, HRV, sleep, stress, etc.) with tap-to-detail views for each metric.

**Target device:** Garmin Fenix 8 47mm (AMOLED, 454x454 display)
**Language:** Monkey C (.mc files)
**API level:** 5.1.0 (Connect IQ System 8)

---

## Project Structure

```
prometheus-watchface/
├── manifest.xml                          # App identity, device, permissions
├── monkey.jungle                         # Build config
├── resources/
│   ├── drawables/
│   │   ├── drawables.xml                 # Bitmap resource declarations
│   │   ├── launcher_icon.png             # 40x40 app icon
│   │   └── ic_*.png                      # 8 weather icons (26x26)
│   ├── fonts/fonts.xml                   # Font declarations (uses system fonts)
│   ├── layouts/layouts.xml               # Layout stub (draws programmatically)
│   ├── menus/menus.xml                   # Menu stub
│   ├── settings/settings.xml             # 7 user-configurable settings
│   └── strings/strings.xml               # App name + setting labels
└── source/
    ├── PrometheusApp.mc                  # App entry point, lifecycle
    ├── PrometheusView.mc                 # Main watch face rendering (largest file)
    ├── PrometheusDelegate.mc             # Tap zone detection, navigation
    ├── PrometheusSettings.mc             # Settings singleton, themes, colors
    ├── weather/
    │   └── WeatherProvider.mc            # Weather condition → icon mapping
    └── detail/
        ├── DetailView.mc                 # Base class for all detail screens
        ├── DetailDelegate.mc             # Back button handler for details
        ├── BodyBatteryDetail.mc          # Tap detail: body battery
        ├── HRVDetail.mc                  # Tap detail: heart rate variability
        ├── SleepDetail.mc                # Tap detail: sleep duration
        ├── SleepScoreDetail.mc           # Tap detail: sleep score
        ├── RHRDetail.mc                  # Tap detail: resting heart rate
        ├── StepsDetail.mc                # Tap detail: steps
        ├── KcalDetail.mc                 # Tap detail: calories
        ├── StressDetail.mc               # Tap detail: stress level
        ├── VO2MaxDetail.mc               # Tap detail: VO2 max
        ├── FloorsDetail.mc               # Tap detail: floors climbed
        ├── TrainingLoadDetail.mc         # Tap detail: training load
        ├── TSSDetail.mc                  # Tap detail: training stress score
        ├── ReadinessDetail.mc            # Tap detail: readiness score
        └── WeatherDetail.mc              # Tap detail: weather forecast
```

---

## Step 1: Install the Garmin Connect IQ SDK

This is required before anything will compile.

### Option A: Via VS Code / Cursor Extension (Easiest)
1. Open Cursor
2. Go to Extensions (Ctrl+Shift+X)
3. Search for **"Monkey C"** by Garmin
4. Install it
5. It will prompt you to download the **Connect IQ SDK** — follow the prompts
6. When asked, install the **Fenix 8** device package

### Option B: Manual Install
1. Go to https://developer.garmin.com/connect-iq/sdk/
2. Download the SDK Manager for your OS
3. Run it and install the latest SDK
4. In the SDK Manager, go to Devices and install **Fenix 8 47mm**

### After installing, verify:
Open a terminal in Cursor and run:
```bash
which monkeyc
```
If it prints a path, you're good. If not, you may need to add the SDK `bin/` folder to your PATH. The Monkey C extension usually handles this automatically.

---

## Step 2: Generate a Developer Key

You need a signing key to build. You only do this once.

```bash
# In Cursor's terminal, from the project root:
cd prometheus-watchface
generatekey -o developer_key.der
```

Keep this file — you'll need it every time you build. Do NOT commit it to git.

---

## Step 3: Open the Project in Cursor

1. Clone the repo if you haven't:
   ```bash
   git clone <your-repo-url>
   ```
2. In Cursor: **File → Open Folder** → select the `prometheus-watchface/` folder
3. The Monkey C extension should detect the `monkey.jungle` file automatically

---

## Step 4: Build the Project

### Via Cursor UI (if Monkey C extension is set up):
- Set device to **fenix8** in the bottom status bar
- Press **Ctrl+Shift+B** to build

### Via Terminal:
```bash
cd prometheus-watchface
monkeyc -d fenix8 -f monkey.jungle -o bin/prometheus.prg -y developer_key.der
```

### Expect Compiler Errors on First Build

This project has NOT been compiled yet. There will likely be errors. Common ones:

1. **Unknown symbol errors** — A Garmin API class or method name may be slightly wrong. Fix by checking the Garmin API docs at https://developer.garmin.com/connect-iq/api-docs/
2. **Type check errors** — Monkey C is strict about null safety. May need to add null checks or type casts.
3. **Device ID mismatch** — The manifest uses `fenix8` as the product ID. If the SDK expects a different ID (like `fenix847mm` or `fenix8solar`), update line 10 in `manifest.xml` to match what shows up in your SDK's device list.

To find the correct device ID:
```bash
# List available devices
ls $(sdkmanager --sdk-path)/Devices/
```

**Fixing compiler errors is the main task before you can deploy.** Paste the full error output into Cursor's AI chat and it can fix them for you.

---

## Step 5: Test in the Simulator

Before putting it on your watch, test in the simulator:

```bash
# Launch the simulator
connectiq &

# Run the watch face in the simulator
monkeydo bin/prometheus.prg fenix8
```

Or in Cursor: **Ctrl+F5** (Run Without Debugging)

### In the simulator you can:
- See the watch face render
- Click on the screen to simulate taps (tests detail views)
- Go to **Simulation → Set Weather** to test weather display
- Go to **Simulation → Set Activity Monitor** to set fake step/calorie data
- Toggle AOD mode via **Simulation → Low Power Mode**

**Note:** Body Battery, HRV, Sleep, and Stress history won't have real data in the simulator. Those metrics will show placeholder/fallback values. They'll populate with real data on your actual watch.

---

## Step 6: Deploy to Your Fenix 8

Once it builds and looks decent in the simulator:

1. **Connect your Fenix 8 via USB** — it will mount as a USB drive
2. **Find the GARMIN folder** on the mounted drive
3. **Copy the built file:**
   ```
   Copy: prometheus-watchface/bin/prometheus.prg
   To:   <FENIX_DRIVE>/GARMIN/APPS/prometheus.prg
   ```
4. **Safely eject** the watch drive
5. **On the watch:** Hold the watch face screen → scroll through faces → select **Prometheus**

### If the watch face crashes or won't load:
- Connect via USB again
- Delete `GARMIN/APPS/prometheus.prg`
- Check `GARMIN/APPS/LOGS/` for crash logs — these tell you exactly which line failed
- Fix the issue, rebuild, and re-deploy

---

## Step 7: Iterate

The development loop is:
1. Edit code in Cursor
2. Build (Ctrl+Shift+B or terminal command)
3. Test in simulator (Ctrl+F5)
4. When happy, copy .prg to watch via USB
5. Test on watch
6. Repeat

---

## Key Architecture Notes for AI Assistance

When asking Cursor's AI to fix or modify code, these context points are important:

- **This is a watch face app** (type="watchface" in manifest.xml), NOT a widget or app
- **PrometheusView.mc** is the main file — it draws everything on screen in `onUpdate(dc)`
- **Tapping a metric** calls `WatchUi.pushView()` to show a detail screen (handled in PrometheusDelegate.mc)
- **All sensor data APIs can return null** — every call needs null safety: `if (value != null) { ... }`
- **Display is 454x454 pixels**, center point is (227, 227)
- **Garmin arc angles:** 0 = 3 o'clock, 90 = 12 o'clock (counter-clockwise). Convert from standard: `garminAngle = 90 - standardAngle`
- **AOD (Always-On Display):** Must use minimal pixels (<10%) to prevent AMOLED burn-in. Handled via `onEnterSleep()` / `onExitSleep()` in the view
- **Settings** are defined in `resources/settings/settings.xml` and read via `Application.Properties.getValue("key")` in PrometheusSettings.mc
- The **Monkey C language** is similar to Java but with some differences: `var` for variables, `function` for methods, `as` for type annotations, no generics

### Garmin API Docs Reference
- Full API: https://developer.garmin.com/connect-iq/api-docs/
- SensorHistory: https://developer.garmin.com/connect-iq/api-docs/Toybox/SensorHistory.html
- Weather: https://developer.garmin.com/connect-iq/api-docs/Toybox/Weather.html
- Graphics (drawing): https://developer.garmin.com/connect-iq/api-docs/Toybox/Graphics/Dc.html

---

## Known Issues / TODO

- [ ] **First compile** — Expect compiler errors that need fixing. This is the first priority.
- [ ] **Device product ID** — May need to change `fenix8` in manifest.xml to match your SDK's exact device identifier.
- [ ] **pushView from watch face** — If `WatchUi.pushView()` throws an error on the Fenix 8, the detail view navigation needs to be refactored to an inline state-machine approach (render detail views inside `PrometheusView.onUpdate()` based on a mode variable instead of pushing separate views). This is a known risk.
- [ ] **Memory optimization** — Watch faces have ~124KB memory limit. If you hit memory errors, weather icons should be loaded lazily and sensor history iterators released after use.
- [ ] **Premium features** — Glow effects, themes, and enhanced AOD are gated behind a `isPremium` flag. For testing, you can set `Application.Storage.setValue("isPremium", true)` in `PrometheusApp.onStart()`.
