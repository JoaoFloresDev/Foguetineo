//  ViewController.swift
//  Rocket

//  Created by Joao Flores on 31/05/19.
//  Copyright © 2019 Joao Flores. All rights reserved.

import UIKit
import GameKit
import AVFoundation

class ViewController: UIViewController,GKGameCenterControllerDelegate {
    
    var audioEnd1:    AVAudioPlayer!
    var audioEnd2:  AVAudioPlayer!
    var audioPlayer1: AVAudioPlayer!
    var audioPlayer2: AVAudioPlayer!
    var audioPlayer3: AVAudioPlayer!
    var audioPlayerActual: AVAudioPlayer!
    var audioRocket: AVAudioPlayer!
    var audioBox:    AVAudioPlayer!
    var atualRotationGesture: CGFloat = CGFloat(0)
    var points: Int = 0
    var timerRocketRun: Timer!
    var timerSoundBackground: Timer!
    var timerTutotial: Timer!
    var timerAlphaMenu: Timer!
    var TutorialRotate = true
    var TutorialTap = true
    var soundActive = true
    var inGame = true
    var pause = false
    var rocket:RocketClass!
    var box:BoxClass!
    var alfa: Double = 0
    var gameMode: String = "White"
    
    var velAnimateArrow = 0
    var distAnimateArrow = 0
    // game center
    
    var gcEnabled = Bool() // Check if the user has Game Center enabled
    var gcDefaultLeaderBoard = String() // Check the default leaderboardID
    
    var score = 0
    
    // IMPORTANT: replace the red string below with your own Leaderboard ID (the one you've set in iTunes Connect)
    var LEADERBOARD_ID = "com.joaoFlores.Foguetinho.Ranking"//"com.score.foguetinho"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Call the GC authentication controller
        authenticateLocalPlayer()
        
        labelBestScore.text = UserDefaults.standard.string(forKey: "BS") ?? "0"
        labelScore.text = String(self.points)
        
        rocket = RocketClass(rocketImg: self.rocketImg, backGroundImg: self.backGroundImg)
        box = BoxClass(boxImg: self.boxImg, labelBox: self.labelBox, backGroundImg: self.backGroundImg)
        
        setupSounds()
        showMenu(visible: 0)
        initTutorial()
        
        backGroundImg.layer.zPosition = -10
        gestureRotateImg.layer.zPosition = -9
        gestureTapImg.layer.zPosition = -9
        labelTutorial.layer.zPosition = -9
        
        let rotate = UIRotationGestureRecognizer(target: self, action: #selector(ViewController.rotate(_:)))
        self.view.addGestureRecognizer(rotate)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(ViewController.tap(_:)))
        self.view.addGestureRecognizer(tap)
        
        addScoreAndSubmitToGC()
        
        velAnimateArrow = 10
        distAnimateArrow = 0
        var timertest = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.loop), userInfo: nil, repeats: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
    }
    
    @IBOutlet weak var labelTutorial: UILabel!
    @IBOutlet weak var gestureTapImg: UIImageView!
    @IBOutlet weak var gestureRotateImg: UIImageView!
    @IBOutlet weak var rocketImg: UIImageView!
    @IBOutlet weak var boxImg: UIImageView!
    @IBOutlet weak var backGroundImg: UIImageView!
    @IBOutlet weak var labelBox: UILabel!
    @IBOutlet weak var menu: UIImageView!
    @IBOutlet weak var pauseImg: UIButton!
    @IBOutlet weak var replay: UIButton!
    @IBOutlet weak var sound: UIButton!
    @IBOutlet weak var labelFixScore: UILabel!
    @IBOutlet weak var labelFixBestScore: UILabel!
    @IBOutlet weak var labelScore: UILabel!
    @IBOutlet weak var labelBestScore: UILabel!
    @IBOutlet weak var information: UIButton!
    @IBOutlet weak var changeRocketImg: UIButton!
    @IBOutlet var changeRocketNext: [UIButton]!
    
    @IBAction func changeRocket(_ sender: UIButton) {
        if(changeRocketNext[0].alpha == 1) {
            rocket.stopAnimation()
            
            if(gameMode == "White") {
                rocketImg.image = (UIImage(named: "rocketPink1")!)
                
                let image = UIImage(named: "ChangeRocketPink")
                changeRocketImg.setImage(image, for: .normal)
                
                gameMode = "Pink"
            } else {
                rocketImg.image = (UIImage(named: "rocketWhite1")!)
                
                let image = UIImage(named: "ChangeRocketWhite")
                changeRocketImg.setImage(image, for: .normal)
                
                gameMode = "White"
            }
        }
    }
    
    @IBAction func unwindToGame (for segue: UIStoryboardSegue) {}
    
    @IBAction func playPause(_ sender: Any) {
        if(!pause && inGame) {
            pauseGame()
            rocket.stopAnimation()
            
        } else if(pause) {
            returnToGame()
        }
    }
    
    @IBAction func information(_ sender: Any) {
        
        self.performSegue(withIdentifier: "goInformations", sender: nil)
    }

    @IBAction func sound(_ sender: Any) {
        
        if(soundActive) {
            desativeSound()
        }
        else{
            activeSound()
        }
    }
    
    @IBAction func replay(_ sender: Any) {
        
        if(!inGame && !pause) { // jogo estava no menu e jogador iniciou nova partida
            self.timerAlphaMenu.invalidate()
            TutorialRotate = true
            TutorialTap = true
            inGame = true
            initTutorial()
            showMenu(visible: 0)
            
        } else if(pause) {
            returnToGame()
        }
    }
    
    fileprivate func tap() {
        if(!pause){
            if(TutorialTap && !TutorialRotate) {
                TutorialEnding()
                runRocket()
                
            } else if(!TutorialRotate && !TutorialTap && !rocket.moving && inGame) {
                runRocket()
            }
            
            if(rocket.moving) {
                self.rocket.stopAnimation()
                if(gameMode == "White") {
                    rocketImg.image = (UIImage(named: "rocketWhiteTap")!)
                }
                
                else {
                    rocketImg.image = (UIImage(named: "rocketPinkTap")!)
                }
                
                delayWithSeconds(0.3) {
                    self.rocket.initAnimation(mode: self.gameMode)
                }
            }
            
            self.rocket.atualizeDirection()
            
            if(soundActive && inGame){ audioRocket.play() }
        }
    }
    
    @objc func tap (_ gesture:UITapGestureRecognizer) {
        if(!TutorialRotate && !TutorialTap && !rocket.moving && inGame && !pause && gameMode == "White" ) || (gameMode == "Pink" && !pause && !TutorialRotate) {
            if(TutorialTap) {
                TutorialEnding()
            }
            tap()
        }
    }
    
    @objc func rotate (_ gesture:UIRotationGestureRecognizer) {
        if(!pause){
            if(TutorialRotate) {
                
                self.gestureRotateImg.transform = self.gestureRotateImg.transform.rotated(by: CGFloat(-atualRotationGesture))
                atualRotationGesture = CGFloat(0)
                
                TutorialTapInit()
            }
            
            let rotation = gesture.rotation * 6
            self.rocket.rotate(rotation: rotation)
            gesture.rotation = 0
        }
        
        if gesture.state == .ended {
            if((gameMode == "White" && !pause)) {
                self.tap()
            }
        }
    }
    
//    Funções de movimento do foguete
    @objc func checkRocket() {
        self.rocket.fly()
        self.colisionCheck()
    }
    
    func runRocket() {
        rocket.moving = true
        rocket.initAnimation(mode: gameMode)
        
        self.timerRocketRun = Timer.scheduledTimer(timeInterval: 0.005, target: self, selector: #selector(self.checkRocket), userInfo: nil, repeats: true)
        
    }
    
    func colisionCheck() {
        
        let rocketMinX = self.rocketImg.center.x - rocketImg.frame.width/3
        let rocketMaxX = self.rocketImg.center.x + rocketImg.frame.width/3
        let rocketMinY = self.rocketImg.center.y - rocketImg.frame.height/2.5
        let rocketMaxY = self.rocketImg.center.y + rocketImg.frame.height/2.5
    
        let boxMinX = self.boxImg.center.x - boxImg.frame.width/3
        let boxMaxX = self.boxImg.center.x + boxImg.frame.width/3
        let boxMinY = self.boxImg.center.y - boxImg.frame.height/3
        let boxMaxY = self.boxImg.center.y + boxImg.frame.height/3
    
        let bgMinX = self.backGroundImg.center.x - backGroundImg.frame.width/2 - rocketImg.frame.width/5
        let bgMaxX = self.backGroundImg.center.x + backGroundImg.frame.width/2 + rocketImg.frame.width/5
        let bgMinY = self.backGroundImg.center.y - backGroundImg.frame.height/2 - rocketImg.frame.height/5
        let bgMaxY = self.backGroundImg.center.y + backGroundImg.frame.height/2 + rocketImg.frame.height/5
    
        // foguete pegou alvo
        if (((rocketMinX >= boxMinX && rocketMinX <= boxMaxX) || (rocketMaxX >= boxMinX && rocketMaxX <= boxMaxX))
        && ((rocketMinY >= boxMinY && rocketMinY <= boxMaxY) || (rocketMaxY >= boxMinY && rocketMaxY <= boxMaxY))) {
    
        if(soundActive){ audioBox.play() }
            points += 1
            
            addScoreAndSubmitToGC()
            
            box.atualizeLabelBox(points: points)
            box.atualizePositionBox(sizeScreen: self.backGroundImg.frame.size)
            box.atualizeColorBox()
            rocket.atualizeVelocity(points: self.points)
        }
    
        // foguete na borda da tela
        else if ( rocketMinX <= bgMinX || rocketMaxX >= bgMaxX || rocketMinY <= bgMinY || rocketMaxY >= bgMaxY ) {
            
        if(soundActive){
            let rand = Int.random(in: 0 ..< 2)
            switch rand {
                case 0:
                    audioEnd1.play()
                
                default:
                    audioEnd2.play()
            }
            }
            finishGame()
        }
    }
    
//  estados de jogo
    func returnToGame() {
        
        rocket.initAnimation(mode: gameMode)
        
        self.timerAlphaMenu.invalidate()
        showMenu(visible: 0)
        pause = false
        
        let image = UIImage(named: "pause-button")
        pauseImg.setImage(image, for: .normal)
        
        if(rocket.moving) {
            runRocket()
        }
    }
    
    func pauseGame() {
        if(rocket.moving) {
            timerRocketRun.invalidate()
        }
        
        let image = UIImage(named: "play-button")
        pauseImg.setImage(image, for: .normal)
        
        pause = true
        
        labelScore.text = String(points)
        menuEffectShow()
    }
    
    @objc func dismisMenuEffect() {
        self.showMenu(visible: CGFloat(self.alfa))
        self.alfa += 0.1
        
        if(alfa >= 1) {
            self.timerAlphaMenu.invalidate()
        }
    }
    
    func menuEffectShow(){
        self.alfa = 0.1
    
        self.timerAlphaMenu = Timer.scheduledTimer(timeInterval: 0.04, target: self, selector: #selector(self.dismisMenuEffect), userInfo: nil, repeats: true)
    }
    
    func showMenu(visible: CGFloat) {
        
        changeRocketImg.alpha = visible
        changeRocketNext[0].alpha = visible
        changeRocketNext[1].alpha = visible
        menu.alpha = visible
        sound.alpha = visible
        replay.alpha = visible
        labelFixBestScore.alpha = visible
        labelFixScore.alpha = visible
        labelScore.alpha = visible
        labelBestScore.alpha = visible
        information.alpha = visible
    }
    
    func finishGame() {
        
        inGame = false
        self.rocket.moving = false
        rocket.resetParameters()
        box.resetParameters()
        timerRocketRun.invalidate()
        
        labelScore.text = String(self.points)
        self.atualizeBestScore()
        
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        
        let distX = self.rocket.rocketImg.center.x - self.backGroundImg.center.x
        let distY = self.rocket.rocketImg.center.y - self.backGroundImg.center.y*2 + self.rocketImg.frame.height*1.5
        let duration = sqrt(distX*distX + distY*distY)/400
        
        self.rocket.flyInitPosition(duration: TimeInterval(duration))

        delayWithSeconds(TimeInterval(duration + 0.5)) {
            self.boxImg.image = (UIImage(named: "disc1")!)
            self.labelBox.font = UIFont(name:"Futura", size: 30)
            self.box.atualizeLabelBox(points: self.points)
            
            self.menuEffectShow()
        }
    }
    
    @objc func loop(){
        
//        distAnimateArrow += 1
//
//        if(distAnimateArrow < 80) {
//
//            changeRocketNext[1].center.x += 0.1
//            changeRocketNext[0].center.x -= 0.1
//
//        } else {
//
//            changeRocketNext[1].center.x -= 0.1
//            changeRocketNext[0].center.x += 0.1
//
//            if !(distAnimateArrow < 160) {
//                distAnimateArrow = 0
//            }
//        }
        
        UIView.animate(withDuration: 1, delay: 0, options: UIView.AnimationOptions.curveLinear, animations: {
            
            if(self.distAnimateArrow == 0) {
                
                self.changeRocketNext[1].center.x -= 10
                self.changeRocketNext[0].center.x += 10
                
                self.distAnimateArrow = 1
            } else {
                self.changeRocketNext[0].center.x -= 10
                self.changeRocketNext[1].center.x += 10
                
                self.distAnimateArrow = 0
            }
            
        }, completion: nil)
        
    }
    
//    best score
    func atualizeBestScore() {
        
        if(!UserDefaults.standard.bool(forKey: "bestScore")) {
            UserDefaults.standard.set(true, forKey: "bestScore")
            UserDefaults.standard.set (0, forKey: "BS")
        }
        
        let aux = Int(UserDefaults.standard.string(forKey: "BS") ?? "0")
        if(points > aux!)
        {
            UserDefaults.standard.set (points, forKey: "BS")
        }
        
        labelBestScore.text = UserDefaults.standard.string(forKey: "BS") ?? "0"
        
        points = 0
        self.box.resetParameters()
        labelBox.text = String(Int(points))
    }
    
//    Funções do som
    func desativeSound() {
        let image = UIImage(named: "mute")
        sound.setImage(image, for: .normal)
        soundActive = false
        audioPlayerActual.volume = 0
    }
    
    func activeSound() {
        let image = UIImage(named: "sound")
        sound.setImage(image, for: .normal)
        soundActive = true
        audioPlayerActual.volume = 0.8
    }
    
    
    @objc func soundBg() {
        self.audioPlayerActual.volume = 0
        if( self.audioPlayerActual == self.audioPlayer1)
        {
            self.audioPlayerActual = self.audioPlayer2
            self.audioPlayerActual.volume = 0.8
        }
            
        else if(self.audioPlayerActual == self.audioPlayer2)
        {
            self.audioPlayerActual = self.audioPlayer3
            self.audioPlayerActual.volume = 0.8
        }
        else
        {
            self.audioPlayerActual = self.audioPlayer1
            self.audioPlayerActual.volume = 0.8
        }
        self.audioPlayerActual.play()
        
        if(!self.soundActive)
        {
            self.audioPlayerActual.volume = 0
        }
    }
    
    func setupSounds() {
        do{
            let path = Bundle.main.path(forResource:"Dark_Tranquility" , ofType: "mp3")!
            let url = URL(fileURLWithPath: path)
            audioPlayer1 = try AVAudioPlayer(contentsOf: url)
            audioPlayer1.prepareToPlay()
        }
        catch{
            print(error)
        }
        
        
        do{
            let path = Bundle.main.path(forResource:"Chosen_One" , ofType: "mp3")!
            let url = URL(fileURLWithPath: path)
            audioPlayer2 = try AVAudioPlayer(contentsOf: url)
            audioPlayer2.prepareToPlay()
        }
        catch{
            print(error)
        }
        
        do{
            let path = Bundle.main.path(forResource:"A_Fever" , ofType: "mp3")!
            let url = URL(fileURLWithPath: path)
            audioPlayer3 = try AVAudioPlayer(contentsOf: url)
            audioPlayer3.volume = 0.3
            audioPlayer3.prepareToPlay()
        }
        catch{
            print(error)
        }
        
        audioPlayerActual = audioPlayer1
        audioPlayerActual.volume = 0.8
        audioPlayerActual.play()
        
        self.timerSoundBackground = Timer.scheduledTimer(timeInterval: 170, target: self, selector: #selector(self.soundBg), userInfo: nil, repeats: true)
        
        do{
            let path = Bundle.main.path(forResource:"disparoFoguete" , ofType: "mp3")!
            let url = URL(fileURLWithPath: path)
            audioRocket = try AVAudioPlayer(contentsOf: url)
            audioRocket.volume = 0.3
            audioRocket.prepareToPlay()
        }
        catch{
            print(error)
        }
        
        do{
            let path = Bundle.main.path(forResource:"Air_Woosh_Underwater" , ofType: "mp3")!
            let url = URL(fileURLWithPath: path)
            audioBox = try AVAudioPlayer(contentsOf: url)
            audioBox.volume = 1.5
            audioBox.prepareToPlay()
        }
        catch{
            print(error)
        }
        
        do{
            let path = Bundle.main.path(forResource:"EndSound1" , ofType: "mp3")!
            let url = URL(fileURLWithPath: path)
            audioEnd1 = try AVAudioPlayer(contentsOf: url)
            audioEnd1.volume = 0.2
            audioEnd1.prepareToPlay()
        }
        catch{
            print(error)
        }
        
        do{
            let path = Bundle.main.path(forResource:"EndSound2" , ofType: "mp3")!
            let url = URL(fileURLWithPath: path)
            audioEnd2 = try AVAudioPlayer(contentsOf: url)
            audioEnd2.volume = 0.2
            audioEnd2.prepareToPlay()
        }
        catch{
            print(error)
        }
    }
    
// MARK: - Tutorial Functions
    
    func initTutorial(){
        gestureRotateImg.alpha = 0.7
        gestureTapImg.alpha = 0
        labelTutorial.alpha = 1
        self.gestureRotateImg.transform = self.gestureRotateImg.transform.rotated(by: CGFloat(Double.pi/20))
        atualRotationGesture += CGFloat(Double.pi/20)
        labelTutorial.text = "Rotate to aim"
        
        self.timerTutotial = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.animateGestureRotate), userInfo: nil, repeats: true)
    }
    
    @objc func animateGestureRotate() {
        if(atualRotationGesture < CGFloat(Double.pi/10))
        {
            self.gestureRotateImg.transform = self.gestureRotateImg.transform.rotated(by: CGFloat(Double.pi/10))
            atualRotationGesture += CGFloat(Double.pi/10)
        }
            
        else
        {
            self.gestureRotateImg.transform = self.gestureRotateImg.transform.rotated(by: CGFloat(-Double.pi/10))
            atualRotationGesture -= CGFloat(Double.pi/10)
        }
    }
    
    @objc func animateGestureTap() {
        if(gestureTapImg.image == (UIImage(named: "twoTapImg1"))) { gestureTapImg.image = (UIImage(named: "twoTapImg2")) }
        else if (gestureTapImg.image == (UIImage(named: "twoTapImg2"))) { gestureTapImg.image = (UIImage(named: "twoTapImg3")) }
        else { gestureTapImg.image = (UIImage(named: "twoTapImg1")) }
    }
    
    func TutorialTapInit() {
        gestureRotateImg.alpha = 0
        gestureTapImg.alpha = 0.7
        timerTutotial.invalidate()
        
        self.timerTutotial = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.animateGestureTap), userInfo: nil, repeats: true)
        
        TutorialRotate = false
        
        labelTutorial.text = "Tap to fly"
        if(gameMode == "White") {
            TutorialEnding()
        }
    }
    
    func TutorialEnding() {
        
        gestureTapImg.alpha = 0
        timerTutotial.invalidate()
        TutorialTap = false
        
        labelTutorial.alpha = 0
    }
    
//    Funções de utilidades
    func delayWithSeconds(_ seconds: Double, completion: @escaping () -> ()) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            completion()
        }
    }
    
    // MARK: - AUTHENTICATE LOCAL PLAYER
    func authenticateLocalPlayer() {
        let localPlayer: GKLocalPlayer = GKLocalPlayer.local
        
        localPlayer.authenticateHandler = {(ViewController, error) -> Void in
            if((ViewController) != nil) {
                // 1 Show login if player is not logged in
                self.present(ViewController!, animated: true, completion: nil)
            } else if (localPlayer.isAuthenticated) {
                // 2 Player is already euthenticated & logged in, load game center
                self.gcEnabled = true
                
                // Get the default leaderboard ID
                localPlayer.loadDefaultLeaderboardIdentifier(completionHandler: { (leaderboardIdentifer, error) in
                    if error != nil { print(error)
                    } else { self.gcDefaultLeaderBoard = leaderboardIdentifer ?? self.LEADERBOARD_ID}
                })
                
            } else {
                // 3 Game center is not enabled on the users device
                self.gcEnabled = false
                print("Local player could not be authenticated!")
                print(error)
            }
        }
    }
    
    // MARK: - ADD 10 POINTS TO THE SCORE AND SUBMIT THE UPDATED SCORE TO GAME CENTER
    func addScoreAndSubmitToGC() {
        // Add 10 points to current score
        
        // Submit score to GC leaderboard
        let bestScoreInt = GKScore(leaderboardIdentifier: LEADERBOARD_ID)
        bestScoreInt.value = Int64(points)
        GKScore.report([bestScoreInt]) { (error) in
            if error != nil {
                print(error!.localizedDescription)
            } else {
                print("Best Score submitted to your Leaderboard!")
            }
        }
    }
    
    // Delegate to dismiss the GC controller
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }

    @IBAction func checkGCLeaderboard(_ sender: AnyObject) {
        let gcVC = GKGameCenterViewController()
        gcVC.gameCenterDelegate = self
        gcVC.viewState = .leaderboards
        gcVC.leaderboardIdentifier = LEADERBOARD_ID
        present(gcVC, animated: true, completion: nil)
    }
}
