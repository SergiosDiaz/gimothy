import AVFoundation
import Foundation

/// Reproduce los archivos de audio del bundle del Watch app.
/// Los .mp3 deben estar añadidos directamente al target "GimothyWatch Watch App"
/// (no a Flutter Runner) para que estén disponibles en el bundle de watchOS.
final class SoundManager {

    private var player: AVAudioPlayer?

    init() {
        configureAudioSession()
    }

    // MARK: - API pública

    func play(sound: String) {
        guard let url = Bundle.main.url(forResource: sound, withExtension: "mp3") else {
            print("[SoundManager] Archivo no encontrado: \(sound).mp3")
            return
        }

        do {
            // Reutiliza el player si ya existe, así evitamos allocations en hot-path
            player = try AVAudioPlayer(contentsOf: url)
            player?.prepareToPlay()
            player?.play()
        } catch {
            print("[SoundManager] Error al reproducir '\(sound)': \(error.localizedDescription)")
        }
    }

    // MARK: - Privado

    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(
                .playback,
                mode: .default,
                options: [.mixWithOthers]
            )
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("[SoundManager] Audio session error: \(error.localizedDescription)")
        }
    }
}
