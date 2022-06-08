//
//  MenuViewController.swift
//  Foguetinho
//
//  Created by Joao Victor Flores da Costa on 07/06/22.
//  Copyright © 2022 Joao Flores. All rights reserved.
//

//precisa do points para o GC no datasource

import UIKit
import GameKit
import AVFoundation
import StoreKit
import GoogleMobileAds

protocol MenuViewControllerDataSource {
    func currentScore() -> Int
    func bestScore() -> Int
    func gameState() -> String
}

protocol MenuViewControllerDelegate {
    func returnToGame()
    func updateRocketMode(mode: String)
}

class MenuViewController: UIViewController,GKGameCenterControllerDelegate, GADInterstitialDelegate {
    
    // MARK: IBOutlets
    @IBOutlet weak var labelFixScore: UILabel!
    @IBOutlet weak var labelFixBestScore: UILabel!
    
    @IBOutlet weak var labelScore: UILabel!
    @IBOutlet weak var labelBestScore: UILabel!
    
    @IBOutlet weak var changeRocketImg: UIButton!
    @IBOutlet var changeRocketNext: [UIButton]!
    
    // MARK: Variables
    var gameMode: String = "White"
    var gcEnabled = Bool()
    var gcDefaultLeaderBoard = String()
    var score = 0
    var LEADERBOARD_ID = "com.joaoFlores.Foguetinho.Ranking"
    
    var dataSource: MenuViewControllerDataSource?
    var delegate: MenuViewControllerDelegate?
    
    init(dataSource: MenuViewControllerDataSource, delegate: MenuViewControllerDelegate) {
        super.init(nibName: nil, bundle: nil)
        self.dataSource = dataSource
        self.delegate = delegate
    }
    
    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.clear
        view.isOpaque = false
        
        // Setup Labels
        labelFixScore.text = Text.currentScore.localized()
        labelFixBestScore.text = Text.bestScore.localized()
        
        labelScore.text = "teste1"
        labelBestScore.text = "123123"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "showMenu") {
            if let nextViewController = segue.destination as? MenuViewController {
                nextViewController.modalPresentationStyle = .overCurrentContext
            }
        }
    }
    
    @IBAction func changeRocket(_ sender: UIButton) {
        if(changeRocketNext[0].alpha == 1) {
            if(gameMode == "White") {
                
                let image = UIImage(named: "ChangeRocketPink")
                changeRocketImg.setImage(image, for: .normal)
                
                gameMode = "Pink"
            } else {
                let image = UIImage(named: "ChangeRocketWhite")
                changeRocketImg.setImage(image, for: .normal)
                gameMode = "White"
            }
        }
    }
    
    @IBAction func playPause(_ sender: Any) {
        print("playPause")
    }
    
    @IBAction func information(_ sender: Any) {
        self.performSegue(withIdentifier: "goInformations", sender: nil)
    }
    
    @IBAction func replay(_ sender: Any) {
        print("Replay")
    }
    
    @IBAction func checkGCLeaderboard(_ sender: AnyObject) {
        let gcVC = GKGameCenterViewController()
        gcVC.gameCenterDelegate = self
        gcVC.viewState = .leaderboards
        gcVC.leaderboardIdentifier = LEADERBOARD_ID
        present(gcVC, animated: true, completion: nil)
    }
    
    func rateApp() {
        if #available(iOS 10.3, *) {
            SKStoreReviewController.requestReview()
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
        // Add 10 points to current score
        
        // Submit score to GC leaderboard
        let bestScoreInt = GKScore(leaderboardIdentifier: LEADERBOARD_ID)
        bestScoreInt.value = Int64(600)
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
}
