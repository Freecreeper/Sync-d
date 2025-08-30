import AVFoundation

class SoundManager {
    static let shared = SoundManager()
    
    private var backgroundPlayer: AVAudioPlayer?
    private var soundPlayers: [AVAudioPlayer] = []
    
    private init() {}
    
    func playBackgroundMusic(filename: String) {
        guard let url = Bundle.main.url(forResource: filename, withExtension: nil) else { return }
        
        do {
            backgroundPlayer = try AVAudioPlayer(contentsOf: url)
            backgroundPlayer?.numberOfLoops = -1
            backgroundPlayer?.volume = 0.5
            backgroundPlayer?.play()
        } catch {
            print("Error playing background music: \(error)")
        }
    }
    
    func playSoundEffect(filename: String) {
        guard let url = Bundle.main.url(forResource: filename, withExtension: nil) else { return }
        
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.volume = 0.7
            player.play()
            soundPlayers.append(player)
        } catch {
            print("Error playing sound effect: \(error)")
        }
    }
    
    func stopBackgroundMusic() {
        backgroundPlayer?.stop()
    }
}
