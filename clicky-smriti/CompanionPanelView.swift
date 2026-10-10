//
//  CompanionPanelView.swift
//  clicky-smriti
//
//  The SwiftUI content hosted inside the menu bar panel. Shows the companion
//  voice status, push-to-talk shortcut, and quick settings. Designed to feel
//  like Loom's recording panel — dark, rounded, minimal, and special.
//

import AVFoundation
import SwiftUI

struct CompanionPanelView: View {
    @ObservedObject var companionManager: CompanionManager
    @State private var typedPromptInput: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            panelHeader
            Divider()
                .background(DS.Colors.borderSubtle)
                .padding(.horizontal, 16)

            // Direct Interaction Section (Voice button + prompt text field)
            interactionSection
                .padding(.top, 14)
                .padding(.horizontal, 16)

            Spacer()
                .frame(height: 12)

            // Model Selection Section
            modelPickerRow
                .padding(.horizontal, 16)

            if companionManager.selectedModel == "mistral" {
                HStack(spacing: 6) {
                    Circle()
                        .fill(companionManager.isOllamaRunning ? DS.Colors.success : Color.orange)
                        .frame(width: 7, height: 7)

                    Text(companionManager.isOllamaRunning
                        ? "Local Mistral via Ollama • Ready (zero API keys)"
                        : "Ollama Offline • Start Ollama app or 'ollama serve'")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(companionManager.isOllamaRunning ? DS.Colors.textSecondary : Color.orange)

                    Spacer()

                    if !companionManager.isOllamaRunning {
                        Button("Check") {
                            companionManager.checkOllamaHealth()
                        }
                        .font(.system(size: 10, weight: .semibold))
                        .buttonStyle(.plain)
                        .foregroundColor(DS.Colors.accentText)
                        .pointerCursor()
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 2)
            }

            if companionManager.selectedModel == "ollama-local" {
                localOllamaModelInputRow
                    .padding(.horizontal, 16)

                HStack(spacing: 6) {
                    Circle()
                        .fill(companionManager.isOllamaRunning ? DS.Colors.success : Color.orange)
                        .frame(width: 7, height: 7)

                    Text(companionManager.isOllamaRunning
                        ? "Ollama Connected • Local model"
                        : "Ollama Offline • Run 'ollama serve' in Terminal")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(companionManager.isOllamaRunning ? DS.Colors.textSecondary : Color.orange)

                    Spacer()

                    if !companionManager.isOllamaRunning {
                        Button("Check") {
                            companionManager.checkOllamaHealth()
                        }
                        .font(.system(size: 10, weight: .semibold))
                        .buttonStyle(.plain)
                        .foregroundColor(DS.Colors.accentText)
                        .pointerCursor()
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 2)
            }

            smritiMemorySection
                .padding(.horizontal, 16)

            // Permissions section (only shown if some permissions are pending)
            if !companionManager.allPermissionsGranted {
                Spacer()
                    .frame(height: 12)

                settingsSection
                    .padding(.horizontal, 16)
            }

            // Show cursor toggle
            Spacer()
                .frame(height: 8)

            showClickyCursorToggleRow
                .padding(.horizontal, 16)

            Spacer()
                .frame(height: 10)

            Divider()
                .background(DS.Colors.borderSubtle)
                .padding(.horizontal, 16)

            footerSection
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
        }
        .frame(width: 320)
        .background(panelBackground)
        .onAppear {
            companionManager.checkOllamaHealth()
        }
    }

    // MARK: - Header

    private var panelHeader: some View {
        HStack {
            HStack(spacing: 8) {
                Circle()
                    .fill(statusDotColor)
                    .frame(width: 8, height: 8)
                    .shadow(color: statusDotColor.opacity(0.6), radius: 4)

                Text("Clicky")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(DS.Colors.textPrimary)
            }

            Spacer()

            Text(statusText)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(DS.Colors.textTertiary)

            Button(action: {
                NotificationCenter.default.post(name: .clickyDismissPanel, object: nil)
            }) {
                Image(systemName: "xmark")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(DS.Colors.textTertiary)
                    .frame(width: 20, height: 20)
                    .background(
                        Circle()
                            .fill(Color.white.opacity(0.08))
                    )
            }
            .buttonStyle(.plain)
            .pointerCursor()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }

    // MARK: - Interaction Section

    private var interactionSection: some View {
        VStack(spacing: 10) {
            // Hero Voice Button
            Button(action: {
                companionManager.toggleVoiceRecording()
            }) {
                HStack(spacing: 8) {
                    Image(systemName: companionManager.isVoiceRecordingActive ? "stop.circle.fill" : "mic.fill")
                        .font(.system(size: 15, weight: .bold))

                    Text(companionManager.isVoiceRecordingActive ? "Stop & Send" : "Talk to Clicky")
                        .font(.system(size: 13, weight: .semibold))

                    if companionManager.isVoiceRecordingActive {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 8, height: 8)
                            .opacity(0.8)
                    }
                }
                .foregroundColor(companionManager.isVoiceRecordingActive ? .white : DS.Colors.textOnAccent)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: DS.CornerRadius.medium, style: .continuous)
                        .fill(companionManager.isVoiceRecordingActive ? Color.red : DS.Colors.accent)
                )
            }
            .buttonStyle(.plain)
            .pointerCursor()

            // Subtitle hint
            HStack {
                Text(companionManager.isVoiceRecordingActive
                     ? "Listening... click to answer"
                     : "Click above or hold Ctrl + Option anytime")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(companionManager.isVoiceRecordingActive ? Color.red : DS.Colors.textTertiary)
                Spacer()
            }

            // Quick typed prompt input
            HStack(spacing: 6) {
                TextField("Ask anything (or press Enter)...", text: $typedPromptInput)
                    .textFieldStyle(.plain)
                    .font(.system(size: 12))
                    .foregroundColor(DS.Colors.textPrimary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: DS.CornerRadius.small, style: .continuous)
                            .fill(Color.white.opacity(0.06))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: DS.CornerRadius.small, style: .continuous)
                            .stroke(DS.Colors.borderSubtle, lineWidth: 0.5)
                    )
                    .onSubmit {
                        submitTypedPrompt()
                    }

                if !typedPromptInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    Button(action: {
                        submitTypedPrompt()
                    }) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 18))
                            .foregroundColor(DS.Colors.accent)
                    }
                    .buttonStyle(.plain)
                    .pointerCursor()
                }
            }
        }
    }

    private func submitTypedPrompt() {
        let text = typedPromptInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        typedPromptInput = ""
        companionManager.sendTextPrompt(text)
    }

    // MARK: - Permissions

    private var settingsSection: some View {
        VStack(spacing: 2) {
            Text("PERMISSIONS")
                .font(.system(size: 10, weight: .semibold, design: .rounded))
                .foregroundColor(DS.Colors.textTertiary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 6)

            microphonePermissionRow

            accessibilityPermissionRow

            screenRecordingPermissionRow

            if companionManager.hasScreenRecordingPermission {
                screenContentPermissionRow
            }

        }
    }

    private var accessibilityPermissionRow: some View {
        let isGranted = companionManager.hasAccessibilityPermission
        return HStack {
            HStack(spacing: 8) {
                Image(systemName: "hand.raised")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(isGranted ? DS.Colors.textTertiary : DS.Colors.warning)
                    .frame(width: 16)

                VStack(alignment: .leading, spacing: 1) {
                    Text("Accessibility")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(DS.Colors.textSecondary)

                    Text(isGranted
                         ? "Global Ctrl + Option shortcut active"
                         : "Optional: for Ctrl + Option shortcut")
                        .font(.system(size: 10))
                        .foregroundColor(DS.Colors.textTertiary)
                }
            }

            Spacer()

            if isGranted {
                HStack(spacing: 4) {
                    Circle()
                        .fill(DS.Colors.success)
                        .frame(width: 6, height: 6)
                    Text("Granted")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(DS.Colors.success)
                }
            } else {
                HStack(spacing: 6) {
                    Button(action: {
                        // Triggers the system accessibility prompt (AXIsProcessTrustedWithOptions)
                        // on first attempt, then opens System Settings on subsequent attempts.
                        WindowPositionManager.requestAccessibilityPermission()
                    }) {
                        Text("Grant")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(DS.Colors.textOnAccent)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(DS.Colors.accent)
                            )
                    }
                    .buttonStyle(.plain)
                    .pointerCursor()

                    Button(action: {
                        // Reveals the app in Finder so the user can drag it into
                        // the Accessibility list if it doesn't appear automatically
                        // (common with unsigned dev builds).
                        WindowPositionManager.revealAppInFinder()
                        WindowPositionManager.openAccessibilitySettings()
                    }) {
                        Text("Find App")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(DS.Colors.textSecondary)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .stroke(DS.Colors.borderSubtle, lineWidth: 0.8)
                            )
                    }
                    .buttonStyle(.plain)
                    .pointerCursor()
                }
            }
        }
        .padding(.vertical, 6)
    }

    private var screenRecordingPermissionRow: some View {
        let isGranted = companionManager.hasScreenRecordingPermission
        return HStack {
            HStack(spacing: 8) {
                Image(systemName: "rectangle.dashed.badge.record")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(isGranted ? DS.Colors.textTertiary : DS.Colors.warning)
                    .frame(width: 16)

                VStack(alignment: .leading, spacing: 1) {
                    Text("Screen Recording")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(DS.Colors.textSecondary)

                    Text(isGranted
                         ? "Only takes a screenshot when you use the hotkey"
                         : "Quit and reopen after granting")
                        .font(.system(size: 10))
                        .foregroundColor(DS.Colors.textTertiary)
                }
            }

            Spacer()

            if isGranted {
                HStack(spacing: 4) {
                    Circle()
                        .fill(DS.Colors.success)
                        .frame(width: 6, height: 6)
                    Text("Granted")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(DS.Colors.success)
                }
            } else {
                Button(action: {
                    // Triggers the native macOS screen recording prompt on first
                    // attempt (auto-adds app to the list), then opens System Settings
                    // on subsequent attempts.
                    WindowPositionManager.requestScreenRecordingPermission()
                }) {
                    Text("Grant")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(DS.Colors.textOnAccent)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(DS.Colors.accent)
                        )
                }
                .buttonStyle(.plain)
                .pointerCursor()
            }
        }
        .padding(.vertical, 6)
    }

    private var screenContentPermissionRow: some View {
        let isGranted = companionManager.hasScreenContentPermission
        return HStack {
            HStack(spacing: 8) {
                Image(systemName: "eye")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(isGranted ? DS.Colors.textTertiary : DS.Colors.warning)
                    .frame(width: 16)

                Text("Screen Content")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(DS.Colors.textSecondary)
            }

            Spacer()

            if isGranted {
                HStack(spacing: 4) {
                    Circle()
                        .fill(DS.Colors.success)
                        .frame(width: 6, height: 6)
                    Text("Granted")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(DS.Colors.success)
                }
            } else {
                Button(action: {
                    companionManager.requestScreenContentPermission()
                }) {
                    Text("Grant")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(DS.Colors.textOnAccent)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(DS.Colors.accent)
                        )
                }
                .buttonStyle(.plain)
                .pointerCursor()
            }
        }
        .padding(.vertical, 6)
    }

    private var microphonePermissionRow: some View {
        let isGranted = companionManager.hasMicrophonePermission
        return HStack {
            HStack(spacing: 8) {
                Image(systemName: "mic")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(isGranted ? DS.Colors.textTertiary : DS.Colors.warning)
                    .frame(width: 16)

                Text("Microphone")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(DS.Colors.textSecondary)
            }

            Spacer()

            if isGranted {
                HStack(spacing: 4) {
                    Circle()
                        .fill(DS.Colors.success)
                        .frame(width: 6, height: 6)
                    Text("Granted")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(DS.Colors.success)
                }
            } else {
                Button(action: {
                    // Triggers the native macOS microphone permission dialog on
                    // first attempt. If already denied, opens System Settings.
                    let status = AVCaptureDevice.authorizationStatus(for: .audio)
                    if status == .notDetermined {
                        AVCaptureDevice.requestAccess(for: .audio) { _ in }
                    } else {
                        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Microphone") {
                            NSWorkspace.shared.open(url)
                        }
                    }
                }) {
                    Text("Grant")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(DS.Colors.textOnAccent)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(DS.Colors.accent)
                        )
                }
                .buttonStyle(.plain)
                .pointerCursor()
            }
        }
        .padding(.vertical, 6)
    }

    private func permissionRow(
        label: String,
        iconName: String,
        isGranted: Bool,
        settingsURL: String
    ) -> some View {
        HStack {
            HStack(spacing: 8) {
                Image(systemName: iconName)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(isGranted ? DS.Colors.textTertiary : DS.Colors.warning)
                    .frame(width: 16)

                Text(label)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(DS.Colors.textSecondary)
            }

            Spacer()

            if isGranted {
                HStack(spacing: 4) {
                    Circle()
                        .fill(DS.Colors.success)
                        .frame(width: 6, height: 6)
                    Text("Granted")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(DS.Colors.success)
                }
            } else {
                Button(action: {
                    if let url = URL(string: settingsURL) {
                        NSWorkspace.shared.open(url)
                    }
                }) {
                    Text("Grant")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(DS.Colors.textOnAccent)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(DS.Colors.accent)
                        )
                }
                .buttonStyle(.plain)
                .pointerCursor()
            }
        }
        .padding(.vertical, 6)
    }



    // MARK: - Show Clicky Cursor Toggle

    private var showClickyCursorToggleRow: some View {
        HStack {
            HStack(spacing: 8) {
                Image(systemName: "cursorarrow")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(DS.Colors.textTertiary)
                    .frame(width: 16)

                Text("Show Clicky")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(DS.Colors.textSecondary)
            }

            Spacer()

            Toggle("", isOn: Binding(
                get: { companionManager.isClickyCursorEnabled },
                set: { companionManager.setClickyCursorEnabled($0) }
            ))
            .toggleStyle(.switch)
            .labelsHidden()
            .tint(DS.Colors.accent)
            .scaleEffect(0.8)
        }
        .padding(.vertical, 4)
    }

    private var speechToTextProviderRow: some View {
        HStack {
            HStack(spacing: 8) {
                Image(systemName: "mic.badge.waveform")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(DS.Colors.textTertiary)
                    .frame(width: 16)

                Text("Speech to Text")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(DS.Colors.textSecondary)
            }

            Spacer()

            Text(companionManager.buddyDictationManager.transcriptionProviderDisplayName)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(DS.Colors.textTertiary)
        }
        .padding(.vertical, 4)
    }

    // MARK: - Model Picker

    private var modelPickerRow: some View {
        HStack {
            Text("Model")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(DS.Colors.textSecondary)

            Spacer()

            HStack(spacing: 0) {
                modelOptionButton(label: "Mistral", modelID: "mistral")
                modelOptionButton(label: "Sonnet", modelID: "claude-sonnet-4-6")
                modelOptionButton(label: "Gemini", modelID: "gemini-3.5-flash")
                modelOptionButton(label: "Grok", modelID: "grok-2-vision")
                modelOptionButton(label: "Ollama", modelID: "ollama-local")
            }
            .background(
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(Color.white.opacity(0.06))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .stroke(DS.Colors.borderSubtle, lineWidth: 0.5)
            )
        }
        .padding(.vertical, 4)
    }

    private var localOllamaModelInputRow: some View {
        HStack {
            Text("Ollama Model")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(DS.Colors.textSecondary)

            Spacer()

            TextField("mistral", text: Binding(
                get: { companionManager.localOllamaModelName },
                set: { companionManager.setLocalOllamaModelName($0) }
            ))
            .textFieldStyle(.plain)
            .font(.system(size: 11))
            .foregroundColor(DS.Colors.textPrimary)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.white.opacity(0.06))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(DS.Colors.borderSubtle, lineWidth: 0.5)
            )
            .frame(width: 140)
        }
        .padding(.vertical, 4)
    }

    private func modelOptionButton(label: String, modelID: String) -> some View {
        let isSelected = companionManager.selectedModel == modelID
        return Button(action: {
            companionManager.setSelectedModel(modelID)
        }) {
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(isSelected ? DS.Colors.textPrimary : DS.Colors.textTertiary)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(
                    RoundedRectangle(cornerRadius: 5, style: .continuous)
                        .fill(isSelected ? Color.white.opacity(0.1) : Color.clear)
                )
        }
        .buttonStyle(.plain)
        .pointerCursor()
    }

    private var smritiMemorySection: some View {
        VStack(spacing: 8) {
            Divider()
                .background(DS.Colors.borderSubtle)
                .padding(.vertical, 4)

            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 13))
                        .foregroundColor(companionManager.isSmritiConnected ? DS.Colors.accent : DS.Colors.textTertiary)
                    
                    Text("Smriti Memory")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(DS.Colors.textSecondary)
                }

                Spacer()

                HStack(spacing: 6) {
                    Circle()
                        .fill(companionManager.isSmritiConnected ? DS.Colors.success : DS.Colors.warning)
                        .frame(width: 6, height: 6)
                    
                    Text(companionManager.smritiStatusMessage)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(companionManager.isSmritiConnected ? DS.Colors.textPrimary : DS.Colors.textTertiary)
                }
            }

            if companionManager.isSmritiConnected {
                Button(action: {
                    let mcpConfig = """
                    {
                      "mcpServers": {
                        "smriti-memory": {
                          "command": "python3",
                          "args": [
                            "-m",
                            "smriti_memcore.integrations.mcp_server"
                          ]
                        }
                      }
                    }
                    """
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString(mcpConfig, forType: .string)
                    print("📋 MCP Config copied to clipboard")
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "doc.on.doc")
                            .font(.system(size: 10))
                        Text("Copy MCP Config for Claude/Cursor")
                            .font(.system(size: 10, weight: .semibold))
                    }
                    .foregroundColor(DS.Colors.accent)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(
                        Capsule()
                            .fill(DS.Colors.accent.opacity(0.1))
                    )
                }
                .buttonStyle(.plain)
                .pointerCursor()
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 2)
                
                Text("Paste this config into ~/.config/claude/config.json or Cursor's MCP Settings to link your other agents.")
                    .font(.system(size: 9))
                    .foregroundColor(DS.Colors.textTertiary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 1)
            }
        }
    }

    // MARK: - Footer

    private var footerSection: some View {
        HStack {
            Button(action: {
                NSApp.terminate(nil)
            }) {
                HStack(spacing: 6) {
                    Image(systemName: "power")
                        .font(.system(size: 11, weight: .medium))
                    Text("Quit Clicky")
                        .font(.system(size: 12, weight: .medium))
                }
                .foregroundColor(DS.Colors.textTertiary)
            }
            .buttonStyle(.plain)
            .pointerCursor()

            if companionManager.hasCompletedOnboarding {
                Spacer()

                Button(action: {
                    companionManager.replayOnboarding()
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "play.circle")
                            .font(.system(size: 11, weight: .medium))
                        Text("Watch Onboarding Again")
                            .font(.system(size: 12, weight: .medium))
                    }
                    .foregroundColor(DS.Colors.textTertiary)
                }
                .buttonStyle(.plain)
                .pointerCursor()
            }
        }
    }

    // MARK: - Visual Helpers

    private var panelBackground: some View {
        RoundedRectangle(cornerRadius: 12, style: .continuous)
            .fill(DS.Colors.background)
            .shadow(color: Color.black.opacity(0.5), radius: 20, x: 0, y: 10)
            .shadow(color: Color.black.opacity(0.3), radius: 4, x: 0, y: 2)
    }

    private var statusDotColor: Color {
        switch companionManager.voiceState {
        case .idle:
            return DS.Colors.success
        case .listening:
            return Color.red
        case .processing:
            return DS.Colors.accent
        case .responding:
            return DS.Colors.blue400
        }
    }

    private var statusText: String {
        switch companionManager.voiceState {
        case .idle:
            return "Ready"
        case .listening:
            return "Listening..."
        case .processing:
            return "Thinking..."
        case .responding:
            return "Speaking..."
        }
    }

}
