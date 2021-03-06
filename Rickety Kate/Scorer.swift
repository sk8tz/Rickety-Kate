//
//  Scorer.swift
//  Rickety Kate
//
//  Created by Geoff Burns on 18/09/2015.
//  Copyright © 2015 Geoff Burns. All rights reserved.
//

import SpriteKit



/// Calculate the Result of the trick
class Scorer
{
    var players = [CardPlayer]()
    
    static let sharedInstance = Scorer()
    private init() { }
    
    func setupScorer( players: [CardPlayer])
    {
        self.players=players
        
        for player in players
        {
            player.currentTotalScore.value = 0
            player.scoreForCurrentHand = 0
            player.noOfWins.value = 0
        }
    }
    
    /// Which player has won the trick
    static func playerThatWon(gameState:GameStateBase) -> CardPlayer?
    {
        if let trick = gameState.tricksPile.first
        {
            let leadingSuite = trick.playedCard.suite
            let followingTricks = gameState.tricksPile.filter { $0.playedCard.suite == leadingSuite }
            
            let orderedTricks = followingTricks.sort({ $0.playedCard.value > $1.playedCard.value })
            if let highest = orderedTricks.first
            {
                return highest.player
            }
        }
        return nil
    }
    
    // Update the score of the players
    func recordTheScoresForAGameWin(winner: CardPlayer)
    {
    winner.noOfWins.value = winner.noOfWins.value + 1
    
    for player in self.players
      {
      player.currentTotalScore.value = 0
      }
    }
    
    /// Did player get all the points avalilable in his hand
    func hasShotTheMoon() -> Bool
    {
    var hasShotMoon = false
    for player in self.players
      {
      /// Did player get all the points avalilable in his hand
      if player.scoreForCurrentHand >= GameSettings.sharedInstance.rules.allPoints
         {
         player.currentTotalScore.value = 0
         hasShotMoon = true
         Bus.sharedInstance.send(GameEvent.ShotTheMoon(player.name))
         GameKitHelper.sharedInstance.reportAchievement(Achievement.ShootingTheMoon)
        }
      }
    return hasShotMoon
    }
    
    
    var leaderboardScore : Int64
        {
            
            let ranked  = players
                . sort {$0.currentTotalScore.value < $1.currentTotalScore.value}
                . enumerate()
            
            let humans = ranked.filter { $0.1.playerNo == 0 }
            
            if let human = humans.first
            {
                
                let beaten = ranked
                    . map { $0.1.currentTotalScore.value }
                    . filter { $0 > human.1.currentTotalScore.value}
                let  beatenScore : Int = beaten.reduce(0) { $0 + $1 }
                return Int64(GameSettings.sharedInstance.gameWinningScore -  human.1.currentTotalScore.value/2) * Int64(100) / Int64(human.0+1) + Int64(beatenScore)
            }
            return 1
    }
    
    
    /// Has a player gone over a 100 points
    func hasGameBeenWon()
    {
    var lowestScore = 1000
    var winner : CardPlayer? = nil
    var hasWonGame = false
    var isDraw = false
    
    for player in players
      {
      if player.currentTotalScore.value  < lowestScore
        {
        lowestScore = player.currentTotalScore.value
        winner = player

        isDraw = false
        } else  if player.currentTotalScore.value  == lowestScore
        {
        isDraw = true
        }
    
      if player.currentTotalScore.value >= GameSettings.sharedInstance.gameWinningScore
        {
        hasWonGame = true
        }
      }
    // If there is a draw then do another hand
    let isGameWon = hasWonGame && !isDraw
    if isGameWon
      {
      recordTheScoresForAGameWin(winner!)
        

      GameKitHelper.sharedInstance.reportScore(self.leaderboardScore, forLeaderBoard:  GameSettings.sharedInstance.rules.leaderboard)
        
      if winner?.playerNo == 0
      {
        GameKitHelper.sharedInstance.reportAchievement(GameSettings.sharedInstance.achievementForWin)
       
       
      }
    
      Bus.sharedInstance.send(GameEvent.WinGame(winner!.name))
      }
        
 
    }
    func endHand()
    {
        for player in players
        {
            
            if player.scoreForCurrentHand  < 0
            {
                player.currentTotalScore.value  -= player.scoreForCurrentHand
            }
            player.scoreForCurrentHand = 0
        }
    }
    func trickWon(gameState:GameStateBase) -> CardPlayer?
    {
        if let winner = Scorer.playerThatWon(gameState)
        {
         
                let score = GameSettings.sharedInstance.rules.scoreFor(gameState.tricksPile.map { return $0.playedCard} , winnersName: winner.name)
                if(score != 0)
                {
                    winner.currentTotalScore.value += score
                    winner.scoreForCurrentHand += score
                  
                }
          
            return winner
            
        }
        return nil
        }
}
    