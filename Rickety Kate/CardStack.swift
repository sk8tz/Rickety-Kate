//
//  CardStack.swift
//  Rickety Kate
//
//  Created by Geoff Burns on 30/10/2015.
//  Copyright © 2015 Geoff Burns. All rights reserved.
//

import SpriteKit

/// How the cards are displayed in a stack
/// Only certain cards are accepted on the stack
/// Used in Sevens and Penalty Games
typealias ValidNextCardsCalculator = PlayingCard -> Set<PlayingCard>
typealias ValidNextCardCalculator = PlayingCard -> PlayingCard?

class CardStack : CardPile
{
    weak var parentStack : CardStack? = nil
    var suite: PlayingCard.Suite = PlayingCard.Suite.Spades
    var baseCard : PlayingCard? = nil  { didSet { updateBase() } }
    
    var baseSprite : CardSprite? { if baseCard == nil {return nil}; return scene!.whiteCardSprite(baseCard!) }
    
    var validNextCardsCalculator : (PlayingCard) -> [PlayingCard] = CardStack.nextHigherCard
 
    var lowerStack: CardStack? = nil

    static func nextLowerCard(lastCard:PlayingCard) ->[PlayingCard]
    {
            let prevcards = GameSettings.sharedInstance.deck!.orderedDeck
                .filter { $0.suite == lastCard.suite && $0.value < lastCard.value }
                .sort {$0.value > $1.value}
            
            return prevcards
    }

    static func nextHigherCard(lastCard:PlayingCard) ->[PlayingCard]
    {
        
    let nextcards = GameSettings.sharedInstance.deck!.orderedDeck
        .filter { $0.suite == lastCard.suite && $0.value > lastCard.value }
        .sort {$0.value < $1.value}
        
    return nextcards
    }
    override func discardAll()
    {
        if isBackground
        {
            discardAreas?.discardWhitePile.transferFrom(self)
        }
        else
        {
            discardAreas?.discardPile.transferFrom(self)
        }
        if let base = baseCard
        {
            discardAreas?.discardWhitePile.append( base  )
            baseCard = nil
        }
    }
 
    override func rotationOfCard(positionInSpread:CGFloat, fullHand:CGFloat) -> CGFloat
    {
        return 0
    }
    func nextCard() -> PlayingCard?
    {

        if let last = cards.last
        {
            return self.validNextCardsCalculator ( last ).first
        }
        return baseCard
    }
    var isFinished : Bool {
        
        
        if let last = cards.last
        {
            if self.validNextCardsCalculator ( last ).first == nil
            {
                return true
            }
        }
        return false
    }
    var finished : CardStack? {
        
        if let parent = self.parentStack
        {
            return parent.finished
        }
        
        if let lower = lowerStack
        where isFinished && lower.isFinished
        {
            return self
        }
        return nil
    }
    func playBefore(card:PlayingCard) -> PlayingCard?
    {
        if baseCard == nil {
            return nil }
        if baseCard!.suite != card.suite { return nil }
        
        if let next = nextCard()
           where next != card
           && Set(self.validNextCardsCalculator ( next )).contains(card)
            {
            return next
            }
        
        if let lower = lowerStack,
            next = lower.nextCard()
            where next != card
                && Set(lower.validNextCardsCalculator ( next )).contains(card)
        {
            return next
        }
        
        return baseCard
        
    }
    
    func addLower() ->CardStack
    {
        lowerStack = CardStack(name: CardPileType.Stack.description)
        lowerStack!.validNextCardsCalculator = CardStack.nextLowerCard
        lowerStack!.parentStack = self
        return lowerStack!
    }
    
    override func update()
    {
        
        if !cards.isEmpty
        {
            if let lower = lowerStack where lower.baseCard == nil
            {
            lower.baseCard = GameSettings.sharedInstance.deck!.lowerMiddleCardIn(self.baseCard!.suite)
            }
        }
        /// if its a pile instead of a fan you don't need to rearrange the pile for every change
    }
    //
    func updateBase()
    {
        if let sprite = baseSprite
        {
            sprite.fan = self
            
          //  if (sprite.state != CardState.AtRest)
          //  {
                sprite.zPosition = 1
                sprite.state = CardState.AtRest
          //  }
            
            
            sprite.positionInSpread = 0
            
            // PlayerOne's cards are larger
            let newScale =  sizeOfCards.scale
            
            let newHeight = newScale * sprite.size.height / sprite.yScale
            sprite.updateAnchorPoint(cardAnchorPoint)
            sprite.color = UIColor.whiteColor()
            sprite.colorBlendFactor = 0
            
            
            sprite.position =  positionOfCard(0, spriteHeight: newHeight, fullHand:fullHand)
            
            sprite.zRotation = rotationOfCard(0, fullHand:fullHand)
            sprite.setScale(sizeOfCards.scale)
            
        }
    }
}