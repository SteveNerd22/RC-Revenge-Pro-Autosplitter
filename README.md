# RC Revenge Pro Autosplitter

An automatic splitter script for **RC Revenge Pro** (PlayStation 2) designed for use with [LiveSplit](https://livesplit.org/). 

This autosplitter utilizes [emu-help-v3](https://github.com/Jujstme/emu-help-v3) to manage memory hook functionality across supported PS2 emulators.

---

## 📋 Features

- **Auto-Start**: Automatically begins the timer when the first race starts.
- **Auto-Split**: Automatically splits upon completing each race (supports all 24 races).
- **Auto-Reset**: Automatically resets the timer when returning to the main menu or starting a new run.

---

## 🛠️ Requirements

1. **LiveSplit** (latest version recommended)
2. **emu-help-v3** library
3. Supported PS2 Emulator (e.g., PCSX2, as supported by `emu-help`)

---

## 🚀 Setup & Installation

### Step 1: Install `emu-help-v3`
1. Download the [`emu-help-v3`](https://raw.githubusercontent.com/Jujstme/emu-help-v3/refs/heads/main/lib/Livesplit/emu-help-v3) file.
2. Place the `emu-help-v3` file into the **`Components/`** folder located inside your main LiveSplit directory.

### Step 2: Configure LiveSplit
1. Download the `RCRevengePro.asl` file from this repository.
2. Open LiveSplit, right-click and go to **Edit Layout...**
3. Click the **`+`** button $\rightarrow$ **Control** $\rightarrow$ **Scriptable Auto Splitter**.
4. Double-click **Scriptable Auto Splitter** to open its settings.
5. Under **Script Path**, click **Browse** and select the `RCRevengePro.asl` file.
6. Ensure **Start**, **Split**, and **Reset** are checked according to your preference.

### Step 3: Split Setup
- Make sure your splits file is set up with **24 splits** (1 split per race).

---

## 🎮 How to Use

1. Launch your emulator and load **RC Revenge Pro**.
2. Open LiveSplit with the configured layout.
3. Start playing — the autosplitter will handle timing automatically!

---

## 🤝 Credits & Acknowledgments

- **emu-help-v3**: Developed by [Jujstme](https://github.com/Jujstme) for universal emulator integration in LiveSplit scripts.
