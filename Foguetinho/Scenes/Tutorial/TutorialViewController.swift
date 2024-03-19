//
//  TutorialViewController.swift
//  Foguetinho
//
//  Created by Joao Victor Flores da Costa on 12/06/22.
//  Copyright © 2022 Joao Flores. All rights reserved.
//

import UIKit
import GameKit
import AVFoundation
import StoreKit
import GoogleMobileAds

class TutorialViewController: UIViewController {
    
    var tutorialView: GestureAnimationView = {
        let myView = Bundle.loadView(fromNib: "GestureAnimationView", withType: GestureAnimationView.self)
        myView.setup()
        myView.rotateTutorial()
        return myView
    }()
    
    var showAdsIn3games = 0
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
    var rocketMode: RocketMode = .white {
        didSet {
            switch rocketMode {
            case .white:
                rocketImg.image = UIImage(named: ImageName.rocketWhite.rawValue+"1")
            default:
                rocketImg.image = UIImage(named: ImageName.rocketPink.rawValue+"1")
            }
        }
    }
    
    var velAnimateArrow = 0
    var distAnimateArrow = 0
    
    var score = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set Background
        let random = Int.random(in: 0 ..< 2)
        backGroundImg.image = UIImage(named: "Background\(random)")
        
        rocket = RocketClass(rocketImg: self.rocketImg, backGroundImg: self.backGroundImg)
        box = BoxClass(boxImg: self.boxImg, labelBox: self.labelBox, backGroundImg: self.backGroundImg)
        
        setupSounds()
        
        backGroundImg.layer.zPosition = -11
        rocketImg.layer.zPosition = -10
        boxImg.layer.zPosition = -10
        let rotate = UIRotationGestureRecognizer(target: self, action: #selector(TutorialViewController.rotate(_:)))
        self.view.addGestureRecognizer(rotate)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(TutorialViewController.tap(_:)))
        self.view.addGestureRecognizer(tap)
        
        velAnimateArrow = 10
        distAnimateArrow = 0
        
        self.rocket.flyInitPosition(duration: TimeInterval(0.5))
        
        view.addSubview(tutorialView)
        tutorialView.translatesAutoresizingMaskIntoConstraints = false
        let horizontalConstraint = tutorialView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        let verticalConstraint = tutorialView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        let leftConstraint = tutorialView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20)
        let rightConstraint = tutorialView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        view.addConstraints([horizontalConstraint, verticalConstraint, leftConstraint, rightConstraint])
        
        skeepTutorialButton.layer.cornerRadius = 16
        skeepTutorialButton.alpha = 0.7
        skeepTutorialButton.layer.shadowOffset = CGSize(width: 0, height: 1)
        skeepTutorialButton.layer.shadowColor = UIColor.lightGray.cgColor
        skeepTutorialButton.layer.shadowOpacity = 1
        skeepTutorialButton.layer.shadowRadius = 5
        skeepTutorialButton.layer.masksToBounds = false
        skeepTutorialButton.setTitle(Text.skipTutorial.localized(), for: .normal)
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        self.view.addGestureRecognizer(panGestureRecognizer)
    }
    
    private var initialTouchPoint: CGPoint = CGPoint.zero
    
    @objc private func handlePanGesture(_ gestureRecognizer: UIPanGestureRecognizer) {
        if rocketMode != .white {
            return
        }
        let currentTouchPoint = gestureRecognizer.location(in: self.view)

        // Quando o gesto começa, armazenamos o ponto inicial
        if gestureRecognizer.state == .began {
            initialTouchPoint = currentTouchPoint
        }

        let distance = calculateDistance(from: initialTouchPoint, to: currentTouchPoint)
        
        if !pause {
            let rotation = distance / 50
            self.rocket.rotate(rotation: rotation)
            initialTouchPoint = gestureRecognizer.location(in: self.view)
        }
        if rocketMode == .white {
            tutorialView.releaseTutorial()
        }
        if gestureRecognizer.state == .ended {
            if rocketMode == .white {
                tutorialView.rotateTutorial()
                self.tap()
            } else {
                tutorialView.tapTutorial()
            }
        }
    }

    // Função para calcular a distância entre dois pontos
    private func calculateDistance(from startPoint: CGPoint, to endPoint: CGPoint) -> CGFloat {
        return endPoint.y - startPoint.y
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBOutlet weak var rocketImg: UIImageView!
    @IBOutlet weak var boxImg: UIImageView!
    @IBOutlet weak var backGroundImg: UIImageView!
    
    @IBOutlet weak var labelBox: UILabel!
    @IBOutlet weak var pauseImg: UIButton!
    
    @IBOutlet weak var skeepTutorialButton: UIButton!
    
    @IBAction func skeepTutorial(_ sender: Any) {
        self.modalPresentationStyle = .overCurrentContext
        self.dismiss(animated: true) {
            self.inGame = false
            self.soundActive = false
            self.willMove(toParent: nil)
            self.view.removeFromSuperview()
            self.removeFromParent()
        }
    }
    
    private func replayUpdateState() {
        if(!inGame && !pause) { // jogo estava no menu e jogador iniciou nova partida
            inGame = true
            tutorialView.rotateTutorial()
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
                    tutorialView.endTutorial()
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
        if rocketMode == .white {
            return
        }
        if !pause {
            let rotation = gesture.rotation * 6
            self.rocket.rotate(rotation: rotation)
            gesture.rotation = 0
        }
        if rocketMode == .white {
            tutorialView.releaseTutorial()
        }
        if gesture.state == .ended {
            if rocketMode == .white {
                tutorialView.rotateTutorial()
                self.tap()
            } else {
                tutorialView.tapTutorial()
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
        let bgMinY = self.backGroundImg.center.y - backGroundImg.frame.height/2 + 60
        let bgMaxY = self.backGroundImg.center.y + backGroundImg.frame.height/2
        
        // foguete pegou alvo
        if (((rocketMinX >= boxMinX && rocketMinX <= boxMaxX) || (rocketMaxX >= boxMinX && rocketMaxX <= boxMaxX))
            && ((rocketMinY >= boxMinY && rocketMinY <= boxMaxY) || (rocketMaxY >= boxMinY && rocketMaxY <= boxMaxY))) {

            if(soundActive){ audioBox.play() }
            points += 1
            
            box.atualizeLabelBox(points: points)
            box.atualizePositionBox(sizeScreen: self.backGroundImg.frame.size)
            box.atualizeColorBox()
            rocket.atualizeVelocity(points: self.points)
        }
        
        // foguete na borda da tela
        else if ( rocketMinX <= bgMinX || rocketMaxX >= bgMaxX || rocketMinY <= bgMinY || rocketMaxY >= bgMaxY ) {
            self.rocket.rotate(rotation: 90)
            self.tap()
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
    
    func setupSounds() {
        
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
        
    }
    
    //    Funções de utilidades
    func delayWithSeconds(_ seconds: Double, completion: @escaping () -> ()) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            completion()
        }
    }
}
