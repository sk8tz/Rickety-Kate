//
//  CardSprite.swift
//  Rickety Kate
//
//  Created by Geoff Burns on 17/09/2015.
//  Copyright (c) 2015 Geoff Burns. All rights reserved.
//


import SpriteKit


/// controls the appearance of the card on the screen
class CardSprite : SKSpriteNode
{
    /////////////////////////////////////////////////////
    /// Variables
    /////////////////////////////////////////////////////
    weak static var currentScene : SKNode? = nil
    var fan : CardPile? = nil
        {
        didSet {
            if let f = fan
            where f.player != nil {
                player = f.player
            }
        }
    }
    var player : CardHolderBase? = nil
    var card : PlayingCard
    var isUp = false
    var positionInSpread = CGFloat(0.0)
    var state = CardState.AtRest
    var originalTouch : CGPoint = CGPointZero
    var label : SKLabelNode? = nil
    var localLabel : SKSpriteNode? = nil
    var letterBackground : SKSpriteNode? = nil
    var originalScale = CGFloat(1.0)
    var originalCardPosition   = CGPointZero
    var originalCardRotation  = CGFloat(0.0)
    var originalCardZPosition  = CGFloat(0.0)
    
    
    /////////////////////////////////////////////////////
    /// Constructors
    /////////////////////////////////////////////////////
    init(card:PlayingCard,  texture: SKTexture = SKTexture(imageNamed: "Back1"))
    {
    self.card = card
    super.init(texture: texture, color: UIColor.whiteColor(), size: texture.size())
      

    self.name = card.imageName
    self.userInteractionEnabled = false
    self.anchorPoint = CGPointMake(0.5, 0.5)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    static func create(card:PlayingCard, scene:SKNode) -> CardSprite
    {
        let sprite = CardSprite(card: card)
        scene.addChild(sprite)
        self.currentScene = scene
        return sprite
    }
    
    static func create(card:PlayingCard, isUp: Bool, scene:SKNode) -> CardSprite
    {
        let sprite = CardSprite(card: card,
            texture: isUp
                ? SKTexture(imageNamed: card.imageName)
                :SKTexture(imageNamed: "Back1"))
        sprite.isUp = isUp
        if isUp {
            sprite.addLocalization()
        }
        scene.addChild(sprite)
        self.currentScene = scene
        return sprite
    }
    
    /////////////////////////////////////////////
    /// Instance Methods
    /////////////////////////////////////////////


    /// changing the anchorpoint is not something you can do with a SKAction
    /// therefore changing the anchorpoint without causing the sprite to jump requires finess
    
    func rotateAboutPoint(position:CGPoint, rotatePoint:CGPoint, zRotation:CGFloat) -> CGPoint
    {
        let dx1 = (rotatePoint.x - self.anchorPoint.x) * self.size.width
        let dy1 = (rotatePoint.y - self.anchorPoint.y) * self.size.height
        
        let dx = dx1 * cos(zRotation) - dy1 * sin(zRotation)
        let dy = dx1 * sin(zRotation) + dy1 * cos(zRotation)
        return CGPointMake(position.x+dx, position.y+dy)
    }
    func rotateAboutPoint(position:CGPoint, rotatePoint:CGPoint, zRotation:CGFloat, newScale:CGFloat) -> CGPoint
    {
        let dx1 = (self.anchorPoint.x - rotatePoint.x) * self.size.width  * newScale / self.yScale
        let dy1 = (self.anchorPoint.y - rotatePoint.y ) * self.size.height  * newScale / self.yScale
        
        
        let dx = dx1 * cos(zRotation) - dy1 * sin(zRotation)
        let dy = dx1 * sin(zRotation) + dy1 * cos(zRotation)
        return CGPointMake(position.x+dx, position.y+dy)
    }
    func updateAnchorPoint(anchorPoint:CGPoint = CGPointMake(0.5, 0.5))
    {
        
        self.position = rotateAboutPoint(self.position,rotatePoint: anchorPoint,zRotation:self.zRotation)
        
        self.anchorPoint = anchorPoint
    }
    /// changing the anchorpoint is not something you can do with a SKAction
    /// therefore changing the anchorpoint without causing the sprite to jump requires finess
    func removeLabel()
    {
        if let description = label
        {
            description.removeFromParent()
            label = nil
        }
    }
    func removeAll()
    {
        self.removeAllChildren()
        label = nil
        localLabel = nil
        letterBackground  = nil
    }
    func addLabel()
    {
        if label != nil { return }
        label = SKLabelNode(text:self.card.description)
        // let originalScale = self.yScale
        
        if let l = label
        {
        l.position = CGPoint(x: 0.0, y:  self.size.height * 0.44 / self.yScale)
        l.fontColor = UIColor.blackColor()
        l.fontName = "Verdana"
        l.fontSize = 11
      
        l.zPosition =  0.7
        self.addChild(l)
        }
    
    }
    func tintRed()
    {
        self.color = UIColor.redColor()
        if let letter = self.letterBackground
        {
            letter.color = UIColor.redColor()
            letter.colorBlendFactor = 0.2
        }
        self.colorBlendFactor = 0.2
    }
    func tintGreen()
    {
        self.color = UIColor.greenColor()
        if let letter = self.letterBackground
        {
            letter.color = UIColor.greenColor()
            letter.colorBlendFactor = 0.2
        }
        self.colorBlendFactor = 0.2
    }
    func removeTint()
    {
        self.color = UIColor.whiteColor()
        if let letter = self.letterBackground
        {
            letter.color = UIColor.whiteColor()
            letter.colorBlendFactor = 0.0
        }
        self.colorBlendFactor = 0.0
    }

    var rankOfCourtCard : Int
    {
        switch card.value
        {
        case .CourtCard :
            if let deck = GameSettings.sharedInstance.deck
            {
                return deck.rankFor(card)
            }
            return 0
        default : return 0
        }
    }

    var needsNumber : Bool
    {
            return GameSettings.sharedInstance.useNumbersForCourtCards &&
              rankOfCourtCard >= 8
    }
    var hasIndexAlready : Bool
    {
        return letterBackground != nil
    }
    var foregroundColor : UIColor
    {
        return card.suite.color
    }
    var backgroundColor : UIColor
    {
            return UIColor.whiteColor()
    }
    var indexMaskingImageName : String { return "letter" }
    
    func addNumber()
    {
        
        let local = rankOfCourtCard
        localLabel = SKSpriteNode(imageNamed:"Number" + local.description)
        
        
        if let letterForeground = localLabel {
            
            letterForeground.color = foregroundColor
            letterForeground.colorBlendFactor = 1.0
            letterForeground.anchorPoint=CGPoint(x: 0.5,y: 0.5)
            letterForeground.position = CGPointZero
            
            letterForeground.zPosition =  0.1
            letterBackground = SKSpriteNode(imageNamed:indexMaskingImageName)
            if let background = letterBackground
                where background.frame.size.width > 2
            {
                background.zPosition =  0.8
                background.anchorPoint=CGPoint(x: 0.5,y: 0.5)
     
                background.position = CGPoint(x: -self.size.width*0.5+background.frame.size.width*0.5, y:  self.size.height*0.5-background.frame.size.height*0.5)
                background.addChild(letterForeground)
                addChild(background)
            }
        }

        
        
    }
    func addLocalLetter()
    {
        let local = card.value.localLetter
   
    
        localLabel = SKSpriteNode(imageNamed:local + "_letter")
 
        if let letterForeground = localLabel {
        
           letterForeground.color = foregroundColor
           letterForeground.colorBlendFactor = 1.0

           letterForeground.position = CGPointZero
            
           letterForeground.anchorPoint=CGPoint(x: 0.5,y: 0.5)
           letterForeground.zPosition =  0.1
           letterBackground = SKSpriteNode(imageNamed:indexMaskingImageName)
            if let background = letterBackground
                where background.size.width > 2
            {
            background.zPosition =  0.8
            background.anchorPoint=CGPoint(x: 0.5,y: 0.5)
       

            background.position = CGPoint(x: -self.size.width*0.5+background.size.width*0.5, y:  self.size.height*0.5-background.size.height*0.5)
            background.addChild(letterForeground)
            addChild(background)
            }
            else
            {
                letterBackground = nil
                localLabel = nil
            }
        }
    }
    /// the user has just started dragging the sprite
    func liftUp(positionInScene:CGPoint)
    {

        state = CardState.Dragged
        originalScale = self.yScale
        originalCardPosition  = self.position
        originalCardRotation  = self.zRotation
        originalCardZPosition  = self.zPosition


        self.zPosition = 120
      //  removeAllActions()
        runAction(
            SKAction.sequence([
                SKAction.group([
            SKAction.scaleTo(CardSize.Huge.scale, duration: 0.3),
            SKAction.rotateToAngle(0.0, duration: 0.3),
            SKAction.moveTo(positionInScene, duration: 0.3)
            ]),
            SKAction.runBlock
                {
                       self.addLabel()
                }]))
      
    }
    /// the user has just stopped dragging the sprite
    func setdown()
    {
        removeLabel()
        state = CardState.AtRest

        runAction(SKAction.sequence([SKAction.group([
            SKAction.scaleTo(originalScale, duration: 0.3),
            SKAction.rotateToAngle(originalCardRotation, duration: 0.3),
            SKAction.moveTo(originalCardPosition, duration: 0.3)
            ]),
            SKAction.runBlock {
               self.zPosition = self.originalCardZPosition
                self.fan?.reaZOrderCardsAtRest()
                
            }]))
    }

    /// the user has just switched which sprite they are dragging
    func liftUpQuick(positionInScene:CGPoint)
    {
        removeAllActions()
        
        state = CardState.Dragged
        originalScale = self.yScale
        originalCardPosition  = self.position
        originalCardRotation  = self.zRotation
        self.zPosition = 120
        self.position = positionInScene
        self.zRotation = 0.0
        self.setScale(CardSize.Huge.scale)
        addLabel()
    }
    
    /// the user has just switched which sprite they are dragging
    func setdownQuick()
    {
        removeAllActions()
        removeLabel()
        state = CardState.AtRest
        self.zPosition = originalCardZPosition
        self.position = originalCardPosition
        self.zRotation = originalCardRotation
        self.setScale(originalScale)
        self.fan?.reaZOrderCardsAtRest()
   
    }
    
    var needsLocalization : Bool
    {
        return card.value.localLetter != ""
    }
    func addLocalization()
    {
    if hasIndexAlready || (!needsLocalization && !needsNumber)  { return }
    let rotate = self.zRotation
        let xScale = self.xScale
        let yScale = self.yScale
    self.setScale(1.0)
    self.zRotation = 0
        
        if needsNumber {
            addNumber()
        } else if needsLocalization {
            self.addLocalLetter()
        }
    self.zRotation = rotate
    self.setScale(yScale)
    self.xScale = xScale
    }
    /// Turn the card face up
    func flipUp()
    {
        if !isUp
        {
            texture = SKTexture(imageNamed: name!)
            isUp = true
            
        addLocalization()

        }
    }
    /// Turn the card
    func flip(toUp:Bool)
    {
        if toUp
        {
            flipUp()
        }
        else
        {
            flipDown()
        }
    }
    
    /// Turn the card face down
    func flipDown()
    {
        if isUp
        {
            self.removeAll()
            texture = SKTexture(imageNamed: "Back1")
            isUp = false
        }
    }
}

/// controls the appearance of the card on the screen
class WhiteCardSprite : CardSprite
{
    
    var white : SKSpriteNode? = nil
    var shadow : SKSpriteNode? = nil
    var blank : SKSpriteNode? = nil
    var outline : SKSpriteNode? = nil
    var outlineShadow : SKSpriteNode? = nil
    
    override var foregroundColor : UIColor
    {
            return  UIColor.whiteColor()
    }
    override var backgroundColor : UIColor
    {
            return GameSettings.backgroundColor
    }
    
    override var indexMaskingImageName : String { return "letterwhite" }
    private init(card:PlayingCard)
    {
        super.init(card:card, texture: SKTexture(imageNamed: "blank"))
        
        white = SKSpriteNode(imageNamed: card.whiteImageName)
        blank = SKSpriteNode(imageNamed:  "blank")
        outline = SKSpriteNode(imageNamed:  "outline")
        shadow = SKSpriteNode(imageNamed:  card.whiteImageName)
        outlineShadow = SKSpriteNode(imageNamed:  "outline")
        
 /*
        self.color =  GameSettings.backgroundColor
        self.colorBlendFactor = 1.0
  */
        
      if let b = blank
        {
            b.color =  GameSettings.backgroundColor
            b.colorBlendFactor = 1.0
            b.zPosition = 0.0
            self.addChild(b)
        }
        if let s = shadow
        {
            
            s.color = UIColor.blackColor()
            s.colorBlendFactor = 1.0
            s.zPosition = 0.1
            s.position = CGPoint(x:2,y:-2)
            self.addChild(s)
        }
        if let w = white
        {
            w.zPosition = 0.2
            self.addChild(w)
        }
        if let os = outlineShadow
        {
            
            os.color = UIColor.blackColor()
            os.colorBlendFactor = 1.0
            os.zPosition = 0.3
            os.position = CGPoint(x:2,y:-2)
            self.addChild(os)
        }

        if let o = outline
        {
            o.zPosition = 0.4
            self.addChild(o)
        }
        
        self.name = card.whiteImageName
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    static func createWhite(card:PlayingCard, scene:SKNode) -> CardSprite
    {
        let sprite = WhiteCardSprite(card: card)
        
        sprite.addLocalization()
        scene.addChild(sprite)
        self.currentScene = scene
        return sprite
    }
}


extension SKNode
{
 func cardSpriteNamed(cardname :String) -> CardSprite?
    {
    return (self.childNodeWithName(cardname) as? CardSprite?)!
    }
func cardSprite(card :PlayingCard) -> CardSprite?
    {
        if let sprite = self.cardSpriteNamed(card.imageName)
        {
            return sprite
        }
        return CardSprite.create(card, scene: self)
    }
    
func whiteCardSprite(card :PlayingCard) -> CardSprite?
    {
        if let sprite = self.cardSpriteNamed(card.whiteImageName)
        {
            return sprite
        }
        return WhiteCardSprite.createWhite(card, scene: self)
    }

func cardSprite(card :PlayingCard,isUp: Bool) -> CardSprite?
{
    if let sprite = self.cardSpriteNamed(card.imageName)
    {
        return sprite
    }
    return CardSprite.create(card, isUp:isUp, scene: self)
}

}