import SwiftUI

struct ContentView: View {
    @StateObject private var motionManager = MotionManager()
    @State private var gimothyScale: CGFloat = 1.0
    @State private var showSoundLabel = false

    // Emoji que reacciona según el tipo de sonido
    private var reactionEmoji: String {
        switch motionManager.lastPlayedSound {
        case "timido":    return "😳"
        case "suave":     return "😌"
        case "intenso":   return "😤"
        case "robusto":   return "💪"
        case "dramatico": return "😱"
        default:          return "😶"
        }
    }

    var body: some View {
        VStack(spacing: 6) {
            Text(reactionEmoji)
                .font(.system(size: 44))
                .scaleEffect(gimothyScale)
                .animation(
                    .spring(response: 0.25, dampingFraction: 0.4),
                    value: gimothyScale
                )

            Text("Gimothy")
                .font(.headline)
                .fontWeight(.bold)

            if let sound = motionManager.lastPlayedSound, showSoundLabel {
                Text("« \(sound) »")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .transition(.opacity.combined(with: .scale(scale: 0.8)))
            }

            Spacer(minLength: 4)

            Button {
                if motionManager.isMonitoring {
                    motionManager.stopMonitoring()
                } else {
                    motionManager.startMonitoring()
                }
            } label: {
                Label(
                    motionManager.isMonitoring ? "Detener" : "¡Activar!",
                    systemImage: motionManager.isMonitoring ? "stop.fill" : "waveform"
                )
            }
            .tint(motionManager.isMonitoring ? .red : .green)
            .controlSize(.large)
        }
        .padding(.horizontal, 4)
        .onChange(of: motionManager.lastPlayedSound) { _ in
            triggerReactionAnimation()
        }
    }

    private func triggerReactionAnimation() {
        withAnimation { showSoundLabel = true }
        gimothyScale = 1.45
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            gimothyScale = 1.0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation { showSoundLabel = false }
        }
    }
}

#Preview {
    ContentView()
}
