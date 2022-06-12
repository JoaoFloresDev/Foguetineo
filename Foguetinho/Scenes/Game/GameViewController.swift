//  GameViewController.swift
//  Rocket

//  Created by Joao Flores on 31/05/19.
//  Copyright © 2019 Joao Flores. All rights reserved.

import UIKit
import GameKit
import AVFoundation
import StoreKit
import GoogleMobileAds

class GameViewController: UIViewController,GKGameCenterControllerDelegate, GADInterstitialDelegate {
    
    //    ADS
    var interstitial: GADInterstitial!
    
    func createAndLoadInterstitial() -> GADInterstitial {
        let interstitial = GADInterstitial(adUnitID: "ca-app-pub-8858389345934911/1816921732")
        interstitial.delegate = self
        interstitial.load(GADRequest())
        return interstitial
    }
    
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        interstitial = createAndLoadInterstitial()
    }
    
    var tutorialView: GestureAnimationView = {
        let myView = Bundle.loadView(fromNib: "GestureAnimationView", withType: GestureAnimationView.self)
        myView.startTutorial()
        return myView
    }()
    
    var showAdsIn3games = 0
    var audioEnd1:    AVAudioPlayer!
    var audioEnd2:  AVAudioPlayer!
    var audioPlayer1: AVAudioPlayer!
    var audioPlayer2: AVAudioPlayer!
    var audioPlayer3: AVAudioPlayer!
    var audioPlayerActual: AVAudioPlayer!
    var audioRocket: AVAudioPlayer!
    var audioBox:    AVAudioPlayer!
    var points: Int = 0
    var timerRocketRun: Timer!
    var timerSoundBackground: Timer!
    var soundActive = true
    var inGame = true
    var pause = false
    var rocket:RocketClass!
    var box:BoxClass!
    var rocketMode: RocketMode = .white
    var velAnimateArrow = 0
    var distAnimateArrow = 0
    
    // game center
    var gcEnabled = Bool() // Check if the user has Game Center enabled
    var gcDefaultLeaderBoard = String() // Check the default leaderboardID
    
    var score = 0
    
    // IMPORTANT: replace the red string below with your own Leaderboard ID (the one you've set in iTunes Connect)
    var LEADERBOARD_ID = "com.joaoFlores.Foguetinho.Ranking"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set Background
        let random = Int.random(in: 0 ..< 2)
        backGroundImg.image = UIImage(named: "Background\(random)")
        
        // ADS
        interstitial = GADInterstitial(adUnitID: "ca-app-pub-8858389345934911/1816921732")
        let request = GADRequest()
        interstitial.load(request)
        interstitial.delegate = self
        
        interstitial = createAndLoadInterstitial()
        
        // Call the GC authentication controller
        authenticateLocalPlayer()
        
        rocket = RocketClass(rocketImg: self.rocketImg, backGroundImg: self.backGroundImg)
        box = BoxClass(boxImg: self.boxImg, labelBox: self.labelBox, backGroundImg: self.backGroundImg)
        
        setupSounds()
        
        backGroundImg.layer.zPosition = -11
        rocketImg.layer.zPosition = -10
        boxImg.layer.zPosition = -10
        let rotate = UIRotationGestureRecognizer(target: self, action: #selector(GameViewController.rotate(_:)))
        self.view.addGestureRecognizer(rotate)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(GameViewController.tap(_:)))
        self.view.addGestureRecognizer(tap)
        
        addScoreAndSubmitToGC()
        
        velAnimateArrow = 10
        distAnimateArrow = 0
        
        self.rocket.flyInitPosition(duration: TimeInterval(0.5))
        
        view.addSubview(tutorialView)
        tutorialView.translatesAutoresizingMaskIntoConstraints = false
        let horizontalConstraint = tutorialView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        let verticalConstraint = tutorialView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        let leftConstraint = tutorialView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20)
        let rightConstraint = tutorialView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        let heightConstraint = tutorialView.heightAnchor.constraint(equalTo: tutorialView.widthAnchor)
        view.addConstraints([horizontalConstraint, verticalConstraint, leftConstraint, rightConstraint,heightConstraint])
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == SegueIdentifier.showMenu.rawValue) {
            if let nextViewController = segue.destination as? MenuViewController {
                nextViewController.dataSource = self
                nextViewController.delegate = self
                nextViewController.modalPresentationStyle = .overCurrentContext
                    }
        }
    }
    
    @IBOutlet weak var rocketImg: UIImageView!
    @IBOutlet weak var boxImg: UIImageView!
    @IBOutlet weak var backGroundImg: UIImageView!
    
    @IBOutlet weak var labelBox: UILabel!
    @IBOutlet weak var pauseImg: UIButton!
    
    @IBAction func playPause(_ sender: Any) {
        if(!pause && inGame) {
            pauseGame()
            rocket.stopAnimation()
            rateApp()
        }
    }
    
    private func replayUpdateState() {
        if(!inGame && !pause) { // jogo estava no menu e jogador iniciou nova partida
            inGame = true
            tutorialView.startTutorial()
        } else if(pause) {
            returnToGame()
        }
    }
    
    func rateApp() {
        if #available(iOS 10.3, *) {
            SKStoreReviewController.requestReview()
        }
    }
    
    func tap() {
        if(!pause){
            if(!rocket.moving && inGame) {
                runRocket()
            }
            
            if(rocket.moving) {
                self.rocket.stopAnimation()
                if(rocketMode == .white) {
                    rocketImg.image = (UIImage(named: ImageName.rocketWhiteTap.rawValue)!)
                } else {
                    rocketImg.image = (UIImage(named: ImageName.rocketPinkTap.rawValue)!)
                }
                
                delayWithSeconds(0.3) {
                    self.rocket.initAnimation(mode: self.rocketMode)
                }
            }
            
            self.rocket.atualizeDirection()
            if(soundActive && inGame){ audioRocket.play() }
        }
    }
    
    @objc func tap (_ gesture:UITapGestureRecognizer) {
        if(!rocket.moving && inGame && !pause && rocketMode == .white) || (rocketMode == .pink && !pause) {
            tap()
        }
    }
    
    @objc func rotate (_ gesture:UIRotationGestureRecognizer) {
        if !pause {
            let rotation = gesture.rotation * 6
            self.rocket.rotate(rotation: rotation)
            gesture.rotation = 0
        }
        
        if gesture.state == .ended {
            if rocketMode == .white {
                tutorialView.endTutorial()
                self.tap()
            } else {
                tutorialView.endTutorial()
            }
//            if((rocketMode == .white && !pause)) {
//                self.tap()
//            } else {
//
//            }
        }
    }
    
    //    Funções de movimento do foguete
    @objc func checkRocket() {
        self.rocket.fly()
        self.colisionCheck()
    }
    
    func runRocket() {
        rocket.moving = true
        rocket.initAnimation(mode: rocketMode)
        self.timerRocketRun = Timer.scheduledTimer(timeInterval: 0.005, target: self, selector: #selector(self.checkRocket), userInfo: nil, repeats: true)
        inGame = true
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
        rocket.initAnimation(mode: rocketMode)
        pause = false
        
        let image = UIImage(named: ImageName.pauseButton.rawValue)
        pauseImg.setImage(image, for: .normal)
        
        if (rocket.moving) {
            runRocket()
        }
    }
    
    func pauseGame() {
        if (rocket.moving) {
            timerRocketRun.invalidate()
        }
        
        let image = UIImage(named: ImageName.playButton.rawValue)
        pauseImg.setImage(image, for: .normal)
        pause = true
        self.performSegue(withIdentifier: SegueIdentifier.showMenu.rawValue, sender: nil)
    }
    
    func finishGame() {
        inGame = false
        self.rocket.moving = false
        rocket.resetParameters()
        box.resetParameters()
        timerRocketRun.invalidate()
        let distX = self.rocket.rocketImg.center.x - self.backGroundImg.center.x
        let distY = self.rocket.rocketImg.center.y - self.backGroundImg.center.y*2 + self.rocketImg.frame.height*1.5
        var duration = sqrt(distX*distX + distY*distY)/500
        duration = 0.5
        self.rocket.flyInitPosition(duration: TimeInterval(duration))
        
        self.atualizeBestScore()
        
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        
        delayWithSeconds(TimeInterval(duration + 0.5)) {
            self.boxImg.image = (UIImage(named: ImageName.disc1.rawValue)!)
            self.labelBox.font = UIFont(name:"Futura", size: 30)
            self.box.atualizeLabelBox(points: self.points)
            
            self.performSegue(withIdentifier: SegueIdentifier.showMenu.rawValue, sender: nil)
        }
        
        if (showAdsIn3games >= 3) {
            if interstitial.isReady {
                interstitial.present(fromRootViewController: self)
            }
            showAdsIn3games = 0
        } else {
            showAdsIn3games += 1
        }
    }
    
    @objc func loop(){
        
        UIView.animate(withDuration: 1, delay: 0, options: UIView.AnimationOptions.curveLinear, animations: {
            
            if(self.distAnimateArrow == 0) {
                self.distAnimateArrow = 1
            } else {
                self.distAnimateArrow = 0
            }
            
        }, completion: nil)
        
    }
    
    //    best score
    func atualizeBestScore() {
        if !BoolDefault.bestScore.getValue() {
            BoolDefault.bestScore.setValue(value: true)
            IntDefault.BS.setValue(value: 0)
        }
        
        let aux = IntDefault.BS.getValue()
        if(points > aux) {
            IntDefault.BS.setValue(value: points)
        }
        
        points = 0
        self.box.resetParameters()
        labelBox.text = String(points)
    }
    
    //    Funções do som
    func desativeSound() {
        soundActive = false
        audioPlayerActual.volume = 0
    }
    
    func activeSound() {
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
                self.present(ViewController!, animated: true, completion: nil)
            } else if (localPlayer.isAuthenticated) {
                self.gcEnabled = true
                localPlayer.loadDefaultLeaderboardIdentifier(completionHandler: { (leaderboardIdentifer, error) in
                    if error != nil {
                        print(error)
                    } else { self.gcDefaultLeaderBoard = leaderboardIdentifer ?? self.LEADERBOARD_ID }
                })
            } else {
                self.gcEnabled = false
                print("Local player could not be authenticated!")
            }
        }
    }
    
    // MARK: - ADD 10 POINTS TO THE SCORE AND SUBMIT THE UPDATED SCORE TO GAME CENTER
    func addScoreAndSubmitToGC() {
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
    
    private func showGCBoard() {
        let gcVC = GKGameCenterViewController()
        gcVC.gameCenterDelegate = self
        gcVC.viewState = .leaderboards
        gcVC.leaderboardIdentifier = LEADERBOARD_ID
        present(gcVC, animated: true, completion: nil)
    }
}

extension GameViewController: MenuViewControllerDelegate {
    func updateRocketMode(mode: RocketMode) {
        rocketMode = mode
    }
    
    func returnTapped() {
        replayUpdateState()
    }
}

extension GameViewController: MenuViewControllerDataSource {
    func currentRocketMode() -> RocketMode {
        return rocketMode
    }
    
    func currentScore() -> String {
        return String(points)
    }
    
    func bestScore() -> String {
        return String(IntDefault.BS.getValue())
    }
}
