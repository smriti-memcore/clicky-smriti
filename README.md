# Clicky with SMRITI (`clicky-smriti`)

An intelligent macOS menu bar companion that lives next to your cursor, sees your screen, talks with you, points at UI elements across your monitors, and remembers everything across sessions using **SMRITI local-first long-term memory**.

Works **out-of-the-box with zero API keys** using local **Mistral** via Ollama.

---

## ✨ Features

- 🧠 **SMRITI Long-Term Memory**: Shared local memory layer (`~/.smriti/global`) connecting Clicky, Smriti Desktop App, Claude Code, Gemini CLI, and terminal agents. Every conversation turn is encoded into your memory palace and recalled in future conversations.
- ⚡ **Zero API Keys by Default**: Runs entirely on your Mac using local **Mistral** via Ollama. No credit cards, proxies, or cloud subscriptions required.
- 🤖 **Multi-Model Support**: Switch seamlessly in the menu bar panel between:
  - **Mistral** (Local via Ollama — *Default*, 0 API keys)
  - **Claude** (Sonnet 4.6 / Opus 4.6 via Worker proxy)
  - **Gemini** (3.5 Flash via Worker proxy)
  - **Grok** (2 Vision via Worker proxy)
  - **Custom Ollama** (Run any local model: `llama3.2-vision`, `qwen3.5`, etc.)
- 🎯 **Element Pointing**: Clicky calculates screen coordinates and flies a blue cursor companion along bezier arcs to point at buttons, windows, and UI elements.
- 🎙️ **Push-to-Talk**: Hold `Ctrl + Option` anywhere in macOS to speak. Features streaming transcription, live audio waveform feedback, and multi-monitor screen capture.
- 🔇 **Native macOS Menu Bar App**: Lives entirely in your status bar (`LSUIElement=true`). No dock clutter, non-activating floating control panel, and auto-dismissing overlays.

---

## 🚀 Quick Start (Zero API Keys)

The fastest way to run Clicky with local memory and local AI:

### 1. Prerequisites

- **macOS 14.2+** (Apple Silicon recommended)
- **Xcode 15+**
- **Python 3.10+** (with `pip3`)
- **Ollama** for the local Mistral model:
  ```bash
  brew install ollama
  ollama run mistral
  ```

### 2. Clone the Repository

```bash
git clone https://github.com/smriti-memcore/clicky-smriti.git
cd clicky-smriti
```

### 3. Open in Xcode & Run

```bash
open leanring-buddy.xcodeproj
```

1. Select the **leanring-buddy** scheme and destination **My Mac**.
2. Select your signing team in **Signing & Capabilities**.
3. Press **Cmd + R** to build and run.

> ⚠️ **Important**: Do **NOT** run `xcodebuild` from the terminal — building from terminal can invalidate macOS TCC privacy permissions (Screen Recording, Accessibility, Microphone). Always build directly within Xcode.

### 4. Grant Permissions

When Clicky opens in your menu bar, click the icon and grant:
- **Accessibility**: For the global `Ctrl + Option` push-to-talk shortcut
- **Screen Recording**: For multi-monitor visual perception
- **Microphone**: For voice input

Clicky will automatically boot its internal **SMRITI Local API daemon** on port `7798` and connect to your local Ollama server.

---

## 🧠 SMRITI Memory Architecture

Clicky integrates the **SMRITI Neuro-Inspired Memory Architecture** to maintain a persistent episodic and semantic memory palace across your workflow:

- **Local Storage**: All memories are stored locally on your machine at `~/.smriti/global/palace/palace.json`.
- **Cross-Tool Sharing**: Memories created in Clicky are instantly accessible by the [**Smriti Desktop App**](https://github.com/smriti-memcore/Smriti-Desktop-App) and command-line AI coding assistants.
- **Local HTTP Daemon**: Clicky manages a high-performance `ThreadingHTTPServer` on `http://127.0.0.1:7798` that automatically handles memory recall before each AI turn and encodes new conversational knowledge.
- **Auto-Installation**: If `smriti-memcore` is missing, Clicky automatically installs it to your Python environment on launch.

To inspect or consolidate your memory palace graphically, run the [Smriti Desktop App](https://github.com/smriti-memcore/Smriti-Desktop-App):
```bash
git clone https://github.com/smriti-memcore/Smriti-Desktop-App.git
cd Smriti-Desktop-App && npm install && npm run tauri dev
```

---

## ☁️ Optional Cloud Models & Proxy Setup

If you wish to use cloud models (Claude Sonnet 4.6, Gemini 3.5 Flash, Grok 2 Vision) or ElevenLabs realistic text-to-speech, set up the Cloudflare Worker proxy:

```bash
cd worker
npm install

# Configure secrets
npx wrangler secret put ANTHROPIC_API_KEY
npx wrangler secret put ASSEMBLYAI_API_KEY
npx wrangler secret put ELEVENLABS_API_KEY
# Optional for Gemini / Grok
npx wrangler secret put GEMINI_API_KEY
npx wrangler secret put GROK_API_KEY

# Set ElevenLabs Voice ID in wrangler.toml, then deploy:
npx wrangler deploy
```

Update `workerBaseURL` in [`leanring-buddy/CompanionManager.swift`](leanring-buddy/CompanionManager.swift) to your deployed Worker URL.

---

## ⌨️ Shortcuts & Controls

| Shortcut / Action | Function |
| :--- | :--- |
| **Hold `Ctrl + Option`** | Push-to-talk voice capture + screen perception |
| **Release `Ctrl + Option`** | Finalize audio and generate streaming response |
| **Click Menu Bar Icon** | Open companion settings, model selector, & memory palace stats |
| **Model Selector** | Toggle between Mistral (Local), Sonnet, Gemini, Grok, and Ollama |

---

## 📁 Project Structure

```
clicky-smriti/
├── leanring-buddy/                     # Native SwiftUI / AppKit macOS app
│   ├── CompanionManager.swift          # Core orchestrator: dictation, AI dispatch, SMRITI daemon
│   ├── CompanionPanelView.swift        # Floating menu bar dropdown UI & model picker
│   ├── OverlayWindow.swift             # Full-screen transparent blue cursor companion & pointer
│   ├── OpenAICompatibleAPI.swift       # Client for Mistral (Ollama), Gemini, and Grok
│   ├── ClaudeAPI.swift                 # Streaming Claude vision client
│   ├── BuddyDictationManager.swift     # Push-to-talk audio capture and STT pipeline
│   ├── ElevenLabsTTSClient.swift       # TTS playback with macOS system voice fallback
│   ├── DesignSystem.swift              # Consistent typography, spacing, and dark palette
│   └── scripts/smriti_local_api.py     # High-performance SMRITI REST API server
├── worker/                             # Optional Cloudflare Worker API proxy
├── AGENTS.md                           # Specification and conventions for AI coding agents
└── README.md
```

---

## 🤝 Acknowledgments & Credits

- Built on top of the original open-source [Clicky](https://github.com/farzaa/clicky) by [@farzatv](https://x.com/farzatv).
- Enhanced with persistent long-term memory, multi-model execution, and zero-key local inference by the [**SMRITI**](https://github.com/smriti-memcore) team.

## 📄 License

MIT License. See [LICENSE](LICENSE) for details.
