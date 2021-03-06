//
//  CardSlide.swift
//  Rickety Kate
//
//  Created by Geoff Burns on 1/10/2015.
//  Copyright © 2015 Geoff Burns. All rights reserved.
//

import SpriteKit

/// How the cards are displayed in a slide
/// Cards positions need to be calculated more frequently in a slide as opposed to a pile
/// No rotation is needed unlike a fan

class CardSlide : CardPile
{
    
    var slideWidth = CGFloat()
    
    func setup(scene:HasDiscardArea, slideWidth: CGFloat, sizeOfCards: CardSize = CardSize.Medium)
    {
        self.discardAreas = scene
        self.scene = scene as? SKNode
        self.sideOfTable = SideOfTable.Bottom
        self.slideWidth = slideWidth
        self.isUp = true
        self.sizeOfCards = sizeOfCards
        self.direction = Direction.Up
        self.zPositon = self.sizeOfCards.zOrder
    }
    
    override func append(card:PlayingCard)
    {
        var updatedCards = cards
        updatedCards.append(card)
        let sortedHand = updatedCards.sort()
        cards = ( Array(sortedHand.reverse()))
    }
    override func update()
    {
        rearrange()
    }
    override func positionOfCard(positionInSpread:CGFloat, spriteHeight:CGFloat,fullHand:CGFloat) -> CGPoint
    {
        let seperation = max (CardPile.defaultSpread , CGFloat(cards.count))
        return CGPoint(x:position.x+slideWidth*positionInSpread/seperation, y:position.y)
    }
    override func rotationOfCard(positionInSpread:CGFloat, fullHand:CGFloat) -> CGFloat
    {
        return 0.0
    }
    override func appendContentsOf(newCards:[PlayingCard])
    {
        var updatedCards = cards
        updatedCards.appendContentsOf(newCards)
        let sortedHand = updatedCards.sort()
        cards = ( Array(sortedHand.reverse()))
    }
    override func replaceWithContentsOf(newCards:[PlayingCard])
    {
        let updatedCards = newCards
        let sortedHand = updatedCards.sort()
        cards = ( Array(sortedHand.reverse()))
    }
    override func rearrange()
    {
        if(scene==nil)
        {
            return
        }
        
        let noCards = CGFloat(cards.count)
        
        
        for (positionInSpread,card) in cards.enumerate()
        {
            rearrangeFor(card,positionInSpread:CGFloat(positionInSpread), fullHand:noCards)
            
            
        }
    }
    
}

