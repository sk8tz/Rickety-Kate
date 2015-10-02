//
//  CardSlide.swift
//  Rickety Kate
//
//  Created by Geoff Burns on 1/10/2015.
//  Copyright © 2015 Geoff Burns. All rights reserved.
//

import SpriteKit

/// How the cards are displayed in a fan
/// Cards positions need to be calculated more frequently in a fan as opposed to a pile
class CardSlide : CardPile
{
    
    var slideWidth = CGFloat()
    
    func setup(scene:SKNode, slideWidth: CGFloat, sizeOfCards: CardSize = CardSize.Big)
    {
        self.scene = scene
        self.sideOfTable = SideOfTable.Bottom
        self.slideWidth = slideWidth
        self.isUp = true
        self.sizeOfCards = sizeOfCards
        self.direction = Direction.Up
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
        return CGPoint(x:position.x+positionInSpread/CGFloat(cards.count), y:position.y)
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
}
