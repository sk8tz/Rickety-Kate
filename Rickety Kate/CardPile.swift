//
//  CardPile.swift
//  Rickety Kate
//
//  Created by Geoff Burns on 23/09/2015.
//  Copyright © 2015 Geoff Burns All rights reserved.
//

import SpriteKit

class CardPile
{
    var cards : [PlayingCard] = [] { didSet { update() } }
    var isUp = false
    var isBig = false
    var scene : SKNode? = nil
    let cardScale = CGFloat(0.9)
    var cardTossDuration = 0.4
    let cardAnchorPoint = CGPoint(x: 0.5, y: UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Pad ?
        -0.7 :
        -1.0)
    var fullHand = CGFloat(13)
    var sideOfTable = SideOfTable.Bottom
    var direction = Direction.Up
    var isFanClosed = false
    var isFanOpen :Bool { return !isFanClosed }
    
    
    var position = CGPoint()
    
    subscript(index: Int) -> PlayingCard {
        return cards[index]
    }
    
 
    func setup(scene:SKNode, direction: Direction, position: CGPoint, isUp: Bool = false, isBig: Bool = false)
    {
        self.scene = scene
        self.direction = direction
        self.position = position
        self.isUp = isUp
        self.isBig = isBig
        self.isFanClosed = true
    }
    
    func append(card:PlayingCard)
    {
        cards.append(card)
        rearrange()
    }
    func update()
    {
        
    }
    func appendContentsOf(newCards:[PlayingCard])
    {
       
        cards.appendContentsOf(newCards)
        rearrange()
     
    }
    func replaceWithContentsOf(newCards:[PlayingCard])
    {
        cards = newCards
        rearrange()
     
    }
    func rearrange()
    {
        if(scene==nil)
        {
            return
        }
        var fullHand = CGFloat(13)
        let noCards = CGFloat(cards.count)
        var positionInSpread = CGFloat(0)
        
        if isFanOpen
        {
            positionInSpread = (fullHand - noCards) * 0.5
            if fullHand < noCards
            {
                fullHand = noCards
                positionInSpread = CGFloat(0)
            }
        }
        for card in cards
        {
            if let sprite = CardSprite.spriteFor(card)
            {
                // Stop all running animations before starting new ones
                sprite.removeAllActions()
                
                // PlayerOne's cards are larger
                sprite.setScale(isBig ? cardScale: cardScale*0.5)
                sprite.anchorPoint = cardAnchorPoint
                
                var flipAction = (SKAction.scaleTo(isBig ? cardScale : cardScale*0.5, duration: cardTossDuration))
                let newPosition =  isFanClosed ?
                    position :
                    sideOfTable.positionOfCard(positionInSpread, spriteHeight: sprite.size.height,
                        width: scene!.frame.width, height: scene!.frame.height, fullHand:fullHand)
                let moveAction = (SKAction.moveTo(newPosition, duration:(cardTossDuration*0.8)))
                let rotationAngle = direction.rotationOfCard(positionInSpread, fullHand:fullHand)
                let rotateAction = (SKAction.rotateToAngle(rotationAngle, duration:(cardTossDuration*0.8)))
                let scaleAction =  (SKAction.scaleTo(isBig ? cardScale : cardScale*0.5, duration: cardTossDuration))
                let scaleYAction =  SKAction.scaleYTo(isBig ? cardScale : cardScale*0.5, duration: cardTossDuration)
                var groupAction = SKAction.group([moveAction,rotateAction,scaleAction])
                
                if isUp && !sprite.isUp
                {
                    //    sprite.flipUp()
                    flipAction = (SKAction.sequence([
                        SKAction.scaleXTo(0.0, duration: cardTossDuration*0.5),
                        SKAction.runBlock({
                            sprite.flipUp()
                        }) ,
                        SKAction.scaleXTo(isBig ? cardScale : cardScale*0.5, duration: cardTossDuration*0.5)
                        ]))
                    groupAction = SKAction.group([moveAction,rotateAction,flipAction,scaleYAction])
                }
                else if !isUp && sprite.isUp
                {
                    // sprite.flipDown()
                    flipAction = (SKAction.sequence([
                        SKAction.scaleXTo(0.0, duration: cardTossDuration*0.5),
                        SKAction.runBlock({
                            sprite.flipDown()
                        }) ,
                        SKAction.scaleXTo(isBig ? cardScale : cardScale*0.5, duration: cardTossDuration*0.5)
                        ]))
                    groupAction = SKAction.group([moveAction,rotateAction,flipAction,scaleYAction])
                }
                
                sprite.runAction(groupAction)
                sprite.zPosition = (isBig ? 100: 10) + positionInSpread
                sprite.color = UIColor.whiteColor()
                sprite.colorBlendFactor = 0
                positionInSpread++
            }
        }
    }
    
    
}

