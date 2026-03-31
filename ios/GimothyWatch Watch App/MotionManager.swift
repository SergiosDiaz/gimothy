import CoreMotion
import Combine
import Foundation

/// Detecta movimientos bruscos con el acelerómetro del Apple Watch
/// y reproduce un sonido cuya intensidad escala con la del golpe.
final class MotionManager: ObservableObject {

    // MARK: - Estado publicado
    @Published private(set) var isMonitoring = false
    @Published private(set) var lastPlayedSound: String?

    // MARK: - Privado
    private let cmManager = CMMotionManager()
    private let soundManager = SoundManager()

    /// Intervalo de muestreo (20 ms → 50 Hz)
    private let sampleInterval: TimeInterval = 0.02

    /// Umbral mínimo de aceleración para considerar un golpe (en g)
    private let shakeThreshold: Double = 1.8

    /// Tiempo mínimo entre dos golpes consecutivos
    private let cooldown: TimeInterval = 1.2

    private var lastShakeDate: Date = .distantPast

    // MARK: - API pública

    func startMonitoring() {
        guard cmManager.isAccelerometerAvailable, !isMonitoring else { return }

        cmManager.accelerometerUpdateInterval = sampleInterval
        cmManager.startAccelerometerUpdates(to: .main) { [weak self] data, _ in
            guard let self, let data else { return }
            self.evaluate(acceleration: data.acceleration)
        }
        isMonitoring = true
    }

    func stopMonitoring() {
        cmManager.stopAccelerometerUpdates()
        isMonitoring = false
    }

    // MARK: - Lógica de detección

    private func evaluate(acceleration: CMAcceleration) {
        // Magnitud total del vector de aceleración
        let magnitude = sqrt(
            acceleration.x * acceleration.x +
            acceleration.y * acceleration.y +
            acceleration.z * acceleration.z
        )

        // Exceso sobre la gravedad (≈ 1 g en reposo)
        let excess = magnitude - 1.0
        guard excess > shakeThreshold else { return }

        let now = Date()
        guard now.timeIntervalSince(lastShakeDate) > cooldown else { return }
        lastShakeDate = now

        let sound = classify(excess: excess)
        lastPlayedSound = sound
        soundManager.play(sound: sound)
    }

    /// Mapea la intensidad del golpe a uno de los cinco sonidos de Gimothy
    private func classify(excess: Double) -> String {
        switch excess {
        case ..<2.2:  return "timido"
        case ..<3.0:  return "suave"
        case ..<4.2:  return "intenso"
        case ..<5.5:  return "robusto"
        default:      return "dramatico"
        }
    }
}
